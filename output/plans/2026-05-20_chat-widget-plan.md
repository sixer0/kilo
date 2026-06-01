---
task: debug-chat-widget-and-ai-webhook
date: 2026-05-20
agent: data-analyst
type: plan
based_on: analysis/2026-05-20_chat-widget-analysis.md
---

# Implementation Plan: Chat Widget & AI Webhook Fix

## Current State
The chat widget is completely non-functional. Requests are failing at the authentication layer (header mismatch), routing layer (Laravel POST error), and API forwarding layer (truncated JWT). The lead reporting system is broken due to PHP fatal errors.

## Target State
A fully operational communication path: `User Widget` $\rightarrow$ `PHP Bridge/Controller` $\rightarrow$ `AI API`. Lead reporting via `nailla-email.php` is functional. Tokens are managed centrally in `.env`.

## Steps

### 1. Authentication & Header Alignment
- **Action**: Update `public/js/chat-widget.js` to use `X-Hook-Token` as the header name for the token.
- **Action**: Update `app/Http/Controllers/ChatHookController.php` to consistently check `X-Hook-Token`.
- **Action**: Ensure `public/nailla-webhook.php` uses `X-Hook-Token`.

### 2. Bridge Repair (OpenClaw Connectivity)
- **Action**: Locate the actual valid JWT for the OpenClaw API.
- **Action**: Replace the truncated JWT placeholders in `public/nailla-webhook.php` with the real token.
- **Action**: Update the bridge to read the `NAILLA_CHAT_HOOK_TOKEN` from `.env` using `getenv()` or a similar method if not already doing so.

### 3. Laravel Routing Fix
- **Action**: Verify `routes/web.php` for the `hooks/nailla-chat/{token}` route.
- **Action**: Execute `php artisan route:clear` to ensure the `POST` method is recognized.
- **Action**: Test the endpoint using `curl` to verify that `POST` requests no longer return "Method Not Supported".

### 4. Utility Script Repair
- **Action**: In `public/nailla-email.php`, modify the `smtpSend()` call to pass an array for the headers argument instead of a string.
- **Action**: In `public/nailla-docs.php`, wrap nested ternary operators in parentheses to comply with PHP 8+ syntax.

### 5. Token Centralization & Cleanup
- **Action**: Remove hardcoded SHA256 tokens from `ChatHookController.php` and `nailla-webhook.php`.
- **Action**: Ensure the frontend token is injected via `guest.blade.php` using `config()` or `env()` instead of being hardcoded in `chat-widget.js`.
- **Action**: Delete the debug file `public/nailla-webhook-8b9007...php`.

## Dependencies
- Valid OpenClaw AI API JWT.
- Access to the server terminal to clear Laravel route cache.

## Blockers/Challenges
| Blocker | Solution |
|---------|----------|
| Missing valid JWT | Request valid JWT from the AI provider / config. |
| SMTP Auth Failure | Check `.env` mail settings and server firewall for port 465. |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Token Leakage | Medium | High | Do not commit `.env` to git; use a separate public token for the widget if possible. |
| Regression in Email | Low | Medium | Test `nailla-email.php` with a mock payload before deploying. |

## Next Steps
1. Implement header changes in JS and PHP.
2. Repair JWT and clear route cache.
3. Fix utility script syntax errors.
4. End-to-end verification.

---
*Generated: 2026-05-20 09:25*
