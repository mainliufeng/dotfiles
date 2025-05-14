package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"mobius/internal/logs"
	"os"
	"time"

	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/compose"
	"github.com/cloudwego/eino/flow/agent"
	"github.com/cloudwego/eino/flow/agent/react"
	"github.com/cloudwego/eino/schema"
	"github.com/mark3labs/mcp-go/client"
	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"

	"github.com/cloudwego/eino-ext/components/model/openai"
	mcpp "github.com/cloudwego/eino-ext/components/tool/mcp"
)

func main() {
	startMCPServer()
	time.Sleep(1 * time.Second)
	ctx := context.Background()

	cli, err := client.NewStdioMCPClient(
		"npx",
		nil,
		"-y",
		"@executeautomation/playwright-mcp-server",
	)
	//cli, err := client.NewSSEMCPClient("http://localhost:12345/sse")
	if err != nil {
		log.Fatal(err)
	}

	err = cli.Start(ctx)
	if err != nil {
		log.Fatal(err)
	}

	initRequest := mcp.InitializeRequest{}
	initRequest.Params.ProtocolVersion = mcp.LATEST_PROTOCOL_VERSION
	initRequest.Params.ClientInfo = mcp.Implementation{
		Name:    "example-client",
		Version: "1.0.0",
	}

	_, err = cli.Initialize(ctx, initRequest)
	if err != nil {
		log.Fatal(err)
	}

	tools, err := mcpp.GetTools(ctx, &mcpp.Config{Cli: cli})
	if err != nil {
		log.Fatal(err)
	}

	//model, err := deepseek.NewChatModel(ctx, &deepseek.ChatModelConfig{
	//	APIKey:  os.Getenv("OPENAI_API_KEY"),
	//	BaseURL: os.Getenv("OPENAI_BASE_URL"),
	//	Model:   "deepseek-chat",
	//})
	model, err := openai.NewChatModel(ctx, &openai.ChatModelConfig{
		APIKey:  os.Getenv("OPENAI_API_KEY"),
		BaseURL: os.Getenv("OPENAI_BASE_URL"),
		Model:   "gpt-4.1",
	})
	if err != nil {
		log.Fatalf("NewChatModel of gemini failed, err=%v", err)
	}

	ragent, err := react.NewAgent(ctx, &react.AgentConfig{
		Model: model,
		ToolsConfig: compose.ToolsNodeConfig{
			Tools: tools,
		},
	})
	if err != nil {
		logs.Errorf("failed to create agent: %v", err)
		return
	}

	//message, err := ragent.Generate(ctx, []*schema.Message{
	//	{
	//		Role:    schema.System,
	//		Content: "你是一个AI助手",
	//	},
	//	{
	//		Role:    schema.User,
	//		Content: "65+88*102等于多少",
	//	},
	//}, agent.WithComposeOptions())
	//if err != nil {
	//	logs.Errorf("failed to stream: %v", err)
	//	return
	//}
	//logs.Infof("message: %v", message)

	sr, err := ragent.Stream(ctx, []*schema.Message{
		{
			Role:    schema.System,
			Content: "你是一个AI助手",
		},
		{
			Role:    schema.User,
			Content: "海淀区今天天气怎么样，使用baidu.com搜索",
		},
		//}, agent.WithComposeOptions())
	}, agent.WithComposeOptions(compose.WithCallbacks(&LoggerCallback{})))
	if err != nil {
		logs.Errorf("failed to stream: %v", err)
		return
	}

	defer sr.Close() // remember to close the stream

	logs.Infof("\n\n===== start streaming =====\n\n")

	for {
		msg, err := sr.Recv()
		if err != nil {
			if errors.Is(err, io.EOF) {
				// finish
				break
			}
			// error
			logs.Infof("failed to recv: %v", err)
			return
		}

		// 打字机打印
		logs.Tokenf("%v", msg.Content)
	}

	logs.Infof("\n\n===== finished =====\n")

}

type LoggerCallback struct {
	callbacks.HandlerBuilder // 可以用 callbacks.HandlerBuilder 来辅助实现 callback
}

func (cb *LoggerCallback) OnStart(ctx context.Context, info *callbacks.RunInfo, input callbacks.CallbackInput) context.Context {
	fmt.Println("==================")
	inputStr, _ := json.MarshalIndent(input, "", "  ") // nolint: byted_s_returned_err_check
	fmt.Printf("[OnStart] %s\n", string(inputStr))
	return ctx
}

func (cb *LoggerCallback) OnEnd(ctx context.Context, info *callbacks.RunInfo, output callbacks.CallbackOutput) context.Context {
	fmt.Println("=========[OnEnd]=========")
	outputStr, _ := json.MarshalIndent(output, "", "  ") // nolint: byted_s_returned_err_check
	fmt.Println(string(outputStr))
	return ctx
}

func (cb *LoggerCallback) OnError(ctx context.Context, info *callbacks.RunInfo, err error) context.Context {
	fmt.Println("=========[OnError]=========")
	fmt.Println(err)
	return ctx
}

func (cb *LoggerCallback) OnEndWithStreamOutput(ctx context.Context, info *callbacks.RunInfo,
	output *schema.StreamReader[callbacks.CallbackOutput]) context.Context {

	var graphInfoName = react.GraphName

	go func() {
		defer func() {
			if err := recover(); err != nil {
				fmt.Println("[OnEndStream] panic err:", err)
			}
		}()

		defer output.Close() // remember to close the stream in defer

		fmt.Println("=========[OnEndStream]=========")
		for {
			frame, err := output.Recv()
			if errors.Is(err, io.EOF) {
				// finish
				break
			}
			if err != nil {
				fmt.Printf("internal error: %s\n", err)
				return
			}

			s, err := json.Marshal(frame)
			if err != nil {
				fmt.Printf("internal error: %s\n", err)
				return
			}

			if info.Name == graphInfoName { // 仅打印 graph 的输出, 否则每个 stream 节点的输出都会打印一遍
				fmt.Printf("%s: %s\n", info.Name, string(s))
			}
		}

	}()
	return ctx
}

func (cb *LoggerCallback) OnStartWithStreamInput(ctx context.Context, info *callbacks.RunInfo,
	input *schema.StreamReader[callbacks.CallbackInput]) context.Context {
	defer input.Close()
	return ctx
}

func startMCPServer() {
	svr := server.NewMCPServer("demo", mcp.LATEST_PROTOCOL_VERSION)
	svr.AddTool(mcp.NewTool("calculate",
		mcp.WithDescription("Perform basic arithmetic operations"),
		mcp.WithString("operation",
			mcp.Required(),
			mcp.Description("The operation to perform (add, subtract, multiply, divide)"),
			mcp.Enum("add", "subtract", "multiply", "divide"),
		),
		mcp.WithNumber("x",
			mcp.Required(),
			mcp.Description("First number"),
		),
		mcp.WithNumber("y",
			mcp.Required(),
			mcp.Description("Second number"),
		),
	), func(ctx context.Context, request mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		op := request.Params.Arguments["operation"].(string)
		x := request.Params.Arguments["x"].(float64)
		y := request.Params.Arguments["y"].(float64)

		var result float64
		switch op {
		case "add":
			result = x + y
		case "subtract":
			result = x - y
		case "multiply":
			result = x * y
		case "divide":
			if y == 0 {
				return mcp.NewToolResultText("Cannot divide by zero"), nil
			}
			result = x / y
		}
		log.Printf("Calculated result: %.2f", result)
		return mcp.NewToolResultText(fmt.Sprintf("%.2f", result)), nil
	})
	go func() {
		defer func() {
			e := recover()
			if e != nil {
				fmt.Println(e)
			}
		}()

		err := server.NewSSEServer(svr, server.WithBaseURL("http://localhost:12345")).Start("localhost:12345")

		if err != nil {
			log.Fatal(err)
		}
	}()
}
