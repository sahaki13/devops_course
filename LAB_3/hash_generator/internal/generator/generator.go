package generator

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"hash-generator/config"
	"log"
	"net/http"
	"time"
)

func Run(ctx context.Context, cfg *config.Config) {
	ticker := time.NewTicker(time.Duration(cfg.IntervalSec) * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Println("Generator stopped")
			return
		case <-ticker.C:
			generateAndSend(cfg.TargetURL)
		}
	}
}

func generateAndSend(targetURL string) {
	// Ваша логика генерации и отправки

	generateHash()
	log.Printf("Sending hash to %s", targetURL)
}

func sendHash(client *http.Client, url string) {
	now := time.Now()
	// Generate hash from current time + nanoseconds for uniqueness
	raw := fmt.Sprintf("%s-%d", now.String(), time.Now().UnixNano())
	hash := generateHash(raw)

	payload := Payload{
		Hash:      hash,
		Timestamp: now.Format(time.RFC3339),
		Source:    "hash_generator",
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		log.Printf("JSON marshaling error: %v", err)
		return
	}

	resp, err := client.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		log.Printf("Error sending request to %s: %v", url, err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		log.Printf("Sent successfully: %s...", hash[:8])
	} else {
		log.Printf("Server responded with status: %d", resp.StatusCode)
	}
}

func generateHash(input string) string {
	hasher := sha256.New()
	hasher.Write([]byte(input))
	return hex.EncodeToString(hasher.Sum(nil))
}
