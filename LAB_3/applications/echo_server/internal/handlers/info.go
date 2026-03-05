package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"time"
)

func (h *InfoHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.Logger.Warn("Unsupported method", "method", r.Method, "path", r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	response := InfoResponse{
		Service:   "echo-server",
		Version:   h.Config.Version,
		BuildDate: h.Config.BuildDate,
		Hostname:  h.Config.Hostname,
		TimeNow:   time.Now().Format(time.RFC3339),
		UID:       os.Getuid(),
	}

	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.Logger.Error("Failed to encode JSON response", "err", err)
		return
	}

	h.Logger.Info("GET /",
		"version", h.Config.Version,
		"hostname", h.Config.Hostname,
		"remoteAddr", r.RemoteAddr,
	)
}
