package llm

import (
	"context"
	"encoding/json"
	"fmt"

	"mobius/tool"

	"github.com/sashabaranov/go-openai"
)

type LLMWithTools struct {
	Tools []tool.Tool
	LLM   LLM
}

func (llm *LLMWithTools) ChatCompletion(ctx context.Context, req openai.ChatCompletionRequest) (resp openai.ChatCompletionResponse, err error) {
	tools := make([]openai.Tool, 0, len(llm.Tools))
	nameToolMap := make(map[string]tool.Tool, len(llm.Tools))
	for _, tool := range llm.Tools {
		tools = append(tools, tool.Tool())
		nameToolMap[tool.Tool().Function.Name] = tool
	}

	for i := 0; i < 5; i++ {
		req.Tools = tools

		bs, _ := json.Marshal(req)
		fmt.Printf("req: %s\n\n", string(bs))

		resp, err = llm.LLM.CreateChatCompletion(ctx, req)
		if err != nil {
			return
		}

		bs, _ = json.Marshal(resp)
		fmt.Printf("resp: %s\n\n", string(bs))

		choice := resp.Choices[0]
		req.Messages = append(req.Messages, choice.Message)
		if len(choice.Message.ToolCalls) == 0 {
			return
		}

		// tool call
		for _, toolCall := range choice.Message.ToolCalls {
			if tool, ok := nameToolMap[toolCall.Function.Name]; ok {
				var toolOutput string
				toolOutput, err = tool.Call(ctx, toolCall.Function.Arguments)
				if err != nil {
					return
				}
				fmt.Printf("tool: %s, input: %s, output: %s\n\n", tool.Tool().Function.Name, toolCall.Function.Arguments, toolOutput)

				req.Messages = append(req.Messages, openai.ChatCompletionMessage{
					Role:       openai.ChatMessageRoleTool,
					Content:    toolOutput,
					ToolCallID: toolCall.ID,
				})
			}
		}
	}

	return
}
