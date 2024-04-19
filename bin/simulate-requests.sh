#!/bin/bash

# Check if the number of seconds is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <duration_in_seconds>"
    exit 1
fi

# Extract duration in seconds from command-line argument
duration=$1

# Validate if duration is a positive integer
if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
    echo "Error: Duration must be a positive integer."
    exit 1
fi

# get rand UUID
generate_uuid() {
    local os_type
    os_type=$(uname -s)

    case "$os_type" in
        Linux*)
            # Check if /proc/sys/kernel/random/uuid exists
            if [ -f /proc/sys/kernel/random/uuid ]; then
                cat /proc/sys/kernel/random/uuid
            else
                # Fallback: Use uuidgen if available
                if command -v uuidgen &>/dev/null; then
                    uuidgen
                else
                    echo "Error: Unable to generate UUID. Please install 'uuidgen'." >&2
                    exit 1
                fi
            fi
            ;;
        Darwin*)
            # macOS: Use uuidgen if available
            if command -v uuidgen &>/dev/null; then
                uuidgen
            else
                echo "Error: Unable to generate UUID. Please install 'uuidgen'." >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported operating system '$os_type'. Unable to generate UUID." >&2
            exit 1
            ;;
    esac
}


# Main loop to simulate HTTP requests
end_time=$((SECONDS + duration))  # Calculate end time based on current time + duration

echo "Simulating HTTP requests for $duration seconds..."

while [ $SECONDS -lt $end_time ]; do
    uuid=$(generate_uuid)  # Generate a new UUID for each request
    url="http://localhost/$uuid"

    # Make HTTP GET request using curl
   response=$(curl --silent --show-error --write-out "\n%{http_code}" "$url")

   # Extract response body and status code
   http_code=$(echo "$response" | tail -n 1)
   body=$(echo "$response" | sed '$d')  # Remove last line (http_code)

   # Check if request was successful (2xx status code)
   if [[ $http_code =~ ^2 ]]; then
       echo "Request successful (HTTP $http_code): $body"
   else
       echo "Request failed (HTTP $http_code)"
       echo "Error message: $body"
   fi

    sleep 0.3  # Wait before sending the next request
done


echo "Simulation complete."
