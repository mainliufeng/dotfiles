package task

import (
	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/schema"
)

type Memory interface {
	Round() Round
	GetMessages() []*schema.Message
}

type Round interface {
	Before(inputMessages []*schema.Message) (messages []*schema.Message)
	Callbacks() []callbacks.Handler
	After(outputMessage *schema.Message) (messages []*schema.Message)
}
