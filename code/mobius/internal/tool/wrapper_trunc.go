package tool

import (
	"context"

	"github.com/sashabaranov/go-openai"
)

type TruncWrapper struct {
	Threshold int
	Wrapped   Tool
}

func (wrapper *TruncWrapper) Tool() openai.Tool {
	return wrapper.Wrapped.Tool()
}

func (wrapper *TruncWrapper) Call(ctx context.Context, input string) (output string, err error) {
	output, err = wrapper.Wrapped.Call(ctx, input)
	if wrapper.Threshold <= 0 {
		return
	}

	if len(output) <= wrapper.Threshold {
		return
	}

	output = output[:wrapper.Threshold]
	return
}

func WrapTrunc(tools []Tool, threshold int) (newTools []Tool) {
	for _, tool := range tools {
		newTools = append(newTools, &TruncWrapper{
			Threshold: threshold,
			Wrapped:   tool,
		})
	}
	return
}
