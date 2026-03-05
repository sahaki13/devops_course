package handlers

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
	"time"

	"hash-generator/internal/config"
)

type InfoResponse struct {
	Service   string `json:"service"`
	Version   string `json:"version"`
	BuildDate string `json:"buildDate"`
	Hostname  string `json:"hostname"`
	TimeNow   string `json:"timeNow"`
	UID       int    `json:"uid"`
	TargetURL string `json:"targetURL"`
	Interval  string `json:"sendInterval"`
}

type InfoHandler struct {
	Logger *slog.Logger
	Config *config.Config
}

func (h *InfoHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.Logger.Warn("Unsupported method", "method", r.Method)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	response := InfoResponse{
		Service:   "hash-service",
		Version:   h.Config.Version,
		BuildDate: h.Config.BuildDate,
		Hostname:  h.Config.Hostname,
		TimeNow:   time.Now().Format(time.RFC3339),
		UID:       os.Getuid(),
		TargetURL: h.Config.TargetURL,
		Interval:  h.Config.SendInterval.String(),
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
