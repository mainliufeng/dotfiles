package io

import (
	"context"
	"fmt"

	"github.com/sashabaranov/go-openai"
)

func GetUserInputMessages(ctx context.Context) (messages []openai.ChatCompletionMessage) {
	inputPrompt := "输入问题（输入p截图）："
	fmt.Print(inputPrompt)

	var userInput string
	fmt.Scanln(&userInput)

	fmt.Println("")

	switch userInput {
	case "p":
		imageMessage, err := GetScreenshotMessage(ctx)
		if err == nil {
			messages = append(messages, imageMessage)
		}
		messages = append(messages, GetUserInputMessages(ctx)...)
	default:
		messages = append(messages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleUser,
			Content: userInput,
		})
	}

	return
}
