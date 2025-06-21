#!/bin/bash
# Professional Backup Script
# Lead Persona Dashboard & Supabase Backend

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/opt/webapp-stack/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

echo -e "${BLUE}💾 Professional Backup: Lead Persona Dashboard${NC}"
echo -e "${BLUE}================================================${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}📦 Creating backup for $DATE...${NC}"

# Database backup
echo -e "${BLUE}🗄️  Backing up PostgreSQL database...${NC}"
if docker exec supabase-db pg_isready -U postgres; then
    docker exec supabase-db pg_dump -U postgres postgres > "$BACKUP_DIR/database_$DATE.sql"
    gzip "$BACKUP_DIR/database_$DATE.sql"
    echo -e "${GREEN}✅ Database backup created: database_$DATE.sql.gz${NC}"
else
    echo -e "${RED}❌ Database not available for backup${NC}"
fi

# Application configuration backup
echo -e "${BLUE}⚙️  Backing up application configuration...${NC}"
tar -czf "$BACKUP_DIR/config_$DATE.tar.gz" \
    /opt/webapp-stack/config/ \
    /opt/webapp-stack/infrastructure/ \
    --exclude="*/node_modules/*" \
    --exclude="*/.next/*" \
    --exclude="*/logs/*" 2>/dev/null

echo -e "${GREEN}✅ Configuration backup created: config_$DATE.tar.gz${NC}"

# Environment files backup
echo -e "${BLUE}🔐 Backing up environment files...${NC}"
tar -czf "$BACKUP_DIR/env_$DATE.tar.gz" \
    /root/supabase-setup/.env \
    /opt/webapp-stack/config/environments/ 2>/dev/null

echo -e "${GREEN}✅ Environment backup created: env_$DATE.tar.gz${NC}"

# Docker volumes backup (if needed)
echo -e "${BLUE}📁 Backing up Docker volumes...${NC}"
docker run --rm \
    -v supabase_db-config:/data \
    -v "$BACKUP_DIR:/backup" \
    alpine tar -czf "/backup/volumes_$DATE.tar.gz" /data 2>/dev/null || true

# Cleanup old backups
echo -e "${YELLOW}🧹 Cleaning up old backups (older than $RETENTION_DAYS days)...${NC}"
find "$BACKUP_DIR" -name "*.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete 2>/dev/null || true

# Backup summary
echo -e "\n${BLUE}📊 Backup Summary:${NC}"
ls -lh "$BACKUP_DIR"/*"$DATE"* 2>/dev/null || echo "No backups created"

echo -e "\n${BLUE}💾 Total backup size:${NC}"
du -sh "$BACKUP_DIR"

echo -e "\n${GREEN}✅ Backup completed successfully!${NC}"
echo -e "${BLUE}Backup location: $BACKUP_DIR${NC}"
echo -e "${BLUE}Backup timestamp: $DATE${NC}"