#!/bin/bash

# Quick Load Test Script for Individual Profiles
# Usage: ./quick-test.sh [profile] [users] [duration]
# Note: Assumes the web application is already running

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PROFILE=${1:-"normal"}
USERS=${2:-10}
DURATION=${3:-2}

# Validate profile
VALID_PROFILES=("normal" "cache" "search" "nginx-normal" "all")
if [[ ! " ${VALID_PROFILES[@]} " =~ " ${PROFILE} " ]]; then
    echo -e "${RED}Invalid profile: $PROFILE${NC}"
    echo "Valid profiles: ${VALID_PROFILES[*]}"
    exit 1
fi

echo -e "${BLUE}=== Quick Load Test ===${NC}"
echo "Profile: $PROFILE"
echo "Users: $USERS"
echo "Duration: $DURATION minutes"
echo ""

# Create directories
mkdir -p results logs

# Function to wait for service
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=10
    local attempt=1
    
    echo -e "${YELLOW}Checking if ${service_name} is ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}${service_name} is ready!${NC}"
            return 0
        fi
        
        echo "Attempt $attempt/$max_attempts - ${service_name} not ready yet..."
        sleep 2
        ((attempt++))
    done
    
    echo -e "${RED}${service_name} is not accessible at $url${NC}"
    echo -e "${YELLOW}Make sure you have started the web application with:${NC}"
    echo -e "${YELLOW}docker-compose --profile $PROFILE up --build${NC}"
    return 1
}

# Determine the correct URL and wait for service
case $PROFILE in
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
    echo -e "${RED}Cannot connect to the web application for profile: $PROFILE${NC}"
    exit 1
fi

# Create network if it doesn't exist
docker network create web_application_network 2>/dev/null || true

# Run the load test using the same image as docker-compose.gatling.yml
test_name="${PROFILE}_${USERS}users_quick"
echo -e "${BLUE}Running Gatling load test: $test_name${NC}"

docker run --rm \
    --network web_application_network \
    -v "$(pwd)/simulations:/opt/gatling/user-files/simulations" \
    -v "$(pwd)/results:/opt/gatling/results" \
    -e JAVA_OPTS="-DbaseUrl=$base_url -Dusers=$USERS -Dduration=$DURATION" \
    denvazh/gatling:3.2.1 \
    -s WebApplicationLoadTest \
    -rf /opt/gatling/results \
    -rn "${test_name}"

echo -e "${GREEN}Load test completed!${NC}"

# Show container stats for running containers
echo -e "${BLUE}Current container stats:${NC}"
case $PROFILE in
    "normal")
        docker stats --no-stream web_application_app web_application_db 2>/dev/null || true
        ;;
    "cache")
        docker stats --no-stream web_application_app_cache web_application_db web_application_redis 2>/dev/null || true
        ;;
    "search")
        docker stats --no-stream web_application_app_search web_application_db web_application_opensearch 2>/dev/null || true
        ;;
    "nginx-normal")
        docker stats --no-stream web_application_nginx_app web_application_app web_application_db 2>/dev/null || true
        ;;
    "all")
        docker stats --no-stream web_application_nginx_all web_application_app_search web_application_db web_application_redis web_application_opensearch 2>/dev/null || true
        ;;
esac

echo ""
echo -e "${GREEN}Test results available at: results/${test_name}/index.html${NC}"
