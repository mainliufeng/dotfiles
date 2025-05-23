package worker

import "github.com/cloudwego/eino/schema"

type Task struct {
	Goal string `json:"goal"` // 目标

	Plan  string `json:"plan"`  // 计划
	Notes string `json:"notes"` // 备注

	Steps []*Step
}

type Step struct {
	// action的描述
	Action string `json:"action"`

	// action执行过程
	Messages []*schema.Message `json:"messages"`

	// 执行结果的总结
	Summary string `json:"summary"`
}
