package agent

import (
	"context"

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

	OnToolCall func(tool openai.Tool, output string)

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
		toolCallMessages, err = agent.CallTools(ctx, input.ConfirmToolCallIDs)
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

	req.Tools = toOpenaiTools(agent.Tools)
	agent.Messages = append(agent.Messages, newMessages...)
	req.Messages = agent.Messages

	// bs, _ := json.Marshal(req)
	// fmt.Printf("req: %s\n\n", string(bs))

	resp, err := agent.LLM.CreateChatCompletion(ctx, *req)
	if err != nil {
		return
	}
	agent.LastRequest = req

	// bs, _ = json.Marshal(resp)
	// fmt.Printf("resp: %s\n\n", string(bs))

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

func (agent *Agent) CallTools(ctx context.Context, confirmToolCallIDs []string) (messages []openai.ChatCompletionMessage, err error) {
	confirmSet := make(map[string]struct{}, len(confirmToolCallIDs))
	for _, toolCallID := range confirmToolCallIDs {
		confirmSet[toolCallID] = struct{}{}
	}

	nameToolMap := make(map[string]tool.Tool, len(agent.Tools))
	for _, tool := range agent.Tools {
		nameToolMap[tool.Tool().Function.Name] = tool
	}

	for _, toolCall := range agent.NeedConfirmToolCalls {
		tool, toolOK := nameToolMap[toolCall.Function.Name]
		_, confirm := confirmSet[toolCall.ID]
		if toolOK && confirm {
			var toolOutput string
			toolOutput, err = tool.Call(ctx, toolCall.Function.Arguments)
			if err != nil {
				return
			}

			if agent.OnToolCall != nil {
				agent.OnToolCall(tool.Tool(), toolOutput)
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

func toOpenaiTools(tools []tool.Tool) (openaiTools []openai.Tool) {
	for _, tool := range tools {
		openaiTools = append(openaiTools, tool.Tool())
	}
	return
}
