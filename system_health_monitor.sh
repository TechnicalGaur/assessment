#!/bin/bash
# system_health_monitor.sh
# System Health Monitoring Script

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80
LOG_FILE="/var/log/system_health.log"

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local resource=$1
    local usage=$2
    echo -e "${RED}⚠️  ALERT: $resource usage is at $usage%!${NC}"
    log_message "ALERT: $resource usage exceeded threshold - $usage%"
    # You can add email notification here
    # echo "$resource usage is at $usage%" | mail -s "System Alert" admin@example.com
}

# Function to check CPU usage
check_cpu() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
    echo -e "${GREEN}CPU Usage:${NC} $cpu_usage%"
    
    if [ "$cpu_usage" -ge "$CPU_THRESHOLD" ]; then
        send_alert "CPU" "$cpu_usage"
    fi
    
    echo "$cpu_usage"
}

# Function to check memory usage
check_memory() {
    local memory_usage=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')
    echo -e "${GREEN}Memory Usage:${NC} $memory_usage%"
    
    # Display detailed memory information
    echo "  $(free -h | awk 'NR==2 {print "Total: "$2", Used: "$3", Free: "$4}')"
    
    if [ "$memory_usage" -ge "$MEMORY_THRESHOLD" ]; then
        send_alert "Memory" "$memory_usage"
    fi
    
    echo "$memory_usage"
}

# Function to check disk usage
check_disk() {
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo -e "${GREEN}Disk Usage (/):{NC} $disk_usage%"
    
    # Display detailed disk information
    echo "  $(df -h / | awk 'NR==2 {print "Total: "$2", Used: "$3", Available: "$4}')"
    
    if [ "$disk_usage" -ge "$DISK_THRESHOLD" ]; then
        send_alert "Disk" "$disk_usage"
    fi
    
    echo "$disk_usage"
}

# Function to check running processes
check_processes() {
    local process_count=$(ps aux | wc -l)
    echo -e "${GREEN}Running Processes:${NC} $process_count"
    
    # Show top 5 CPU consuming processes
    echo -e "${YELLOW}Top 5 CPU consuming processes:${NC}"
    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-10s %-8s %-6s %s\n", $1, $2, $3"%", $11}'
    
    # Show top 5 memory consuming processes
    echo -e "${YELLOW}Top 5 Memory consuming processes:${NC}"
    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-10s %-8s %-6s %s\n", $1, $2, $4"%", $11}'
}

# Main monitoring function
main() {
    echo "========================================"
    echo "   System Health Monitoring Report"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""
    
    log_message "Starting system health check"
    
    check_cpu
    echo ""
    check_memory
    echo ""
    check_disk
    echo ""
    check_processes
    
    echo ""
    echo "========================================"
    log_message "System health check completed"
}

# Run the monitoring
main
