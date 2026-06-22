# Global Memory Index

## Current Projects
- **Project:** Library CLI (dkatalis-test)
- **Path:** E:\Projects\dkatalis-test
- **Stack:** Node.js + TypeScript + tsx (no build step)
- **Phase:** Final report committed and private archive refreshed; local-only/no push
- **Task folder:** `docs/2026_06_18_solve_problem_nodejs_typescript/`
- **Key decision:** Waitlist fulfillment corrected 2026-06-18 — return transfers book to first waitlisted user (book stays borrowed), stores notification, shifts positions. NOT notification-only.

## Current Project (2026-06-12)
- **Project:** Comprehensive E-commerce App
- **Path:** E:\Projects\e-commerse
- **Stack:** NestJS + Next.js 15 + Prisma + SQLite + Radix UI + Tailwind v4
- **Phase:** Phase 2 COMPLETE | Phase 3 PENDING

## Recent Activities

### Library CLI Final Report and Private Archive Refresh (2026-06-19)
- Final report committed locally as `a5f0472437b14e389eba795c09ddd5047f924ca7`; archive report committed through `afac34d`.
- Private tar.gz/ZIP archives regenerated and verified: final report present, `start.sh` mode preserved, stale/prohibited/generated entries absent, no remotes/no push.
- Lesson: archived reports should avoid exact archive byte sizes because report content becomes part of the archive and can cause size self-reference drift.

### Kilo Phase Accountability Workflow (2026-06-19)
- Added centralized `Documentation Accountability Contract` to `AGENTS.md`.
- Added phase accountability inserts to required agent files.
- Created `docs/2026_06_19_phase_accountability_workflow/` with all required phase artifacts.
- Lesson: verify `/output` carefully because a pre-existing directory may exist; confirm no task artifacts or session-modified files are under it.

### Task Architect Scale Category Enhancement (2026-06-21)
- Enhanced `agent/task-architect.md` so task-architect classifies work by scale category and designs Source → Spec → Impact research before implementation planning.
- Added scale-category matrix, research depth rules, structured template sections, and routing guidance for New Project, Enhancement, Refactor, Migration, Research, Debug, and Administration tasks.
- Lesson: scale category should drive research posture, specification rigor, agent mapping, and verification strategy rather than being treated as a passive label.

### Analyst Spec Artifact Assignment (2026-06-21)
- Updated task architecture and analyst planning rules so `data-analyst` creates the canonical `masterplan/01_specs.md` when assigned to the spec phase.
- Updated `AGENTS.md`, `agent/data-analyst.md`, `agent/pm-planner.md`, and `agent/task-architect.md` so the masterplan flow is: research/analysis → `masterplan/01_specs.md` → `masterplan/02_plan.md`.
- Lesson: `pm-planner` should consume the canonical spec artifact instead of planning implementation from analysis alone when formal specs are required.

### E-commerce App Development (2026-06-12)
- **Phase 0 (Foundation):** Monorepo, NestJS backend skeleton, Next.js frontend, Prisma + SQLite, design system primitives, CI/CD — COMPLETE (`f2e17b9`)
- **Phase 1 (Auth & Users):** JWT RS256 auth, refresh rotation, argon2id, profile/addresses, frontend auth pages — COMPLETE (`6ee29fa`, `85b8364`)
- **Phase 2 (Catalog & Search):** Products/Categories/Brands CRUD, FTS5 search, Reviews module, Admin catalog management, frontend catalog pages/components — COMPLETE (`7c15c59`)
- **Phase 2 Code Review Fixes (ALL RESOLVED):**
  - Admin controllers refactored to service layer (AdminCategoriesService, AdminBrandsService)
  - Reviews cursor pagination refactored from offset-style to keyset (created cursor-pagination.util.ts)
  - parseJsonField extracted to common/utils/json.util.ts
  - FtsSyncService registered in CatalogModule, reindex endpoint added
  - Reviews moderation uses @Roles('ADMIN') decorator
  - Validation throws BadRequestException instead of plain objects
  - Schema reconciled via migration (added metaTitle, metaDescription, isFeatured, sessionId, isPrimary, isVerifiedPurchase, PROCESSING/CANCELLED PaymentStatus)
  - CategoryTreeEditor refactored (extracted CategoryFormModal, ReorderControls)
  - FTS error handling now logs warnings

### Previous Sessions...
    - Transformed AI Agent Preview backend into a reusable service for VPS/Kiloclaw.
    - Implemented Provider pattern for Runtime, Storage, and Auth.
    - Added Hybrid Auth (JWT + API Key) and Swagger documentation.
    - Established Docker/PM2 deployment and GitHub Actions CI/CD.
    - Verified end-to-end with automated tests.
- Completed UI/UX redesign for AI Agent Preview using Tailwind, jQuery, SweetAlert2.
  - Built design system (dark-mode-first RGB tokens), reusable components, refactored all pages.
  - Fixed hardcoded hex colors, PostCSS config, port conflicts (3101/3102 after restart).
  - Wrote Puppeteer UAT simulation → 5/5 steps pass.
  - All changes committed and apps running in background.
- **Previous session:** UI/UX redesign for Certification Marketplace using Tailwind CSS and React-native interactions; committed and pushed to GitHub (master branch).

## Key Lessons Learned
### AI Agent Preview (2026-05-18 to 2026-05-19)
1. **PostCSS config is required:** Tailwind 4 needs an explicit `postcss.config.js` (`plugins: { tailwindcss: {}, autoprefixer: {} }`). Zero-config builds can break silently.
2. **Verify ports before automation:** Use `Get-NetTCPConnection -State Listen` to confirm active ports before writing Puppeteer scripts that depend on them.
3. **jQuery in React/Vite:** Install via npm (`npm install jquery`), do NOT use CDN `<script>`. CDN + npm results in duplicate globals and erratic behavior.
4. **jsPDF in Vite:** Use `npm install jspdf`. CDN UMD version conflicts with ESM module resolution and fails silently during PDF generation.
5. **Puppeteer UAT reliability:** Always `await page.waitForSelector(selector)` before any `page.click()`; timeouts without explicit waits cause false-negative test results.
6. **Hex color elimination strategy:** Migrate hardcoded hex values component-by-component, then run a repo-wide grep (`rg '#[0-9a-fA-F]{6}'`) to catch any leftovers in a final sweep.
7. **Sequelize Class Fields Shadowing:** Declaring public class fields in TS models (e.g., `public id: number`) shadows Sequelize's internal getters/setters. Use the `declare` keyword to avoid `undefined` values on retrieved models.
8. **Provider Pattern for Reusability:** Abstracting infrastructure (Runtime, Storage, Auth) behind interfaces allows the service to remain agnostic of the specific environment and enables easy switching between providers (e.g., OpenClaw to KiloClaw).
9. **Hybrid Auth Flow**: Implementing a middleware that prioritizes API keys over JWTs allows seamless integration for both human users (web) and service-to-service calls (VPS/Kiloclaw).

### Certification Marketplace (Earlier session)
7. Semantic Tailwind colors (using `bg-color-foreground` / `text-color-muted`) ensure branding consistency across components.
8. LF vs CRLF line endings require Git config handling on Windows (`core.autocrlf`) to avoid spurious diffs.
9. React-native-style interactions (handler-driven) avoid DOM conflicts in Next.js / server-rendered projects.
10. Role‑aware navigation improves user experience by hiding/showing routes based on account type.
11. Global memory updates (MEMORY.md) help track progress and lessons across sessions and devices.

### Task Architect Scale Category Enhancement (2026-06-21)
1. Scale category should drive research posture, specification rigor, agent mapping, and verification strategy rather than being treated as a passive label.
2. Source → Spec → Impact research should be designed before implementation planning so evidence, acceptance criteria, and blast radius are explicit.

### Analyst Spec Artifact Assignment (2026-06-21)
1. `data-analyst` should create `masterplan/01_specs.md` when assigned to the spec phase.
2. `pm-planner` should consume `masterplan/01_specs.md` before creating `masterplan/02_plan.md`, rather than planning from analysis alone.
