package tool

import (
	"context"
	"encoding/json"

	"mobius/internal/shell"

	"github.com/sashabaranov/go-openai"
)

type GoogleSearch struct{}

func (c *GoogleSearch) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name: "google-search",
			Description: `Google搜索接口用于处理需要实时信息或最新动态的查询，尤其是涉及当前事件、新闻、体育比分、天气预报等信息的情况。此外，当用户提到一些新术语或完全不熟悉的术语时，可以使用Google搜索接口进行查找。该接口通过搜索引擎获取相关结果，并从中选择一组高质量和多样化的资源进行详细阅读，以提供准确和全面的回答。

适用场景：

用户询问当前事件或需要实时信息（如新闻、天气、体育比分等）。
用户提到一些新术语或完全不熟悉的术语，需要通过搜索获取更多信息。
用户明确要求进行网络搜索或提供参考链接。`,
			Parameters: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"query": map[string]any{
						"type":        "string",
						"description": "search query",
					},
				},
				"required": []string{"query"},
			},
		},
	}
}

func (c *GoogleSearch) Call(ctx context.Context, input string) (output string, err error) {
	searchInput := struct {
		Query string `json:"query"`
	}{}
	err = json.Unmarshal([]byte(input), &searchInput)
	if err != nil {
		return
	}

	return shell.RunPythonCode(shell.GoogleSearchPy, searchInput.Query)
}
