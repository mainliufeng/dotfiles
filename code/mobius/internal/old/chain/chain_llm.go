package chain

import (
	"context"
	"mobius/llm"
	"strings"
	"text/template"

	"github.com/sashabaranov/go-openai"
)

type LLMChain struct {
	LLM          llm.LLM
	SystemPrompt *template.Template
	Prompt       *template.Template
}

func (chain *LLMChain) Call(ctx context.Context, input map[string]any) (output openai.ChatCompletionResponse, err error) {
	sb := new(strings.Builder)
	err = chain.Prompt.Execute(sb, input)
	if err != nil {
		return
	}
	prompt := sb.String()

	sb = new(strings.Builder)
	err = chain.SystemPrompt.Execute(sb, input)
	if err != nil {
		return
	}
	systemPrompt := sb.String()

	req := openai.ChatCompletionRequest{
		Messages: []openai.ChatCompletionMessage{
			{
				Role:    openai.ChatMessageRoleSystem,
				Content: systemPrompt,
			},
			{
				Role:    openai.ChatMessageRoleUser,
				Content: prompt,
			},
		},
	}

	return chain.LLM.CreateChatCompletion(ctx, req)
}
