package main

import (
	"log/slog"
	"os"

	"hash-generator/internal/config"
	"hash-generator/internal/server"
)

func main() {
	cfg := config.Load()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))

	logger.Info("Starting service",
		"listenPort", cfg.Port,
		"buildDate", cfg.BuildDate,
		"hostname", cfg.Hostname,
		"targetURL", cfg.TargetURL,
		"sendInterval (sec)", cfg.SendInterval.Seconds(),
	)

	srv := server.NewServer(cfg, logger)

	if err := srv.Run(); err != nil {
		logger.Error("Server failed", "err", err)
		os.Exit(1)
	}
}
