package chat

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/neovim/go-client/nvim"
)

const (
	RoleSystem    Role = "system"
	RoleUser      Role = "user"
	RoleAssistant Role = "assistant"
	RolePrefix         = "#"
)

type Role string

type Segment struct {
	Role    Role
	Content string
}

type ChatConfig struct {
	Model       string   `json:"model"`
	Temperature *float32 `json:"temperature"`
}

type Chat struct {
	ChatConfig
	Segments []*Segment
}

func NewChatFromFile(filePath string) (chat *Chat, err error) {
	// 打开文件
	file, err := os.Open(filePath)
	if err != nil {
		return
	}
	defer file.Close()

	// 创建一个新的bufio.Reader
	scanner := bufio.NewScanner(file)

	lines := make([]string, 0, 128)

	// 逐行读取
	for scanner.Scan() {
		// 获取当前行的内容
		line := scanner.Text()
		// 将读取的行添加到Chat.Lines中
		lines = append(lines, line)
	}

	// 检查是否在读取文件时发生错误
	if err = scanner.Err(); err != nil {
		// 处理读取文件时的错误
		return
	}

	return NewChatFromLines(lines)
}

func NewChatFromBuffer(vim *nvim.Nvim, buffer nvim.Buffer) (chat *Chat, err error) {
	bufferLines, err := vim.BufferLines(buffer, 0, -1, false)
	if err != nil {
		return
	}

	stringLines := make([]string, 0, len(bufferLines))
	for _, line := range bufferLines {
		stringLines = append(stringLines, string(line))
	}

	chat, err = NewChatFromLines(stringLines)
	if err != nil {
		return
	}

	return
}

func NewChatFromLines(lines []string) (chat *Chat, err error) {
	chat = &Chat{ChatConfig: ChatConfig{}, Segments: make([]*Segment, 0, len(lines))}

	config := ChatConfig{}
	role := ""
	content := ""

	// role和content加到chat里
	addSegment := func() {
		if role == "" {
			return
		}

		content = strings.TrimFunc(content, func(r rune) bool {
			return r == '\n'
		})

		chat.Segments = append(chat.Segments, &Segment{
			Role:    Role(role),
			Content: content,
		})
		role = ""
		content = ""
	}

	for _, line := range lines {
		// 解析参数
		unmarshalErr := json.Unmarshal([]byte(strings.TrimSpace(line)), &config)
		if unmarshalErr == nil {
			if config.Model != "" {
				chat.Model = config.Model
			}
			if config.Temperature != nil {
				chat.Temperature = config.Temperature
			}
			continue
		}

		nextRole := ""
		if strings.HasPrefix(strings.TrimSpace(line), RolePrefix) {
			line = strings.TrimSpace(line)
			maybeRole := strings.ReplaceAll(line, RolePrefix, "")
			maybeRole = strings.TrimSpace(maybeRole)
			maybeRole = strings.ToLower(maybeRole)
			switch maybeRole {
			case string(RoleSystem), string(RoleUser), string(RoleAssistant):
				nextRole = maybeRole
			}
		}

		if nextRole == "" {
			content = content + "\n" + line
		} else {
			addSegment()
			role = nextRole
		}
	}

	if content != "" {
		addSegment()
	}

	return
}

func (chat *Chat) ToLines() (lines []string) {
	appendLine := func(line string) {
		lines = append(lines, line)
	}
	configBytes, _ := json.Marshal(chat.ChatConfig)
	appendLine(string(configBytes))

	appendLine("")

	for i, segment := range chat.Segments {
		appendLine(fmt.Sprintf("%s %s", RolePrefix, segment.Role))
		appendLine("")

		lines := strings.Split(segment.Content, "\n")

		for _, line := range lines {
			appendLine(line)
		}

		if i < len(chat.Segments)-1 && len(lines) > 0 {
			appendLine("")
		}
	}

	return
}

func (chat *Chat) ToBuffer(vim *nvim.Nvim, buffer nvim.Buffer) {
	lines := chat.ToLines()
	byteLines := make([][]byte, 0, len(lines))
	for _, line := range lines {
		byteLines = append(byteLines, []byte(line))
	}

	vim.SetBufferLines(buffer, 0, -1, false, byteLines)
}
