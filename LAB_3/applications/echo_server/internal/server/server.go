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

	"echo-server/internal/config"
	"echo-server/internal/handlers"
)

type Server struct {
	httpServer *http.Server
	Logger     *slog.Logger
	Config     *config.Config
}

func NewServer(cfg *config.Config, logger *slog.Logger) *Server {
	mux := http.NewServeMux()

	infoHandler := &handlers.InfoHandler{Logger: logger, Config: cfg}
	echoHandler := &handlers.EchoHandler{Logger: logger}
	healthHandler := &handlers.HealthHandler{Logger: logger}

	mux.HandleFunc("/healthcheck", healthHandler.ServeHTTP)
	mux.HandleFunc("/echo", echoHandler.ServeHTTP)
	mux.HandleFunc("/", infoHandler.ServeHTTP)

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
		s.Logger.Info("Server starting", "addr", s.httpServer.Addr)
		if err := s.httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			s.Logger.Error("ListenAndServe failed", "err", err)
		}
	}()

	<-quit
	s.Logger.Info("Shutdown signal received")

	// soft exit
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := s.httpServer.Shutdown(ctx); err != nil {
		return fmt.Errorf("server forced to shutdown: %w", err)
	}

	s.Logger.Info("Server exited gracefully")
	return nil
}
