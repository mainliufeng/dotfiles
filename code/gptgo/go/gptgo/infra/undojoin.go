package infra

import (
	"fmt"
	"runtime/debug"

	"github.com/neovim/go-client/nvim"
)

func UndoJoin(vim *nvim.Nvim) {
	err := vim.Command("undojoin")
	if err != nil {
		Log(vim, fmt.Sprintf("undojoin failed, err: %s, stack: %s", err.Error(), string(debug.Stack())))
	}
}
