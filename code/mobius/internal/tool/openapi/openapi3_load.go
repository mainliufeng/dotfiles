package openapi

import (
	"context"
	"net/url"

	"github.com/getkin/kin-openapi/openapi3"
)

func loadOpenapi3Doc(ctx context.Context, uriString string) (doc *openapi3.T, err error) {
	uri, err := url.Parse(uriString)
	if err != nil {
		return
	}

	loader := openapi3.NewLoader()
	doc, err = loader.LoadFromURI(uri)
	if err != nil {
		return
	}

	err = doc.Validate(ctx)
	if err != nil {
		return
	}

	return
}
