package prompt

import "fmt"

func CoT(prompt string) string {
	return fmt.Sprintf("%s\nLet's think step by step.", prompt)
}
