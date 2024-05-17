package tool

import (
	"context"

	"github.com/sashabaranov/go-openai"
)

type Tool interface {
	Tool() openai.Tool
	Call(ctx context.Context, input string) (string, error)
}

func ToOpenaiTools(tools []Tool) (openaiTools []openai.Tool) {
	for _, tool := range tools {
		openaiTools = append(openaiTools, tool.Tool())
	}
	return
}

func Call(ctx context.Context, tools []Tool, toolCalls []openai.ToolCall, confirmToolCallIDs []string) (messages []openai.ChatCompletionMessage, err error) {
	confirmSet := make(map[string]struct{}, len(confirmToolCallIDs))
	for _, toolCallID := range confirmToolCallIDs {
		confirmSet[toolCallID] = struct{}{}
	}

	nameToolMap := make(map[string]Tool, len(tools))
	for _, tool := range tools {
		nameToolMap[tool.Tool().Function.Name] = tool
	}

	for _, toolCall := range toolCalls {
		tool, toolOK := nameToolMap[toolCall.Function.Name]
		_, confirm := confirmSet[toolCall.ID]
		if toolOK && confirm {
			var toolOutput string
			toolOutput, err = tool.Call(ctx, toolCall.Function.Arguments)
			if err != nil {
				return
			}

			messages = append(messages, openai.ChatCompletionMessage{
				Role:       openai.ChatMessageRoleTool,
				Content:    toolOutput,
				ToolCallID: toolCall.ID,
			})
		}
	}

	return
}
