---
task: ai-agent-preview-implementation-plan-pt1
date: 2026-05-17
agent: data-analyst-free
type: plan
based_on: analysis/2026-05-17_ai-agent-preview-simple-analysis.md
status: draft
---

# Implementation Plan — Part 1 (Phases 1 & 2)

## Current State

Greenfield project at `D:\Portfolio\AI-Agent-Preview`. Zero application code exists. Only the PRD document and exploration/analysis files are present.

## Target State for Part 1

Phase 1 & 2 implemented: project scaffolded, database initialized, auth functional, workspace CRUD operational, knowledge upload pipeline working.

---

# Phase 1: Core API & Database

## Priority: CRITICAL — Foundation layer, everything depends on this.

### Tasks

| # | Task | Description | Dependencies |
|---|------|-------------|--------------|
| 1.1 | Init project structure | Create `backend/` (Express) and `frontend/` (React+Vite) directories, `package.json`, `tsconfig.json`, `.env`, `.gitignore` | None |
| 1.2 | Database migration | Create `backend/src/db/migrations/` with SQL for 5 tables: `users`, `workspaces`, `knowledge_files`, `providers`, `audit_logs`. Run initial migration. | 1.1 |
| 1.3 | DB connection & models | Set up Sequelize/Knex ORM, define model files for each table, connection config in `.env`. | 1.2 |
| 1.4 | Auth module | Implement POST `/api/auth/login`, JWT generation (access + refresh token), bcrypt password hashing, middleware for route protection. | 1.3 |
| 1.5 | User seed & basic RBAC | Seed an admin user, implement `role`-based guard middleware (`admin`, `user`, `developer`). | 1.4 |
| 1.6 | Audit logging middleware | Express middleware that logs authenticated requests to `audit_logs` table (action, user_id, ip, payload). | 1.3 |
| 1.7 | Error handling & validation | Global error handler middleware, request validation schemas (Joi/Zod) for all endpoints. | 1.1 |
| 1.8 | Provider management CRUD | Admin-only endpoints: `POST /api/admin/provider`, `GET /api/admin/providers`, `PUT /api/admin/provider/:id`, `DELETE /api/admin/provider/:id`. AES-256 encryption for API keys. | 1.4, 1.5 |

### Verification (Phase 1)

1. `npm run migrate` creates all 5 tables in MySQL without errors.
2. `POST /api/auth/login` returns valid JWT for seeded admin user.
3. Protected routes reject requests without valid JWT (401).
4. RBAC middleware rejects `user` role from accessing admin endpoints (403).
5. Provider CRUD: admin can add/list/update/delete providers; API key stored encrypted.
6. Audit logs populate on every authenticated request.
7. All validation errors return consistent `{ error, details }` format.

---

# Phase 2: Workspace & Knowledge Management

## Priority: HIGH — Core business logic, directly enables sandbox (Phase 3).

### Tasks

| # | Task | Description | Dependencies |
|---|------|-------------|--------------|
| 2.1 | Workspace CRUD API | `GET /api/workspaces`, `POST /api/workspaces`, `PUT /api/workspaces/:id`, `DELETE /api/workspaces/:id` (soft delete). Owner-based access: users see only their own workspaces. | 1.4, 1.5 |
| 2.2 | OpenClaw workspace provisioning | On workspace creation, call OpenClaw API to create project/agent. Store returned `openclaw_workspace_id`. Handle failure gracefully (rollback DB record). | 2.1 |
| 2.3 | Knowledge upload endpoint | `POST /api/knowledge/upload` — accept multipart file (PDF/TXT/DOCX/MD), validate type and size, save to disk temporarily. | 2.1 |
| 2.4 | OpenClaw ingestion forwarding | After file save, call OpenClaw ingestion API with file. Store `openclaw_reference_id` in `knowledge_files` table. Update status: `pending` → `processing` → `ready` / `failed`. | 2.3 |
| 2.5 | Knowledge list endpoint | `GET /api/knowledge/:workspaceId` — return uploaded files with status per workspace. | 2.1, 2.4 |
| 2.6 | File cleanup job | Cron/scheduled task to remove temp uploaded files older than 24h. | 2.3 |
| 2.7 | Workspace-scoped provider resolution | Logic to resolve which provider + model a workspace uses (from `workspaces.provider` + `workspaces.model`). Prepares for sandbox chat. | 2.1 |
| 2.8 | Integration middleware stubs | Stub `POST /api/ai/:workspaceSlug/chat` returning `{ "response": "Integration endpoint ready", "session_id": null }`. Full implementation in Phase 3. | 2.1 |

### Verification (Phase 2)

1. Workspace CRUD: create, list, update, soft delete a workspace. Deleted workspaces excluded from list.
2. User A cannot see or modify User B's workspaces (owner isolation).
3. Workspace creation calls OpenClaw stub/simulated API; DB stores returned ID.
4. Upload PDF/TXT file → record created in `knowledge_files` with `pending` status.
5. Simulated OpenClaw ingestion updates status to `ready` with a reference ID.
6. Knowledge list returns files scoped to workspace, sorted by upload date.
7. `/api/ai/:workspaceSlug/chat` returns 200 with placeholder response.

---

## Dependencies

- **Node.js 18+** and **npm** installed on dev machine.
- **MySQL 8** instance running locally (or Docker container).
- **OpenClaw/KiloClaw** API available (or mock/stub for development).
- Environment variables: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASS`, `JWT_SECRET`, `JWT_REFRESH_SECRET`, `ENCRYPTION_KEY`, `OPENCLAW_API_URL`, `OPENCLAW_API_KEY`.

## Blockers / Challenges

| Blocker | Solution |
|---------|----------|
| OpenClaw API may not be available during dev | Create a mock OpenClaw client module that logs calls and returns fake responses. Swappable via config. |
| File upload size limits | Configure multer with 10MB limit per PRD; reject oversized files with clear error. |
| Encrypted API key searchability | Store encrypted keys only; decryption happens at runtime when making API calls to provider. No plaintext search needed. |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| OpenClaw API contract changes | Medium | High | Abstract all OpenClaw calls behind `OpenClawClient` interface; only one file to update if API changes. |
| File format parsing errors | Low | Medium | Validate file extension + MIME type before accepting upload. Reject unsupported formats upfront. |
| Race condition on workspace creation | Low | High | Use DB transaction: create workspace record + call OpenClaw in transaction; rollback on failure. |
| JWT token expiry UX | Medium | Low | Implement refresh token flow; frontend auto-refreshes before expiry. |

## Next Steps

1. Create project scaffolding: `backend/` + `frontend/` directories, package.json files.
2. Write and run database migration SQL against local MySQL.
3. Implement auth module (login, JWT, middleware).
4. Implement workspace CRUD endpoints.
5. Implement knowledge upload + OpenClaw forwarding.
6. Build stub integration middleware endpoint.

---
*Generated: 2026-05-17 13:00 WIB*