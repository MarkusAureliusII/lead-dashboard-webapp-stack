# Lead Persona Dashboard - Production Stack

## 🏗️ Professional WebApp Deployment

This is a production-ready deployment of the Lead Persona Dashboard with Supabase backend, following enterprise development practices.

## 📁 Directory Structure

```
/opt/webapp-stack/
├── apps/                           # Application services
│   ├── frontend/                   # Lead Persona Dashboard (React/Next.js)
│   └── backend/                    # Supabase services (running separately)
├── infrastructure/                 # DevOps & Infrastructure  
│   ├── docker/                     # Docker orchestration
│   ├── nginx/                      # Reverse proxy configuration
│   └── scripts/                    # Deployment & maintenance scripts
├── config/                         # Configuration management
│   ├── environments/               # Environment-specific configs
│   └── database/                   # Database migrations & schemas
├── docs/                          # Documentation
└── tools/                         # Development & monitoring tools
```

## 🚀 Quick Start

```bash
# Deploy the full stack
cd /opt/webapp-stack
./infrastructure/scripts/deploy.sh

# Check status
./infrastructure/scripts/health-check.sh

# View logs
docker compose -f infrastructure/docker/docker-compose.yml logs -f
```

## 🌐 Service URLs

- **Dashboard:** http://217.154.211.42/
- **API:** http://217.154.211.42/api/
- **Admin Panel:** http://217.154.211.42/admin/
- **Health Check:** http://217.154.211.42/health/

## 🔧 Development

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for development setup and guidelines.

## 📋 Production

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for production deployment and maintenance.

---
*Professional deployment structure for scalable web applications*