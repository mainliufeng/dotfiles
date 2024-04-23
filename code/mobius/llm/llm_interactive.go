package llm

import (
	"context"
	"encoding/json"
	"fmt"

	"mobius/tool"

	"github.com/sashabaranov/go-openai"
)

type InteractiveLLM struct {
	LLM   LLM
	Tools []tool.Tool
	Debug bool

	req  *openai.ChatCompletionRequest
	resp *openai.ChatCompletionResponse
}

func ChatWithLLM(llm LLM, tools []tool.Tool, systemPrompt string) {
	interactiveLLM := NewInteractiveLLM(
		llm, tools,
		openai.ChatCompletionRequest{
			Messages: []openai.ChatCompletionMessage{
				{
					Role:    openai.ChatMessageRoleSystem,
					Content: systemPrompt,
				},
			},
		},
	)
	// interactiveLLM.Debug = true
	ctx := context.Background()

	for {
		needConfirmToolCalls := false
		if interactiveLLM.resp != nil {
			choice := interactiveLLM.resp.Choices[0]
			if len(choice.Message.ToolCalls) > 0 {
				needConfirmToolCalls = true
			}
		}

		inputPrompt := "输入问题："
		if needConfirmToolCalls {
			inputPrompt = "直接回车确认执行工具，或直接输入问题跳过工具执行："
		}
		fmt.Print(inputPrompt)

		var input string
		fmt.Scanln(&input)

		resp, err := interactiveLLM.Step(ctx, input)
		if err != nil {
			panic(err)
		}

		if resp == nil {
			continue
		}

		choice := resp.Choices[0]
		if len(choice.Message.ToolCalls) > 0 {
			for _, toolCall := range choice.Message.ToolCalls {
				fmt.Printf("需要执行工具：%s，参数：\n%s\n\n", toolCall.Function.Name, toolCall.Function.Arguments)
			}
			continue
		} else {
			fmt.Printf("模型输出：\n%s\n\n", choice.Message.Content)
		}
	}
}

func NewInteractiveLLM(llm LLM, tools []tool.Tool, req openai.ChatCompletionRequest) *InteractiveLLM {
	return &InteractiveLLM{
		LLM:   llm,
		Tools: tools,
		req:   &req,
	}
}

func (llm *InteractiveLLM) Step(ctx context.Context, content string) (resp *openai.ChatCompletionResponse, err error) {
	needToolCallsResult := false
	if llm.resp != nil && llm.req != nil {
		lastMessage := llm.req.Messages[len(llm.req.Messages)-1]
		choice := llm.resp.Choices[0]
		if lastMessage.Role == openai.ChatMessageRoleAssistant && len(choice.Message.ToolCalls) > 0 {
			needToolCallsResult = true
		}
	}

	if needToolCallsResult {
		// 内容不为空跳过工具
		err = llm.callTools(ctx, content != "")
		if err != nil {
			return
		}

		// 内容为空执行工具后，让模型再输出结果
		if content == "" {
			resp, err = llm.chatCompletion(ctx)
			return
		}
	}

	// 忽略工具，直接执行content
	if content != "" {
		llm.req.Messages = append(llm.req.Messages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleUser,
			Content: content,
		})
		resp, err = llm.chatCompletion(ctx)
		if err != nil {
			return
		}
		return
	}

	return
}

func (llm *InteractiveLLM) callTools(ctx context.Context, skip bool) (err error) {
	nameToolMap := make(map[string]tool.Tool, len(llm.Tools))
	for _, tool := range llm.Tools {
		nameToolMap[tool.Tool().Function.Name] = tool
	}

	choice := llm.resp.Choices[0]

	for _, toolCall := range choice.Message.ToolCalls {
		if tool, ok := nameToolMap[toolCall.Function.Name]; ok {
			var toolOutput string
			if !skip {
				toolOutput, err = tool.Call(ctx, toolCall.Function.Arguments)
				if err != nil {
					return
				}
			}

			llm.req.Messages = append(llm.req.Messages, openai.ChatCompletionMessage{
				Role:       openai.ChatMessageRoleTool,
				Content:    toolOutput,
				ToolCallID: toolCall.ID,
			})
		}
	}

	return
}

func (llm *InteractiveLLM) chatCompletion(ctx context.Context) (*openai.ChatCompletionResponse, error) {
	tools := make([]openai.Tool, 0, len(llm.Tools))
	nameToolMap := make(map[string]tool.Tool, len(llm.Tools))
	for _, tool := range llm.Tools {
		tools = append(tools, tool.Tool())
		nameToolMap[tool.Tool().Function.Name] = tool
	}

	llm.req.Tools = tools

	if llm.Debug {
		bs, _ := json.Marshal(llm.req)
		fmt.Printf("req: %s\n", string(bs))
	}
	resp, err := llm.LLM.CreateChatCompletion(ctx, *llm.req)
	if err != nil {
		return nil, err
	}

	llm.resp = &resp
	if llm.Debug {
		bs, _ := json.Marshal(llm.resp)
		fmt.Printf("resp: %s\n", string(bs))
	}

	llm.req.Messages = append(llm.req.Messages, resp.Choices[0].Message)

	return llm.resp, nil
}
