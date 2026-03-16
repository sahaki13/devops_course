package client

import (
	"fmt"
	"net/url"
)

func buildURL(baseURL string, endpoint string) (string, error) {
	u, err := url.Parse(baseURL)
	if err != nil {
		return "", fmt.Errorf("invalid base URL: %w", err)
	}

	fullURL := u.JoinPath(endpoint).String()
	return fullURL, nil
}
