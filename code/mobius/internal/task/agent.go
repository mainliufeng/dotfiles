package task

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/cloudwego/eino/components/model"
	"github.com/cloudwego/eino/components/prompt"
	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/compose"
	"github.com/cloudwego/eino/flow/agent"
	"github.com/cloudwego/eino/flow/agent/react"
	"github.com/cloudwego/eino/schema"
)

type Agent struct {
	name        string
	description string

	promptTempalte prompt.ChatTemplate
	agent          *react.Agent
	memory         Memory
}

func NewAgent(
	ctx context.Context,
	name string, description string,
	promptTempalte prompt.ChatTemplate,
	model model.ToolCallingChatModel,
	tools []tool.BaseTool,
	memory Memory,
	maxStep int,
) (agent *Agent, err error) {
	agent = &Agent{
		name:           name,
		description:    description,
		promptTempalte: promptTempalte,
		memory:         memory,
	}

	agent.agent, err = react.NewAgent(ctx, &react.AgentConfig{
		MaxStep:          20,
		ToolCallingModel: model,
		ToolsConfig: compose.ToolsNodeConfig{
			Tools:               tools,
			ExecuteSequentially: true,
		},
	})
	if err != nil {
		return
	}

	return
}

type ActionResult struct {
	// action的描述
	Action string `json:"action"`

	// action执行过程
	Messages []*schema.Message `json:"messages"`

	// 执行结果的总结
	Summary string `json:"summary"`
}

func (a *Agent) DoAction(ctx context.Context, action string) (result *ActionResult, err error) {
	fmt.Printf("%s: DoAction, Action: %s\n", a.name, action)

	result = &ActionResult{
		Action: action,
	}
	defer func() {
		if err != nil {
			result.Summary = fmt.Sprintf("执行失败，错误信息：%s", err.Error())
		}
		fmt.Printf("%s: DoAction, Result: %s\n", a.name, result.Summary)

		if err != nil {
			for _, message := range a.memory.GetMessages() {
				messageBytes, _ := json.Marshal(message)
				fmt.Printf("%s\n", string(messageBytes))
			}
		}
	}()

	round := a.memory.Round()

	inputMessages, err := a.promptTempalte.Format(ctx, map[string]any{
		"action": action,
	})
	if err != nil {
		return
	}
	inputMessages = round.Before(inputMessages)

	outputMessage, err := a.agent.Generate(ctx, inputMessages, agent.WithComposeOptions(compose.WithCallbacks(round.Callbacks()...)))
	if err != nil {
		return
	}

	round.After(outputMessage)
	result.Summary = outputMessage.Content
	return
}
