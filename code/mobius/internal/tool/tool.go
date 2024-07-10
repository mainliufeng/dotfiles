package tool

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/sashabaranov/go-openai"
)

type Tool interface {
	Tool() openai.Tool
	// TODO 支持流式事件输出（例如搜索的url和标题）
	Call(ctx context.Context, input string) (string, error)
}

// validateInput 解析字符串（input）到struct（in），如果失败返回错误信息
func validateInput(input string, in interface{}) (ok bool, invalidOutput string) {
	err := json.Unmarshal([]byte(input), &in)
	if err != nil {
		return false, fmt.Sprintf("invalid input: %s", input)
	}

	return true, ""
}
