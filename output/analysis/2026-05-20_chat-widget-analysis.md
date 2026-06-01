---
task: debug-chat-widget-and-ai-webhook
date: 2026-05-20
agent: data-analyst
type: mixed
confidence: HIGH
task_file: output/tasks/2026-05-20_debug-chat-widget-and-ai-webhook.md
last_updated: 2026-05-20 09:25
---

# Data Analysis Report: Chat Widget & AI Webhook Issues

## Overview
This analysis covers the failure of the Nailla AI chat widget and its associated webhook bridge in the `lp-laravel` project. The system is currently failing to communicate between the frontend widget, the PHP backend bridge, and the OpenClaw/KiloClaw AI API.

## Original Task Reference
- **Task File**: `output/tasks/2026-05-20_debug-chat-widget-and-ai-webhook.md`
- **Intent**: Perform root cause analysis and create an implementation plan to fix the chat widget and AI webhook.
- **Scope**: Frontend widget (`chat-widget.js`), Webhook bridge (`nailla-webhook.php`, `ChatHookController.php`), and reporting pipeline (`nailla-email.php`).

## Input Sources Referenced
| Source | File | Items Used |
|--------|------|------------|
| Task/Collector | `output/tasks/2026-05-20_debug-chat-widget-and-ai-webhook.md` | Header mismatch, routing errors, PHP fatal errors |
| Explore | `output/explore/2026-05-20_chat-widget-and-ai-webhook.md` | Project structure, file paths, JWT truncation |

## Memory Relevance Validation
No specific memory records were provided for this task. Project structure and environment details were derived from the explore output.

## Summary
The AI chat functionality is currently broken due to a combination of header mismatches (authentication failure), truncated authentication tokens in the bridge (API failure), and Laravel routing conflicts (request failure). Additionally, the lead reporting pipeline is disabled by PHP fatal errors.

## Requirements
- Restore chat widget communication: `Widget` $\rightarrow$ `Webhook Bridge` $\rightarrow$ `AI API`.
- Ensure authentication is consistent across all layers using `.env` variables.
- Fix fatal errors in auxiliary scripts (`nailla-email.php`, `nailla-docs.php`).
- Resolve Laravel routing conflicts for the `/hooks/nailla-chat` endpoint.

## Proposed Approach
The fix will involve standardizing the authentication header to `X-Hook-Token`, repairing the JWT in the standalone bridge, cleaning up routing, and fixing PHP type/syntax errors in utility files. Token management will be centralized in the `.env` file to eliminate hardcoded secrets.

## Key Findings

### Finding 1: Authentication Header Mismatch [Confidence: HIGH]
- **Evidence**: `chat-widget.js` sends `X-OpenClaw-Token`, but `ChatHookController.php` and the standalone webhook expect `X-Hook-Token`.
- **Implication**: Every request from the widget is rejected with a 401 Unauthorized error before it even reaches the AI logic.

### Finding 2: Truncated JWT in Production Bridge [Confidence: HIGH]
- **Evidence**: `public/nailla-webhook.php` contains JWT placeholders (`...`) instead of a real token.
- **Implication**: Even if the initial token check is bypassed or fixed, the bridge cannot authenticate with the OpenClaw AI API, resulting in a failed request to the AI.

### Finding 3: Laravel Routing Conflict [Confidence: MEDIUM]
- **Evidence**: `public/error_log` reports `The POST method is not supported for route hooks/nailla-chat` despite the route being defined as `match(['get', 'post'], ...)`.
- **Implication**: Requests to the Laravel-managed endpoint are being rejected by the framework, likely due to route caching or a conflicting route definition.

### Finding 4: Broken Reporting Pipeline [Confidence: HIGH]
- **Evidence**: `nailla-email.php` has a `TypeError` in `smtpSend()` (string given instead of array for headers) and `nailla-docs.php` has a syntax error with unparenthesized ternaries.
- **Implication**: Leads captured by the AI are not being emailed to the administrators.

## Files to Modify
- `public/js/chat-widget.js`
- `public/nailla-webhook.php`
- `app/Http/Controllers/ChatHookController.php`
- `public/nailla-email.php`
- `public/nailla-docs.php`
- `.env`

## Implementation Order
1. **Fix Header Mismatch**: Align `chat-widget.js` and backend on `X-Hook-Token`.
2. **Repair JWT**: Replace truncated JWT in `nailla-webhook.php` with actual token.
3. **Fix Routing**: Clear route cache and verify `routes/web.php`.
4. **Repair Utilities**: Fix PHP errors in `nailla-email.php` and `nailla-docs.php`.
5. **Centralize Tokens**: Remove hardcoded tokens from JS and PHP files.
6. **Cleanup**: Delete debug hash-named webhook files.

## Risks
- **Token Exposure**: Moving tokens to `.env` is safer, but if they are needed in JS, they must be handled carefully (e.g., injected via Blade) to avoid exposing administrative tokens to the public.
- **SMTP Failures**: Fixing the `TypeError` may reveal underlying SMTP connection issues (credentials, firewall).

## Recommendations
1. **Route Cache**: Always run `php artisan route:clear` after modifying `routes/web.php`.
2. **Logging**: Implement a unified logging system for the bridge to avoid scattered `.log` files.
3. **Validation**: Add a simple health-check endpoint for the webhook to verify API connectivity independently of the widget.

---
*Generated: 2026-05-20 09:25*
*Last Updated: 2026-05-20 09:25*
