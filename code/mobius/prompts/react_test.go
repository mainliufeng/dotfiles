package prompts

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFormatReActPrompt(t *testing.T) {
	type testCase struct {
		args     *ReActPromptTemplateArgs
		expected string
	}

	for _, c := range []testCase{
		{
			args: &ReActPromptTemplateArgs{
				AiPrefix: "AI",
				Tools: []*Tool{
					{Name: "name1", Description: "description1"},
					{Name: "name2", Description: "description2"},
				},
				ChatHistory:    "chat_history1",
				Input:          "input1",
				AgentScrathpad: "agent_scratchpad1",
			},
			expected: "Assistant is a large language model trained by OpenAI.\n\nAssistant is designed to be able to assist with a wide range of tasks, from answering simple questions to providing in-depth explanations and discussions on a wide range of topics. As a language model, Assistant is able to generate human-like text based on the input it receives, allowing it to engage in natural-sounding conversations and provide responses that are coherent and relevant to the topic at hand.\n\nAssistant is constantly learning and improving, and its capabilities are constantly evolving. It is able to process and understand large amounts of text, and can use this knowledge to provide accurate and informative responses to a wide range of questions. Additionally, Assistant is able to generate its own text based on the input it receives, allowing it to engage in discussions and provide explanations and descriptions on a wide range of topics.\n\nOverall, Assistant is a powerful tool that can help with a wide range of tasks and provide valuable insights and information on a wide range of topics. Whether you need help with a specific question or just want to have a conversation about a particular topic, Assistant is here to assist.\n\nTOOLS:\n------\n\nAssistant has access to the following tools:\n>name1: description1\n>name2: description2\n\n\nTo use a tool, please use the following format:\n\n```\nThought: Do I need to use a tool? Yes\nAction: the action to take, should be one of  name1  name2 \n\nAction Input: the input to the action\nObservation: the result of the action\n```\n\nWhen you have a response to say to the Human, or if you do not need to use a tool, you MUST use the format:\n\n```\nThought: Do I need to use a tool? No\nAI: [your response here]\n\nBegin!\n\nPrevious conversation history:\nchat_history1\n\nNew input: input1\nagent_scratchpad1\n",
		},
	} {
		output, err := FormatReActPrompt(c.args)
		assert.NoError(t, err)
		assert.Equal(t, c.expected, output)
	}
}
