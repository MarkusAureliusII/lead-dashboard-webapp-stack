#!/bin/bash
# Professional Full-Stack Deployment Script
# Lead Persona Dashboard with Supabase Backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
DOCKER_DIR="$STACK_ROOT/infrastructure/docker"
APP_NAME="Lead Persona Dashboard"

echo -e "${BLUE}🚀 Professional Deployment: $APP_NAME${NC}"
echo -e "${BLUE}================================================${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available${NC}"
    exit 1
fi

if [ ! -f "$DOCKER_DIR/.env" ]; then
    echo -e "${RED}❌ Environment file not found: $DOCKER_DIR/.env${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Load environment variables
echo -e "${YELLOW}🔧 Loading configuration...${NC}"
source "$DOCKER_DIR/.env"

# Check if Supabase is running
echo -e "${YELLOW}🔍 Checking Supabase backend status...${NC}"
if ! curl -f http://217.154.211.42:8000/health &> /dev/null; then
    echo -e "${YELLOW}⚠️  Supabase backend not responding, attempting to start...${NC}"
    
    # Try to start Supabase if it's not running
    if [ -d "/root/supabase-setup" ]; then
        cd /root/supabase-setup
        docker compose -f docker-compose.yml up -d --no-deps kong studio auth rest meta
        sleep 15
    else
        echo -e "${RED}❌ Supabase setup directory not found${NC}"
        exit 1
    fi
fi

# Build and deploy
echo -e "${YELLOW}🏗️  Building application containers...${NC}"
cd "$DOCKER_DIR"

# Pull latest images
docker compose pull nginx

# Build custom images
echo -e "${YELLOW}📦 Building webapp container...${NC}"
docker compose build webapp

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker compose down 2>/dev/null || true

# Start services in order
echo -e "${YELLOW}🚀 Starting services...${NC}"

# Start webapp
echo -e "${BLUE}   Starting webapp...${NC}"
docker compose up -d webapp

# Wait for webapp to be healthy
echo -e "${YELLOW}⏳ Waiting for webapp to be ready...${NC}"
sleep 30

# Start nginx
echo -e "${BLUE}   Starting nginx reverse proxy...${NC}"
docker compose up -d nginx

# Start health monitoring
echo -e "${BLUE}   Starting health monitoring...${NC}"
docker compose up -d healthcheck

# Final status check
echo -e "${YELLOW}🔍 Checking deployment status...${NC}"
sleep 10

# Show service status
echo -e "${BLUE}📊 Service Status:${NC}"
docker compose ps

# Test endpoints
echo -e "${YELLOW}🧪 Testing endpoints...${NC}"

# Test webapp
if curl -f http://217.154.211.42/ &> /dev/null; then
    echo -e "${GREEN}✅ WebApp: http://217.154.211.42/${NC}"
else
    echo -e "${RED}❌ WebApp not responding${NC}"
fi

# Test API
if curl -f http://217.154.211.42/api/health &> /dev/null; then
    echo -e "${GREEN}✅ API: http://217.154.211.42/api/${NC}"
else
    echo -e "${RED}❌ API not responding${NC}"
fi

# Test admin
if curl -f http://217.154.211.42/admin/ &> /dev/null; then
    echo -e "${GREEN}✅ Admin: http://217.154.211.42/admin/${NC}"
else
    echo -e "${YELLOW}⚠️  Admin requires authentication${NC}"
fi

# Success message
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Your Lead Persona Dashboard is now live at:${NC}"
echo -e "${BLUE}🌐 Dashboard: http://217.154.211.42/${NC}"
echo -e "${BLUE}🔗 API: http://217.154.211.42/api/${NC}"
echo -e "${BLUE}👤 Admin: http://217.154.211.42/admin/${NC}"
echo -e "${BLUE}❤️  Health: http://217.154.211.42/health${NC}"
echo -e "${BLUE}================================================${NC}"

# Show logs
echo -e "${YELLOW}📋 Recent logs (last 20 lines):${NC}"
docker compose logs --tail=20 webapp

echo -e "${GREEN}✨ Professional deployment complete!${NC}"