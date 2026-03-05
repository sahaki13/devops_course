package main

import (
	"context"
	"hash-generator/config"
	"hash-genrator/internal/generator"
	"hash-genrator/internal/handler"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	// 1. Load configuration from environment variables
	cfg := config.LoadConfig()

	log.Printf("Starting hash_generator microservice on port %s", cfg.Port)
	log.Printf("Target URL: %s, Interval: %d seconds", cfg.TargetURL, cfg.IntervalSec)

	// 2. Setup context for graceful shutdown
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// 3. Start the background worker (hash generation loop)
	go func() {
		generator.(ctx, cfg)
	}

	// 4. Setup HTTP server for health checks and info
	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/", infoHandler)

	server := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: mux,
	}

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("HTTP server error: %v", err)
		}
	}()

	<-ctx.Done()
	log.Println("Shutdown signal received...")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("Error during server shutdown: %v", err)
	}
}
