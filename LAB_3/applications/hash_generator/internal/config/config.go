package config

import (
	"os"
	"time"
)

var (
	version   = "dev"
	buildDate = "unknown"
)

type Config struct {
	Port         string
	Version      string
	BuildDate    string
	Hostname     string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
	IdleTimeout  time.Duration
	TargetURL    string
	HTTPTimeout  time.Duration
	SendInterval time.Duration
}

func Load() *Config {
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "3000"
	}

	hostname, err := os.Hostname()
	if err != nil {
		hostname = "unknown"
	}

	targetURL := os.Getenv("TARGET_URL")
	if targetURL == "" {
		targetURL = "http://localhost:3000/echo"
	}

	return &Config{
		Port:         port,
		Version:      version,
		BuildDate:    buildDate,
		Hostname:     hostname,
		ReadTimeout:  parseDuration(os.Getenv("READ_TIMEOUT"), 10*time.Second),
		WriteTimeout: parseDuration(os.Getenv("WRITE_TIMEOUT"), 10*time.Second),
		IdleTimeout:  parseDuration(os.Getenv("IDLE_TIMEOUT"), 60*time.Second),
		TargetURL:    targetURL,
		HTTPTimeout:  parseDuration(os.Getenv("HTTP_TIMEOUT"), 5*time.Second),
		SendInterval: parseDuration(os.Getenv("SEND_INTERVAL"), 10*time.Second),
	}
}
