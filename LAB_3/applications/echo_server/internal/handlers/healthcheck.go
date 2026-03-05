package handlers

import (
	"net/http"
	"time"
)

func (h *HealthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.Logger.Warn("Unsupported method", "method", r.Method, "path", r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	h.Logger.Info("Healthcheck OK", "time", time.Now().Format(time.RFC3339))
}
