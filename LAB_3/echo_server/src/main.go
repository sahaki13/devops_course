package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

var (
	buildDate string
	version   string
	hostname  string
)

func healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodGet {
		fmt.Fprintln(w, "OK")
		fmt.Println("Healthcheck OK at", time.Now().Format(time.RFC3339))
	} else {
		fmt.Printf("WARN: Unsupported method %q on %q at %s\n", r.Method, r.URL.Path, time.Now().Format(time.RFC3339))
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func echoHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		response := fmt.Sprintf(
			"echo-service\nVersion: %s\nBuldDate: %s\nHostname: %s\nTimeNow: %s\n",
			version,
			buildDate,
			hostname,
			time.Now().Format(time.RFC3339))
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(response))
		fmt.Printf("GET /echo | Host: %s | Time: %s\n", hostname, time.Now().Format(time.RFC3339))
	case http.MethodPost:
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading body", http.StatusBadRequest)
			fmt.Printf("ERROR reading POST body: %v\n", err)
			return
		}
		defer r.Body.Close()

		bodyStr := string(body)

		if len(bodyStr) > 1024 {
			bodyStr = bodyStr[:1024] + " [truncated...]"
		}

		bodyStr = strings.TrimSpace(bodyStr)
		fmt.Printf("POST /echo at %s | Body: %q\n", time.Now().Format(time.RFC3339), bodyStr)

		w.Header().Set("Content-Type", r.Header.Get("Content-Type"))
		w.WriteHeader(http.StatusOK)
		w.Write(body)
		w.Write([]byte("\n"))
	default:
		fmt.Printf("WARN: Unsupported method %q on %q at %s\n", r.Method, r.URL.Path, time.Now().Format(time.RFC3339))
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func main() {
	hostname, _ = os.Hostname()

	fmt.Printf("buildDate: %s\nVersion: %s\n\n", buildDate, version)
	fmt.Printf("Running with UID: %d\n", os.Getuid())
	fmt.Printf("Hostname: %s\n", hostname)

	appPort := os.Getenv("APP_PORT")
	if appPort == "" {
		appPort = "3000"
	}
	appPort = ":" + appPort

	http.HandleFunc("/echo", echoHandler)
	http.HandleFunc("/healthcheck", healthcheckHandler)

	fmt.Println("The server is running at", appPort)
	if err := http.ListenAndServe(appPort, nil); err != nil {
		fmt.Println("Error:", err)
	}
}
