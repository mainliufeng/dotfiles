package tool

import (
	"context"
	"fmt"

	"github.com/sashabaranov/go-openai"
)

type ConfirmWrapper struct {
	Wrapped Tool
}

func (wrapper *ConfirmWrapper) Tool() openai.Tool {
	return wrapper.Wrapped.Tool()
}

func (wrapper *ConfirmWrapper) Call(ctx context.Context, input string) (output string, err error) {
	toolCall := wrapper.Wrapped.Tool()
	fmt.Printf(
		"准备执行工具：%s\n参数：%s\n是否允许（y或Y表示允许）：",
		toolCall.Function.Name,
		input,
	)
	var userInput string
	fmt.Scanln(&userInput)

	switch userInput {
	case "y", "Y":
		output, err = wrapper.Wrapped.Call(ctx, input)
	}
	return
}

func WrapConfirm(tools []Tool) (newTools []Tool) {
	for _, tool := range tools {
		newTools = append(newTools, &ConfirmWrapper{
			Wrapped: tool,
		})
	}
	return
}
