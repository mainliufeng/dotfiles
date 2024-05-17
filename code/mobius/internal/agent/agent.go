package agent

import (
	"context"
	"encoding/json"
	"fmt"

	"mobius/internal/llm"
	"mobius/internal/tool"

	"github.com/sashabaranov/go-openai"
)

type AgentInput struct {
	Request            *openai.ChatCompletionRequest
	ConfirmToolCallIDs []string
}

type AgentOutput struct {
	Resp      *openai.ChatCompletionResponse
	ToolCalls []openai.ToolCall
}

type Agent struct {
	Tools []tool.Tool
	LLM   llm.LLM

	Messages             []openai.ChatCompletionMessage
	NeedConfirmToolCalls []openai.ToolCall
	LastRequest          *openai.ChatCompletionRequest

	// openai.ChatCompletionRequest
	// 工具授权s，请求授权s

	// 人工输入：openai.ChatCompletionRequest
	// 自动化（停止判断）：[]openai.ChatCompletionMessage -> openai.ChatCompletionRequest
	// 请求授权：openai.ChatCompletionRequest -> bool
	// 工具授权：openai.ChatCompletionResponse -> bool
}

func (agent *Agent) Chat(ctx context.Context, input AgentInput) (output AgentOutput, err error) {
	newMessages := make([]openai.ChatCompletionMessage, 0)
	if len(agent.NeedConfirmToolCalls) > 0 {
		var toolCallMessages []openai.ChatCompletionMessage
		toolCallMessages, err = tool.Call(ctx, agent.Tools, agent.NeedConfirmToolCalls, input.ConfirmToolCallIDs)
		if err != nil {
			return
		}

		newMessages = append(newMessages, toolCallMessages...)
		agent.NeedConfirmToolCalls = nil
	}

	if input.Request != nil {
		newMessages = append(newMessages, input.Request.Messages...)
	}

	if len(newMessages) == 0 {
		return
	}

	req := agent.LastRequest
	if input.Request != nil {
		req = input.Request
	}

	if req == nil {
		return
	}

	req.Tools = tool.ToOpenaiTools(agent.Tools)
	agent.Messages = append(agent.Messages, newMessages...)
	req.Messages = agent.Messages

	bs, _ := json.Marshal(req)
	fmt.Printf("req: %s\n\n", string(bs))

	resp, err := agent.LLM.CreateChatCompletion(ctx, *req)
	if err != nil {
		return
	}
	agent.LastRequest = req

	bs, _ = json.Marshal(resp)
	fmt.Printf("resp: %s\n\n", string(bs))

	choice := resp.Choices[0]
	agent.Messages = append(agent.Messages, choice.Message)
	if len(choice.Message.ToolCalls) == 0 {
		output = AgentOutput{
			Resp: &resp,
		}
		return
	}

	agent.NeedConfirmToolCalls = choice.Message.ToolCalls
	output = AgentOutput{
		ToolCalls: choice.Message.ToolCalls,
	}
	return
}
