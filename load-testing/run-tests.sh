#!/bin/bash

# Load Testing Script for Phoenix Web Application
# Tests all Docker Compose profiles with different load levels

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configurations
PROFILES=("normal" "cache" "search" "nginx-normal" "all")
LOAD_LEVELS=(1 10 100 1000 5000)
TEST_DURATION=5 # minutes

# Create results directory
mkdir -p results
mkdir -p logs

echo -e "${BLUE}=== Phoenix Web Application Load Testing ===${NC}"
echo "Testing profiles: ${PROFILES[*]}"
echo "Load levels: ${LOAD_LEVELS[*]} requests"
echo "Test duration: ${TEST_DURATION} minutes each"
echo ""

# Function to wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=60
    local attempt=1
    
    echo -e "${YELLOW}Waiting for ${service_name} to be ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}${service_name} is ready!${NC}"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts - ${service_name} not ready yet..."
        sleep 5
        ((attempt++))
    done
    
    echo -e "${RED}${service_name} failed to start within expected time${NC}"
    return 1
}

# Function to get container stats
get_container_stats() {
    local container_name=$1
    local output_file=$2
    
    echo "Collecting stats for container: $container_name"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}" $container_name >> "$output_file"
}

# Function to run load test
run_load_test() {
    local profile=$1
    local users=$2
    local base_url=$3
    local test_name="${profile}_${users}users"
    
    echo -e "${BLUE}Running test: $test_name${NC}"
    echo "Profile: $profile, Users: $users, URL: $base_url"
    
    # Create network if it doesn't exist
    docker network create web_application_network 2>/dev/null || true
    
    # Start monitoring in background
    local stats_file="results/${test_name}_container_stats.txt"
    echo "Container Stats for $test_name - $(date)" > "$stats_file"
    echo "=================================" >> "$stats_file"
    
    # Run Gatling test
    docker run --rm \
        --network web_application_network \
        -v "$(pwd)/simulations:/opt/gatling/user-files/simulations" \
        -v "$(pwd)/results:/opt/gatling/results" \
        -e JAVA_OPTS="-DbaseUrl=$base_url -Dusers=$users -Dduration=$TEST_DURATION" \
        denvazh/gatling:3.2.1 \
        -s WebApplicationLoadTest \
        -rf /opt/gatling/results \
        -rn "${test_name}" \
        > "logs/${test_name}.log" 2>&1 &
    
    local gatling_pid=$!
    
    # Monitor container stats during test
    for i in {1..30}; do # Monitor for 5 minutes (30 * 10 seconds)
        sleep 10
        
        # Get stats for all running containers
        case $profile in
            "normal")
                get_container_stats "web_application_app" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_db" "$stats_file" 2>/dev/null || true
                ;;
            "cache")
                get_container_stats "web_application_app_cache" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_db" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_redis" "$stats_file" 2>/dev/null || true
                ;;
            "search")
                get_container_stats "web_application_app_search" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_db" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_opensearch" "$stats_file" 2>/dev/null || true
                ;;
            "nginx-normal")
                get_container_stats "web_application_nginx_app" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_app" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_db" "$stats_file" 2>/dev/null || true
                ;;
            "all")
                get_container_stats "web_application_nginx_all" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_app_search" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_db" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_redis" "$stats_file" 2>/dev/null || true
                get_container_stats "web_application_opensearch" "$stats_file" 2>/dev/null || true
                ;;
        esac
        
        # Check if Gatling is still running
        if ! kill -0 $gatling_pid 2>/dev/null; then
            break
        fi
    done
    
    # Wait for Gatling to finish
    wait $gatling_pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}Test completed successfully: $test_name${NC}"
    else
        echo -e "${RED}Test failed: $test_name${NC}"
    fi
    
    echo "Stats saved to: $stats_file"
    echo "Logs saved to: logs/${test_name}.log"
    echo ""
}

# Main testing loop
for profile in "${PROFILES[@]}"; do
    echo -e "${YELLOW}=== Testing Profile: $profile ===${NC}"
    
    # Start the profile
    echo "Starting Docker Compose profile: $profile"
    if [ "$profile" = "nginx-normal" ]; then
        docker-compose --profile normal --profile nginx up -d --build
    else
        docker-compose --profile $profile up -d --build
    fi
    
    # Determine the correct URL and wait for service
    case $profile in
        "normal")
            base_url="http://web_application_app:4000"
            wait_for_service "http://localhost:4000" "Phoenix App (Normal)"
            ;;
        "cache")
            base_url="http://web_application_app_cache:4000"
            wait_for_service "http://localhost:4000" "Phoenix App (Cache)"
            ;;
        "search")
            base_url="http://web_application_app_search:4000"
            wait_for_service "http://localhost:4000" "Phoenix App (Search)"
            ;;
        "nginx-normal")
            base_url="http://web_application_nginx_app"
            wait_for_service "http://localhost:80" "Nginx + Phoenix App (Normal)"
            ;;
        "all")
            base_url="http://web_application_nginx_all"
            wait_for_service "http://localhost:80" "Complete Stack"
            ;;
    esac
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to start profile: $profile${NC}"
        docker-compose --profile $profile down
        continue
    fi
    
    # Run tests for each load level
    for users in "${LOAD_LEVELS[@]}"; do
        run_load_test "$profile" "$users" "$base_url"
        
        # Wait between tests
        echo "Waiting 30 seconds before next test..."
        sleep 30
    done
    
    # Stop the profile
    echo "Stopping Docker Compose profile: $profile"
    if [ "$profile" = "nginx-normal" ]; then
        docker-compose --profile normal --profile nginx down
    else
        docker-compose --profile $profile down
    fi
    
    echo -e "${GREEN}Completed testing profile: $profile${NC}"
    echo "Waiting 60 seconds before next profile..."
    sleep 60
done

echo -e "${GREEN}=== All Load Tests Completed ===${NC}"
echo "Results are available in the 'results' directory"
echo "Container stats are available in the 'results' directory"
echo "Logs are available in the 'logs' directory"

# Generate summary report
echo -e "${BLUE}Generating summary report...${NC}"
echo "Load Test Summary - $(date)" > results/summary.txt
echo "=================================" >> results/summary.txt
echo "" >> results/summary.txt

for profile in "${PROFILES[@]}"; do
    echo "Profile: $profile" >> results/summary.txt
    for users in "${LOAD_LEVELS[@]}"; do
        test_name="${profile}_${users}users"
        if [ -f "results/${test_name}/index.html" ]; then
            echo "  $users users - Report: results/${test_name}/index.html" >> results/summary.txt
        else
            echo "  $users users - Test failed or incomplete" >> results/summary.txt
        fi
    done
    echo "" >> results/summary.txt
done

echo -e "${GREEN}Summary report saved to: results/summary.txt${NC}"
