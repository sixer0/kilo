---
task: backend-explore
date: 2026-05-18
agent: explore
scope: Backend components mapping
---

# Project Exploration Report

## Overview
Exploration of backend components in the AI Agent Preview project, focusing on server-side architecture, API routes, services, database models, and configuration files.

## Directory Structure

### Directories Found
| Path | Purpose | Status |
|------|---------|--------|
| backend/ | Root backend directory | EXISTING |
| backend/src/ | Source code directory | EXISTING |
| backend/src/routes/ | API route definitions | EXISTING |
| backend/src/controllers/ | Request handlers | EXISTING |
| backend/src/services/ | Business logic services | EXISTING |
| backend/src/middleware/ | Express middleware | EXISTING |
| backend/src/websocket/ | WebSocket server implementation | EXISTING |
| backend/src/db/ | Database models and migrations | EXISTING |
| backend/src/cron/ | Scheduled tasks | EXISTING |
| backend/uploads/ | File upload storage | EXISTING |
| backend/uploads/tmp/ | Temporary file storage | EXISTING |
| backend/node_modules/ | Dependencies | EXISTING |

### Entry Points Identified
- `backend/src/index.ts` - Main application entry point
- `backend/src/db/migrations/run.ts` - Database migration runner
- `backend/src/db/check.ts` - Database connection checker
- `backend/src/db/seed.ts` - Database seeder
- `backend/src/cron/cleanup.ts` - Cleanup cron job
- `backend/seed-providers.js` - Provider data seeder

### Configuration Files
- `backend/package.json` - Dependencies and scripts
- `backend/tsconfig.json` - TypeScript configuration
- `backend/.env` (implied from dotenv usage) - Environment variables

### Naming Conventions
- Routes: camelCase with .ts extension (e.g., `authRoutes.ts`)
- Controllers: camelCase with Controller suffix (e.g., `authController.ts`)
- Services: camelCase with Service suffix (e.g., `authService.ts`)
- Middleware: camelCase (e.g., `auth.ts`, `validate.ts`)
- Models: PascalCase (e.g., `User.ts`)
- Migrations: numbered prefix with description (e.g., `001_create_users.sql`)
- WebSocket: descriptive names (e.g., `server.ts`, `sessionManager.ts`)

## File Type Summary
| Extension | Count | Purpose |
|-----------|-------|---------|
| .ts | 25 | TypeScript source files |
| .js | 2 | JavaScript files (seeders) |
| .sql | 5 | Database migration files |
| .json | 2 | Configuration files |
| .log | 2 | Server logs |

## Backend Components Detail

### Routes (API Endpoints)
- `authRoutes.ts` - Authentication endpoints
- `providerRoutes.ts` - Provider management endpoints
- `knowledgeRoutes.ts` - Knowledge base endpoints
- `workspaceRoutes.ts` - Workspace management endpoints
- `aiRoutes.ts` - AI integration endpoints

### Controllers
- `authController.ts` - Authentication logic
- `providerController.ts` - Provider management logic
- `knowledgeController.ts` - Knowledge base logic
- `workspaceController.ts` - Workspace management logic

### Services
- `authService.ts` - Authentication business logic
- `providerService.ts` - Provider management logic
- `ingestionService.ts` - Data ingestion logic
- `encryptionService.ts` - Encryption/decryption logic
- `openclawClient.ts` - OpenClaw runtime integration
- `apiError.ts` - Custom error handling utility

### Middleware
- `auth.ts` - JWT authentication middleware
- `validate.ts` - Request validation middleware (Zod)
- `errorHandler.ts` - Centralized error handling
- `auditLogger.ts` - Audit logging middleware
- `roleGuard.ts` - Role-based access control
- `multer.ts` - File upload handling

### WebSocket Components
- `server.ts` - WebSocket server setup
- `sessionManager.ts` - Client session management
- `auth.ts` - WebSocket authentication

### Database Layer
- Models: User, Provider, Workspace, KnowledgeFile, AuditLog
- Migrations: 5 SQL files for table creation
- Index: Database connection and utilities
- Check: Database connectivity verification
- Seed: Initial data population
- Migrations runner: Execute database migrations

### Cron Jobs
- `cleanup.ts` - Scheduled cleanup tasks

## Gaps / Needs Investigation
- No explicit `.env` file visible in listing (likely gitignored)
- No API documentation (OpenAPI/Swagger) visible
- No test directory visible for backend unit/integration tests
- No Dockerfile or deployment configuration visible