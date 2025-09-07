# Load Testing with Gatling

This directory contains a comprehensive load testing setup for the Phoenix Web Application using Gatling. The setup tests all Docker Compose profiles with different load levels as required.

## Overview

The load testing framework tests these Docker Compose profiles:

- **normal**: Basic app with database
- **cache**: App with Redis caching
- **search**: App with OpenSearch
- **nginx**: App behind Nginx reverse proxy
- **all**: Complete setup with cache, search, and Nginx

Each profile is tested with: **1, 10, 100, 1000, 5000 requests in 5 minutes**

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- `curl` command available
- Bash shell

### Run All Tests (Full Suite)

```bash
cd load-testing
chmod +x run-tests.sh
./run-tests.sh
```

This will:

1. Test each Docker Compose profile sequentially
2. Run 5 different load levels (1, 10, 100, 1000, 5000 users) for each profile
3. Capture server metrics (CPU, Memory, Network I/O) for each container
4. Generate detailed HTML reports for each test
5. Create a summary report

**Total estimated time: ~3-4 hours**

### Run Quick Test (Single Profile)

```bash
cd load-testing
chmod +x quick-test.sh

# Test specific profile with custom parameters
./quick-test.sh [profile] [users] [duration_minutes]

# Examples:
./quick-test.sh normal 50 3        # Test normal profile with 50 users for 3 minutes
./quick-test.sh cache 100 2        # Test cache profile with 100 users for 2 minutes
./quick-test.sh all 10 1           # Test complete stack with 10 users for 1 minute
```

## File Structure

```
load-testing/
├── README.md                           # This file
├── run-tests.sh                        # Full test suite script
├── quick-test.sh                       # Quick individual test script
├── docker-compose.gatling.yml          # Gatling and monitoring setup
├── simulations/
│   └── WebApplicationLoadTest.scala    # Main Gatling simulation
├── monitoring/
│   └── prometheus.yml                  # Prometheus configuration
├── results/                            # Test results (generated)
│   ├── summary.txt                     # Summary of all tests
│   ├── [profile]_[users]users/         # Individual test reports
│   └── [profile]_[users]users_container_stats.txt
└── logs/                               # Test execution logs (generated)
    └── [profile]_[users]users.log
```

## Test Scenarios

The Gatling simulation includes realistic user scenarios:

### Browse Books (40% of traffic)

- Visit home page
- Browse books list
- Navigate to page 2
- Realistic pauses between requests

### Search Books (25% of traffic)

- Search for "programming"
- Advanced search for "elixir" in titles
- Tests both basic and OpenSearch functionality

### Browse Authors (15% of traffic)

- List authors
- Navigate through pages

### Browse Reviews (15% of traffic)

- List reviews
- Search reviews for "excellent"

### Browse Sales (5% of traffic)

- List sales
- Filter by year (2024)

## Metrics Collected

### Application Metrics

- Response times (min, max, mean, percentiles)
- Request rates (requests per second)
- Success/failure rates
- Concurrent users over time

### Server Metrics (per container)

- CPU usage percentage
- Memory usage (used/available)
- Memory percentage
- Network I/O
- Block I/O
- Number of processes/threads

### Containers Monitored by Profile

| Profile | Containers Monitored                                                                                                         |
| ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| normal  | web_application_app, web_application_db                                                                                      |
| cache   | web_application_app_cache, web_application_db, web_application_redis                                                         |
| search  | web_application_app_search, web_application_db, web_application_opensearch                                                   |
| nginx   | web_application_nginx_app, web_application_app, web_application_db                                                           |
| all     | web_application_nginx_all, web_application_app_search, web_application_db, web_application_redis, web_application_opensearch |

## Understanding Results

### Gatling Reports

Each test generates an HTML report at `results/[test_name]/index.html` containing:

- Response time distribution
- Requests per second over time
- Response time percentiles
- Active users over time
- Detailed request statistics

### Container Stats

Container statistics are saved to `results/[test_name]_container_stats.txt` showing:

- Resource usage during the test
- Performance impact on each service
- Bottleneck identification

### Key Performance Indicators

- **Response Time**: Should be < 1000ms mean, < 5000ms max
- **Success Rate**: Should be > 95%
- **CPU Usage**: Monitor for sustained high usage
- **Memory Usage**: Watch for memory leaks or excessive consumption

## Test Configurations

### Load Patterns

- **Ramp Test**: Gradually increase users over 5 minutes (default)
- **Spike Test**: Immediate load of all users
- **Stress Test**: Sustained load for duration

### Customization

Modify `simulations/WebApplicationLoadTest.scala` to:

- Add new scenarios
- Change user behavior patterns
- Adjust timing and pauses
- Add custom assertions

## Troubleshooting

### Common Issues

**Service not ready**

```bash
# Check if services are running
docker-compose --profile [profile] ps

# Check logs
docker-compose --profile [profile] logs [service_name]
```

**Network issues**

```bash
# Ensure network exists
docker network create web_application_network

# Check network connectivity
docker network inspect web_application_network
```

**Permission issues**

```bash
# Make scripts executable
chmod +x run-tests.sh quick-test.sh
```

### Manual Gatling Execution

```bash
# Run Gatling manually with custom parameters
docker run --rm \
    --network web_application_network \
    -v "$(pwd)/simulations:/opt/gatling/user-files/simulations" \
    -v "$(pwd)/results:/opt/gatling/results" \
    -e JAVA_OPTS="-DbaseUrl=http://web_application_app:4000 -Dusers=50 -Dduration=3 -DtestType=ramp" \
    denvazh/gatling:3.9.5 \
    -s simulations.WebApplicationLoadTest \
    -rf /opt/gatling/results \
    -rn "custom_test"
```

## Advanced Monitoring (Optional)

Start Prometheus and Grafana for advanced monitoring:

```bash
cd load-testing
docker-compose -f docker-compose.gatling.yml --profile monitoring up -d

# Access Grafana at http://localhost:3000 (admin/admin)
# Access Prometheus at http://localhost:9090
```

## Performance Expectations

Based on the application architecture:

### Expected Performance by Profile

- **normal**: Baseline performance, database-limited
- **cache**: Improved read performance with Redis
- **search**: Additional OpenSearch overhead but better search performance
- **nginx**: Potential static asset performance improvement
- **all**: Best feature set, highest resource usage

### Load Level Expectations

- **1-10 users**: Should handle easily with low resource usage
- **100 users**: Moderate load, some resource increase
- **1000 users**: High load, potential bottlenecks may appear
- **5000 users**: Stress test, likely to show system limits
