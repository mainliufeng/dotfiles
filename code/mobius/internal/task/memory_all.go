package task

import (
	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/schema"
)

type AllMemory struct {
	messages []*schema.Message
}

func (m *AllMemory) GetMessages() []*schema.Message {
	return m.messages
}

type allMemoryRound struct {
	cb     *MessagesCallback
	memory *AllMemory
}

func (m *AllMemory) Round() Round {
	return &allMemoryRound{
		cb:     &MessagesCallback{},
		memory: m,
	}
}

func (r *allMemoryRound) Before(inputMessages []*schema.Message) (messages []*schema.Message) {
	messages = append(messages, r.memory.messages...)
	messages = append(messages, inputMessages...)
	return
}

func (r *allMemoryRound) Callbacks() []callbacks.Handler {
	return []callbacks.Handler{r.cb}
}

func (r *allMemoryRound) After(outputMessage *schema.Message) (messages []*schema.Message) {
	r.memory.messages = append(r.memory.messages, r.cb.GetMessages()...)
	return r.memory.messages
}
