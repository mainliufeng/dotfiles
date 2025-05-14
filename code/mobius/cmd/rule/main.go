package main

import (
	"context"
	"log"
	"mobius/internal/callbacks/jaeger"
	"mobius/internal/logs"
	"mobius/internal/tools"
	"os"
	"strings"

	"github.com/cloudwego/eino-ext/components/model/openai"
	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/compose"
	"github.com/cloudwego/eino/flow/agent/react"
	"github.com/cloudwego/eino/schema"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/trace"
)

func main() {
	ctx := context.Background()

	// // cozeloop
	// client, err := cozeloop.NewClient()
	// if err != nil {
	// 	panic(err)
	// }
	// defer client.Close(ctx)
	// // 在服务 init 时 once 调用
	// handler := ccb.NewLoopHandler(client)

	handler, shutdown, err := jaeger.NewJaegerHandler()
	if err != nil {
		panic(err)
	}
	defer shutdown(ctx)

	callbacks.AppendGlobalHandlers(handler)

	// 直接调用api
	//ctx, span := cozeloop.StartSpan(ctx, "开始", "custom")
	//defer span.Finish(ctx)

	ctx, span := otel.Tracer("mobius").Start(ctx, "开始", trace.WithSpanKind(trace.SpanKindClient))
	defer span.End()

	tools := []tool.BaseTool{
		tools.SearchTool,
		tools.UrlLoaderTool,
	}

	model, err := openai.NewChatModel(ctx, &openai.ChatModelConfig{
		APIKey:  os.Getenv("OPENAI_API_KEY"),
		BaseURL: os.Getenv("OPENAI_BASE_URL"),
		Model:   "gpt-3.5-turbo",
	})
	if err != nil {
		log.Fatalf("NewChatModel of gemini failed, err=%v", err)
	}

	questions := `
	辽阳今天天气
	海淀区今天天气
	`

	answers := make([]string, 0, len(questions))
	for _, question := range strings.Split(questions, "\n") {
		if strings.TrimSpace(question) == "" {
			continue
		}

		var ragent *react.Agent
		ragent, err = react.NewAgent(ctx, &react.AgentConfig{
			Model: model,
			ToolsConfig: compose.ToolsNodeConfig{
				Tools: tools,
			},
		})
		if err != nil {
			logs.Errorf("failed to create agent: %v", err)
			return
		}

		logs.Infof("question: %s", question)
		var msg *schema.Message
		msg, err = ragent.Generate(ctx, []*schema.Message{
			{
				Role:    schema.System,
				Content: "你是一个AI助手",
			},
			{
				Role:    schema.User,
				Content: question,
			},
		})
		if err != nil {
			logs.Errorf("failed to generate: %v", err)
			return
		}

		content := msg.Content
		logs.Infof("answer: %s", content)
		answers = append(answers, content)
	}

	logs.Infof("answers: %v", answers)
}
