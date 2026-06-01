---
task: ai-agent-preview-simple-analysis
date: 2026-05-17
agent: data-analyst-free
type: requirements
confidence: HIGH
task_file: (not present — direct /analyze command)
last_updated: 2026-05-17 12:53
---

# Simplified Technical Analysis — AI Agent Preview

## 1. Recommended Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | React + Vite | Nginx deployment, WebSocket client |
| Backend | Node.js + Express.js | REST + WebSocket (ws or Socket.IO) |
| Database | MySQL 8 | Via Sequelize or Knex ORM |
| Auth | JWT (access + refresh token) | jsonwebtoken + bcrypt |
| File Upload | multer | PDF/TXT/DOCX/MD forwarding |
| Real-time | WebSocket (ws library) | Token streaming for sandbox chat |
| Deployment | Docker + Docker Compose | Nginx reverse proxy, Ubuntu host |
| AI Runtime | OpenClaw / KiloClaw | External — not part of this app |
| Encryption | Node crypto (AES-256) | For stored provider API keys |

## 2. Core Database Tables (5)

### users
```sql
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(255) NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  role          ENUM('admin','user','developer') NOT NULL DEFAULT 'user',
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### workspaces
```sql
CREATE TABLE workspaces (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  name                  VARCHAR(255) NOT NULL,
  owner_id              INT NOT NULL,
  openclaw_workspace_id VARCHAR(255),
  provider              VARCHAR(100),
  model                 VARCHAR(100),
  system_prompt         TEXT,
  channels              JSON,
  is_deleted            BOOLEAN DEFAULT FALSE,
  created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES users(id)
);
```

### knowledge_files
```sql
CREATE TABLE knowledge_files (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  workspace_id          INT NOT NULL,
  filename              VARCHAR(255) NOT NULL,
  file_type             VARCHAR(10),
  openclaw_reference_id VARCHAR(255),
  status                ENUM('pending','processing','ready','failed') DEFAULT 'pending',
  uploaded_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (workspace_id) REFERENCES workspaces(id)
);
```

### providers
```sql
CREATE TABLE providers (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(100) NOT NULL,
  api_key_encrypted TEXT NOT NULL,
  is_enabled      BOOLEAN DEFAULT TRUE,
  is_default      BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### audit_logs
```sql
CREATE TABLE audit_logs (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT,
  action     VARCHAR(100) NOT NULL,
  payload    JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 3. Core API Endpoints (5)

### 1. Authentication
```http
POST /api/auth/login
Content-Type: application/json

Request:  { "email": "string", "password": "string" }
Response: { "token": "jwt...", "refreshToken": "...", "user": {...} }
```

### 2. Create Workspace
```http
POST /api/workspaces
Authorization: Bearer <jwt>
Content-Type: application/json

Request:  { "name": "string", "provider": "string", "model": "string", "system_prompt": "string", "channels": ["whatsapp","email"] }
Response: { "id": 1, "openclaw_workspace_id": "kc_abc123", ... }
```
- Creates record in MySQL + provisions project/agent in OpenClaw.

### 3. Upload Knowledge Document
```http
POST /api/knowledge/upload
Authorization: Bearer <jwt>
Content-Type: multipart/form-data

Request:  { file: <pdf|txt|docx|md>, workspaceId: 1 }
Response: { "id": 1, "openclaw_reference_id": "ref_xxx", "status": "processing" }
```
- Accepts file, forwards to OpenClaw ingestion API, stores reference ID.

### 4. Sandbox Chat (WebSocket)
```http
WS /ws/sandbox/:workspaceId
Authorization: Bearer <jwt>   (query param or first message)

Client → Server: { "type": "message", "content": "string" }
Server → Client: { "type": "token", "data": "streamed_chunk" }
Server → Client: { "type": "source", "data": { "references": [...] } }
Server → Client: { "type": "done", "data": { "full_response": "..." } }
```
- Server proxies stream from OpenClaw API to frontend in real-time.
- Session history persisted on disconnect.

### 5. Integration Middleware (Internal Apps)
```http
POST /api/ai/:workspaceSlug/chat
Authorization: Bearer <jwt>
Content-Type: application/json

Request:  { "message": "string", "session_id": "string (optional)" }
Response: { "response": "string", "sources": [...], "session_id": "..." }
```
- Simplified endpoint for ERP/CRM/HRIS to send prompts to a specific workspace.
- Internally maps `workspaceSlug` → OpenClaw runtime + provider config.

---
*Generated: 2026-05-17 12:53 WIB*