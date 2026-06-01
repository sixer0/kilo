# Windows Development & E2E Testing Lessons
Date: 2026-05-17

## 🛠️ Process & Port Management
- **Node.js Background Processes**: On Windows, `npm run dev` in a terminal may not persist correctly or may time out when managed by an agent. 
- **Verification**: Always use `Get-NetTCPConnection -LocalPort <port>` to verify if a server is actually listening, rather than relying on `tasklist` or `ps`.
- **Clean State**: Use `Stop-Process -Name "node" -Force` to ensure no zombie processes are holding onto ports before restarting servers.

## 🧪 E2E Testing with PowerShell
- **NonInteractive Mode**: `Invoke-RestMethod` and `Invoke-WebRequest` can fail or behave inconsistently in `NonInteractive` mode when sending `multipart/form-data`.
- **Reliable Fallback**: Use `curl.exe` (native Windows curl) for multipart file uploads.
- **Example**: `curl.exe -X POST -H "Authorization: Bearer $token" -F "file=@path/to/file" -F "workspaceId=123" "http://localhost:4000/api/knowledge/upload"`

## 🗄️ Database State & Logic
- **Silent Failures**: Logic that relies on a database lookup (e.g., `resolveProvider`) can return 404s that look like routing errors but are actually data errors.
- **Seeding**: Always ensure a minimal set of "Default" configuration data (like AI Providers) is seeded during E2E tests to avoid "No provider found" errors.

## 🚀 Skill Improvement
- **Iterative Debugging**: When a server "starts" but the health check fails, check the actual TCP binding state first.
- **Tooling**: `curl.exe` is often more predictable than PowerShell's `Invoke-*` cmdlets for complex API requests in automated environments.
