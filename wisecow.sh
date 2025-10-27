#!/bin/bash

# Simple HTTP server that prints a cowsay message with random or custom text

PORT=4499

echo "Starting Wisecow server on port $PORT..."
echo "--------------------------------------"

while true; do
    {
        # Read the first line of the request
        read request
        # Extract query text if provided, e.g., /?text=Hello
        query=$(echo "$request" | grep -oE "text=[^ ]+" | cut -d'=' -f2 | sed 's/%20/ /g')

        # If no custom text provided, generate random fortune
        if [ -z "$query" ]; then
            message=$(fortune)
        else
            message="$query"
        fi

        cow_output=$(echo "$message" | cowsay)

        # Return HTTP response
        echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$cow_output"
    } | nc -l -p $PORT -q 1
done

