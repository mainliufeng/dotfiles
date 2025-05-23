package task

import (
	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/schema"
)

type LastMemory struct {
	messages []*schema.Message
}

func (m *LastMemory) GetMessages() []*schema.Message {
	return m.messages
}

type lastMemoryRound struct {
	memory *LastMemory
}

func (m *LastMemory) Round() Round {
	return &lastMemoryRound{
		memory: m,
	}
}

func (r *lastMemoryRound) Before(inputMessages []*schema.Message) (messages []*schema.Message) {
	messages = append(messages, r.memory.messages...)
	messages = append(messages, inputMessages...)
	return
}

func (r *lastMemoryRound) Callbacks() []callbacks.Handler {
	return nil
}

func (r *lastMemoryRound) After(outputMessage *schema.Message) (messages []*schema.Message) {
	r.memory.messages = append(r.memory.messages, outputMessage)
	return r.memory.messages
}
