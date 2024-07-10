package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"mobius/internal/agent"
	"mobius/internal/io"
	"mobius/internal/llm"
	"mobius/internal/prompt"
	"mobius/internal/tool"
	"mobius/internal/tool/openapi"
	"os"
	"runtime/debug"
	"strings"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/sashabaranov/go-openai"
)

func main() {
	var openapi3ToolSetFilePath string
	var sysPrompt string
	var userPrompt string
	flag.StringVar(&openapi3ToolSetFilePath, "openapi", "", "Specify the openapi parameter")
	flag.StringVar(&sysPrompt, "system", "", "System Prompt")
	flag.StringVar(&userPrompt, "user", "", "User Prompt")
	debugFlag := flag.Bool("debug", false, "sets log level to debug")

	flag.Parse()

	zerolog.SetGlobalLevel(zerolog.InfoLevel)
	if *debugFlag {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	}
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	if sysPrompt == "" {
		sysPrompt = strings.TrimSpace(`
You are a helpful assistant who can answer multistep questions by sequentially calling functions. Follow a pattern of THOUGHT (reason step-by-step about which function to call next), ACTION (call a function to as a next step towards the final answer), OBSERVATION (output of the function). Reason step by step which actions to take to get to the answer. Only call functions with arguments coming verbatim from the user or the output of other functions.

使用browser工具的情况下：

用户询问当前事件或需要实时信息（天气、体育比分等）。
用户询问一个你完全不熟悉的术语（它可能是新的）。
用户明确要求你浏览或提供参考链接。
在需要检索的查询情况下，你的操作将包括以下三步：

使用search函数获取结果列表。
使用mclick函数并行检索这些结果的多样且高质量的子集。记住要选择至少3个来源，最多不超过10个。选择具有多样化视角并且可信赖的来源。由于某些页面可能无法加载，即使内容可能重复，也可以选择一些冗余的页面。
根据这些结果为用户撰写响应。在你的响应中，使用下面的引用格式引用来源。
在某些情况下，如果初始结果不满意，并且你认为可以通过细化查询获得更好的结果，可以重复第1步两次。

引用来自'browser'工具的内容时，请按以下格式呈现引用：

短引用格式：【{message idx}†{链接文本}】
长引用格式：[链接文本](message idx)
否则不要呈现链接。
		`)
	}

	ctx := context.Background()

	browser := &tool.Browser{}

	tools := []tool.Tool{
		&tool.Calculator{},
		&tool.WikiPediaSearch{},
		browser.Search(),
		browser.MClick(),
	}

	needConfirmTools := []tool.Tool{
		&tool.Python{},
		&tool.Bash{},
	}

	if openapi3ToolSetFilePath != "" {
		openapiTools, err := openapi.LoadOpenapi3ToolSetFromFile(ctx, openapi3ToolSetFilePath)
		if err != nil {
			panic(err)
		}
		needConfirmTools = append(needConfirmTools, openapiTools...)
	}

	tools = append(tools, tool.WrapConfirm(needConfirmTools)...)

	tools = tool.WrapTrunc(tools, 2000)

	a := &agent.Agent{
		Tools: tools,
		LLM:   &llm.OpenAI{},

		BeforeChatCompletions: func(req openai.ChatCompletionRequest) {
			fmt.Printf("请求%s模型\n", req.Model)
		},
		AfterChatCompletions: func(req openai.ChatCompletionRequest, resp openai.ChatCompletionResponse, err error) {
			if err != nil {
				fmt.Printf("请求%s模型, 失败：%s\n", req.Model, err.Error())
			}
			bs, _ := json.Marshal(resp)
			log.Debug().Msgf("请求%s模型，输出：\n%s\n", req.Model, string(bs))
		},

		BeforeToolCall: func(toolCall openai.ToolCall) {
			fmt.Printf("执行工具：%s，参数：%s\n", toolCall.Function.Name, toolCall.Function.Arguments)
		},
		AfterToolCall: func(toolCall openai.ToolCall, output string) {
			log.Debug().Msgf("执行工具：%s，输出：\n%s\n", toolCall.Function.Name, output)
		},
	}

	request := openai.ChatCompletionRequest{
		Messages: make([]openai.ChatCompletionMessage, 0),
	}

	if sysPrompt != "" {
		request.Messages = append(request.Messages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleSystem,
			Content: sysPrompt,
		})
	}

	var userMessages []openai.ChatCompletionMessage
	if userPrompt != "" {
		userMessages = append(userMessages, openai.ChatCompletionMessage{
			Role:    openai.ChatMessageRoleUser,
			Content: userPrompt,
		})
	} else {
		userMessages = append(userMessages, io.GetUserInputMessages(ctx)...)
	}

	if len(userMessages) > 0 {
		request.Messages = append(request.Messages, userMessages[:len(userMessages)-1]...)
		lastUserMessage := userMessages[len(userMessages)-1]
		if lastUserMessage.Content != "" {
			lastUserMessage.Content = prompt.CoT(lastUserMessage.Content)
		}
		request.Messages = append(request.Messages, lastUserMessage)
	} else {
		request.Messages = append(request.Messages, userMessages...)
	}

	for {
		resp, err := a.Chat(ctx, request)
		if err != nil {
			fmt.Println(string(debug.Stack()))
			panic(err)
		}

		choice := resp.Choices[0]
		fmt.Printf("\n模型输出：%s\n\n", choice.Message.Content)

		userInput := io.GetUserInputMessages(ctx)
		if len(userInput) != 0 {
			request = openai.ChatCompletionRequest{
				Messages: userInput,
			}
		}
	}
}
