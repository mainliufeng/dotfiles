package commands

import (
	"context"
	"gptgo/chat"
	"gptgo/infra"
	"gptgo/llm"
	"strings"

	"github.com/neovim/go-client/nvim"
	"github.com/sashabaranov/go-openai"
)

func BufferChatContinue(vim *nvim.Nvim) (err error) {
	buffer, err := vim.CurrentBuffer()
	if err != nil {
		return
	}

	c, err := chat.NewChatFromBuffer(vim, buffer)
	if err != nil {
		return
	}

	var lastRole chat.Role

	messages := make([]openai.ChatCompletionMessage, 0, len(c.Segments))
	for _, segment := range c.Segments {
		messages = append(messages, openai.ChatCompletionMessage{
			Role:    string(segment.Role),
			Content: segment.Content,
		})
		lastRole = segment.Role
	}

	// 最后一句不是user直接退出
	if lastRole != chat.RoleUser {
		return
	}

	c.Segments = append(c.Segments, &chat.Segment{Role: chat.RoleAssistant})

	c.ToBuffer(vim, buffer)
	infra.UndoJoin(vim)

	go func() {
		_ = llm.Stream(context.Background(), messages, func(content string) {
			lines := strings.Split(content, "\n")

			for i, line := range lines {
				var currentBufferLines [][]byte
				currentBufferLines, err = vim.BufferLines(buffer, -2, -1, false)
				if err != nil {
					return
				}
				currentLine := string(currentBufferLines[0])

				infra.UndoJoin(vim)
				vim.SetBufferLines(buffer, -2, -1, false, [][]byte{
					[]byte(currentLine + line),
				})
				infra.UndoJoin(vim)

				if i < len(lines)-1 {
					vim.SetBufferLines(buffer, -1, -1, false, [][]byte{
						[]byte(""),
					})
					infra.UndoJoin(vim)
				}

				// vim.Command("redraw")
			}
		})
	}()

	return
}
