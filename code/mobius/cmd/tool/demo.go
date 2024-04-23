package main

import (
	"context"
	"encoding/json"
	"fmt"
	"mobius/llm"
	"mobius/tool"
	"os"

	"github.com/sashabaranov/go-openai"
)

func main() {
	agent := &llm.LLMWithTools{
		LLM: &llm.OpenAI{},
		Tools: []tool.Tool{
			&tool.WikiPediaSearch{},
			&tool.Calculator{},
			&tool.DuckDuckGoSearch{},
		},
	}
	req := openai.ChatCompletionRequest{
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: "你是一个助手",
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: os.Args[1],
			},
		},
	}

	resp, err := agent.ChatCompletion(context.Background(), req)
	if err != nil {
		panic(err)
	}

	bs, _ := json.Marshal(resp)
	fmt.Print(string(bs))
	fmt.Println("")
}
