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
			Description: `"A wrapper around Wikipedia. "
			"Useful for when you need to answer general questions about "
			"people, places, companies, facts, historical events, or other subjects. "
        	"Input should be a search query."`,
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

	return shell.RunPythonCode(shell.WikipediaSearchPy, searchInput.Query, "--lang", lang)
}
