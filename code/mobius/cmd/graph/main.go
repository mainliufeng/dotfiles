package main

import (
	"context"
	"encoding/json"
	"fmt"
	"mobius/internal/graph"
)

func main() {
	ctx := context.Background()
	r, err := graph.BuildpromptAndModel(ctx)
	if err != nil {
		panic(err)
	}

	in := map[string]any{"q": "北京有几个区"}
	ret, err := r.Invoke(ctx, in)
	if err != nil {
		panic(err)
	}

	fmt.Println("invoke result: ", ret.Content)

	usage, _ := json.Marshal(ret.ResponseMeta.Usage)
	fmt.Println("usage: ", string(usage))
}
