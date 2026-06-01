---
task: backend-reusable-service
date: 2026-05-18
agent: data-analyst
type: requirements
confidence: HIGH
task_file: N/A (Provided in prompt)
last_updated: 2026-05-18 20:55
---

# Data Analysis Report: Backend Reusable Service

## Overview
Analysis of the current AI Agent Preview backend architecture to transform it from a project-specific monolithic server into a reusable, modular service capable of deployment on a VPS and integration with Kiloclaw.

## Original Task Reference
- **Intent**: Transform backend into a reusable service for VPS deployment and Kiloclaw connection.
- **Scope**: Architecture analysis, modularization proposal, API design, VPS integration strategy, and deployment roadmap.

## Input Sources Referenced
| Source | File | Items Used |
|--------|------|------------|
| Task | Prompt | Intent, scope, constraints |
| Explore | output/explore/2026-05-18_backend-explore.md | Directory structure, component mapping, entry points |
| Collector | output/collector/2026-05-18_backend-collector.md | Code snippets (index.ts, openclawClient.ts), dependencies |

## Memory Relevance Validation
| Record Path | Status | Justification |
|-------------|--------|----------------|
| MEMORY.md | ✅ Relevant | Confirmed project identity as "Middleware for OpenClaw runtime" |

## Summary
The current backend is a well-structured Express.js application but is functionally monolithic. It is tightly coupled to its local file system, a specific database schema, and a mocked runtime client. To make it "reusable", it must transition to a **Provider-based Architecture** where external dependencies (Storage, Runtime, Auth) are abstracted behind interfaces.

## Requirements
- **Modularity**: Decouple core business logic from infrastructure (DB, Storage, Runtime).
- **Portability**: Ensure the service can run in any environment (Docker/VPS).
- **Extensibility**: Allow easy addition of new runtime providers (e.g., switching from OpenClaw to KiloClaw).
- **Security**: Implement a robust API authentication mechanism for external service connection.
- **Scalability**: Design for stateless operation to allow horizontal scaling.

## Proposed Architecture
### Modular Layered Design
1. **API Layer (Transport)**: Express.js / Socket.io. Handles HTTP/WS requests, validation (Zod), and response formatting.
2. **Service Layer (Core Logic)**: Orchestrates business processes. Agnostic of where data comes from or where it goes.
3. **Adapter Layer (Infrastructure)**:
    - `IRuntimeProvider`: Interface for workspace provisioning/ingestion (OpenClaw, KiloClaw).
    - `IStorageProvider`: Interface for file handling (Local, S3, Azure).
    - `IAuthProvider`: Interface for identity management (JWT, API Key, OAuth2).
4. **Data Layer**: Sequelize/MySQL for persistence.

### Architecture Diagram (Text-Based)
```
[ External Clients / Kiloclaw ] 
       │ (HTTPS / WSS)
       ▼
[ API Layer (Express/Socket.io) ] ◄─── [ Auth Adapter ]
       │
       ▼
[ Service Layer (Core Business Logic) ]
       │
       ├───────► [ Runtime Adapter ] ──────► [ OpenClaw / KiloClaw API ]
       ├───────► [ Storage Adapter ] ──────► [ Local FS / S3 / Cloud ]
       └───────► [ Data Access Layer ] ────► [ MySQL Database ]
```

## Key Findings

### Finding 1: High Coupling in Runtime Integration [Confidence: HIGH]
- **Evidence**: `openclawClient.ts` is implemented as a concrete class used directly in services.
- **Implication**: Changing the runtime or supporting multiple runtimes requires modifying core service code.
- **Recommendation**: Implement a `RuntimeProvider` interface and a Factory pattern to instantiate the correct provider based on configuration.

### Finding 2: Local File System Dependency [Confidence: HIGH]
- **Evidence**: `backend/uploads` directory and Multer configuration are local.
- **Implication**: Not suitable for VPS deployments with multiple instances (load balancing) or ephemeral containers.
- **Recommendation**: Abstract storage via a `StorageProvider` interface and implement an S3-compatible adapter.

### Finding 3: Monolithic Configuration [Confidence: MEDIUM]
- **Evidence**: Reliance on a single `.env` file with basic key-value pairs.
- **Implication**: Difficult to manage different environments (dev, staging, prod) or multi-tenant configurations.
- **Recommendation**: Move to a hierarchical configuration system (e.g., `convict` or `config` package) supporting YAML/JSON and environment overrides.

## Files to Modify
- `backend/src/index.ts` (Entry point reorganization)
- `backend/src/services/openclawClient.ts` (Convert to Adapter)
- `backend/src/services/` (Create new interfaces and factories)
- `backend/src/middleware/` (Enhance auth for API keys)
- New: `backend/src/providers/` (Directory for Runtime, Storage, and Auth adapters)
- New: `Dockerfile`, `docker-compose.yml`

## Implementation Order
1. **Abstraction Layer**: Define interfaces for Runtime, Storage, and Auth.
2. **Provider Implementation**: Refactor `openclawClient` into an `OpenClawProvider`.
3. **Infrastructure Decoupling**: Implement S3/Cloud storage adapter.
4. **API Hardening**: Implement API Key authentication for external service access.
5. **Containerization**: Create Dockerfile and Compose configurations.
6. **VPS Pipeline**: Set up CI/CD and Nginx reverse proxy.

## Risks
- **Breaking Changes**: Refactoring the core service layer may break existing API endpoints.
- **Performance Overhead**: Adding abstraction layers can introduce slight latency, though negligible for this use case.
- **Migration Complexity**: Moving from local storage to S3 requires a data migration strategy for existing uploads.

## Recommendations
1. **Implement OpenAPI/Swagger**: As the service becomes "reusable", clear documentation is mandatory for other teams/projects to consume the API.
2. **Health Check Enhancement**: Expand `/api/health` to include dependency checks (DB status, Runtime API status).
3. **Structured Logging**: Replace `console.log` with a library like `winston` or `pino` for better log management on VPS (ELK/Loki).

---
*Generated: 2026-05-18 20:55*
*Last Updated: 2026-05-18 20:55*
