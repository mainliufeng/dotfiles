package task

import (
	"context"
	"fmt"
	"strings"

	"github.com/cloudwego/eino/components/model"
	"github.com/cloudwego/eino/components/prompt"
	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/components/tool/utils"
	"github.com/cloudwego/eino/schema"
	"github.com/samber/lo"
)

const (
	actionStop = "<action>[STOP]</action>"
)

var (
	leaderPromptTemplate = prompt.FromMessages(
		schema.Jinja2,
		schema.UserMessage(fmt.Sprintf(`
		按照下面步骤执行：
		1. 分析目标，如果还没有制定计划，则制定计划，否则跳到下一步
		2. 根据计划，和计划完成情况，判断目标是否已经达成，如果已经达成，输出%s，否则跳到下一步
		3. 根据计划，和计划完成情况，确定下一步的action，并执行action

		目标：
		{{action}}
		
		说明：
		1. 获取信息可以使用浏览器打开搜索引擎
		`, actionStop)),
	)

	developerPromptTemplate = prompt.FromMessages(
		schema.Jinja2,
		schema.SystemMessage("你是一个AI助手"),
		schema.UserMessage(`
		请根据用户的需求执行任务，执行任务后，请总结执行结果。
		总是返回具体的结果，不要让用户再执行任何操作。
		如果需要调用工具，确保每次只调用一个工具。

		用户的需求是：{{action}}`),
	)
)

type Task struct {
	Goal string `json:"goal"` // 目标

	leader    *Agent
	developer *Agent
}

func NewTask(goal string, model model.ToolCallingChatModel, tools []tool.BaseTool) (task *Task, err error) {
	ctx := context.Background()

	task = &Task{
		Goal: goal,
	}

	developerTools := []tool.BaseTool{}
	developerTools = append(developerTools, wrapToolsWithNoError(tools)...)

	task.developer, err = NewAgent(ctx, "worker", "负责执行具体且明确的action", developerPromptTemplate, model, developerTools, &AllMemory{}, 20)
	if err != nil {
		return nil, err
	}

	actionToolKit := &ActionToolKit{
		agents: map[string]*Agent{
			"worker": task.developer,
		},
	}

	planToolKit := &PlanToolKit{}

	leaderTools := []tool.BaseTool{}
	leaderTools = append(leaderTools, wrapToolsWithNoError(actionToolKit.GetTools())...)
	leaderTools = append(leaderTools, wrapToolsWithNoError(planToolKit.GetTools())...)

	task.leader, err = NewAgent(ctx, "leader", "leader", leaderPromptTemplate, model, leaderTools, &LastMemory{}, 20)
	if err != nil {
		return nil, err
	}

	return task, nil
}

func (task *Task) DoTask(ctx context.Context) (result *ActionResult, err error) {
	for i := 0; i < 10; i++ {
		result, err = task.leader.DoAction(ctx, task.Goal)
		if err != nil {
			fmt.Printf("DoTask, Error: %v\n", err)
			continue
		}
		fmt.Printf("DoTask, Summary: %s\n", result.Summary)
		fmt.Printf("----------------------------------------------------------\n\n")

		if strings.Contains(result.Summary, actionStop) {
			break
		}
	}

	return
}

func wrapToolsWithNoError(tools []tool.BaseTool) []tool.BaseTool {
	return lo.Map(tools, func(tool tool.BaseTool, _ int) tool.BaseTool {
		return utils.WrapToolWithErrorHandler(tool, func(ctx context.Context, err error) string {
			return fmt.Sprintf("Error: %v\n", err)
		})
	})
}
