package tools

import (
	"context"

	mcpp "github.com/cloudwego/eino-ext/components/tool/mcp"
	"github.com/cloudwego/eino/components/tool"
	"github.com/mark3labs/mcp-go/client"
	"github.com/mark3labs/mcp-go/mcp"
)

type McpConfig struct {
	Command string
	Env     []string
	Args    []string
}

func LoadToolsFromMcps(ctx context.Context, mcpConfigs []*McpConfig) (tools []tool.BaseTool, err error) {
	for _, mcpConfig := range mcpConfigs {
		cli, err := client.NewStdioMCPClient(
			mcpConfig.Command,
			mcpConfig.Env,
			mcpConfig.Args...,
		)
		if err != nil {
			return nil, err
		}

		err = cli.Start(ctx)
		if err != nil {
			return nil, err
		}

		initRequest := mcp.InitializeRequest{}
		initRequest.Params.ProtocolVersion = mcp.LATEST_PROTOCOL_VERSION
		initRequest.Params.ClientInfo = mcp.Implementation{
			Name:    "example-client",
			Version: "1.0.0",
		}

		_, err = cli.Initialize(ctx, initRequest)
		if err != nil {
			return nil, err
		}

		mcpTools, err := mcpp.GetTools(ctx, &mcpp.Config{Cli: cli})
		if err != nil {
			return nil, err
		}

		tools = append(tools, mcpTools...)
	}

	return tools, nil
}
