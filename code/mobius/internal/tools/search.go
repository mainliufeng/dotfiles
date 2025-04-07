package tools

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/cloudwego/eino/components/tool"
	"github.com/cloudwego/eino/components/tool/utils"
)

var (
	SearchTool tool.InvokableTool
)

func init() {
	var err error
	SearchTool, err = utils.InferTool(
		"search",
		"搜索并返回文本，搜索时需要使用用户提问的语言",
		Search)
	if err != nil {
		panic(err)
	}
}

type SearchParams struct {
	Query string `json:"query" jsonschema:"description=query of the search"`
}

// 处理函数
func Search(_ context.Context, params *SearchParams) ([]*SearchResultItem, error) {
	client := &http.Client{}
	reqBody := map[string]interface{}{
		"workflow_id": "7490571049530032138",
		"parameters": map[string]string{
			"query": params.Query,
		},
	}
	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("JSON编码失败: %v", err)
	}

	req, err := http.NewRequest("POST", "https://api.coze.cn/v1/workflow/run", bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %v", err)
	}

	req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", os.Getenv("COZE_API_KEY")))
	req.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("发送请求失败: %v", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %v", err)
	}

	var searchResponse SearchResponse
	err = json.Unmarshal(body, &searchResponse)
	if err != nil {
		return nil, fmt.Errorf("JSON解码失败: %v", err)
	}

	var bingSearchResponse BingSearchResponse
	err = json.Unmarshal([]byte(searchResponse.Data), &bingSearchResponse)
	if err != nil {
		return nil, fmt.Errorf("JSON解码失败: %v", err)
	}

	return bingSearchResponse.Data.WebPages.Value, nil
}

type SearchResponse struct {
	Code int    `json:"code"`
	Data string `json:"data"`
}

type BingSearchResponse struct {
	Code int `json:"code"`
	Data struct {
		WebPages struct {
			Value []*SearchResultItem `json:"value"`
		} `json:"webPages"`
	} `json:"data"`
}

type SearchResultItem struct {
	Name    string `json:"name"`
	Snippet string `json:"snippet"`
	URL     string `json:"url"`
}
