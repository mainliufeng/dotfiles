package graph

import (
	"context"

	"github.com/cloudwego/eino/components/prompt"
	"github.com/cloudwego/eino/schema"
)

func newChatTemplate(_ context.Context) (ctp prompt.ChatTemplate, err error) {
	ctp = prompt.FromMessages(schema.Jinja2,
		schema.SystemMessage("你是一个AI助手"),
		schema.UserMessage("{{q}}"),
	)
	return ctp, nil
}
