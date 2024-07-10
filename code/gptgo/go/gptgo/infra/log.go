package infra

import "github.com/neovim/go-client/nvim"

func Log(vim *nvim.Nvim, text string) {
	vim.Echo([]nvim.TextChunk{{Text: text}}, true, map[string]interface{}{})
}
