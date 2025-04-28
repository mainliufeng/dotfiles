package graph

import (
	"context"

	"github.com/cloudwego/eino/compose"
	"github.com/cloudwego/eino/schema"
)

func BuildpromptAndModel(ctx context.Context) (r compose.Runnable[map[string]any, *schema.Message], err error) {
	const (
		ChatTemplate1    = "ChatTemplate1"
		CustomChatModel1 = "CustomChatModel1"
	)
	g := compose.NewGraph[map[string]any, *schema.Message]()
	chatTemplate1KeyOfChatTemplate, err := newChatTemplate(ctx)
	if err != nil {
		return nil, err
	}
	_ = g.AddChatTemplateNode(ChatTemplate1, chatTemplate1KeyOfChatTemplate)
	customChatModel1KeyOfChatModel, err := newChatModel(ctx)
	if err != nil {
		return nil, err
	}
	_ = g.AddChatModelNode(CustomChatModel1, customChatModel1KeyOfChatModel)
	_ = g.AddEdge(compose.START, ChatTemplate1)
	_ = g.AddEdge(CustomChatModel1, compose.END)
	_ = g.AddEdge(ChatTemplate1, CustomChatModel1)
	r, err = g.Compile(ctx, compose.WithGraphName("promptAndModel"), compose.WithNodeTriggerMode(compose.AllPredecessor))
	if err != nil {
		return nil, err
	}
	return r, err
}
