---
task: Explore codebase to identify files related to User and Admin UI for the Certification Marketplace
date: 2026-05-17
agent: explore
scope: Examined all frontend source files, pages, contexts, services, styles, and config in D:\Portfolio\Certification-Marketplace
---

# Project Exploration Report — Certification Marketplace UI/UX Mapping

## Overview
Explored the full frontend codebase of the Certification Marketplace (a Next.js 14 + Tailwind CSS project). Mapped all existing view files, templates, style configs, and shared context that will be relevant for UI/UX design updates across the User (Participant) and Admin interfaces.

---

## Project Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 14 (App Router) |
| UI Library | React 18 |
| Styling | Tailwind CSS 3.3 |
| Icons | lucide-react |
| Data Fetching | axios |
| Language | TypeScript + TSX |

---

## Directory Structure

### Key Directories

| Path | Purpose | Status |
|------|---------|--------|
| `frontend/src/app/` | Next.js App Router pages (views) | MAPPED |
| `frontend/src/context/` | React Context providers | MAPPED |
| `frontend/src/services/` | API client | MAPPED |
| `frontend/src/styles/` | Global CSS | MAPPED |
| `frontend/` | Root config files | MAPPED |
| `services/` | Backend microservices (10 services) | NOT SCOPE |
| `PRD/` | Product docs | REFERENCED |

---

## All View Files — Full Mapping

### Entry Points

| File | Purpose | Key Sections |
|------|---------|-------------|
| `frontend/src/app/layout.tsx` | Root layout — wraps app in `AuthProvider` | App shell, auth context |
| `frontend/src/app/page.tsx` | Landing page — Hero + Program Catalog mock | Hero, catalog grid |
| `frontend/src/app/globals.css` | Global Tailwind styles | Custom colors, gradients |

---

### Authentication UI

| File | Feature | Elements |
|------|---------|----------|
| `frontend/src/app/login/page.tsx` (85 lines) | **Sign In / Login** | Email/password form, error display, submit button, loading state, redirection on success |

> ⚠️ **Gap Identified:** No `signup/register` page exists. The registration flow is only handled via `handleEnroll()` in the Program Detail page (`programs/[id]/page.tsx`), which hits `/register` API. A dedicated **Signup/Registration UI** page is missing entirely.

---

### User (Participant) Interface

| File | Feature | Elements |
|------|---------|----------|
| `frontend/src/app/profile/page.tsx` (77 lines) | **User Profile** | Avatar, name/email display, role badge, logout button, account details section |
| `frontend/src/app/programs/[id]/page.tsx` (126 lines) | **Course Catalog / Program Detail** (acts as catalog/listing detail) | Hero image, program details grid (duration, quota, status, scheme), fee card, **Enroll Now CTA**, syllabus modules list |
| `frontend/src/app/dashboard/participant/page.tsx` (126 lines) | **User Dashboard / My Programs** | Stat cards (Active Programs, Certificates Earned, Pending Action), registration list, certificate list, status badges |
| `frontend/src/app/certificate/verify/page.tsx` (123 lines) | **Certificate Verification (Public)** | Search bar, loading spinner, valid/invalid result cards |

---

### Admin Interface

| File | Feature | Elements |
|------|---------|----------|
| `frontend/src/app/dashboard/admin/page.tsx` (128 lines) | **Admin Dashboard — Course & User Management** | Create Program button, Active Programs table (Title, Quota, Status, Edit), Verification Queue (Verify/Reject actions) |
| `frontend/src/app/dashboard/layout.tsx` (105 lines) | **Shared Dashboard Layout (Admin side)** | Collapsible sidebar, role-based menu items, user avatar, header bar |

> ⚠️ **Gap Identified:** Several Admin menu items link to **non-existent pages**:
> - `/dashboard/admin/settings` — System Settings (no page yet)
> - `/dashboard/assessor/schedule` — Scheduling (partial page exists, schedule sub-page missing)
> - `/dashboard/assessor/scoring` — Scoring (no page yet)
> - `/dashboard/finance/invoices` — Invoices list (no page yet)
> - `/dashboard/finance/reports` — Payment Reports (no page yet)
> - `/dashboard/participant/programs` — My Programs list (no page yet)
> - `/dashboard/participant/certificates` — Certificates list (no page yet)

---

### Finance Interface

| File | Feature | Elements |
|------|---------|----------|
| `frontend/src/app/dashboard/finance/page.tsx` (93 lines) | **Finance Dashboard — Invoice & Payment Analytics** | Revenue + Pending Invoices stat cards, Invoice Management table (ID, Participant, Amount, Status, Detail), Export button |

> ⚠️ **Gap Identified:** Invoice Detail page and Payment Reports page do not exist. Data retrieval has a potential bug — `summary` is constructed from `invoices` state before it's populated (closure issue on line 18-19).

---

### Assessor Interface

| File | Feature | Elements |
|------|---------|----------|
| `frontend/src/app/dashboard/assessor/page.tsx` (100 lines) | **Assessor Dashboard — Assessment Queue** | Stat cards (Upcoming Assessments, Certificates Issued), Assessment list, Competent / NYC decision buttons |

> ⚠️ **Gap Identified:** Assessment Scheduling page and Scoring detail page do not exist. Variable naming error on line 9 (`assessments` vs `assessments` on line 11/14/48/55). Typo in mock reviewer_id on line 31.

---

### Shared Infrastructure / Non-View Files

| File | Purpose |
|------|---------|
| `frontend/src/context/AuthContext.tsx` (59 lines) | Auth state management — `user`, `login`, `logout`, `isLoading` |
| `frontend/src/services/api.ts` (33 lines) | axios client — JWT interceptor, 401 redirect, base URL config |
| `frontend/tailwind.config.js` (27 lines) | Design tokens — colors, fonts |
| `frontend/src/styles/globals.css` (19 lines) | Root Tailwind imports + RGB variable definitions |
| `frontend/tsconfig.json` | Path aliases (`@/*` → `./src/*`) |
| `frontend/package.json` | Dependencies: next 14, react 18, tailwind 3.3, lucide-react, axios |

---

## Design Tokens (from `tailwind.config.js`)

```javascript
colors: {
  primary:     '#1C4ED8'   // DEFAULT
  primary:     '#153eb1'   // dark
  primary:     '#4d6df5'   // light
  secondary:   '#F3F4F6'   // background gray
  accent:      '#10B981'   // green success
  warning:     '#F59E0B'   // amber
  danger:      '#EF4444'   // red
}
fontFamily: {
  heading: Montserrat
  sans:    Inter
}
```

---

## Target Interface Summary — What Exists vs What's Missing

### 🔵 USER (Participant) Interface

| Target | Status | File | Notes |
|--------|--------|------|-------|
| **Signup / Registration** | ❌ MISSING | — | No signup page. Only `handleEnroll()` inline in Program Detail page |
| **Course Catalog / Program Listing** | ⚠️ PARTIAL | `page.tsx` | Landing page has 3 mock cards. Program catalog page (`/programs`) doesn't exist as a real listing — only detail pages work |
| **Program Detail** | ✅ EXISTS | `programs/[id]/page.tsx` | Full detail + enroll CTA |
| **Checkout / Payment Flow** | ❌ MISSING | — | No checkout/payment page. "Enroll Now" only alerts success |
| **My Dashboard / My Programs** | ⚠️ PARTIAL | `dashboard/participant/page.tsx` | UI exists but linked sub-pages (`/programs`, `/certificates`) are missing |
| **Profile / User Settings** | ✅ EXISTS | `profile/page.tsx` | Read-only profile view |
| **Certificate Verification** | ✅ EXISTS | `certificate/verify/page.tsx` | Public verification portal |

### 🔴 ADMIN Interface

| Target | Status | File | Notes |
|--------|--------|------|-------|
| **Course Management** | ⚠️ PARTIAL | `dashboard/admin/page.tsx` | Program management table exists; Edit/create are placeholders only |
| **User Management / Analytics** | ❌ MISSING | — | No user management page, no user analytics/dashboard |
| **Content Moderation** | ❌ MISSING | — | No content moderation UI |
| **Verification Queue** | ✅ EXISTS | `dashboard/admin/page.tsx` | Verify/Reject registration queue |
| **System Settings** | ❌ MISSING | — | `/dashboard/admin/settings` in sidebar but no page file |
| **User Analytics** | ❌ MISSING | — | No admin analytics dashboard |
| **Invoice / Finance Review** | ❌ MISSING | — | Link in sidebar → no page file |
| **Assessment Scoring** | ❌ MISSING | — | Link in sidebar → no page file |
| **Assessor Scheduling** | ❌ MISSING | — | Link in sidebar → no page file |

---

## Navigation Menu Structure (from `DashboardLayout` — Bearer for Future Pages)

```
Participant:
  /dashboard/participant          ✅ exists
  /dashboard/participant/programs ❌ missing
  /dashboard/participant/certificates ❌ missing
  /profile                        ✅ exists

Admin:
  /dashboard/admin                ✅ exists
  /dashboard/admin/programs       ❌ missing (Edit button in admin page but no real CRUD page)
  /dashboard/admin/verify         ✅ exists (embedded in admin page)
  /dashboard/admin/settings       ❌ missing

Finance:
  /dashboard/finance              ✅ exists
  /dashboard/finance/invoices     ❌ missing
  /dashboard/finance/reports      ❌ missing

Assessor:
  /dashboard/assessor             ✅ exists
  /dashboard/assessor/schedule    ❌ missing
  /dashboard/assessor/scoring     ❌ missing
```

---

## No Components Library Found

- There is **no `frontend/src/components/` directory** — all pages are written inline as monolithic page components
- There are **no reusable UI components** (no Button, Card, Input factories)
- There are **no template files** — HTML/templating beyond JSX in pages
- There are **no asset files** (images, SVGs, fonts) — all icons are from `lucide-react`, hero images are colored `div`s / gradients

---

## Known Code Quality Issues Found During Exploration

| File | Issue |
|------|-------|
| `participant/page.tsx` line 45 | Uses `BookOpen` from state but the mock shim at bottom is defined as `BookOpen` — works but fragile |
| `dashboard/admin/page.tsx` line 128 | Same mock shim pattern for `BookOpen` |
| `dashboard/assessor/page.tsx` line 9 | Variable is misspelled `assessments` instead of `assessments` |
| `dashboard/finance/page.tsx` lines 18-19 | `summary` computed from `invoices` state before fetch completes — always shows `0,0` initially |
| All pages | No error boundaries, no retry logic, no skeleton states beyond text "Loading..." |
| All pages | Hardcoded mock IDs (`reviewer_id: 1`, `user_id: user.id` without server assignment) |

---

## Data Flow Summary

```
Browser → Next.js Page → AuthContext (localStorage)
                  ↓
              api.ts (axios)
                  ↓
         http://localhost:8080 (API Gateway)
                  ↓
         Backend microservices → MySQL
```

---

## PRD Feature Coverage vs Frontend Implementation

| PRD Requirement | Frontend Page | Completion |
|----------------|--------------|-----------|
| Login / Logout / RBAC | `login/page.tsx` + `AuthContext.tsx` | ✅ |
| Participant biodata | `profile/page.tsx` | ✅ (read-only) |
| Program listing & detail | `page.tsx` (mock) + `programs/[id]` | ⚠️ |
| Online registration | _Inline in Program Detail_ | ⚠️ |
| Payment tracking | `dashboard/finance/page.tsx` | ⚠️ (invoice table only) |
| Assessment scoring | `dashboard/assessor/page.tsx` | ⚠️ (queue only; no scoring form) |
| Certificate generation | No UI | ❌ |
| Certificate verification | `certificate/verify/page.tsx` | ✅ |
| Course catalog / listing | Landing page mocks | ⚠️ (no real catalog) |
| User analytics | None | ❌ |
| Content moderation | None | ❌ |

---

## Recommendations for UI/UX Design Scope

Based on this exploration, the pages that most need **professional UI/UX treatment** are:

1. **Signup / Registration Page** — currently completely missing
2. **Course Catalog / Program Listing** — currently only mock cards on landing page
3. **Checkout / Payment Flow** — currently no page, only an inline alert
4. **Course Management (Admin)** — table exists but CRUD editors are non-existent
5. **User Analytics (Admin)** — completely missing
6. **Content Moderation (Admin)** — completely missing
7. **My Programs page (Participant dashboard sub-page)** — linked but no file
8. **Invoice Detail / Finance Report pages** — linked but no files
9. **System Settings page** — linked but no file

---

*Generated: 2026-05-17 22:06*
