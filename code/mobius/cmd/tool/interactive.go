package main

import (
	"mobius/llm"
	"mobius/tool"
)

func main() {
	llm.ChatWithLLM(
		&llm.OpenAI{},
		[]tool.Tool{
			&tool.WikiPediaSearch{Lang: "en"},
			&tool.Calculator{},
			&tool.DuckDuckGoSearch{},
		},
		"你是一个助手",
	)
}
