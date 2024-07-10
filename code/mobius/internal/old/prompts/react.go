package prompts

import (
	_ "embed"
	"strings"
	"text/template"
)

//go:embed ReAct.txt
var promptReAct string

type Tool struct {
	Name        string
	Description string
}

type ReActPromptTemplateArgs struct {
	AiPrefix       string
	Tools          []*Tool
	ChatHistory    string
	Input          string
	AgentScrathpad string
}

func FormatReActPrompt(args *ReActPromptTemplateArgs) (string, error) {
	parsedTmpl, err := template.New("template").
		Option("missingkey=error").
		Parse(promptReAct)
	if err != nil {
		return "", err
	}
	sb := new(strings.Builder)
	err = parsedTmpl.Execute(sb, args)
	if err != nil {
		return "", err
	}
	return sb.String(), nil

}
