package openapi

import (
	"github.com/getkin/kin-openapi/openapi3"
	"github.com/sashabaranov/go-openai"
)

type apiTool struct {
	method string
	path   string
	tool   openai.Tool
}

func openapi3DocToOpenAITools(doc *openapi3.T) (apiTools []*apiTool, err error) {
	for path, pathItem := range doc.Paths.Map() {
		for method, operation := range pathItem.Operations() {
			var tool openai.Tool
			tool, err = openapi3HttpApiToOpenAITool(operation)
			if err != nil {
				return
			}

			apiTools = append(apiTools, &apiTool{
				method: method,
				path:   path,
				tool:   tool,
			})
		}
	}
	return
}

func openapi3HttpApiToOpenAITool(operation *openapi3.Operation) (tool openai.Tool, err error) {
	if operation == nil {
		return
	}

	functionParams := make(map[string]interface{}, 0)

	// 解析body
	if operation.RequestBody != nil {
		schema := operation.RequestBody.Value.Content.Get("application/json").Schema
		functionParams["body"] = schema.Value
	}

	// 解析header、路径参数、query参数
	queryParams := make(map[string]interface{}, 0)
	pathParams := make(map[string]interface{}, 0)
	headers := make(map[string]interface{}, 0)
	for _, parameter := range operation.Parameters {
		switch parameter.Value.In {
		case "path":
			pathParams[parameter.Value.Name] = parameter.Value.Schema.Value
		case "query":
			queryParams[parameter.Value.Name] = parameter.Value.Schema.Value
		case "header":
			headers[parameter.Value.Name] = parameter.Value.Schema.Value
		}
	}
	if len(queryParams) > 0 {
		functionParams["query_params"] = queryParams
	}
	if len(pathParams) > 0 {
		functionParams["path_params"] = pathParams
	}
	if len(headers) > 0 {
		functionParams["headers"] = headers
	}

	// 描述
	var description string
	if operation.Description != "" {
		description = operation.Description
	} else {
		description = operation.Summary
	}

	tool = openai.Tool{
		Type: openai.ToolTypeFunction,
		Function: &openai.FunctionDefinition{
			Name:        operation.OperationID,
			Description: description,
			Parameters: map[string]any{
				"type":       "object",
				"properties": functionParams,
			},
		},
	}
	return
}
