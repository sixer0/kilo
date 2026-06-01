---
task: chat-widget-and-ai-webhook-exploration
date: 2026-05-20
agent: explore
scope: Full directory mapping of D:/Portfolio/lp-laravel — focus: chat widget, AI webhook, contact & notification pipeline
---

# Project Exploration Report — lp-laravel (Chat/AI Webhook Focus)

## Overview
`D:/Portfolio/lp-laravel` is a **Laravel 11** portfolio/landing-page CMS for **Sixer0 / Budi Kusharyanto**. It contains a public-facing Bootstrap UI, an admin CMS for project CRUD, a contact form, and — the focus of this exploration — a **Nailla AI chat widget** with a full webhook bridge to the **OpenClaw/KiloClaw AI API** plus an automated email-prospect reporting pipeline.

---

## 1. Chat Widget — Frontend

### `public/js/chat-widget.js` ← Primary Widget Asset
| Attribute | Detail |
|-----------|--------|
| Path | `public/js/chat-widget.js` |
| Loaded from | `resources/views/layouts/guest.blade.php` → `<script src="/public/js/chat-widget.js"></script>` (line 321) |
| Branding | **"Nailla"** — agent `nailla-cs`, subtitle "Tim Pak Budi Kusharyanto" |
| Config constants | `agentId: 'nailla-cs'`, `placeId`, `apiEndpoint`, `hookToken`, `primaryColor: '#2563eb'` |
| Message POST | `POST` to `/nailla-webhook.php?token=<SHA256>` with `X-OpenClaw-Token` header; body `{ message, sessionKey }` |
| Auto-trigger | Idle detection: fires **once** after **45 000 ms** idle, sends `prePrompt: 'ada pengunjung di websitenya budi kusharyanto...'` silently |
| Email report signal | Parses `[NAILLA_EMAIL_REPORT: name="…" contact="…" …]` from bot responses → POSTs to `/nailla-email.php` |
| Error handling | Catch-all fallback: "Koneksi bermasalah. Silakan coba lagi." |
| DOM structure | Floating launcher button → 370×490px chat window with header/body/footer, CSS embedded via template string |

---

## 2. Webhook Handler — PHP Bridge Layer

Three PHP files handle the webhook, arranged in increasing reliability:

### A. `public/nailla-webhook.php` (Standalone — preferred in production)
- CORS-compliant, handles OPTIONS preflight
- Hardcoded `$expectedHookToken` and `$openclawEndpoint` to `https://i-5dc40be347644e148c0516b639489d89.kiloclaw.ai/hooks/nailla-chat`
- JWT-based authentication with the OpenClaw end
- Maintains direct PHP connection — risks including hardcoded JWT

### B. `public/nailla-webhook-8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a.php` (Hash-named debug version)
- Reads `NAILLA_CHAT_HOOK_TOKEN` from `.env`
- Has the token check **temporarily removed** for debugging purposes
- Logs every request to `webhook_requests.log` and `webhook_debug_final.log`
- Returns `{ status: 'ok' }` to callers

### C. `routes/web.php` → `ChatHookController` (Laravel route)
- Route: `GET|POST /hooks/nailla-chat/{token}` — **no web middleware** (bypasses CSRF / session)
- Tokens validated from URL param, `X-Hook-Token` header, or `token` JSON field
- Logs all requests to `public/webhook_final_debug.log`
- Returns 401 if token mismatch; 200 with `{ status: 'ok' }` success

---

## 3. ChatHookController (Laravel)

| File | `app/Http/Controllers/ChatHookController.php` |
|------|----------------------------------------------|
| Route | `/hooks/nailla-chat/{token}` (no middleware group) |
| Token var | `X-Hook-Token` header, URL `{token}`, or JSON body `token` |
| Expected token env var | `NAILLA_CHAT_HOOK_TOKEN` (fallback: hardcoded 64-char SHA256) |
| Debug logging | Appends to `public/webhook_final_debug.log` — logs `time`, `url_token`, `header_token`, `body_token`, `env_token`, `expected_hardcoded` |
| CORS | `Access-Control-Allow-Origin: *` on all responses |

---

## 4. Email Prospect Reporter — `nailla-email.php`

| Attribute | Detail |
|-----------|--------|
| Path | `public/nailla-email.php` |
| POST signature | Werk JSON `{ name, contact, reason, interest, context, attachments }` |
| SMTP config | `nailla@sixer0-bk.my.id` → `mail.sixer0-bk.my.id:465` (implicit TLS) with `AUTH LOGIN` |
| Recipients | Primary: `sixer0.bk@gmail.com` · CC: `sixer0.bk@live.com` |
| Subject base | `[Nailla] Prospek Baru dari Website Sixer0` (with attachments → `[Nailla] Dokumentasi …`) |
| Fallback | PHP `mail()` if SMTP fails |
| MIME | Plain + HTML multipart (no attachments); multipart/mixed with base64 attachments when present |

---

## 5. Environmental Variables (`.env`)

```dotenv
APP_URL=https://landing.sixer0-bk.my.id
NAILLA_CHAT_HOOK_TOKEN="8b900704df572ffd4ab341f89098c8db862cd19753deb7e92f421183809d020a"
NAILLA_CHAT_AGENT_ID="nailla-cs"
NAILLA_CHAT_SESSION_KEY="hook:website-nailla-{{timestamp}}"
```

---

## 6. Contact Form — Backend Pipeline

| Component | File | Purpose |
|-----------|------|---------|
| Controller | `app/Http/Controllers/ContactController.php` | Validates, stores, sends email |
| Model | `app/Models/ContactSubmission.php` | Eloquent: company, name, phone, email, message, ip, user_agent_short, status |
| Mail | `app/Mail/ContactNotification.php` | Markdown `emails.contact-notification` → `sixer0.bk@gmail.com` |
| Blade | `resources/views/emails/contact-notification.blade.php` | Notification email template |
| Route | `POST /contact` in `routes/web.php` | Public contact endpoint |
| Migration | `database/migrations/2026_05_15_create_contact_submissions_table.php` | Full schema (10 cols) |

---

## 7. Directory Structure — Key Components

```
D:/Portfolio/lp-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AppBaseController.php
│   │   │   ├── ChatHookController.php        ← AI webhook Laravel endpoint
│   │   │   ├── ContactController.php         ← Contact form handler
│   │   │   ├── HomeController.php            ← Landing page + project pages
│   │   │   └── Admin/
│   │   │       ├── DashboardController.php
│   │   │       ├── LoginController.php
│   │   │       └── ProjectController.php     ← CMS CRUD
│   │   └── Kernel.php                         ← routeMiddleware: session.admin (AdminMiddleware)
│   ├── Mail/
│   │   └── ContactNotification.php           ← Contact email Mailable
│   ├── Models/
│   │   ├── ContactSubmission.php             ← Contact DB model
│   │   ├── Project.php                       ← Portfolio model
│   │   └── User.php                          ← Admin auth model
│   └── Middleware/
│       └── AdminMiddleware.php
├── public/
│   ├── js/
│   │   └── chat-widget.js                    ← Chat widget (frontend embed)
│   ├── nailla-webhook.php                    ← Standalone webhook → OpenClaw
│   ├── nailla-webhook-8b9007…                ← Debug hash-named variant (token check disabled)
│   ├── nailla-email.php                      ← Email SMTP reporter (prospect intake)
│   ├── nailla-docs.php                       ← Nailla docs endpoint
│   ├── hook-probe.php                        ← Webhook probe/debug logger
│   └── nailla-webhook… (duplicate)           ← Same SHA256 hash name in filename
├── resources/views/
│   ├── layouts/guest.blade.php               ← Main layout; injects chat-widget.js (line 321)
│   ├── home.blade.php                       ← Landing page
│   ├── project/show.blade.php               ← Project detail
│   ├── auth/login.blade.php                 ← Admin login
│   ├── admin/
│   │   ├── layout.blade.php, dashboard.blade.php
│   │   └── projects/ (list.blade.php, form.blade.php)
│   ├── emails/contact-notification.blade.php
│   ├── legal/ (privacy.blade.php, notice.blade.php)
│   └── errors/ (404.blade.php, 500.blade.php)
├── routes/
│   ├── web.php                              ← Public + webhook routes
│   ├── admin.php                            ← Protected admin CRUD
│   └── console.php                          ← Artisan console
├── database/
│   ├── migrations/
│   │   ├── 2026_05_15_create_contact_submissions_table.php  (full schema 10 cols)
│   │   ├── 2026_05_17_create_contact_submissions_table.php  (reduced schema)
│   │   ├── 2026_05_17_create_users_table.php
│   │   └── 2026_05_18_111217_create_sessions_table.php
│   └── seeders/
│       └── ProjectSeeder.php
├── PRD/project_summary.md                   ← Project PRD / architecture doc
├── docs/updates-summary.md                  ← Changelog / rebuild notes
├── memory/                                  ← Daily logs, refs, tasks
├── config/app.php, database.php              ← App config (only 2 files)
└── .env                                     ← NAILLA_* env vars + DB/app config
```

---

## 8. Data/Fixation Architecture — Summary

```
Browser user types in chat window
        │
        ▼
chat-widget.js  (public/js/)
 POST /nailla-webhook.php?token=<hash>
  Header: X-OpenClaw-Token: <token>
  Body:  { message, sessionKey }
        │
        ▼
nailla-webhook.php (or ChatHookController)
  → Validates token
  → Forwards to OpenClaw / KiloClaw AI API
  → Returns response to widget
        │
        ▼ (AI detects lead intent)
Bot response contains [NAILLA_EMAIL_REPORT: name="…" contact="…" …]
        │
        ▼
chat-widget.js internal parser
 POST /nailla-email.php
  Body: { name, contact, reason, interest, context }
        │
        ▼
nailla-email.php (SMTP via cPanel, fallback to mail())
 → nailla@sixer0-bk.my.id
 → sixer0.bk@gmail.com  (main)
 → sixer0.bk@live.com   (CC)
```

---

## 9. Notable Observations (for Reference Task)

### Widget → Server
| Path | Method | Expected Token |
|------|--------|----------------|
| `/nailla-webhook.php?token=<hash>` | POST | X-OpenClaw-Token header |
| `/hooks/nailla-chat/{token}` | GET/POST | URL token / X-Hook-Token |
| `/nailla-webhook-8b9007…php` | POST | env var check (currently DISABLED for debug) |

### Auth Tokens
- The shared hook token is stored as a plain string in 4+ locations: `.env`, `nailla-webhook.php`, the debug variant, `ChatHookController.php`, and `chat-widget.js`
- JWT in standlone `nailla-webhook.php` is truncated with placeholder — may not work in production

### File Type Summary (project-local .php only, excl. vendor)
| Extension | Count (est.) | Scope |
|-----------|-------------|-------|
| `.php` | ~78 | App + public + config |
| `.blade.php` | 12+ | Views |
| `.js` | 1 | `chat-widget.js` |
| `.md` | 2+ | PRD + docs + memory |
| `.json` | 3+ | Composer, package-lock |

### Gaps / Needs Investigation
- `nailla-webhook.php` JWT token is truncated (`…` placeholders) — actual forwarding to OpenClaw cannot succeed
- `nailla-webhook-8b9007…` has token validation **commented out** — any caller can hit it
- No `ChatMessage` Eloquent model / `chat_messages` DB table — conversation history is not persisted on the Laravel side
- Two migrations for `contact_submissions` table exist (`2026_05_15` full vs `2026_05_17` reduced) — migration risk on fresh install
- `nailla-docs.php` and `resources/views/admin/projects/` websocket endpoint — needs review
- `nailla-webhook.php` still online — logs requests to server-side debug logs

---

*Generated: 2026-05-20 08:40 MYT*
