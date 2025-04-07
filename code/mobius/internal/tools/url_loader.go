package tools

import (
	"context"
	"fmt"
	"os/exec"

	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/components/tool/utils"
)

var (
	UrlLoaderTool tool.InvokableTool
)

func init() {
	var err error
	UrlLoaderTool, err = utils.InferTool(
		"load_url_content",
		"加载URL内容并返回文本",
		LoadUrls)
	if err != nil {
		panic(err)
	}
}

type LoadUrlsParams struct {
	Urls []string `json:"urls" jsonschema:"description=urls of the browser"`
}

// 处理函数
func LoadUrls(_ context.Context, params *LoadUrlsParams) (string, error) {
	// 构建命令
	cmd := exec.Command("python", append([]string{"internal/py/browser_load_urls.py"}, params.Urls...)...)

	// 执行命令并获取输出
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("执行browser_load_urls.py失败: %v", err)
	}

	return string(output), nil
}
