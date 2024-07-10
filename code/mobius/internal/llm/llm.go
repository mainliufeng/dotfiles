package llm

import (
	"context"

	"github.com/sashabaranov/go-openai"
)

type LLM interface {
	CreateChatCompletion(ctx context.Context, req openai.ChatCompletionRequest) (resp openai.ChatCompletionResponse, err error)
}
