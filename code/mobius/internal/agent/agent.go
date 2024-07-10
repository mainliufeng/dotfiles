package agent

import (
	"context"
	"errors"
	"sync"

	"mobius/internal/llm"
	"mobius/internal/tool"

	"github.com/sashabaranov/go-openai"
)

type Agent struct {
	Tools []tool.Tool
	LLM   llm.LLM

	Messages []openai.ChatCompletionMessage

	BeforeToolCall        func(toolCall openai.ToolCall)
	AfterToolCall         func(toolCall openai.ToolCall, output string)
	BeforeChatCompletions func(req openai.ChatCompletionRequest)
	AfterChatCompletions  func(req openai.ChatCompletionRequest, resp openai.ChatCompletionResponse, err error)

	toolsOnce   sync.Once
	toolMap     map[string]tool.Tool
	openaiTools []openai.Tool
}

func (agent *Agent) Chat(ctx context.Context, req openai.ChatCompletionRequest) (resp openai.ChatCompletionResponse, err error) {
	if len(req.Messages) == 0 {
		err = errors.New("empty messages")
		return
	}
	agent.Messages = append(agent.Messages, req.Messages...)

	for i := 0; i < 10; i++ {
		req.Tools = agent.getOpenAITools()
		req.Messages = agent.Messages

		if agent.BeforeChatCompletions != nil {
			agent.BeforeChatCompletions(req)
		}

		resp, err = agent.LLM.CreateChatCompletion(ctx, req)
		if agent.AfterChatCompletions != nil {
			agent.AfterChatCompletions(req, resp, err)
		}
		if err != nil {
			return
		}

		choice := resp.Choices[0]
		agent.Messages = append(agent.Messages, choice.Message)
		if len(choice.Message.ToolCalls) == 0 {
			break
		}

		var toolCallMessages []openai.ChatCompletionMessage
		toolCallMessages, err = agent.callTools(ctx, choice.Message.ToolCalls)
		if err != nil {
			return
		}
		agent.Messages = append(agent.Messages, toolCallMessages...)
	}
	return
}

func (agent *Agent) callTools(ctx context.Context, toolCalls []openai.ToolCall) (messages []openai.ChatCompletionMessage, err error) {
	for _, toolCall := range toolCalls {
		tool, toolOK := agent.getToolMap()[toolCall.Function.Name]
		if toolOK {
			var toolOutput string

			if agent.BeforeToolCall != nil {
				agent.BeforeToolCall(toolCall)
			}

			toolOutput, err = tool.Call(ctx, toolCall.Function.Arguments)
			if err != nil {
				return
			}

			if agent.AfterToolCall != nil {
				agent.AfterToolCall(toolCall, toolOutput)
			}

			messages = append(messages, openai.ChatCompletionMessage{
				Role:       openai.ChatMessageRoleTool,
				Content:    toolOutput,
				ToolCallID: toolCall.ID,
			})
		}
	}

	return
}

func (agent *Agent) getToolMap() map[string]tool.Tool {
	agent.initTools()
	return agent.toolMap
}

func (agent *Agent) getOpenAITools() []openai.Tool {
	agent.initTools()
	return agent.openaiTools
}

func (agent *Agent) initTools() {
	agent.toolsOnce.Do(func() {
		agent.toolMap = make(map[string]tool.Tool, len(agent.Tools))
		agent.openaiTools = make([]openai.Tool, 0, len(agent.Tools))
		for _, tool := range agent.Tools {
			agent.openaiTools = append(agent.openaiTools, tool.Tool())
			agent.toolMap[tool.Tool().Function.Name] = tool
		}
	})
}
