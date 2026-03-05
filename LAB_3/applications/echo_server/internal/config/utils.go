package config

import "time"

func parseDuration(val string, defaultVal time.Duration) time.Duration {
	if val == "" {
		return defaultVal
	}
	d, err := time.ParseDuration(val)
	if err != nil {
		return defaultVal
	}
	return d
}
