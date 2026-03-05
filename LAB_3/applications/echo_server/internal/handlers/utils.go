package handlers

import "encoding/json"

func extractHash(body []byte) (string, bool) {
	var payload map[string]any

	if err := json.Unmarshal(body, &payload); err != nil {
		return "", false
	}

	hash, hashOk := payload["hash"].(string)
	// source, sourceOk := payload["source"].(string)

	if hashOk && hash != "" {
		return hash, true
	}

	return "", false
}
