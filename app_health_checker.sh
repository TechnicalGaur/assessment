#!/bin/bash
# app_health_checker.sh
# Application Health Checker Script

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
LOG_FILE="/var/log/app_health.log"
CHECK_INTERVAL=60  # seconds

# Application endpoints to check
declare -A ENDPOINTS=(
    ["Main Website"]="https://www.google.com"
    ["API Server"]="https://api.github.com"
    ["Example Service"]="https://httpbin.org/status/200"
)

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check HTTP endpoint
check_http_endpoint() {
    local name=$1
    local url=$2
    local response_code
    local response_time
    
    # Make HTTP request and capture status code and response time
    response_code=$(curl -o /dev/null -s -w "%{http_code}" -m 10 "$url")
    response_time=$(curl -o /dev/null -s -w "%{time_total}" -m 10 "$url")
    
    if [ "$response_code" -eq 200 ]; then
        echo -e "${GREEN}✓ $name is UP${NC} (Status: $response_code, Response Time: ${response_time}s)"
        log_message "SUCCESS: $name is UP - Status: $response_code, Response Time: ${response_time}s"
        return 0
    elif [ "$response_code" -eq 000 ]; then
        echo -e "${RED}✗ $name is DOWN${NC} (Connection failed)"
        log_message "FAILURE: $name is DOWN - Connection failed"
        send_alert "$name" "Connection failed"
        return 1
    else
        echo -e "${RED}✗ $name is DOWN${NC} (Status: $response_code)"
        log_message "FAILURE: $name is DOWN - Status: $response_code"
        send_alert "$name" "$response_code"
        return 1
    fi
}

# Function to check TCP port
check_tcp_port() {
    local name=$1
    local host=$2
    local port=$3
    
    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}✓ $name is UP${NC} (Port $port is open)"
        log_message "SUCCESS: $name is UP - Port $port is reachable"
        return 0
    else
        echo -e "${RED}✗ $name is DOWN${NC} (Port $port is closed/unreachable)"
        log_message "FAILURE: $name is DOWN - Port $port is unreachable"
        send_alert "$name" "Port $port unreachable"
        return 1
    fi
}

# Function to send alert
send_alert() {
    local service=$1
    local status=$2
    
    echo -e "${RED}🚨 ALERT: $service is experiencing issues!${NC}"
    echo "   Status: $status"
    echo "   Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # You can integrate with email, Slack, PagerDuty, etc.
    # Example: send email
    # echo "$service is down with status $status" | mail -s "Service Alert: $service" admin@example.com
}

# Function to generate health report
generate_report() {
    local total=$1
    local up=$2
    local down=$3
    
    echo ""
    echo "=========================================="
    echo "   Application Health Check Summary"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo "Total Applications: $total"
    echo -e "${GREEN}Applications UP: $up${NC}"
    echo -e "${RED}Applications DOWN: $down${NC}"
    echo "Uptime Percentage: $(awk "BEGIN {printf \"%.2f\", ($up/$total)*100}")%"
    echo "=========================================="
}

# Main health check function
main() {
    echo -e "${BLUE}Starting Application Health Check...${NC}"
    echo ""
    
    local total=0
    local up=0
    local down=0
    
    # Check all HTTP endpoints
    for name in "${!ENDPOINTS[@]}"; do
        url="${ENDPOINTS[$name]}"
        total=$((total + 1))
        
        if check_http_endpoint "$name" "$url"; then
            up=$((up + 1))
        else
            down=$((down + 1))
        fi
        echo ""
    done
    
    # Generate summary report
    generate_report "$total" "$up" "$down"
    
    log_message "Health check completed - Total: $total, UP: $up, DOWN: $down"
}

# Continuous monitoring mode
continuous_monitor() {
    echo -e "${YELLOW}Starting continuous monitoring (interval: ${CHECK_INTERVAL}s)${NC}"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        main
        echo ""
        echo "Next check in ${CHECK_INTERVAL} seconds..."
        echo ""
        sleep "$CHECK_INTERVAL"
    done
}

# Parse command line arguments
if [ "$1" == "--continuous" ] || [ "$1" == "-c" ]; then
    continuous_monitor
else
    main
fi
