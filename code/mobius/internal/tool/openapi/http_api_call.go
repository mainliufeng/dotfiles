package openapi

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/url"
	"strings"
)

func callHttpApi(ctx context.Context, client *http.Client, baseURL string, method, path string, apiFunc httpApiParams) (respString string, err error) {
	// Replace path parameters in URL
	for param, value := range apiFunc.PathParams {
		path = strings.ReplaceAll(path, "{"+param+"}", value)
	}

	// Construct full URL with query parameters
	fullURL := baseURL + path
	if len(apiFunc.QueryParams) > 0 {
		params := url.Values{}
		for key, value := range apiFunc.QueryParams {
			params.Add(key, value)
		}
		fullURL += "?" + params.Encode()
	}

	// Create the request
	var req *http.Request
	if apiFunc.Body != nil {
		var bodyBytes []byte
		bodyBytes, err = json.Marshal(apiFunc.Body)
		if err != nil {
			return
		}
		req, err = http.NewRequest(method, fullURL, bytes.NewBuffer(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
	} else {
		req, err = http.NewRequest(method, fullURL, nil)
	}
	if err != nil {
		return
	}

	// Set headers
	for key, value := range apiFunc.Headers {
		req.Header.Set(key, value)
	}

	// Send the request
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	defer resp.Body.Close()

	// Read the response
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return
	}

	respString = string(respBody)
	return
}
