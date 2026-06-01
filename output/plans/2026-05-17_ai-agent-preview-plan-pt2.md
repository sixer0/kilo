---
task: ai-agent-preview-implementation-plan-pt2
date: 2026-05-17
agent: data-analyst-free
type: plan
based_on: analysis/2026-05-17_ai-agent-preview-simple-analysis.md
part: 2
phases: 3-4
status: draft
---

# Implementation Plan — Part 2 (Phases 3 & 4)

## Current State After Part 1

Phase 1 & 2 complete: project scaffolded (backend + frontend), MySQL 5 tables migrated, auth with JWT + RBAC functional, workspace CRUD + OpenClaw provisioning operational, knowledge upload pipeline working, integration middleware stubs exist.

## Target State for Part 2

Phase 3 & 4 deployed: sandbox realtime chat via WebSocket streaming to OpenClaw, full integration middleware with session persistence, and complete React frontend covering all 6 navigation sections (Dashboard, Workspaces, Sandbox, Knowledge, Integrations, Audit Logs).

---

# Phase 3: Sandbox & AI Integration

## Priority: HIGH — Core differentiating feature; enables MVP acceptance criteria #3, #4, #5.

### Tasks

| # | Task | Description | Dependencies |
|---|------|-------------|--------------|
| 3.1 | WebSocket server setup | Install `ws` library, create `backend/src/ws/` module. Authenticate connections via JWT query param. Handle connect/disconnect lifecycle. Track active sessions per workspace. | 1.4 (JWT middleware) |
| 3.2 | OpenClaw streaming proxy | On WS message `{ type: "message", content }`, call OpenClaw streaming API. Forward each token chunk as `{ type: "token", data: chunk }`. Handle streaming errors and timeouts. | 3.1, 2.7 (provider resolution) |
| 3.3 | Message persistence | On WS disconnect or `done` event, save full conversation to `chat_sessions` and `chat_messages` tables. New DB migration required. Include workspace + user context. | 3.2, 1.2 (DB migration infra) |
| 3.4 | Session history retrieval | REST endpoint `GET /api/workspaces/:id/sessions` returning past conversations. Support pagination and date filtering. | 3.3 |
| 3.5 | Source grounding & tool preview | Parse OpenClaw response metadata. Forward `{ type: "source", data: { references: [...] } }` and `{ type: "tool", data: { action: "..." } }` to client. | 3.2 |
| 3.6 | Full integration middleware | Implement `POST /api/ai/:workspaceSlug/chat` — resolve workspace by slug, call OpenClaw (non-streaming), return `{ response, sources, session_id }`. No WebSocket needed for internal apps. | 2.2 (OpenClaw provisioning), 2.8 (stub) |
| 3.7 | Webhook bridge | Accept `POST /api/ai/:workspaceSlug/webhook` — queued message processing. Respond with 202 immediately. Optional callback URL for async delivery. | 3.6 |
| 3.8 | Rate limiting | Apply `express-rate-limit` on integration endpoints: 60 req/min per workspace for middleware, 10 concurrent WS connections per user for sandbox. | 3.6, 3.1 |
| 3.9 | Chat sessions DB migration | New table `chat_sessions` (id, workspace_id, user_id, created_at) and `chat_messages` (id, session_id, role: user/assistant, content, sources JSON, created_at). | 1.2 |

### Verification (Phase 3)

1. WebSocket connects with valid JWT; rejects without (401).
2. Sending a message streams tokens back via WS (`type: token`).
3. On stream completion, `type: done` fires with full response.
4. Source references and tool actions are emitted as separate event types.
5. Disconnect and reconnect retrieves previous session history.
6. `GET /api/workspaces/:id/sessions` returns paginated chat history.
7. `POST /api/ai/:workspaceSlug/chat` returns structured response.
8. Webhook endpoint returns 202 and processes asynchronously.
9. Rate limiter blocks requests exceeding threshold with 429.

---

# Phase 4: UI/UX

## Priority: HIGH — User-facing layer; all phases 1-3 APIs are invisible without it.

### Tasks

| # | Task | Description | Dependencies |
|---|------|-------------|--------------|
| 4.1 | Frontend scaffold | Create `frontend/` with React + Vite + TypeScript. Set up routing (react-router-dom), global state (React Context or Zustand), Axios HTTP client. | 1.1 (project structure) |
| 4.2 | Login page | `/login` — email/password form, JWT storage in httpOnly cookie or localStorage, redirect to dashboard. Error handling for invalid credentials. | 4.1, 1.4 |
| 4.3 | App shell & navigation | Persistent sidebar/layout with 6 nav items: Dashboard, Workspaces, Sandbox, Knowledge, Integrations, Audit Logs. Responsive. Role-based menu hiding (Audit Logs, Integrations → admin/developer only). | 4.1 |
| 4.4 | Dashboard page | `/dashboard` — summary cards: active workspaces count, recent sessions, provider status. Quick-action buttons (Create Workspace, Open Sandbox). | 4.3, 2.1, 3.4 |
| 4.5 | Workspace list page | `/workspaces` — table of workspaces (name, provider, model, status, created). Search/filter. Create button opens modal with form (name, provider dropdown, model, system prompt textarea, channel checkboxes). | 4.3, 2.1 |
| 4.6 | Workspace detail page | `/workspaces/:id` — view/edit workspace config. Delete (soft) with confirmation dialog. Linked knowledge files and recent sessions shown. | 4.5, 2.1 |
| 4.7 | Sandbox chat page | `/sandbox/:workspaceId` — realtime chat UI. Message list (user + AI bubbles), text input, send button. Loading indicator during stream. Markdown rendering for AI responses. Source grounding panel (collapsible sidebar showing document references). Tool action log. Session selector dropdown to browse past conversations. | 4.3, 3.1-3.5 |
| 4.8 | Knowledge management page | `/knowledge/:workspaceId` — file upload area (drag & drop + file picker). File list table (name, type, status, upload date). Status badges: pending (yellow), processing (blue), ready (green), failed (red). Delete file option. | 4.3, 2.3-2.5 |
| 4.9 | Integrations page | `/integrations` — for each workspace, show endpoint URL, curl example, and API key info. Webhook setup form. Copy-to-clipboard for endpoint URLs. | 4.3, 3.6-3.7 |
| 4.10 | Provider management page (admin) | `/admin/providers` — table of providers (name, enabled/disabled, default badge). Add/edit form (name, API key, enabled toggle, set default). API key field masked after save. | 4.3, 1.8 |
| 4.11 | Audit log viewer | `/audit-logs` — paginated table of actions (timestamp, user, action, IP). JSON payload expandable. Date range filter. Export to CSV. | 4.3, 1.6 |
| 4.12 | WebSocket client hook | Custom React hook `useWebSocket(workspaceId, jwt)` managing connection lifecycle, auto-reconnect, message dispatch to state. Used by Sandbox page. | 4.7, 3.1 |
| 4.13 | API client module | Axios instance with interceptors: attach JWT header, handle 401 by refreshing token, redirect to login on refresh failure. Base URL from env var. | 4.1 |
| 4.14 | UI polish & error states | Loading skeletons, empty states ("No workspaces yet"), error toasts, 404 page, form validation feedback. Consistent styling via CSS modules or Tailwind. | 4.1-4.13 |

### Verification (Phase 4)

1. Login flow: valid credentials → dashboard; invalid → error message.
2. Sidebar navigation renders all 6 menu items; admin-only items hidden for non-admin.
3. Dashboard shows correct summary counts from API.
4. Workspace CRUD: create via modal, edit in detail page, soft delete with confirmation.
5. Sandbox: connect to WS, send message, see token stream in real-time, sources panel populates.
6. Knowledge: upload file, see status transition (pending → processing → ready).
7. Integrations page: copy endpoint URL, see curl example for selected workspace.
8. Provider management: admin adds/edits provider, API key masked after save.
9. Audit logs: paginated table with date filters, payload expandable.
10. Loading states, error messages, and empty states render correctly across all pages.
11. Token refresh works seamlessly (no redirect on page navigation during session).
12. Responsive layout: sidebar collapses on mobile, content area adjusts.

---

## Dependencies

- **OpenClaw/KiloClaw** streaming API accessible (or mock for dev).
- MySQL `chat_sessions` and `chat_messages` tables added via migration.
- Frontend build tooling: Vite, React 18+, TypeScript.
- CSS framework: Tailwind CSS (recommended — rapid prototyping, utility-first).

## Blockers / Challenges

| Blocker | Solution |
|---------|----------|
| OpenClaw streaming API contract unknown | Abstract OpenClaw streaming behind `StreamClient` interface. Build a mock that simulates token-by-token emission for frontend dev. |
| WebSocket reconnection storms | Exponential backoff with jitter (1s, 2s, 4s, max 30s). Max reconnect attempts = 10. |
| Large chat histories | Paginate session retrieval (default 20 per page). Virtualized message list for sessions with 500+ messages. |
| JWT token expiry during long sandbox session | Implement refresh before WS connect; re-auth middleware intercepts 401 and triggers reconnect with new token. |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| WebSocket memory leak from abandoned sessions | Low | High | Heartbeat ping/pong every 30s; close stale connections after 3 missed pongs. |
| Markdown rendering XSS | Low | High | Sanitize AI response with DOMPurify or similar before `dangerouslySetInnerHTML`. |
| Large file upload blocking UI | Low | Medium | Upload via background XHR with progress bar; disable submit button during upload. |
| Race condition in concurrent WS messages | Low | Medium | Queue outbound messages per connection; process sequentially. |

## Next Steps

1. Implement WebSocket server with JWT auth + OpenClaw streaming proxy.
2. Add chat_sessions and chat_messages DB migration.
3. Build Sandbox chat UI with real-time token rendering.
4. Complete integration middleware and webhook endpoints.
5. Scaffold frontend, implement all 6 navigation pages.
6. Polish UI with loading states, error handling, responsive design.

---

*Generated: 2026-05-17 13:03 WIB*