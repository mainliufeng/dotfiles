package tool

import (
	"context"
	"mobius/internal/shell"
	"strings"

	"github.com/sashabaranov/go-openai"
)

type Bash struct{}

func (c *Bash) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        "bash",
			Description: `执行bash脚本，可以用python、go、git等命令`,
			Parameters: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"script": map[string]any{
						"type": "string",
						"description": `bash脚本代码
						如果需要打开文件（包括图片、文本文件），运行"xdg-open 文件路径"
						如果需要打开url，运行"google-chrome-stable 这个url"
						`,
					},
				},
				"required": []string{"script"},
			},
		},
	}
}

func (c *Bash) Call(ctx context.Context, input string) (output string, err error) {
	in := struct {
		Script string `json:"script"`
	}{}

	if !strings.HasPrefix(input, "{") {
		// 容错
		in.Script = input
	} else if ok, output := validateInput(input, &in); !ok {
		return output, nil
	}

	return shell.RunBashCode(in.Script)
}
