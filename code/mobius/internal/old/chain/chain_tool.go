package chain

import (
	"context"
	"fmt"
	"mobius/tool"
)

const (
	toolChainInputVarName  = "input"
	toolChainOutputVarName = "output"
)

type ToolChain struct {
	Tool          tool.Tool
	InputVarName  string
	OutputVarName string
}

func (chain *ToolChain) Call(ctx context.Context, input map[string]any) (output map[string]any, err error) {
	toolInput, ok := input[chain.InputVarName]
	if !ok {
		err = fmt.Errorf("no var %s", chain.InputVarName)
		return
	}

	toolInputString, ok := toolInput.(string)
	if !ok {
		err = fmt.Errorf("var %s is not string", chain.OutputVarName)
		return
	}

	toolOutput, err := chain.Tool.Call(ctx, toolInputString)
	if err != nil {
		return
	}

	output = make(map[string]any, 1)
	output[toolChainOutputVarName] = toolOutput
	return
}
