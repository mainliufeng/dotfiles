package tool

import (
	"context"
	"encoding/json"
	"os/exec"

	"github.com/sashabaranov/go-openai"
)

type DuckDuckGoSearch struct{}

func (c *DuckDuckGoSearch) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        "duckduckgo-search",
			Description: `DuckDuckGo search.`,
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

func (c *DuckDuckGoSearch) Call(ctx context.Context, input string) (output string, err error) {
	searchInput := struct {
		Query string `json:"query"`
	}{}
	err = json.Unmarshal([]byte(input), &searchInput)
	if err != nil {
		return
	}

	cmd := exec.Command("mobius_duckduckgo_search", searchInput.Query)
	bs, err := cmd.CombinedOutput()
	if err != nil {
		return
	}

	output = string(bs)
	return
}
