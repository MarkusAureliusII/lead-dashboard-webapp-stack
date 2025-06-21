# System Architecture Documentation

## Overview

This document describes the architecture of the Lead Generation and CRM Web Application, including component relationships, data flow, and system interactions.

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Supabase      │    │   External      │
│   React App     │◄──►│   Backend       │◄──►│   Services      │
│   (Port 8080)   │    │   (Port 8000)   │    │   (N8N, etc.)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Frontend Architecture

### Component Hierarchy

```
App
├── QueryClientProvider (TanStack Query)
├── AuthProvider (Authentication Context)
├── TooltipProvider (UI Framework)
├── BrowserRouter (Routing)
│   └── Routes
│       ├── Auth (Public Route)
│       └── ProtectedRoute (Authenticated Routes)
│           ├── Index (Dashboard)
│           ├── LeadAgent (Lead Generation)
│           ├── Personalization (Settings)
│           ├── LeadDetail (Individual Lead)
│           ├── Crm (CRM Dashboard)
│           ├── ScrapingJobs (Job Management)
│           ├── Integrations (External Services)
│           ├── Statistics (Analytics)
│           └── Settings (User Preferences)
└── Toast Systems (Notifications)
```

### State Management Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     State Management                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   TanStack      │  │   React         │  │   Local      │ │
│  │   Query         │  │   Context       │  │   State      │ │
│  │                 │  │                 │  │              │ │
│  │ • Server State  │  │ • Auth State    │  │ • UI State   │ │
│  │ • API Caching   │  │ • User Data     │  │ • Forms      │ │
│  │ • Mutations     │  │ • Global Config │  │ • Modals     │ │
│  │ • Invalidation  │  │                 │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow Architecture

### Authentication Flow

```
1. User Login Request
   ↓
2. Supabase Auth Validation
   ↓
3. JWT Token Generation
   ↓
4. AuthContext State Update
   ↓
5. Protected Route Access Granted
   ↓
6. TanStack Query Authorization Headers
```

### Data Fetching Flow

```
1. Component Mount/User Action
   ↓
2. TanStack Query Hook Execution
   ↓
3. Supabase Client API Call
   ↓
4. Database Query with RLS
   ↓
5. Data Response & Caching
   ↓
6. Component Re-render
   ↓
7. UI Update
```

### Real-time Updates Flow

```
1. Database Change (Insert/Update/Delete)
   ↓
2. Supabase Realtime Trigger
   ↓
3. WebSocket Message to Client
   ↓
4. TanStack Query Cache Invalidation
   ↓
5. Automatic Re-fetch
   ↓
6. UI Update
```

## Backend Architecture (Supabase)

### Database Schema Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     auth        │    │     public      │    │    storage      │
│                 │    │                 │    │                 │
│ • users         │    │ • leads         │    │ • buckets       │
│ • sessions      │    │ • scrape_jobs   │    │ • objects       │
│ • user_metadata │    │ • webhook_settings    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Row Level Security (RLS) Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    RLS Policy Structure                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Table: leads                                               │
│  ├── SELECT: Public read access                            │
│  ├── INSERT: Authenticated users only                      │
│  ├── UPDATE: Owner only (user_id = auth.uid())            │
│  └── DELETE: Owner only (user_id = auth.uid())            │
│                                                             │
│  Table: scrape_jobs                                         │
│  ├── SELECT: Owner only (user_id = auth.uid())            │
│  ├── INSERT: Authenticated users only                      │
│  └── UPDATE: Owner only (user_id = auth.uid())            │
│                                                             │
│  Table: webhook_settings                                    │
│  ├── SELECT: Owner only (user_id = auth.uid())            │
│  ├── INSERT: Authenticated users only                      │
│  ├── UPDATE: Owner only (user_id = auth.uid())            │
│  └── DELETE: Owner only (user_id = auth.uid())            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Page-Level Components

```
┌─────────────────────────────────────────────────────────────┐
│                     Page Components                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Index           • Dashboard overview                       │
│  │               • Quick stats & metrics                    │
│  │               • Recent activity feed                     │
│                                                             │
│  LeadAgent       • Lead generation interface                │
│  │               • Target audience configuration            │
│  │               • Personalization settings                 │
│                                                             │
│  CRM             • Lead management table                    │
│  │               • Lead status tracking                     │
│  │               • Bulk operations                          │
│                                                             │
│  Settings        • User preferences                         │
│  │               • Integration configurations               │
│  │               • Notification settings                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Feature-Based Component Organization

```
components/
├── ui/              # Base shadcn/ui components
│   ├── button.tsx
│   ├── dialog.tsx
│   ├── form.tsx
│   └── ...
├── auth/            # Authentication components
│   ├── AuthForm.tsx
│   ├── ProtectedRoute.tsx
│   └── SignInForm.tsx
├── lead-agent/      # Lead generation features
│   ├── LeadGenerationForm.tsx
│   ├── TargetAudienceForm.tsx
│   └── PersonalizationForm.tsx
├── settings/        # Settings components
│   ├── ProfileSettings.tsx
│   ├── IntegrationSettings.tsx
│   └── WebhookSettings.tsx
└── integrations/    # External integrations
    ├── DatabaseConnections.tsx
    ├── WebhookConfigurations.tsx
    └── MailingListIntegrations.tsx
```

## Service Layer Architecture

### Service Organization

```
services/
├── n8n/                     # N8N integration service
│   ├── N8nService.ts       # Main service class
│   ├── EnhancedN8nService.ts # Enhanced functionality
│   ├── responseParser.ts   # Response handling
│   ├── types.ts           # Type definitions
│   ├── validators/        # Input validation
│   ├── utils/            # Utilities
│   └── tests/            # Service tests
└── batchProcessing.ts     # Batch operation handling
```

### Service Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                   Service Layer Duties                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  N8nService                                                 │
│  ├── Workflow automation                                    │
│  ├── Chat widget integration                               │
│  ├── Health monitoring                                     │
│  └── Error handling & recovery                             │
│                                                             │
│  BatchProcessing                                            │
│  ├── Bulk lead operations                                  │
│  ├── Data import/export                                    │
│  ├── Queue management                                      │
│  └── Progress tracking                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Integration Architecture

### External Service Integrations

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      N8N        │    │     Apollo      │    │   Webhooks      │
│   Automation    │    │    Search       │    │   External      │
│                 │    │                 │    │   Services      │
│ • Workflows     │    │ • Lead Search   │    │ • Notifications │
│ • Chat Widget   │    │ • Data Preview  │    │ • Data Sync     │
│ • Triggers      │    │ • Validation    │    │ • Events        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                               │
                    ┌─────────────────┐
                    │   Frontend      │
                    │   React App     │
                    └─────────────────┘
```

### Data Synchronization

```
Frontend State ◄─► TanStack Query Cache ◄─► Supabase API ◄─► PostgreSQL
     │                      │                    │              │
     │                      │                    │              │
     └─ UI Updates          └─ Automatic         └─ Real-time   └─ Data
        Real-time              Invalidation        Subscriptions    Persistence
```

## Security Architecture

### Authentication & Authorization Layers

```
┌─────────────────────────────────────────────────────────────┐
│                   Security Layers                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Frontend Protection                                        │
│  ├── ProtectedRoute Components                             │
│  ├── AuthContext State Validation                          │
│  └── Conditional UI Rendering                              │
│                                                             │
│  API Layer Protection                                       │
│  ├── JWT Token Validation                                  │
│  ├── Supabase Auth Middleware                             │
│  └── CORS Configuration                                    │
│                                                             │
│  Database Protection                                        │
│  ├── Row Level Security (RLS)                             │
│  ├── Policy-based Access Control                          │
│  └── SQL Injection Prevention                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Performance Architecture

### Optimization Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                Performance Optimizations                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Frontend Optimizations                                     │
│  ├── React Router Code Splitting                           │
│  ├── TanStack Query Caching                               │
│  ├── Lazy Component Loading                                │
│  └── Vite Bundle Optimization                              │
│                                                             │
│  Backend Optimizations                                      │
│  ├── Database Query Optimization                           │
│  ├── Connection Pooling                                    │
│  ├── Real-time Subscription Management                     │
│  └── API Response Caching                                  │
│                                                             │
│  Build Optimizations                                        │
│  ├── Tree Shaking (Unused Code)                           │
│  ├── CSS Purging (Tailwind)                               │
│  ├── Asset Compression                                     │
│  └── Bundle Splitting                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

### Development vs Production

```
Development Environment:
├── Local Vite Dev Server (Port 8080)
├── Local Supabase Instance (Port 8000)
├── Hot Module Replacement (HMR)
└── Development Tools & Debugging

Production Environment:
├── Built React Application (Static Files)
├── Supabase Production Instance
├── CDN Asset Delivery
└── Production Monitoring & Logging
```

## Error Handling Architecture

### Error Boundary Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                   Error Handling Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Component Level                                            │
│  ├── React Error Boundaries                                │
│  ├── TanStack Query Error States                           │
│  └── Form Validation Errors                                │
│                                                             │
│  Service Level                                              │
│  ├── API Error Handling                                    │
│  ├── Network Error Recovery                                │
│  └── Authentication Error Handling                         │
│                                                             │
│  Global Level                                               │
│  ├── Toast Notifications                                   │
│  ├── Error Logging                                         │
│  └── Fallback UI Components                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

This architecture provides a scalable, maintainable, and secure foundation for the lead generation and CRM application, with clear separation of concerns and well-defined data flows.