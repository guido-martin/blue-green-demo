package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
	"fmt"
)

var (
	version          string
	startTime        time.Time
	failAfterSeconds time.Duration
)

type response struct {
	Location string `json:"location"`
	Version  string `json:"version"`
}

func main() {

	startTime = time.Now()
	initFailMiddleware()

	// Create Router
	mux := http.NewServeMux()

	mux.HandleFunc("/", handler)

	// Wrap the serve mux with fail middleware
	http.Handle("/", failAfterMiddleware(mux))

	// Start the HTTP server
	port := ":80"
	log.Printf("Starting server on port %s...\n", port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// logRequest logs request to standard output
func logRequest(r *http.Request) {
	log.Printf("Request: %s %s %s %s", r.Method, r.URL.Path, r.RemoteAddr, version)
}

// handler process incoming requests
// calls logRequest and returns location and version
func handler(w http.ResponseWriter, r *http.Request) {
	logRequest(r)

	response := response{
		Location: r.URL.Path,
		Version:  version,
	}

	jsonResponse, err := json.Marshal(response)
	if err != nil {
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

func initFailMiddleware() {

	failAfterSeconds = 0
	failAfterSecondsOpt := os.Getenv("FAIL_AFTER_SECONDS")

	// Set failAfterSeconds if FAIL_AFTER_SECONDS variable is present
	if failAfterSecondsOpt != "" {
		fmt.Printf("Found FAIL_AFTER_SECONDS option set to '%s'.\n", failAfterSecondsOpt)
		fmt.Println("Fail Simulation is enabled.")
		// Attempt to parse the value as an integer
		seconds, err := strconv.Atoi(failAfterSecondsOpt)
		if err != nil {
			fmt.Errorf("FAIL_AFTER_SECONDS value '%s' is not a valid integer. error : %v\n", failAfterSecondsOpt, err)
			os.Exit(1)
		}
		failAfterSeconds = time.Duration(seconds) * time.Second
	}
}

func failAfterMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Process only if failAfterSeconds is greater than 0, skip otherwise
		if failAfterSeconds > 0 {

			elapsed := time.Since(startTime)

			// Check if the elapsed time has exceeded failAfterSeconds
			if elapsed > failAfterSeconds {
				// Server failure condition met
				http.Error(w, "Server failure triggered", http.StatusInternalServerError)
				return
			}
		}

		// Continue to the next handler
		next.ServeHTTP(w, r)
	})
}
