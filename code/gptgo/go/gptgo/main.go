package main

import (
	"gptgo/commands"
	"gptgo/infra"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

func main() {
	plugin.Main(func(p *plugin.Plugin) error {
		p.HandleCommand(&plugin.CommandOptions{
			Name: "GptGoNewBuffer",
		}, func(vim *nvim.Nvim) (err error) {
			return infra.RequireInput(vim, "", commands.NewBuffer)
		})
		p.HandleCommand(&plugin.CommandOptions{
			Name: "GptGoContinue",
		}, commands.BufferChatContinue)

		p.HandleFunction(&plugin.FunctionOptions{
			Name: infra.ConsumeInputVimFuncName,
		}, infra.ConsumeInput)
		return nil
	})
}
