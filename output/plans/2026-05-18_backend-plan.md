---
task: backend-reusable-service
date: 2026-05-18
agent: data-analyst
type: plan
based_on: analysis/2026-05-18_backend-analysis.md
---

# Implementation Plan: Backend Reusable Service

## Current State
- Monolithic Express.js application.
- Tightly coupled to local file system (`/uploads`).
- Tightly coupled to a mocked OpenClaw client.
- Basic JWT authentication.
- Manual deployment (not containerized).

## Target State
- Modular, provider-based architecture.
- Abstracted storage (Cloud/S3 compatible).
- Pluggable runtime providers (OpenClaw/KiloClaw).
- API Key + JWT hybrid authentication.
- Fully containerized (Docker) or standalone Node.js deployment, deployable via CI/CD to VPS.

## Steps

### Phase 1: Architecture Decoupling (The "Provider" Pattern)
1. **Define Interfaces**: 
   - Create `backend/src/providers/types.ts` containing `IRuntimeProvider`, `IStorageProvider`, and `IAuthProvider`.
2. **Refactor Runtime**:
   - Move `OpenClawClient` logic to `backend/src/providers/runtime/OpenClawProvider.ts`.
   - Create a `RuntimeFactory` to return the active provider based on `process.env.RUNTIME_PROVIDER`.
3. **Refactor Storage**:
   - Create `backend/src/providers/storage/LocalStorageProvider.ts` (for backward compatibility).
   - Create `backend/src/providers/storage/S3StorageProvider.ts`.
   - Update `ingestionService.ts` to use `StorageProvider` instead of direct FS calls.
4. **Refactor Auth**:
   - Implement an `ApiKeyProvider` to allow external services (like Kiloclaw) to connect without user-level JWTs.

### Phase 2: API Hardening & Documentation
1. **API Key Implementation**:
   - Add `api_keys` table to MySQL.
   - Create `authApiKey.ts` middleware to validate requests from external services.
2. **Swagger Integration**:
   - Install `swagger-jsdoc` and `swagger-ui-express`.
   - Document all endpoints in `backend/src/routes/`.
3. **Enhanced Health Checks**:
   - Update `/api/health` to check DB and active Runtime Provider connectivity.

### Phase 3: Deployment Readiness (Containerized & Standalone)
1. **Dockerization**:
   - Create a multi-stage `Dockerfile` (Build stage with TS -> Runtime stage with JS).
   - Create `docker-compose.yml` including `backend` and `mysql` services.
2. **Standalone Node.js Setup**:
   - Define environment requirements: Node.js LTS (>= 20.x).
   - Implement a production startup script using PM2 (Process Manager 2) for automatic restarts and cluster mode.
   - Document manual deployment steps: `npm install` -> `npm run build` -> `pm2 start dist/index.js`.
3. **Environment Management**:
   - Create `.env.example` with all required keys.
   - Implement a config validator (using Zod) to ensure the server doesn't start with missing critical env vars.
4. **Network Setup**:
   - Design Nginx configuration for SSL termination and reverse proxying to either the Docker container or the PM2 process.

### Phase 4: Deployment & Integration
1. **CI/CD Pipeline**:
   - Setup GitHub Actions to build Docker image and push to a registry (GHCR/DockerHub).
   - Add a deployment step to SSH into VPS and `docker-compose pull && docker-compose up -d`.
2. **Kiloclaw Integration**:
   - Configure Kiloclaw to connect to the VPS endpoint using the newly created API Key.
3. **E2E Verification**:
   - Run the UAT simulation against the VPS deployment.

## Dependencies
- **Node.js**: LTS (>= 20.x) required for standalone runs.
- **PM2**: Process manager for standalone production deployments.
- **Docker**: Required for containerization.
- **S3 Compatible Storage**: (AWS S3, MinIO, or DigitalOcean Spaces) for cloud storage.
- **VPS**: Linux server with Docker, Nginx, and/or Node.js installed.

## Blockers/Challenges
| Blocker | Solution |
|---------|----------|
| Data Migration | Create a script to move local `/uploads` to S3 during the first deployment. |
| Runtime API Changes | Use the Adapter pattern to wrap API changes without affecting business logic. |
| Secret Management | Use Docker Secrets or a secure `.env` management tool on VPS. |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| API Breaking Changes | Medium | High | Maintain versioned routes (e.g., `/api/v1/`) during the transition. |
| VPS Security | Medium | High | Implement a strict firewall (UFW), use SSH keys, and keep Nginx updated. |
| Provider Latency | Low | Medium | Implement caching for frequent runtime lookups. |

## Next Steps
1. Initialize the `backend/src/providers/` directory.
2. Implement the `IRuntimeProvider` interface.
3. Refactor `OpenClawClient` into the new provider structure.

---
*Generated: 2026-05-18 21:00*
*Last Updated: 2026-05-18 21:00*
