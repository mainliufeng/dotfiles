package jaeger

import (
	"context"
	"fmt"
	"io"
	"log"
	"runtime/debug"
	"strings"
	"time"

	"github.com/bytedance/sonic"
	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/components"
	"github.com/cloudwego/eino/components/embedding"
	"github.com/cloudwego/eino/components/model"
	"github.com/cloudwego/eino/schema"
	"go.opentelemetry.io/otel"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/exporters/jaeger"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.4.0"
	"go.opentelemetry.io/otel/trace"
)

func NewJaegerHandler() (handler callbacks.Handler, shutdown func(ctx context.Context) error, err error) {
	jaegerAddr := "http://localhost:14268/api/traces"

	exp, err := jaeger.New(jaeger.WithCollectorEndpoint(jaeger.WithEndpoint(jaegerAddr)))
	if err != nil {
		fmt.Println(fmt.Errorf("new trace exporter failed: %w", err))
		return
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exp),
		sdktrace.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL,
			semconv.ServiceNameKey.String("mobius"),
		)),
	)
	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}))

	tracer := otel.GetTracerProvider().Tracer("mobius")

	return &jaegerHandler{
		tracer:       tracer,
		otelProvider: tp,
	}, tp.Shutdown, nil
}

type jaegerHandler struct {
	otelProvider *sdktrace.TracerProvider
	tracer       trace.Tracer
}

type requestInfo struct {
	model string
}

type jaegerStateKey struct{}
type jaegerState struct {
	startTime   time.Time
	span        trace.Span
	requestInfo *requestInfo
}

type traceStreamInputAsyncKey struct{}
type streamInputAsyncVal chan struct{}

func (a *jaegerHandler) OnStart(ctx context.Context, info *callbacks.RunInfo, input callbacks.CallbackInput) context.Context {
	if info == nil {
		return ctx
	}

	spanName := getName(info)
	if len(spanName) == 0 {
		spanName = "unset"
	}
	startTime := time.Now()
	requestModel := ""
	ctx, span := a.tracer.Start(ctx, spanName, trace.WithSpanKind(trace.SpanKindClient), trace.WithTimestamp(startTime))

	contentReady := false

	//TODO: covert input from other type of component
	//ref: https://github.com/cloudwego/eino-ext/pull/103#discussion_r1967017732
	config, inMessage, _, err := extractModelInput(convModelCallbackInput([]callbacks.CallbackInput{input}))
	if err != nil {
		log.Printf("extract stream model input error: %v, runinfo: %+v", err, info)
	} else {
		for i, in := range inMessage {
			if in != nil && len(in.Content) > 0 {
				contentReady = true
				span.SetAttributes(attribute.String(fmt.Sprintf("llm.prompts.%d.role", i), string(in.Role)))
				span.SetAttributes(attribute.String(fmt.Sprintf("llm.prompts.%d.content", i), in.Content))
			}
		}

		if config != nil {
			span.SetAttributes(attribute.String("llm.request.model", config.Model))
			requestModel = config.Model
			span.SetAttributes(attribute.Int("llm.request.max_token", config.MaxTokens))
			span.SetAttributes(attribute.Float64("llm.request.temperature", float64(config.Temperature)))
			span.SetAttributes(attribute.Float64("llm.request.top_p", float64(config.TopP)))
			span.SetAttributes(attribute.StringSlice("llm.request.stop", config.Stop))
		}
	}

	if !contentReady {
		in, err := sonic.MarshalString(input)
		if err == nil {
			span.SetAttributes(attribute.String("llm.prompts.0.role", string(schema.User)))
			span.SetAttributes(attribute.String("llm.prompts.0.content", in))
		}
	}

	span.SetAttributes(attribute.String("runinfo.name", info.Name))
	span.SetAttributes(attribute.String("runinfo.type", info.Type))
	span.SetAttributes(attribute.String("runinfo.component", string(info.Component)))

	return context.WithValue(ctx, jaegerStateKey{}, &jaegerState{
		startTime:   startTime,
		span:        span,
		requestInfo: &requestInfo{model: requestModel},
	})
}

func (a *jaegerHandler) OnEnd(ctx context.Context, info *callbacks.RunInfo, output callbacks.CallbackOutput) context.Context {
	if info == nil {
		return ctx
	}

	state, ok := ctx.Value(jaegerStateKey{}).(*jaegerState)
	if !ok {
		log.Printf("no state in context, runinfo: %+v", info)
		return ctx
	}
	span := state.span

	defer func() {
		if stopCh, ok := ctx.Value(traceStreamInputAsyncKey{}).(streamInputAsyncVal); ok {
			<-stopCh
		}
		span.End(trace.WithTimestamp(time.Now()))
	}()

	contentReady := false
	switch info.Component {
	case components.ComponentOfEmbedding:
		if ecbo := embedding.ConvCallbackOutput(output); ecbo != nil {
			if ecbo.Config != nil {
				span.SetAttributes(attribute.String("llm.response.model", ecbo.Config.Model))
			}
		}
	case components.ComponentOfChatModel:
		fallthrough
	default:
		usage, outMessages, _, config, err := extractModelOutput(convModelCallbackOutput([]callbacks.CallbackOutput{output}))
		if err == nil {

			for i, out := range outMessages {
				if out != nil && len(out.Content) > 0 {
					contentReady = true
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.role", i), string(out.Role)))
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.content", i), out.Content))
					if out.ResponseMeta != nil {
						span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.finish_reason", i), out.ResponseMeta.FinishReason))
					}
				}
			}
			if !contentReady && outMessages != nil {
				outMessage, err := sonic.MarshalString(outMessages)
				if err == nil {
					contentReady = true
					span.SetAttributes(attribute.String("llm.completions.0.content", outMessage))
				}
			}

			if config != nil {
				span.SetAttributes(attribute.String("llm.response.model", config.Model))
			}

			if usage != nil {
				span.SetAttributes(attribute.Int("llm.usage.total_tokens", usage.TotalTokens))
				span.SetAttributes(attribute.Int("llm.usage.prompt_tokens", usage.PromptTokens))
				span.SetAttributes(attribute.Int("llm.usage.completion_tokens", usage.CompletionTokens))
			}
		}
	}

	if !contentReady {
		out, err := sonic.MarshalString(output)
		if err != nil {
			log.Printf("marshal output error: %v, runinfo: %+v", err, info)
		} else {
			span.SetAttributes(attribute.String("llm.completions.0.content", out))
		}
	}
	span.SetAttributes(attribute.Bool("llm.is_streaming", false))

	return ctx
}

func (a *jaegerHandler) OnError(ctx context.Context, info *callbacks.RunInfo, err error) context.Context {
	if info == nil {
		return ctx
	}

	state, ok := ctx.Value(jaegerStateKey{}).(*jaegerState)
	if !ok {
		log.Printf("no state in context, runinfo: %+v", info)
		return ctx
	}
	span := state.span
	defer func() {
		if stopCh, ok := ctx.Value(traceStreamInputAsyncKey{}).(streamInputAsyncVal); ok {
			<-stopCh
		}
		span.End(trace.WithTimestamp(time.Now()))
	}()

	span.SetStatus(codes.Error, err.Error())
	span.RecordError(err)

	return ctx
}

func (a *jaegerHandler) OnStartWithStreamInput(ctx context.Context, info *callbacks.RunInfo, input *schema.StreamReader[callbacks.CallbackInput]) context.Context {
	if info == nil {
		return ctx
	}

	spanName := getName(info)
	if len(spanName) == 0 {
		spanName = "unset"
	}
	startTime := time.Now()
	requestInfo := &requestInfo{}
	ctx, span := a.tracer.Start(ctx, spanName, trace.WithSpanKind(trace.SpanKindClient), trace.WithTimestamp(startTime))

	span.SetAttributes(attribute.String("runinfo.name", info.Name))
	span.SetAttributes(attribute.String("runinfo.type", info.Type))
	span.SetAttributes(attribute.String("runinfo.component", string(info.Component)))

	stopCh := make(streamInputAsyncVal)
	ctx = context.WithValue(ctx, traceStreamInputAsyncKey{}, stopCh)

	go func() {
		defer func() {
			e := recover()
			if e != nil {
				log.Printf("recover update span panic: %v, runinfo: %+v, stack: %s", e, info, string(debug.Stack()))
			}
			input.Close()
			close(stopCh)
		}()
		var ins []callbacks.CallbackInput
		for {
			chunk, err_ := input.Recv()
			if err_ == io.EOF {
				break
			}
			if err_ != nil {
				log.Printf("read stream input error: %v, runinfo: %+v", err_, info)
				return
			}
			ins = append(ins, chunk)
		}
		contentReady := false
		config, inMessage, _, err := extractModelInput(convModelCallbackInput(ins))
		if err != nil {
			log.Printf("extract stream model input error: %v, runinfo: %+v", err, info)
		} else {
			for i, in := range inMessage {
				if in != nil && len(in.Content) > 0 {
					contentReady = true
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.prompts.%d.role", i), string(in.Role)))
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.prompts.%d.content", i), in.Content))
				}
			}

			if config != nil {
				span.SetAttributes(attribute.String("llm.request.model", config.Model))
				requestInfo.model = config.Model
				span.SetAttributes(attribute.Int("llm.request.max_token", config.MaxTokens))
				span.SetAttributes(attribute.Float64("llm.request.temperature", float64(config.Temperature)))
				span.SetAttributes(attribute.Float64("llm.request.top_p", float64(config.TopP)))
				span.SetAttributes(attribute.StringSlice("llm.request.stop", config.Stop))
			}
		}
		if !contentReady {
			in, err := sonic.MarshalString(ins)
			if err != nil {
				log.Printf("marshal input error: %v, runinfo: %+v", err, info)
			} else {
				span.SetAttributes(attribute.String("llm.prompts.0.role", string(schema.User)))
				span.SetAttributes(attribute.String("llm.prompts.0.content", in))
			}
		}
	}()
	return context.WithValue(ctx, jaegerStateKey{}, &jaegerState{
		span:        span,
		startTime:   startTime,
		requestInfo: requestInfo,
	})
}

func (a *jaegerHandler) OnEndWithStreamOutput(ctx context.Context, info *callbacks.RunInfo, output *schema.StreamReader[callbacks.CallbackOutput]) context.Context {
	if info == nil {
		return ctx
	}

	state, ok := ctx.Value(jaegerStateKey{}).(*jaegerState)
	if !ok {
		log.Printf("no state in context, runinfo: %+v", info)
		return ctx
	}
	span := state.span

	go func() {
		defer func() {
			e := recover()
			if e != nil {
				log.Printf("recover update span panic: %v, runinfo: %+v, stack: %s", e, info, string(debug.Stack()))
			}
			output.Close()
			if stopCh, ok := ctx.Value(traceStreamInputAsyncKey{}).(streamInputAsyncVal); ok {
				<-stopCh
			}
			span.End(trace.WithTimestamp(time.Now()))
		}()
		var outs []callbacks.CallbackOutput
		for {
			chunk, err := output.Recv()
			if err == io.EOF {
				break
			}
			if err != nil {
				log.Printf("read stream output error: %v, runinfo: %+v", err, info)
			}
			outs = append(outs, chunk)
		}
		contentReady := false
		// both work for ChatModel or not
		usage, outMessages, _, config, err := extractModelOutput(convModelCallbackOutput(outs))
		if err == nil {
			for i, out := range outMessages {
				if out != nil && len(out.Content) > 0 {
					contentReady = true
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.role", i), string(out.Role)))
					span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.content", i), out.Content))
					if out.ResponseMeta != nil {
						span.SetAttributes(attribute.String(fmt.Sprintf("llm.completions.%d.finish_reason", i), out.ResponseMeta.FinishReason))
					}
				}
			}
			if !contentReady && outMessages != nil {
				outMessage, err := sonic.MarshalString(outMessages)
				if err == nil {
					contentReady = true
					span.SetAttributes(attribute.String("llm.completions.0.role", string(schema.Assistant)))
					span.SetAttributes(attribute.String("llm.completions.0.content", outMessage))
				}
			}

			if config != nil {
				span.SetAttributes(attribute.String("llm.response.model", config.Model))
			}

			if usage != nil {
				span.SetAttributes(attribute.Int("llm.usage.total_tokens", usage.TotalTokens))
				span.SetAttributes(attribute.Int("llm.usage.prompt_tokens", usage.PromptTokens))
				span.SetAttributes(attribute.Int("llm.usage.completion_tokens", usage.CompletionTokens))
			}
		}
		if !contentReady {
			out, err := sonic.MarshalString(outs)
			if err != nil {
				log.Printf("marshal stream output error: %v, runinfo: %+v", err, info)
			} else {
				span.SetAttributes(attribute.String("llm.completions.0.content", out))
			}
		}
		span.SetAttributes(attribute.Bool("llm.is_streaming", true))
	}()

	return ctx
}

func getName(info *callbacks.RunInfo) string {
	if len(info.Name) != 0 {
		return info.Name
	}
	return strings.TrimSpace(info.Type + " " + string(info.Component))
}

func convModelCallbackInput(in []callbacks.CallbackInput) []*model.CallbackInput {
	ret := make([]*model.CallbackInput, len(in))
	for i, c := range in {
		ret[i] = model.ConvCallbackInput(c)
	}
	return ret
}

func extractModelInput(ins []*model.CallbackInput) (config *model.Config, messages []*schema.Message, extra map[string]interface{}, err error) {
	var mas [][]*schema.Message
	for _, in := range ins {
		if in == nil {
			continue
		}
		if len(in.Messages) > 0 {
			mas = append(mas, in.Messages)
		}
		if len(in.Extra) > 0 {
			extra = in.Extra
		}
		if in.Config != nil {
			config = in.Config
		}
	}
	if len(mas) == 0 {
		return config, []*schema.Message{}, extra, nil
	}
	messages, err = concatMessageArray(mas)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("concat messages failed: %v", err)
	}
	return config, messages, extra, nil
}

func convModelCallbackOutput(out []callbacks.CallbackOutput) []*model.CallbackOutput {
	ret := make([]*model.CallbackOutput, len(out))
	for i, c := range out {
		ret[i] = model.ConvCallbackOutput(c)
	}
	return ret
}

func extractModelOutput(outs []*model.CallbackOutput) (usage *model.TokenUsage, messages []*schema.Message, extra map[string]interface{}, config *model.Config, err error) {
	masMap := make(map[schema.RoleType][]*schema.Message)
	for _, out := range outs {
		if out == nil {
			continue
		}
		if out.TokenUsage != nil {
			usage = out.TokenUsage
		}
		if out.Message != nil {
			if _, ok := masMap[out.Message.Role]; !ok {
				masMap[out.Message.Role] = make([]*schema.Message, 0)
			}
			masMap[out.Message.Role] = append(masMap[out.Message.Role], out.Message)
		}
		if out.Extra != nil {
			extra = out.Extra
		}
		if out.Config != nil {
			config = out.Config
		}
	}
	if len(masMap) == 0 {
		return usage, nil, extra, config, nil
	}
	messages = make([]*schema.Message, 0)
	for _, mas := range masMap {
		message, err := schema.ConcatMessages(mas)
		if err != nil {
			log.Printf("concat message failed: %v", err)
		} else {
			messages = append(messages, message)
		}
	}

	return usage, messages, extra, config, nil
}

func concatMessageArray(mas [][]*schema.Message) ([]*schema.Message, error) {
	if len(mas) == 0 {
		return nil, fmt.Errorf("message array is empty")
	}
	arrayLen := len(mas[0])

	ret := make([]*schema.Message, arrayLen)
	slicesToConcat := make([][]*schema.Message, arrayLen)

	for _, ma := range mas {
		if len(ma) != arrayLen {
			return nil, fmt.Errorf("unexpected array length. "+
				"Got %d, expected %d", len(ma), arrayLen)
		}

		for i := 0; i < arrayLen; i++ {
			m := ma[i]
			if m != nil {
				slicesToConcat[i] = append(slicesToConcat[i], m)
			}
		}
	}

	for i, slice := range slicesToConcat {
		if len(slice) == 0 {
			ret[i] = nil
		} else if len(slice) == 1 {
			ret[i] = slice[0]
		} else {
			cm, err := schema.ConcatMessages(slice)
			if err != nil {
				return nil, err
			}

			ret[i] = cm
		}
	}

	return ret, nil
}

func convSchemaMessage(in []*schema.Message) []*model.CallbackInput {
	ret := make([]*model.CallbackInput, len(in))
	for i, c := range in {
		ret[i] = model.ConvCallbackInput(c)
	}
	return ret
}
