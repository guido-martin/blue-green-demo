package main

import (
	"encoding/json"
	"log"
	"net/http"
)

var version string

type response struct {
	Location string `json:"location"`
	Version  string `json:"version"`
}

func main() {
	// Create Router
	mux := http.NewServeMux()

	// Define root handler
	mux.HandleFunc("/", handler)

	// Start the HTTP server
	port := ":80"
	log.Printf("Starting server on port %s...\n", port)
	err := http.ListenAndServe(port, mux)
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
