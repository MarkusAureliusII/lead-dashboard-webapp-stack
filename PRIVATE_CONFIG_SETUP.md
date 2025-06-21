# Private Configuration Repository Setup

## Option 1: Separate Private Repository (Recommended)

### Create a Private Config Repo:
1. Go to https://github.com/new
2. Name: `lead-dashboard-config-private`
3. Description: `Private configuration files for lead dashboard`
4. **Make it PRIVATE** ✅
5. Initialize with README

### Add Your Working Config Files:
```bash
# Clone the private config repo
git clone https://github.com/MarkusAureliusII/lead-dashboard-config-private.git
cd lead-dashboard-config-private

# Create the working .env file with your actual values
cat > .env.production << 'EOF'
# Your actual working configuration here
NODE_ENV=production
SERVER_IP=217.154.211.42
NEXT_PUBLIC_SUPABASE_URL=http://217.154.211.42:8000
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
POSTGRES_PASSWORD=306acbc70d380fb3ee12a524457fab0992f26635d431f676c903926907f3705f
JWT_SECRET=75bfa84e6b6b3d22e24c0cedee8f658ec1ef386d4ecd57a41c6a510abe56f2b3
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=SecureAdminPassword2024!
SECRET_KEY_BASE=d22de76854c5544a181d8d661472a1a3006f680255d3dc28e3b2f27f4c0d13cb
VAULT_ENC_KEY=ec8084aeda6d3c71197dfcbbc6ea824132ce5923b906219282e233b5bf0626d6
OPENAI_API_KEY=sk-proj-YOUR_ACTUAL_KEY_HERE
EOF

# Add Docker .env file
cat > docker.env << 'EOF'
# Your actual Docker environment
POSTGRES_PASSWORD=306acbc70d380fb3ee12a524457fab0992f26635d431f676c903926907f3705f
JWT_SECRET=75bfa84e6b6b3d22e24c0cedee8f658ec1ef386d4ecd57a41c6a510abe56f2b3
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=SecureAdminPassword2024!
EOF

# Create README
cat > README.md << 'EOF'
# Lead Dashboard - Private Configuration

This repository contains the actual working configuration files for the Lead Dashboard webapp.

## Files:
- `.env.production` - Production environment variables
- `docker.env` - Docker environment variables
- `nginx.conf` - Working nginx configuration with proxy

## Usage:
1. Copy files to your deployment server
2. Place in appropriate directories in the main webapp stack
3. Restart services

## Security:
- This repository is PRIVATE
- Contains actual API keys and secrets
- Do not share or make public
EOF

# Commit and push
git add .
git commit -m "Add working configuration files with actual secrets"
git push origin main
```

## Option 2: Private Branch in Same Repository

### Create a private branch:
```bash
cd /opt/webapp-stack
git checkout -b config-private
# Add your actual config files here
git add .
git commit -m "Add private configuration with actual secrets"
git push origin config-private
```

Then set the branch to private in GitHub settings.

## Option 3: GitHub Secrets (For CI/CD)

Add your environment variables as GitHub repository secrets:
1. Go to your repository → Settings → Secrets and variables → Actions
2. Add each environment variable as a secret
3. Use in GitHub Actions workflows

## Recommended Approach:
**Option 1 (Separate Private Repository)** is the most secure and organized approach.