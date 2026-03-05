package config

import (
	"os"
	"strconv"
)

func LoadConfig() Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	target := os.Getenv("TARGET_URL")
	if target == "" {
		target = "http://localhost:9999"
	}

	interval := 5
	if envInt := os.Getenv("INTERVAL_SEC"); envInt != "" {
		if val, err := strconv.Atoi(envInt); err == nil {
			interval = val
		}
	}

	return Config{
		Port:        port,
		TargetURL:   target,
		IntervalSec: interval,
	}
}
