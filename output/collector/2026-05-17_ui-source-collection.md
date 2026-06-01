---
task: Design Professional UI/UX for Certification Marketplace
date: 2026-05-17
agent: data-collector
items_collected: 17
last_updated: 2026-05-17 22:37
---

# Data Collection Report — Frontend UI Source Code

## Task Overview
Gather all existing UI page source code, config files, and supporting infrastructure for UI/UX analysis of the Certification Marketplace frontend.

---

## Files Collected

### Source Pages (`frontend/src/app/`)

| # | File | Purpose | Lines | Status |
|---|------|---------|-------|--------|
| 1 | `src/app/layout.tsx` | Root layout — wraps app in `AuthProvider` | 15 | ✅ |
| 2 | `src/app/page.tsx` | Landing page — Hero + Program Catalog mock | 41 | ✅ |
| 3 | `src/app/login/page.tsx` | Sign In / Login (email + password) | 85 | ✅ |
| 4 | `src/app/profile/page.tsx` | User Profile (read-only view) | 77 | ✅ |
| 5 | `src/app/programs/[id]/page.tsx` | Program Detail + Enroll CTA | 126 | ✅ |
| 6 | `src/app/dashboard/participant/page.tsx` | Participant Dashboard / My Programs | 126 | ✅ |
| 7 | `src/app/dashboard/admin/page.tsx` | Admin Dashboard — Course & User Mgmt | 128 | ✅ |
| 8 | `src/app/dashboard/layout.tsx` | Shared Dashboard Layout (collapsible sidebar) | 105 | ✅ |
| 9 | `src/app/dashboard/finance/page.tsx` | Finance Dashboard — Invoice & Payment Analytics | 93 | ✅ |
| 10 | `src/app/dashboard/assessor/page.tsx` | Assessor Dashboard — Assessment Queue | 100 | ✅ |
| 11 | `src/app/certificate/verify/page.tsx` | Certificate Verification (Public portal) | 123 | ✅ |

### Infrastructure / Non-View Files

| # | File | Purpose | Lines |
|---|------|---------|-------|
| 12 | `src/context/AuthContext.tsx` | Auth state management (`user`, `login`, `logout`, `isLoading`) | 59 |
| 13 | `src/services/api.ts` | Axios client — JWT interceptor, 401 redirect | 33 |

### Configuration Files

| # | File | Purpose |
|---|------|---------|
| 14 | `tailwind.config.js` | Design tokens — colors, fonts |
| 15 | `package.json` | Dependencies: Next.js 14, React 18, Tailwind 3.3, lucide-react, axios |
| 16 | `tsconfig.json` | TypeScript config — path aliases (`@/*` → `./src/*`) |
| 17 | `src/styles/globals.css` | Root Tailwind imports + CSS variable definitions |

---

## Code Context

### `src/app/layout.tsx` (1–15)

```tsx
import React from 'react';
import { AuthProvider } from '../context/AuthContext';
import './../styles/globals.css';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
```
Root app shell. All pages inherit `AuthContext` via this provider. Global CSS imported here.

---

### `src/app/page.tsx` — Landing Page (1–41)

```tsx
// Hero: bg-primary, heading font-bold text-5xl, two CTAs
// Catalog: 3 mock cards, grid-cols-1 md:grid-cols-3, price Rp 2.500.000
```
Pure static mock — no API calls. Used as entry point with catalog teaser.

---

### `src/app/login/page.tsx` — Login (1–85)

```tsx
"use client";
// State: email, password, error, isLoading
// POST /auth/login → stores token+user in AuthContext → router.push('/profile')
// Tailwind: centered card, rounded-2xl shadow-xl, primary button, error alert bg-red-50
```
The only page that handles API login. No signup page exists — registration is inline in Program Detail via `handleEnroll()`.

---

### `src/app/profile/page.tsx` — Profile (1–77)

```tsx
"use client";
// Read-only profile: avatar, name/email/role badge, Account Details section
// Logout button → AuthContext.logout() → /login redirect
```
No edit form. Activity section is placeholder text.

---

### `src/app/programs/[id]/page.tsx` — Program Detail (1–126)

```tsx
"use client";
// Fetches /programs/:id
// Hero image div + gradient overlay
// 4 stat cards: Duration, Quota, Status, Scheme
// Sticky fee sidebar with "Enroll Now" CTA
// 4-mock syllabus modules list
// handleEnroll() → POST /register { user_id, program_id } → alert()
```
Hardcoded fee `Rp 2.500.000`. Syllabus uses mock `[1,2,3,4]` loop. No payment flow (only alert).

---

### `src/app/dashboard/participant/page.tsx` — Participant Dashboard (1–126)

```tsx
"use client";
// 3 stat cards: Active Programs, Certificates Earned, Pending Action
// Registrations list (table rows) — status badges, conditional "Pay Now" button
// Certificates list — "Download PDF" button
// GET /registrations/my, GET /certificates/my
```
Uses inline `BookOpen` fallback component at line 126 (Lucide may be unavailable).

---

### `src/app/dashboard/admin/page.tsx` — Admin Dashboard (1–128)

```tsx
"use client";
// Top bar: "Operational Overview" heading + "Create Program" button
// Active Programs table: Title, Quota, Status, Edit
// Verification Queue: participant name + program, Verify / Reject buttons
// GET /programs, GET /registrations/pending
// PATCH /registration/verify/:id { status }
```
`Create Program` has no handler. `Edit` is a stub link. Same `BookOpen` fallback at line 128.

---

### `src/app/dashboard/layout.tsx` — Dashboard Layout (1–105)

```tsx
"use client";
// Collapsible sidebar (w-64 ↔ w-20) via hamburger toggle
// ROLE-BASED menu items from MENU_ITEMS object:
//   Participant → My Dashboard, My Programs, Certificates, Profile
//   Admin       → Overview, Manage Programs, Verify Participants, System Settings
//   Finance     → Finance Overview, Invoices, Payment Reports
//   Assessor    → Assessment List, Scheduling, Scoring
// Header bar: "Role Portal" title, user name + avatar circle
```
Links to many non-existent pages (see Gaps below).

---

### `src/app/dashboard/finance/page.tsx` — Finance Dashboard (1–93)

```tsx
"use client";
// 2 stat cards: Total Revenue, Pending Invoices
// Invoice Management table: ID, Participant, Amount, Status, Detail
// GET /payments/invoices
// ⚠️ BUG line 18-19: summary computed from invoices state before fetch populates it → always "0"
```
`invoices` reducer on line 18 reads stale empty `[]` state before `setInvoices` on line 16 resolves.

---

### `src/app/dashboard/assessor/page.tsx` — Assessor Dashboard (1–100)

```tsx
"use client";
// 2 stat cards: Upcoming Assessments, Certificates Issued
// Assessment Queue: participant name, program tag, scheduled date, Competent/NYC buttons
// POST /assess/decision { assessment_id, final_decision, reviewer_id: 1 }
// ⚠️ TYPO line 14: GET /assessments/my (misspelled "assessments")
// ⚠️ TYPO line 67: `assessments.filter(...)` but state is `assessments`, loop uses `assessments.map()`
```
Line 8 declares `assessments`; lines 11/14/48/55 use `assessments`; line 67 uses `assessments`. Runtime crash on render.

---

### `src/app/certificate/verify/page.tsx` — Certificate Verification (1–123)

```tsx
"use client";
// Search input with Search icon, "Verify" button
// Loading spinner, Valid card (shows user_name, program_name, issue_date, certificate_number), Invalid card
// GET /certificates/verify/:number
// Auto-verifies from URL param certNumber via useEffect
// Best-designed page: rounded-3xl card, animate-in transitions, ShieldCheck icon
```

---

### `src/context/AuthContext.tsx` — Auth Provider (1–59)

```tsx
// User interface: { id, name, email, role }
// Persistence: localStorage (auth_token, user_data)
// login(token, user) → writes to localStorage + state
// logout() → clears both localStorage keys
// isLoading: true during bootstrap, false after localStorage check
```

---

### `src/services/api.ts` — Axios Client (1–33)

```tsx
// baseURL: process.env.NEXT_PUBLIC_API_GATEWAY_URL || 'http://localhost:8080'
// Request: JWT Bearer from localStorage
// Response: 401 → window.location.href = '/login'
```

---

## Design Tokens (`tailwind.config.js`)

```javascript
colors: {
  primary:   { DEFAULT: '#1C4ED8', dark: '#153eb1', light: '#4d6df5' }
  secondary:               '#F3F4F6'          // background gray
  accent:                                '#10B981'  // green success
  warning:                                '#F59E0B'  // amber
  danger:                                 '#EF4444'  // red
}
fontFamily: {
  heading: ['Montserrat', 'sans-serif']
  sans:    ['Inter', 'sans-serif']
}
```

---

## Dependencies (`package.json`)

| Package | Version | Purpose |
|---------|---------|---------|
| `next` | `14.0.0` | React framework (App Router) |
| `react` / `react-dom` | `^18` | UI library |
| `tailwindcss` | `^3.3.0` | CSS framework |
| `lucide-react` | `^0.290.0` | Icon library |
| `axios` | `^1.6.0` | HTTP client |
| `clsx` / `tailwind-merge` | `^2.0.0` | Conditional class utilities |
| `@tanstack/react-query` | `^5.0.0` | Data fetching (installed but unused) |
| `typescript` | `^5` | Type system |

---

## Gaps / Needs More Data

| Gap | File | Detail |
|-----|------|--------|
| ❌ Signup / Registration page | — | No signup page. Registration only inline in Program Detail |
| ❌ Program catalog listing page | — | Landing page only has 3 mock cards. No `/programs` listing page |
| ❌ Checkout / Payment flow | — | "Enroll Now" only triggers alert. No payment page |
| ❌ My Programs sub-page | `dashboard/layout.tsx` → `/dashboard/participant/programs` | Linked in sidebar, no file |
| ❌ Certificates list sub-page | `dashboard/layout.tsx` → `/dashboard/participant/certificates` | Linked in sidebar, no file |
| ❌ System Settings page | `dashboard/layout.tsx` → `/dashboard/admin/settings` | Linked in sidebar, no file |
| ❌ Manage Programs (CRUD) page | `dashboard/layout.tsx` → `/dashboard/admin/programs` | "Edit" button is stub |
| ❌ Invoice Detail page | `dashboard/layout.tsx` → `/dashboard/finance/invoices` | Linked, no file |
| ❌ Payment Reports page | `dashboard/layout.tsx` → `/dashboard/finance/reports` | Linked, no file |
| ❌ Scheduling page | `dashboard/layout.tsx` → `/dashboard/assessor/schedule` | Linked, no file |
| ❌ Scoring detail page | `dashboard/layout.tsx` → `/dashboard/assessor/scoring` | Linked, no file |
| ❌ `/components/` directory | — | No reusable components — all pages are monolithic |
| ⚠️ Assessor page crashes | `dashboard/assessor/page.tsx` line 67 | `assessments` typo — state is `assessments`, loop is `assessments` |
| ⚠️ Finance summary always 0 | `dashboard/finance/page.tsx` lines 18-19 | `summary` computed before `setInvoices` state update resolves |

---

## Navigation Structure Summary

```
/dashboard/participant          ✅ exists
/dashboard/participant/programs ❌ missing
/dashboard/participant/certificates ❌ missing
/profile                        ✅ exists
/dashboard/admin                ✅ exists
/dashboard/admin/programs       ❌ missing (edit stub only)
/dashboard/admin/verify         ✅ exists (embedded in admin page)
/dashboard/admin/settings       ❌ missing
/dashboard/finance              ✅ exists
/dashboard/finance/invoices     ❌ missing
/dashboard/finance/reports      ❌ missing
/dashboard/assessor             ✅ exists
/dashboard/assessor/schedule    ❌ missing
/dashboard/assessor/scoring     ❌ missing
```

---

*Generated: 2026-05-17 22:37*
*Source: D:\Portfolio\Certification-Marketplace\ (explore report 2026-05-17_design-professional-ui-ux-certification-marketplace.md)*
