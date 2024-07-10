package openapi

import (
	"context"
	"encoding/json"
	"fmt"
	"mobius/internal/tool"
	"net/http"
	"os"
	"strings"

	"github.com/sashabaranov/go-openai"
	"gopkg.in/yaml.v2"
)

type openAPITool struct {
	baseURL    string
	httpClient *http.Client

	method string
	path   string

	tool openai.Tool

	token string
}

func (t *openAPITool) Tool() openai.Tool {
	return t.tool
}

func (t *openAPITool) Call(ctx context.Context, input string) (output string, err error) {
	in := httpApiParams{}
	err = json.Unmarshal([]byte(input), &in)
	if err != nil {
		return
	}

	if t.token != "" {
		if in.Headers == nil {
			in.Headers = make(map[string]string)
		}
		in.Headers["Authorization"] = t.token
	}

	return callHttpApi(ctx, t.httpClient, t.baseURL, t.method, t.path, in)
}

type httpApiParams struct {
	Headers     map[string]string `json:"headers"`
	PathParams  map[string]string `json:"path_params"`
	QueryParams map[string]string `json:"query_params"`
	Body        json.RawMessage   `json:"body"`
}

func LoadOpenapi3ToolSetFromFile(ctx context.Context, toolSetFilePath string) (tools []tool.Tool, err error) {
	file, err := os.ReadFile(toolSetFilePath)
	if err != nil {
		return
	}

	var toolset Openapi3ToolSet
	if strings.HasSuffix(toolSetFilePath, ".json") {
		if err = json.Unmarshal(file, &toolset); err != nil {
			return
		}
	} else if strings.HasSuffix(toolSetFilePath, ".yaml") || strings.HasSuffix(toolSetFilePath, ".yml") {
		if err = yaml.Unmarshal(file, &toolset); err != nil {
			return
		}
	} else {
		err = fmt.Errorf("invalid toolset file: %s", toolSetFilePath)
		return
	}

	return toolset.Tools(ctx)
}

type Openapi3ToolSet struct {
	DocURI string `json:"doc_uri"`

	BaseURL string `json:"base_url"`
	Token   string `json:"token"`

	OperationIds []string `json:"operation_ids"`
}

func (ts *Openapi3ToolSet) Tools(ctx context.Context) (tools []tool.Tool, err error) {
	doc, err := loadOpenapi3Doc(ctx, ts.DocURI)
	if err != nil {
		return
	}

	baseURL := ts.BaseURL
	if baseURL == "" {
		baseURL = doc.Servers[0].URL
	}

	apiTools, err := openapi3DocToOpenAITools(doc)

	operationIdSet := make(map[string]struct{}, len(ts.OperationIds))
	for _, operationId := range ts.OperationIds {
		operationIdSet[operationId] = struct{}{}
	}

	for _, apiTool := range apiTools {
		operationId := apiTool.tool.Function.Name
		if len(operationIdSet) > 0 {
			if _, ok := operationIdSet[operationId]; !ok {
				continue
			}
		}
		toJson := func(value interface{}) string {
			bs, _ := json.Marshal(value)
			return string(bs)
		}
		fmt.Printf("openapi3工具（%s %s）：%s\n", apiTool.method, apiTool.path, toJson(apiTool.tool))

		tools = append(tools, &openAPITool{
			baseURL:    baseURL,
			httpClient: http.DefaultClient,
			method:     apiTool.method,
			path:       apiTool.path,
			tool:       apiTool.tool,

			token: ts.Token,
		})
	}

	return
}
