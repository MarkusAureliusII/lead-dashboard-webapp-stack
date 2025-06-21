#!/bin/bash
# Professional Health Check Script
# Lead Persona Dashboard Stack

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🏥 Health Check: Lead Persona Dashboard Stack${NC}"
echo -e "${BLUE}================================================${NC}"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")/docker"

cd "$DOCKER_DIR"

# Check Docker services
echo -e "${YELLOW}🐳 Docker Services Status:${NC}"
docker compose ps

echo -e "\n${YELLOW}🔍 Endpoint Health Checks:${NC}"

# Health check functions with timeout and retry logic
check_endpoint() {
    local url="$1"
    local name="$2"
    local expected_code="${3:-200}"
    local timeout="${4:-5}"
    local max_retries="${5:-1}"
    
    for attempt in $(seq 1 $max_retries); do
        if response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout "$timeout" --max-time "$timeout" "$url" 2>/dev/null); then
            if [ "$response" = "$expected_code" ]; then
                echo -e "${GREEN}✅ $name: $url (HTTP $response)${NC}"
                return 0
            else
                echo -e "${YELLOW}⚠️  $name: $url (HTTP $response)${NC}"
                if [ $attempt -lt $max_retries ]; then
                    echo -e "${BLUE}🔄 Retrying $name in 2 seconds...${NC}"
                    sleep 2
                else
                    return 1
                fi
            fi
        else
            echo -e "${RED}❌ $name: $url (Connection failed - attempt $attempt/$max_retries)${NC}"
            if [ $attempt -lt $max_retries ]; then
                echo -e "${BLUE}🔄 Retrying $name in 3 seconds...${NC}"
                sleep 3
            else
                return 1
            fi
        fi
    done
}

# Test all endpoints
total_checks=0
passed_checks=0

# Main webapp with longer timeout
total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42/" "WebApp Dashboard" "200" "10" "1"; then
    passed_checks=$((passed_checks + 1))
fi

# Health endpoint with shorter timeout
total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42/health" "Health Check" "200" "5" "1"; then
    passed_checks=$((passed_checks + 1))
fi

# API endpoints - reduce frequency by spacing out checks
echo -e "${BLUE}⏸️  Waiting 2 seconds between checks to prevent overwhelming...${NC}"
sleep 2

total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42/api/health" "Supabase API" "401" "8" "1"; then
    passed_checks=$((passed_checks + 1))
fi

sleep 1

# Admin panel (expect 401 due to auth)
total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42/admin/" "Admin Panel" "401" "5" "1"; then
    passed_checks=$((passed_checks + 1))
fi

sleep 1

# Direct Supabase check
total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42:8000/health" "Supabase Direct" "401" "8" "1"; then
    passed_checks=$((passed_checks + 1))
fi

sleep 1

# Studio check
total_checks=$((total_checks + 1))
if check_endpoint "http://217.154.211.42:3000/" "Supabase Studio" "200" "10" "1"; then
    passed_checks=$((passed_checks + 1))
fi

echo -e "\n${YELLOW}📊 Container Resource Usage:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"

echo -e "\n${YELLOW}📋 Recent Logs (webapp):${NC}"
docker compose logs --tail=5 webapp 2>/dev/null || echo "No webapp logs available"

echo -e "\n${YELLOW}📋 Recent Logs (nginx):${NC}"
docker compose logs --tail=5 nginx 2>/dev/null || echo "No nginx logs available"

# Summary
echo -e "\n${BLUE}================================================${NC}"
if [ $passed_checks -eq $total_checks ]; then
    echo -e "${GREEN}🎉 All health checks passed! ($passed_checks/$total_checks)${NC}"
    exit 0
elif [ $passed_checks -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Partial health: $passed_checks/$total_checks checks passed${NC}"
    exit 1
else
    echo -e "${RED}❌ All health checks failed! ($passed_checks/$total_checks)${NC}"
    exit 2
fi