package main

import (
	"log/slog"
	"os"

	"echo-server/internal/config"
	"echo-server/internal/server"
)

func main() {
	cfg := config.Load()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))

	logger.Info("Starting service",
		"listenPort", cfg.Port,
		"version", cfg.Version,
		"buildDate", cfg.BuildDate,
		"hostname", cfg.Hostname,
		"uid", os.Getuid(),
	)

	srv := server.NewServer(cfg, logger)

	if err := srv.Run(); err != nil {
		logger.Error("Server failed", "err", err)
		os.Exit(1)
	}
}
