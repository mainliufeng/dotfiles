package task

import (
	"context"
	"fmt"
	"strings"

	"github.com/cloudwego/eino/components/tool"
)

type ActionToolKit struct {
	agents          map[string]*Agent
	actionHistories []*ActionResult
}

func (k *ActionToolKit) GetTools() []tool.BaseTool {
	agentsDescription := strings.Builder{}
	agentsDescription.WriteString("以下是可选agent列表（格式为：agent_name: agent_description）：\n")
	for name, agent := range k.agents {
		agentsDescription.WriteString(fmt.Sprintf("%s: %s\n", name, agent.description))
	}

	return []tool.BaseTool{
		mustInferTool(
			"get_action_histories",
			"获取最近n个action的总结",
			k.toolGetActionHistories,
		),
		mustInferTool(
			"do_action",
			"指定agent执行action\n\n"+agentsDescription.String(),
			k.toolDoAction,
		),
	}
}

type GetActionHistoriesParams struct {
	LastN int `json:"last_n" jsonschema:"description=最近n个action"`
}

type GetActionHistoriesResult struct {
	ActionHistories []*GetActionHistoriesResultItem `json:"action_histories" jsonschema:"description=已经执行action的历史"`
}

type GetActionHistoriesResultItem struct {
	Action  string `json:"action" jsonschema:"description=执行的action"`
	Summary string `json:"summary" jsonschema:"description=执行结果的总结"`
}

// 处理函数
func (k *ActionToolKit) toolGetActionHistories(_ context.Context, params *GetActionHistoriesParams) (*GetActionHistoriesResult, error) {
	lastN := params.LastN
	if lastN <= 0 {
		lastN = 5
	}

	if lastN > len(k.actionHistories) {
		lastN = len(k.actionHistories)
	}

	fmt.Printf("GetActionHistories: %v, Result: \n", lastN)
	histories := k.actionHistories[len(k.actionHistories)-lastN:]

	results := make([]*GetActionHistoriesResultItem, 0)
	for _, step := range histories {
		results = append(results, &GetActionHistoriesResultItem{
			Action:  step.Action,
			Summary: step.Summary,
		})
	}

	for _, result := range results {
		fmt.Printf("Action: %s, Summary: %s\n", result.Action, result.Summary)
	}

	fmt.Printf("\n")
	return &GetActionHistoriesResult{
		ActionHistories: results,
	}, nil
}

type DoActionParams struct {
	Agent  string `json:"agent" jsonschema:"description=agent"`
	Action string `json:"action" jsonschema:"description=action"`
}

type DoActionResult struct {
	Summary string `json:"summary" jsonschema:"description=执行结果的总结"`
}

// 处理函数
func (k *ActionToolKit) toolDoAction(ctx context.Context, params *DoActionParams) (*DoActionResult, error) {
	agent, ok := k.agents[params.Agent]
	if !ok {
		return nil, fmt.Errorf("agent %s not found", params.Agent)
	}

	result, err := agent.DoAction(ctx, params.Action)
	if err != nil {
		return nil, err
	}

	k.actionHistories = append(k.actionHistories, result)

	return &DoActionResult{
		Summary: result.Summary,
	}, nil
}
