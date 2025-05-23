package main

import (
	"context"
	"log"
	"mobius/internal/task"
	"mobius/internal/tools"
	"os"

	"github.com/cloudwego/eino-ext/components/model/openai"
)

func main() {
	ctx := context.Background()

	tools, err := tools.LoadToolsFromMcps(ctx, []*tools.McpConfig{
		{
			Command: "npx",
			Env:     nil,
			Args:    []string{"-y", "@executeautomation/playwright-mcp-server"},
		},
		//{
		//	Command: "npx",
		//	Env:     nil,
		//	Args: []string{
		//		"-y",
		//		"@modelcontextprotocol/server-filesystem",
		//		"/home/liufeng/temp",
		//	},
		//},
		{
			Command: "uvx",
			Env:     []string{"ALLOW_COMMANDS=ls,cat,pwd,grep,wc,touch,find"},
			Args: []string{
				"mcp-shell-server",
			},
		},
	})
	if err != nil {
		log.Fatal(err)
	}

	model, err := openai.NewChatModel(ctx, &openai.ChatModelConfig{
		APIKey:  os.Getenv("OPENAI_API_KEY"),
		BaseURL: os.Getenv("OPENAI_BASE_URL"),
		Model:   "gpt-4.1-mini",
	})
	if err != nil {
		log.Fatal(err)
	}

	task, err := task.NewTask(os.Args[1], model, tools)
	if err != nil {
		log.Fatal(err)
	}

	_, err = task.DoTask(ctx)
	if err != nil {
		log.Fatal(err)
	}
}
