package main

import (
	"context"
	"fmt"
	"mobius/internal/agent"
	"mobius/internal/io"
	"mobius/internal/llm"
	"mobius/internal/tool"
	"runtime/debug"
	"strings"

	"github.com/sashabaranov/go-openai"
)

func main() {
	ctx := context.Background()
	a := &agent.Agent{
		Tools: []tool.Tool{
			&tool.Calculator{},
			&tool.WikiPediaSearch{},
		},
		LLM: &llm.OpenAI{},

		OnToolCall: func(tool openai.Tool, output string) {
			fmt.Printf("执行工具：%s，输出：\n%s\n", tool.Function.Name, output)
		},
	}

	input := agent.AgentInput{
		Request: &openai.ChatCompletionRequest{
			Messages: io.GetUserInputMessages(ctx),
		},
	}

	for {
		output, err := a.Chat(ctx, input)
		if err != nil {
			fmt.Println(string(debug.Stack()))
			panic(err)
		}

		if output.Resp != nil {
			choice := output.Resp.Choices[0]
			fmt.Printf("\n模型输出：%s\n\n", choice.Message.Content)
		}

		doToolCall := false
		for _, toolCall := range output.ToolCalls {
			fmt.Printf(
				"准备执行工具：%s\n参数：%s\n是否允许（y或Y表示允许）：",
				toolCall.Function.Name,
				toolCall.Function.Arguments,
			)

			var userInput string
			fmt.Scanln(&userInput)

			userInput = strings.ToLower(userInput)

			switch userInput {
			case "y", "yes":
				input.ConfirmToolCallIDs = append(input.ConfirmToolCallIDs, toolCall.ID)
				doToolCall = true
			}
		}

		if doToolCall {
			fmt.Println("")
			continue
		}

		userInput := io.GetUserInputMessages(ctx)
		if len(userInput) != 0 {
			input.Request = &openai.ChatCompletionRequest{
				Messages: userInput,
			}
		}
	}
}
