package worker

import (
	"crypto/sha256"
	"encoding/hex"
	"log/slog"
	"time"

	"hash-generator/internal/client"
	"hash-generator/internal/config"
)

func Start(logger *slog.Logger, cfg *config.Config, httpClient *client.HTTPClient) {
	logger.Info("Worker started",
		"interval", cfg.SendInterval,
		"target", cfg.TargetURL,
	)

	for {
		sendHash(logger, cfg, httpClient)
		time.Sleep(cfg.SendInterval)
	}
}

func sendHash(logger *slog.Logger, cfg *config.Config, httpClient *client.HTTPClient) {
	timestamp := time.Now().Format(time.RFC3339)

	hash := sha256.Sum256([]byte(timestamp))
	hashHex := hex.EncodeToString(hash[:])

	payload := client.HashPayload{
		Hash:      hashHex,
		Timestamp: timestamp,
		Source:    cfg.Hostname,
	}

	resp, err := httpClient.SendHash(payload)

	if err != nil {
		logger.Error("Failed to send hash", "err", err)
		return
	}

	logger.Info("Hash sent successfully",
		"sourceHash", payload.Hash,
		"status", resp.StatusCode,
		"modifiedHash", resp.Header.Get("X-Modified-Body"),
	)
}
