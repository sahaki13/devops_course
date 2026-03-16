package handlers

import (
	"context"
	"hash-generator/internal/client"
	"log/slog"
	"net/http"
	"time"
)

type ReadyHandler struct {
	Logger    *slog.Logger
	TargetURL string
	Client    *client.HTTPClient
}

func (h *ReadyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.Logger.Warn("Unsupported method", "method", r.Method, "path", r.URL.Path)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 1*time.Second)
	defer cancel()

	resp, err := h.Client.Get(ctx, "/healthcheck")
	if err != nil {
		h.Logger.Warn("Service unreachable",
			"target", h.TargetURL,
			"err", err)
		http.Error(w, "Service unreachable", http.StatusServiceUnavailable)
		return
	}
	defer resp.Body.Close()

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("ready"))

	h.Logger.Info("Ready OK", "time", time.Now().Format(time.RFC3339))
}
