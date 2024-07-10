package tool

import (
	"context"
	"mobius/internal/shell"

	"github.com/sashabaranov/go-openai"
)

type Python struct{}

func (c *Python) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        "python-code-interpreter",
			Description: "执行python代码，If you want to see the output of a value, you should print it out with `print(...)`.",
			Parameters: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"code": map[string]any{
						"type":        "string",
						"description": "python代码",
					},
				},
				"required": []string{"code"},
			},
		},
	}
}

func (c *Python) Call(ctx context.Context, input string) (string, error) {
	in := struct {
		Code string `json:"code"`
	}{}
	if ok, output := validateInput(input, &in); !ok {
		return output, nil
	}

	return shell.RunPythonCode(in.Code)
}
