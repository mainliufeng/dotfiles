package llm

import (
	"context"
	"os"

	"github.com/sashabaranov/go-openai"
)

type OpenAI struct {
	Config LLMConfig
}

func (llm *OpenAI) CreateChatCompletion(ctx context.Context, req openai.ChatCompletionRequest) (resp openai.ChatCompletionResponse, err error) {
	config := openai.DefaultConfig(os.Getenv("OPENAI_API_KEY"))
	config.BaseURL = os.Getenv("OPENAI_BASE_URL")

	// config
	req.Model = llm.Config.Model
	if req.Model == "" {
		req.Model = os.Getenv("OPENAI_DEFAULT_MODEL")
	}

	req.Temperature = llm.Config.Temperature
	if req.Temperature == 0 {
		req.Temperature = 0.7
	}

	c := openai.NewClientWithConfig(config)
	resp, err = c.CreateChatCompletion(ctx, req)
	return
}

type LLMConfig struct {
	Model       string  `json:"model"`
	MaxTokens   int     `json:"max_tokens,omitempty"`
	Temperature float32 `json:"temperature,omitempty"`
}
