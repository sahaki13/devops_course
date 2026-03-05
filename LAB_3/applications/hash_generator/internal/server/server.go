package server

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"hash-generator/internal/client"
	"hash-generator/internal/config"
	"hash-generator/internal/handlers"
	"hash-generator/internal/worker"
)

type Server struct {
	httpServer *http.Server
	Logger     *slog.Logger
	Config     *config.Config
}

func NewServer(cfg *config.Config, logger *slog.Logger) *Server {
	mux := http.NewServeMux()

	// Создаём HTTP-клиент для отправки на другой сервис
	healthHandler := &handlers.HealthHandler{Logger: logger}
	httpClient := client.NewHTTPClient(cfg.TargetURL, cfg.HTTPTimeout)

	// Хендлер с зависимостями
	infoHandler := &handlers.InfoHandler{
		Logger: logger,
		Config: cfg,
	}

	mux.HandleFunc("/healthcheck", healthHandler.ServeHTTP)
	mux.HandleFunc("/", infoHandler.ServeHTTP)

	go worker.Start(logger, cfg, httpClient)

	return &Server{
		httpServer: &http.Server{
			Addr:         ":" + cfg.Port,
			Handler:      mux,
			ReadTimeout:  cfg.ReadTimeout,
			WriteTimeout: cfg.WriteTimeout,
			IdleTimeout:  cfg.IdleTimeout,
		},
		Logger: logger,
		Config: cfg,
	}
}

func (s *Server) Run() error {
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		s.Logger.Info("Server starting",
			"addr", s.httpServer.Addr,
			"target", s.Config.TargetURL,
			"interval", s.Config.SendInterval,
		)
		if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			s.Logger.Error("ListenAndServe failed", "err", err)
		}
	}()

	<-quit
	s.Logger.Info("Shutdown signal received")

	// Graceful shutdown: создаём контекст ТОЛЬКО здесь, когда он нужен
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := s.httpServer.Shutdown(ctx); err != nil {
		return fmt.Errorf("server forced to shutdown: %w", err)
	}

	s.Logger.Info("Server exited gracefully")
	return nil
}
