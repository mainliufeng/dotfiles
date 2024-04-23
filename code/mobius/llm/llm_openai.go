package llm

import (
	"context"
	"os"

	"github.com/sashabaranov/go-openai"
)

type OpenAI struct{}

func (llm *OpenAI) CreateChatCompletion(ctx context.Context, req openai.ChatCompletionRequest) (resp openai.ChatCompletionResponse, err error) {
	config := openai.DefaultConfig(os.Getenv("OPENAI_API_KEY"))
	config.BaseURL = os.Getenv("OPENAI_BASE_URL")
	if req.Model == "" {
		req.Model = os.Getenv("OPENAI_DEFAULT_MODEL")
	}
	c := openai.NewClientWithConfig(config)
	resp, err = c.CreateChatCompletion(ctx, req)
	return
}
