package handlers

import (
	"echo-server/internal/config"
	"log/slog"
)

type InfoResponse struct {
	Service   string `json:"service"`
	Version   string `json:"version"`
	BuildDate string `json:"buildDate"`
	Hostname  string `json:"hostname"`
	TimeNow   string `json:"timeNow"`
	UID       int    `json:"uid"`
}

type InfoHandler struct {
	Logger *slog.Logger
	Config *config.Config
}

type EchoHandler struct {
	Logger *slog.Logger
}

type HealthHandler struct {
	Logger *slog.Logger
}
