package tool

import (
	"context"
	"encoding/json"
	"strings"

	"mobius/internal/shell"

	"github.com/rs/zerolog/log"
	"github.com/sashabaranov/go-openai"
)

type Browser struct {
	urls []string
}

func (b *Browser) Search() *Search {
	return &Search{
		browser: b,
	}
}

func (b *Browser) MClick() *MClick {
	return &MClick{
		browser: b,
	}
}

type Search struct {
	browser *Browser
}

func (c *Search) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        "search",
			Description: `向搜索引擎发出查询并显示结果。`,
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

func (c *Search) Call(ctx context.Context, input string) (output string, err error) {
	searchInput := struct {
		Query string `json:"query"`
	}{}
	err = json.Unmarshal([]byte(input), &searchInput)
	if err != nil {
		return
	}

	rawOutput, err := shell.BrowserSearch(searchInput.Query)
	if err != nil {
		return
	}

	c.browser.urls = nil
	lines := strings.Split(rawOutput, "\n")
	for _, line := range lines {
		if strings.HasPrefix(line, "URL: ") {
			url := strings.TrimPrefix(line, "URL: ")
			c.browser.urls = append(c.browser.urls, url)
		}
	}

	return rawOutput, nil
}

type MClick struct {
	browser *Browser
}

func (c *MClick) Tool() openai.Tool {
	return openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        "mclick",
			Description: `检索提供的ID（0开始的索引）对应网页的内容。你应该总是选择至少3个来源，最多10个。选择具有多样化视角并且可信赖的来源。由于某些页面可能无法加载，即使内容可能重复，也可以选择一些冗余的页面。`,
			Parameters: map[string]any{
				"type": "object",
				"properties": map[string]any{
					"ids": map[string]any{
						"type": "array",
						"items": map[string]any{
							"type":        "integer",
							"description": "检索提供的ID（0开始的索引）",
						},
					},
				},
				"required": []string{"ids"},
			},
		},
	}
}

func (c *MClick) Call(ctx context.Context, input string) (output string, err error) {
	mClickInput := struct {
		Ids []int `json:"ids"`
	}{}
	err = json.Unmarshal([]byte(input), &mClickInput)
	if err != nil {
		return
	}

	urls := make([]string, 0, len(mClickInput.Ids))
	for _, id := range mClickInput.Ids {
		if id < len(c.browser.urls) {
			url := c.browser.urls[id]
			urls = append(urls, url)
		}
	}

	log.Debug().Strs("urls", urls).Msg("call mclick py")
	return shell.BrowserLoadUrls(urls)
}
