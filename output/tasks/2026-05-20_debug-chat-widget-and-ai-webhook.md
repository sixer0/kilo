---
task: debug-chat-widget-and-ai-webhook
date: 2026-05-20
agent: data-collector
items_collected: 2
last_updated: 2026-05-20 08:50
---

# Data Collection Report

## Task Overview
Gathering AI webhook configuration and chat widget error logs for debugging purposes.

## Files Collected

### Source Files
| File | Purpose | Lines |
|------|---------|-------|
| `.env` | Environment configuration | 22 |
| `public/js/chat-widget.js` | Frontend chat widget logic | 247 |
| `app/Http/Controllers/ChatHookController.php` | Laravel webhook controller | 65 |
| `public/nailla-webhook.php` | Webhook bridge (appears broken/incomplete) | 25 |
| `public/nailla-webhook-8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a.php` | Standalone webhook handler | 60 |
| `public/error_log` | Web server/Laravel error logs | N/A |
| `error_log` | PHP error logs | N/A |

### Configuration Files
| File | Purpose |
|------|---------|
| `.env` | Contains webhook tokens and agent IDs |

## Code Context

### Webhook Configuration Details

**Environment Variables (`.env`):**
- `NAILLA_CHAT_HOOK_TOKEN="8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a"`
- `NAILLA_CHAT_AGENT_ID="nailla-cs"`
- `NAILLA_CHAT_SESSION_KEY="hook:website-nailla-{{timestamp}}"`

**Frontend Implementation (`public/js/chat-widget.js`):**
- `apiEndpoint`: `/nailla-webhook.php?token=8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a`
- **Header Used:** `X-OpenClaw-Token`

**Backend Implementation (`app/Http/Controllers/ChatHookController.php`):**
- **Expected Header:** `X-Hook-Token` (**MISMATCH DETECTED**)
- Also attempts to fall back to `$token` from URL or `$request->input('token')`.

**Standalone Webhook (`public/nailla-webhook-8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a.php`):**
- **Expected Header:** `X-Hook-Token` (**MISMATCH DETECTED**)

## Error Logs

### Chat Widget & Webhook Related Errors

**`public/error_log`:**
- `[19-May-2026 06:22:58 Asia/Jakarta] LARAVEL-FATAL: The POST method is not supported for route hooks/nailla-chat. Supported methods: GET, HEAD.`
  - *Note: This error occurs even though `routes/web.php` defines the route with `match(['get', 'post'], ...)`. This suggests a potential routing conflict or that the request is being misrouted.*

**`error_log` (Root):**
- Multiple errors in `nailla-email.php`:
  - `PHP Fatal error: Uncaught TypeError: smtpSend(): Argument #10 ($hdrs) must be of type array, string given, called in .../nailla-email.php on line 143`
- Multiple errors in `nailla-docs.php`:
  - `PHP Fatal error: Unparenthesized a ? b : c ? d : e is not supported.`

## Collection Log

| Timestamp | Action | Details |
|-----------|--------|---------|
| 08:40 | Started | Initializing collection |
| 08:45 | Collected | `.env` configuration |
| 08:46 | Collected | `public/js/chat-widget.js` |
| 08:47 | Collected | `app/Http/Controllers/ChatHookController.php` |
| 08:48 | Collected | `public/nailla-webhook.php` |
| 08:48 | Collected | `public/nailla-webhook-8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a.php` |
| 08:49 | Collected | `public/error_log` and `error_log` |

## Gaps / Needs More Data
- More recent logs (post 2026-05-19) if the widget is actively being used and failing.
- Confirmation of whether `nailla-webhook.php` is indeed intended to be a placeholder or if it should be replaced by the standalone version.

---
*Generated: 2026-05-20 08:50*
*Last Updated: 2026-05-20 08:50*
