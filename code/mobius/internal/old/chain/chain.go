package chain

import (
	"context"

	"github.com/sashabaranov/go-openai"
)

type Chain[I any, O any] interface {
	Call(ctx context.Context, input I) (output O, err error)
}

type VariablesChain Chain[map[string]any, map[string]any]

type VariablesToLLMChain Chain[map[string]any, openai.ChatCompletionResponse]

type LLMToVariablesChain Chain[openai.ChatCompletionResponse, map[string]any]
