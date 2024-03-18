package llm

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"

	"github.com/sashabaranov/go-openai"
)

func Stream(ctx context.Context, messages []openai.ChatCompletionMessage, fn func(content string)) (err error) {
	config := openai.DefaultConfig(os.Getenv("OPENAI_API_KEY"))
	config.BaseURL = "https://api.openai-proxy.org/v1"
	c := openai.NewClientWithConfig(config)
	req := openai.ChatCompletionRequest{
		Model:    openai.GPT3Dot5Turbo,
		Messages: messages,
		Stream:   true,
	}
	stream, err := c.CreateChatCompletionStream(ctx, req)
	if err != nil {
		return
	}
	defer stream.Close()

	fmt.Printf("Stream response: ")
	for {
		var response openai.ChatCompletionStreamResponse
		response, err = stream.Recv()
		if errors.Is(err, io.EOF) {
			err = nil
			return
		}

		if err != nil {
			return
		}

		fn(response.Choices[0].Delta.Content)
	}
}
