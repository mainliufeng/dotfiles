package main

import (
	"context"
	"fmt"
	"mobius/internal/agent"
	"mobius/internal/llm"
	"os"
	"runtime/debug"

	"github.com/sashabaranov/go-openai"
)

func main() {
	ctx := context.Background()

	a := &agent.Agent{
		LLM: &llm.OpenAI{},
	}

	request := openai.ChatCompletionRequest{
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: "将下面描述转成shell命令，直接输出命令，不要包在```里边，描述：",
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: os.Args[1],
			},
		},
	}

	resp, err := a.Chat(ctx, request)
	if err != nil {
		fmt.Println(string(debug.Stack()))
		panic(err)
	}

	choice := resp.Choices[0]

	content := choice.Message.Content
	fmt.Println(content)
}
