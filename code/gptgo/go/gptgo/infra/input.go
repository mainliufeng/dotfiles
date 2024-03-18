package infra

import (
	"fmt"

	"github.com/neovim/go-client/nvim"
)

const (
	ConsumeInputVimFuncName = "GptGoSendInput"
)

var (
	inputCallback func(*nvim.Nvim, string) error
)

func RequireInput(vim *nvim.Nvim, prompt string, f func(*nvim.Nvim, string) error) (err error) {
	inputCallback = f

	err = vim.ExecLua(fmt.Sprintf(`
    vim.schedule(function()
	    vim.ui.input({ prompt = "%s" }, function(input)
	    	if not input or input == "" then
	    		return
	    	end
	    	vim.fn.%s(input)
	    end)
	end)
	`, prompt, ConsumeInputVimFuncName), nil, nil)
	return
}

func ConsumeInput(vim *nvim.Nvim, args []string) (err error) {
	if len(args) == 0 {
		return
	}

	callback := inputCallback
	if callback == nil {
		return
	}

	input := args[0]
	return callback(vim, input)
}
