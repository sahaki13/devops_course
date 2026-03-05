package handlers

import (
	"io"
	"net/http"
	"strings"
)

func (h *EchoHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		h.Logger.Warn("Unsupported method", "method", r.Method, "path", r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		h.Logger.Error("Error reading body", "err", err)
		http.Error(w, "Error reading body", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	bodyStr := string(body)
	if len(bodyStr) > 1024 {
		bodyStr = bodyStr[:1024] + " [truncated...]"
	}
	bodyStr = strings.TrimSpace(bodyStr)
	h.Logger.Info("POST /", "body", bodyStr)

	w.Header().Set("Content-Type", r.Header.Get("Content-Type"))

	hash, ok := extractHash(body)
	if ok {
		w.Header().Set("X-Modified-Body", hash+"-modified")
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write(body)
	_, _ = w.Write([]byte("\n"))
}
