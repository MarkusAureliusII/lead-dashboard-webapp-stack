# Webapp Technology Stack Documentation

## Overview

This is a modern full-stack web application for lead generation and CRM functionality, built with React, TypeScript, and Supabase. The application provides a comprehensive dashboard for managing leads, scraping jobs, integrations, and user analytics.

## Technology Stack

### Frontend Framework
- **React 18.3.1** - Modern React with hooks, Suspense, and concurrent features
- **TypeScript 5.5.3** - Static type checking and enhanced developer experience
- **Vite 5.4.1** - Fast development server and build tool
- **@vitejs/plugin-react-swc** - Fast React refresh using SWC compiler

### UI Framework & Styling
- **Tailwind CSS 3.4.11** - Utility-first CSS framework
- **Radix UI** - Unstyled, accessible React components
  - @radix-ui/react-dialog, @radix-ui/react-dropdown-menu, etc.
- **shadcn/ui** - Pre-built component library based on Radix UI
- **Lucide React 0.462.0** - Beautiful SVG icons
- **class-variance-authority** - Type-safe variant management
- **tailwind-merge** - Utility for merging Tailwind classes

### State Management & Data Fetching
- **TanStack Query 5.56.2** - Powerful data synchronization for React
- **React Context API** - Global state management for authentication
- **React Hook Form 7.53.0** - Performant, flexible forms
- **Zod 3.23.8** - TypeScript-first schema validation

### Routing & Navigation
- **React Router DOM 6.26.2** - Declarative routing for React

### Database & Backend
- **Supabase 2.50.0** - Backend-as-a-Service with PostgreSQL
  - Authentication & authorization
  - Real-time subscriptions
  - RESTful API
  - Row Level Security (RLS)
- **PostgreSQL** - Self-hosted at `217.154.211.42:8000`

### Development Tools
- **ESLint 9.9.0** - JavaScript/TypeScript linting
- **TypeScript ESLint 8.0.1** - TypeScript-specific linting rules
- **@types/node, @types/react, @types/react-dom** - TypeScript definitions
- **Autoprefixer & PostCSS** - CSS processing

### Additional Libraries
- **Date-fns 3.6.0** - Modern JavaScript date utility library
- **React Day Picker 8.10.1** - Date picker component
- **Recharts 2.12.7** - Chart library built on React components
- **React Resizable Panels 2.1.3** - Resizable layout panels
- **Sonner 1.5.0** - Toast notification system
- **Embla Carousel React** - Touch-friendly carousel
- **CMDK 1.0.0** - Command palette component
- **Input OTP 1.2.4** - One-time password input
- **Vaul 0.9.3** - Drawer component for mobile
- **Next Themes 0.3.0** - Theme switching capability
- **@n8n/chat 0.27.1** - N8N chat widget integration

## Project Structure

```
/opt/webapp-stack/
├── apps/
│   └── frontend/                    # Main React application
│       ├── src/
│       │   ├── components/          # Reusable UI components
│       │   │   ├── ui/             # shadcn/ui components
│       │   │   ├── auth/           # Authentication components
│       │   │   ├── settings/       # Settings page components
│       │   │   ├── lead-agent/     # Lead generation components
│       │   │   ├── personalization/ # Personalization features
│       │   │   └── integrations/   # Integration components
│       │   ├── pages/              # Page-level components
│       │   ├── contexts/           # React Context providers
│       │   ├── hooks/              # Custom React hooks
│       │   ├── lib/                # Utility functions
│       │   ├── services/           # Business logic & API calls
│       │   ├── types/              # TypeScript type definitions
│       │   ├── integrations/       # External integrations
│       │   │   └── supabase/       # Supabase client & types
│       │   └── styles/             # CSS and styling files
│       ├── public/                 # Static assets
│       ├── package.json            # Dependencies and scripts
│       ├── vite.config.ts          # Vite configuration
│       ├── tailwind.config.ts      # Tailwind CSS configuration
│       ├── tsconfig.json           # TypeScript configuration
│       └── components.json         # shadcn/ui component config
├── config/                         # Configuration files
├── docs/                          # Documentation
└── infrastructure/               # Docker and deployment configs
```

## Key Features

### Authentication & Authorization
- Supabase Auth integration with email/password
- Protected routes with authentication guards
- Session management with automatic token refresh
- Row Level Security (RLS) for data access control

### Lead Management
- Lead generation and capture
- CRM functionality for lead tracking
- Lead detail views with full history
- Bulk operations and filtering

### Integrations
- N8N workflow automation
- Webhook configurations
- Mailing list integrations
- Database connections
- Apollo search preview

### Personalization
- Custom lead processing workflows
- Personalization settings and preferences
- Cultural context handling
- Language selection

### Data Visualization
- Statistics and analytics dashboard
- Charts and graphs using Recharts
- Real-time data updates via Supabase subscriptions

### User Interface
- Dark/light theme support
- Responsive design for mobile and desktop
- Accessibility compliance via Radix UI
- Command palette for quick actions
- Toast notifications for user feedback

## Development Workflow

### Scripts
```bash
npm run dev         # Start development server
npm run build       # Build for production
npm run preview     # Preview production build
npm run lint        # Run ESLint
```

### Environment Configuration
- Development: `http://localhost:8080`
- Production: Connected to Supabase at `217.154.211.42:8000`

## Build Configuration

### Vite Configuration
- Server runs on `::` (IPv6) port 8080
- React Fast Refresh enabled
- TypeScript path aliases configured (`@/` → `./src/`)
- Development-only component tagging

### TypeScript Configuration
- Strict mode enabled
- ES2020 target
- Module resolution optimized for Vite
- Path mapping for clean imports

### Tailwind Configuration
- Custom design system with consistent spacing
- Dark mode support
- Animation utilities enabled
- Typography plugin included

## Performance Optimizations

### Code Splitting
- React Router-based route splitting
- Lazy loading of heavy components
- Dynamic imports for large libraries

### Bundle Optimization
- Vite's rollup-based bundling
- Tree shaking for unused code elimination
- CSS purging via Tailwind
- Asset optimization and compression

### Database Optimization
- Efficient queries via TanStack Query
- Real-time subscriptions only where needed
- Pagination for large datasets
- Proper indexing on database level

## Security Considerations

### Authentication Security
- JWT token management via Supabase
- Secure session storage
- Automatic token refresh
- Protected API endpoints

### Data Security
- Row Level Security (RLS) policies
- Input validation via Zod schemas
- XSS protection through React's built-in escaping
- CSRF protection via Supabase CORS configuration

## Deployment

The application is configured for deployment with:
- Docker support for containerized deployment
- Environment variable configuration
- Production build optimization
- Health check endpoints

## Dependencies Summary

### Core Dependencies (18)
- React ecosystem (React, React DOM, React Router)
- TypeScript and build tools (Vite, SWC)
- UI framework (Radix UI components, Tailwind)
- State management (TanStack Query, React Hook Form)
- Backend integration (Supabase)

### Development Dependencies (10)
- Linting and type checking (ESLint, TypeScript)
- Build tools (Vite plugins, PostCSS, Autoprefixer)
- Development utilities (component tagging, globals)

Total package count: 28 core + 10 dev = 38 dependencies, indicating a well-curated, modern tech stack without bloat.