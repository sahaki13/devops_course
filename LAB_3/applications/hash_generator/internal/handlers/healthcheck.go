package handlers

import (
	"log/slog"
	"net/http"
	"time"
)

type HealthHandler struct {
	Logger *slog.Logger
}

func (h *HealthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.Logger.Warn("Unsupported method", "method", r.Method, "path", r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ok"))

	h.Logger.Info("Healthcheck OK", "time", time.Now().Format(time.RFC3339))
}
