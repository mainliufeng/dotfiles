package task

import (
	"context"
	"fmt"

	"github.com/cloudwego/eino/components/tool"
)

type PlanToolKit struct {
	plan string
}

func (kit *PlanToolKit) GetTools() []tool.BaseTool {
	return []tool.BaseTool{
		mustInferTool(
			"set_plan",
			"更新计划",
			kit.toolSetPlan,
		),
		mustInferTool(
			"get_plan",
			"获取计划",
			kit.toolGetPlan,
		),
	}
}

type SetPlanParams struct {
	Plan string `json:"plan" jsonschema:"description=计划"`
}

type SetPlanResult struct {
}

// 处理函数
func (k *PlanToolKit) toolSetPlan(_ context.Context, params *SetPlanParams) (*SetPlanResult, error) {
	fmt.Printf("SetPlan: %s\n\n", params.Plan)
	k.plan = params.Plan
	return &SetPlanResult{}, nil
}

type GetPlanParams struct {
}

type GetPlanResult struct {
	Plan string `json:"plan" jsonschema:"description=计划"`
}

// 处理函数
func (k *PlanToolKit) toolGetPlan(_ context.Context, params *GetPlanParams) (*GetPlanResult, error) {
	fmt.Printf("GetPlan: %s\n\n", k.plan)
	return &GetPlanResult{Plan: k.plan}, nil
}
