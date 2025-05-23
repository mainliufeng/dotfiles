package task

import (
	"context"

	"github.com/cloudwego/eino/callbacks"
	"github.com/cloudwego/eino/components/model"
	"github.com/cloudwego/eino/schema"
)

type MessagesCallback struct {
	firstInputMessages []*schema.Message
	otherMessages      []*schema.Message
	err                error
	callbacks.HandlerBuilder
}

func (cb *MessagesCallback) GetMessages() (messages []*schema.Message) {
	messages = append(messages, cb.firstInputMessages...)
	messages = append(messages, cb.otherMessages...)
	return
}

func (cb *MessagesCallback) OnStart(ctx context.Context, info *callbacks.RunInfo, input callbacks.CallbackInput) context.Context {
	var messages []*schema.Message
	if callbackInput, ok := input.(*model.CallbackInput); ok {
		messages = callbackInput.Messages
	}

	if messages != nil {
		// messagesBytes, _ := json.Marshal(messages)
		// logs.Infof("OnStart, Messages: %s\n", string(messagesBytes))

		if cb.firstInputMessages == nil {
			cb.firstInputMessages = messages
		} else {
			cb.otherMessages = append(cb.otherMessages, messages[len(messages)-1])
		}
	}

	return ctx
}

func (cb *MessagesCallback) OnEnd(ctx context.Context, info *callbacks.RunInfo, output callbacks.CallbackOutput) context.Context {
	var message *schema.Message
	if callbackOutput, ok := output.(*model.CallbackOutput); ok {
		message = callbackOutput.Message
	}

	if message != nil {
		// messageBytes, _ := json.Marshal(message)
		// logs.Infof("OnEnd, Message: %s\n", string(messageBytes))
		cb.otherMessages = append(cb.otherMessages, message)
	}
	return ctx
}

func (cb *MessagesCallback) OnError(ctx context.Context, info *callbacks.RunInfo, err error) context.Context {
	if err != nil {
		cb.err = err
	}
	return ctx
}

func (cb *MessagesCallback) OnStartWithStreamInput(ctx context.Context, info *callbacks.RunInfo, input *schema.StreamReader[callbacks.CallbackInput]) context.Context {
	return ctx
}

func (cb *MessagesCallback) OnEndWithStreamOutput(ctx context.Context, info *callbacks.RunInfo, output *schema.StreamReader[callbacks.CallbackOutput]) context.Context {
	return ctx
}
