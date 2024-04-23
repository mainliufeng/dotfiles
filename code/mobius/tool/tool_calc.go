package tool

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/sashabaranov/go-openai"
	"go.starlark.net/lib/math"
	"go.starlark.net/starlark"
)

type Calculator struct{}

func (c *Calculator) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name: "calculator",
			Description: `Useful for getting the result of a math expression. 
	The input to this tool should be a valid mathematical expression that could be executed by a starlark evaluator.`,
			Parameters: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"expression": map[string]any{
						"type":        "string",
						"description": "mathematical expression that could be executed by a starlark evaluator",
					},
				},
				"required": []string{"expression"},
			},
		},
	}
}

func (c *Calculator) Call(ctx context.Context, input string) (output string, err error) {
	calcInput := struct {
		Expression string `json:"expression"`
	}{}
	err = json.Unmarshal([]byte(input), &calcInput)
	if err != nil {
		return
	}

	v, err := starlark.Eval(&starlark.Thread{Name: "main"}, "input", calcInput.Expression, math.Module.Members)
	if err != nil {
		return fmt.Sprintf("error from evaluator: %s", err.Error()), nil //nolint:nilerr
	}
	output = v.String()
	return
}
