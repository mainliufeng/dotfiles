package task

import (
	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/components/tool/utils"
)

type ToolKit interface {
	GetTools() []tool.BaseTool
}

func mustInferTool[T, D any](toolName, toolDesc string, i utils.InvokeFunc[T, D], opts ...utils.Option) tool.InvokableTool {
	tool, err := utils.InferTool(toolName, toolDesc, i, opts...)
	if err != nil {
		panic(err)
	}
	return tool
}
