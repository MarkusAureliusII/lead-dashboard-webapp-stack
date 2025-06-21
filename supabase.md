# Supabase Configuration Documentation

## Overview

This document provides comprehensive configuration information for the self-hosted Supabase instance used by the webapp stack.

## Current Configuration

### Server Details
- **Host**: `217.154.211.42`
- **Port**: `3001` (API Gateway)
- **Admin Port**: `8000` (Alternative access)
- **Studio Port**: `3000` (Dashboard Interface)
- **Database**: PostgreSQL
- **Environment**: Self-hosted Docker instance

### Connection Configuration

#### Frontend Client Configuration
Located in: `/opt/webapp-stack/apps/frontend/src/integrations/supabase/client.ts`

```typescript
const SUPABASE_URL = "http://217.154.211.42:3001";
const SUPABASE_PUBLISHABLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE";

export const supabase = createClient<Database>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
});
```

#### Environment Configuration
Located in: `/root/supabase/docker/.env`

Key environment variables:
- `POSTGRES_PASSWORD`: Secure password for PostgreSQL
- `JWT_SECRET`: `your-super-secret-jwt-token-with-at-least-32-characters-long` (Supabase demo secret)
- `ANON_KEY`: Anonymous access key (properly signed with JWT_SECRET)
- `SERVICE_ROLE_KEY`: Service role key (properly signed with JWT_SECRET)
- `ENABLE_EMAIL_AUTOCONFIRM`: `true` (bypasses email confirmation for development)
- `DASHBOARD_USERNAME`: Admin dashboard username
- `DASHBOARD_PASSWORD`: Admin dashboard password

## Database Schema

### Core Tables

#### `auth.users`
- User authentication and profile data
- Managed by Supabase Auth

#### `public.leads`
- Lead information and contact details
- Columns: id (uuid), user_id (uuid), email, phone, name, company, status, created_at, updated_at
- RLS Policy: Authenticated users can only access their own leads

#### `public.scrape_jobs`
- Background job tracking for data scraping
- Columns: id (uuid), user_id (uuid), name, status, target_url, search_criteria (jsonb), results_count, error_message, created_at, updated_at, completed_at
- RLS Policy: Authenticated users can only access their own scrape jobs

#### `public.webhook_settings`
- Webhook configuration for external integrations
- Columns: id (uuid), user_id (uuid), name, url, secret, events (text[]), is_active, created_at, updated_at
- RLS Policy: Authenticated users can only access their own webhook settings

## Row Level Security (RLS) Policies

### Lead Management
```sql
-- SELECT policy for leads
CREATE POLICY "Users can read own leads" ON public.leads 
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT policy for leads
CREATE POLICY "Authenticated users can insert leads" ON public.leads 
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- UPDATE policy for leads
CREATE POLICY "Users can update own leads" ON public.leads 
  FOR UPDATE USING (auth.uid() = user_id);

-- DELETE policy for leads
CREATE POLICY "Users can delete own leads" ON public.leads 
  FOR DELETE USING (auth.uid() = user_id);
```

### Scraping Jobs
```sql
-- SELECT policy for scrape_jobs
CREATE POLICY "Users can read own scrape jobs" ON public.scrape_jobs 
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT policy for scrape_jobs
CREATE POLICY "Authenticated users can insert scrape jobs" ON public.scrape_jobs 
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- UPDATE policy for scrape_jobs
CREATE POLICY "Users can update own scrape jobs" ON public.scrape_jobs 
  FOR UPDATE USING (auth.uid() = user_id);

-- DELETE policy for scrape_jobs
CREATE POLICY "Users can delete own scrape jobs" ON public.scrape_jobs 
  FOR DELETE USING (auth.uid() = user_id);
```

### Webhook Settings
```sql
-- SELECT policy for webhook_settings
CREATE POLICY "Users can read own webhook settings" ON public.webhook_settings 
  FOR SELECT USING (auth.uid() = user_id);

-- INSERT policy for webhook_settings
CREATE POLICY "Authenticated users can insert webhook settings" ON public.webhook_settings 
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- UPDATE policy for webhook_settings
CREATE POLICY "Users can update own webhook settings" ON public.webhook_settings 
  FOR UPDATE USING (auth.uid() = user_id);

-- DELETE policy for webhook_settings
CREATE POLICY "Users can delete own webhook settings" ON public.webhook_settings 
  FOR DELETE USING (auth.uid() = user_id);
```

## Database Triggers

### Automatic User ID Assignment
```sql
-- Function to automatically set user_id on INSERT
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers for all tables
CREATE TRIGGER set_user_id_trigger
  BEFORE INSERT ON public.leads
  FOR EACH ROW EXECUTE FUNCTION public.set_user_id();
```

### Automatic Timestamp Updates
```sql
-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for all tables
CREATE TRIGGER update_updated_at_trigger
  BEFORE UPDATE ON public.leads
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
```

## Authentication Configuration

### Session Management
- **Persistent Sessions**: Enabled for better user experience
- **Auto Refresh**: Tokens automatically refresh before expiration
- **Session Detection**: Handles auth state from URL parameters

### Security Features
- JWT-based authentication
- Secure password hashing (bcrypt)
- Session timeout management
- CORS configuration for frontend access

## Real-time Subscriptions

### Configuration
- **Events per second**: Limited to 10 for performance
- **WebSocket connections**: Maintained for live updates
- **Subscription management**: Automatic cleanup on component unmount

### Usage in Frontend
```typescript
// Example subscription for real-time lead updates
const { data: leads } = useQuery({
  queryKey: ['leads'],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('leads')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
  }
});

// Real-time subscription setup
useEffect(() => {
  const subscription = supabase
    .channel('leads_channel')
    .on('postgres_changes', 
      { event: '*', schema: 'public', table: 'leads' },
      () => {
        queryClient.invalidateQueries({ queryKey: ['leads'] });
      }
    )
    .subscribe();

  return () => subscription.unsubscribe();
}, [queryClient]);
```

## Data Persistence

### Volume Configuration
- **Database data**: Persisted in Docker volumes
- **Backup strategy**: Regular snapshots recommended
- **Recovery procedures**: Documented in `/root/supabase/docker/RESTART_PROCEDURES.md`

### Important Notes
- **Always use `docker compose restart`** instead of `down/up` to maintain data
- **Never delete Docker volumes** without proper backup
- **Environment variables** must be properly configured for data persistence

## API Access

### REST API
- **Base URL**: `http://217.154.211.42:3001/rest/v1/`
- **Alternative URL**: `http://217.154.211.42:8000/rest/v1/`
- **Authentication**: Bearer token in Authorization header
- **Content-Type**: `application/json`

### GraphQL API
- **Endpoint**: `http://217.154.211.42:3001/graphql/v1`
- **Alternative Endpoint**: `http://217.154.211.42:8000/graphql/v1`
- **Schema**: Auto-generated from database schema
- **Introspection**: Available for development

### Realtime API
- **WebSocket**: `ws://217.154.211.42:3001/realtime/v1/websocket`
- **Alternative WebSocket**: `ws://217.154.211.42:8000/realtime/v1/websocket`
- **Channels**: Table-based or custom channels
- **Events**: INSERT, UPDATE, DELETE, SELECT

## Access URLs

### Available Interfaces
- **API Gateway**: `http://217.154.211.42:3001`
- **Alternative API**: `http://217.154.211.42:8000`
- **Studio Dashboard**: `http://217.154.211.42:3000`
- **Frontend App**: `http://217.154.211.42:8080`

## Development vs Production

### Development Configuration
- **Local development**: Frontend runs on port 8080
- **Hot reload**: Enabled via Vite development server
- **Debug mode**: Enhanced error messages and logging

### Production Configuration
- **Static build**: Optimized React bundle
- **Environment variables**: Production-specific secrets
- **SSL/TLS**: Should be configured for production deployment
- **Rate limiting**: Implement for API protection

## Troubleshooting

### Common Issues

#### Connection Errors
- Verify Supabase service is running: `docker ps`
- Check network connectivity to port 8000
- Confirm environment variables are set correctly

#### Authentication Issues
- Verify JWT secret matches between client and server
- Check token expiration and refresh logic
- Confirm RLS policies allow the intended operations

#### Data Persistence Issues
- Ensure proper Docker volume mounting
- Use `docker compose restart` instead of `down/up`
- Check PostgreSQL logs for errors

### Debug Commands
```bash
# Check Supabase container status
docker ps | grep supabase

# View container logs
docker logs supabase_db_1

# Test API connectivity
curl -X GET http://217.154.211.42:8000/rest/v1/ \
  -H "apikey: your_anon_key"

# Check database connection
docker exec -it supabase_db_1 psql -U postgres
```

## Migration and Backup

### Database Migrations
- Schema changes should be applied via Supabase CLI
- Migration files stored in `/root/supabase/docker/migrations/`
- Always test migrations in development first

### Backup Procedures
```bash
# Create database backup
docker exec supabase_db_1 pg_dump -U postgres postgres > backup.sql

# Restore from backup
docker exec -i supabase_db_1 psql -U postgres postgres < backup.sql
```

## Security Considerations

### Production Checklist
- [ ] Change default JWT secret
- [ ] Use strong database passwords
- [ ] Implement HTTPS/SSL
- [ ] Configure proper CORS origins
- [ ] Set up rate limiting
- [ ] Enable audit logging
- [ ] Regular security updates
- [ ] Backup encryption

### Access Control
- Use environment-specific API keys
- Implement proper RLS policies
- Regular audit of user permissions
- Monitor for suspicious activities

## Integration with Frontend

### TanStack Query Integration
The frontend uses TanStack Query for efficient data fetching and caching:

```typescript
// Custom hook for lead data
export const useLeads = () => {
  return useQuery({
    queryKey: ['leads'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('leads')
        .select('*');
      
      if (error) throw error;
      return data;
    }
  });
};
```

### Error Handling
- Comprehensive error boundaries
- User-friendly error messages
- Automatic retry logic for transient failures
- Graceful degradation for offline scenarios

## Monitoring and Maintenance

### Health Checks
- Database connection status
- API response times
- WebSocket connection stability
- Resource usage monitoring

### Maintenance Tasks
- Regular database optimization
- Log rotation and cleanup
- Security patch updates
- Performance monitoring
- Backup verification

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [JWT.io](https://jwt.io/) for token debugging