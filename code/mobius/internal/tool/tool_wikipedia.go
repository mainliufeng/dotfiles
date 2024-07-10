package tool

import (
	"context"
	"encoding/json"
	"mobius/internal/shell"

	"github.com/sashabaranov/go-openai"
)

type WikiPediaSearch struct {
	Lang string
}

func (c *WikiPediaSearch) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name: "wikipedia-search",
			Description: `维基百科搜索接口用于处理需要全面、详细且经过编辑的百科类信息的查询。维基百科提供的内容通常包括历史背景、技术细节、生物信息等广泛主题，适用于需要深度了解某一特定主题或概念的情况。该接口通过维基百科获取信息，并提供经过验证的百科全书式回答。

适用场景：

用户询问某一特定主题或概念的详细背景信息和历史。
用户需要了解某一领域的基础知识或通用信息。
用户提到具体的历史事件、人物、地理位置、科学技术等，需要获取经过编辑的百科全书信息。`,
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

func (c *WikiPediaSearch) Call(ctx context.Context, input string) (output string, err error) {
	lang := c.Lang
	if lang == "" {
		lang = "zh"
	}

	searchInput := struct {
		Query string `json:"query"`
	}{}
	err = json.Unmarshal([]byte(input), &searchInput)
	if err != nil {
		return
	}

	return shell.WikipediaSearch(searchInput.Query, lang)
}
