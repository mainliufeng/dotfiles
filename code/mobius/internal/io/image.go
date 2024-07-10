package io

import (
	"context"
	"fmt"
	"mobius/internal/shell"

	"github.com/sashabaranov/go-openai"
)

func GetScreenshotMessage(ctx context.Context) (output openai.ChatCompletionMessage, err error) {
	base64, err := shell.ScreenshotToBase64()
	if err != nil {
		return
	}

	output = openai.ChatCompletionMessage{
		Role: openai.ChatMessageRoleUser,
		MultiContent: []openai.ChatMessagePart{
			{
				Type: openai.ChatMessagePartTypeImageURL,
				ImageURL: &openai.ChatMessageImageURL{
					URL: fmt.Sprintf("data:image/png;base64,%s", base64),
				},
			},
		},
	}
	return
}
