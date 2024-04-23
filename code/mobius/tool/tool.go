package tool

import (
	"context"

	"github.com/sashabaranov/go-openai"
)

type Tool interface {
	Tool() openai.Tool
	Call(ctx context.Context, input string) (string, error)
}
