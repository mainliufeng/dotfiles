package commands

import (
	"context"
	"gptgo/llm"
	"strings"

	"github.com/neovim/go-client/nvim"
	"github.com/sashabaranov/go-openai"
)

func NewBuffer(vim *nvim.Nvim, input string) (err error) {
	vim.Command("stopinsert")
	buffer, err := vim.CreateBuffer(true, false)
	if err != nil {
		return
	}
	_ = vim.SetCurrentBuffer(buffer)
	_ = vim.SetBufferOption(buffer, "filetype", "markdown")
	// win, err := vim.OpenWindow(buffer, true, &nvim.WindowConfig{})
	// if err != nil {
	// 	return
	// }
	// vim.SetCurrentWindow(win)

	err = llm.Stream(context.Background(), []openai.ChatCompletionMessage{
		{
			Role:    openai.ChatMessageRoleUser,
			Content: input,
		},
	}, func(content string) {
		lines := strings.Split(content, "\n")

		for i, line := range lines {

			var currentBufferLines [][]byte
			currentBufferLines, err = vim.BufferLines(buffer, -2, -1, false)
			if err != nil {
				return
			}
			currentLine := string(currentBufferLines[0])

			vim.SetBufferLines(buffer, -2, -1, false, [][]byte{
				[]byte(currentLine + line),
			})

			if i == len(lines) && i > 0 {
				vim.SetBufferLines(buffer, -1, -1, false, [][]byte{
					[]byte(""),
				})
			}

			vim.Command("redraw")
		}
	})

	return
}
