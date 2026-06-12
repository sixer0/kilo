# Global Memory Index

## Current Project (2026-06-12)
- **Project:** Comprehensive E-commerce App
- **Path:** E:\Projects\e-commerse
- **Stack:** NestJS + Next.js 15 + Prisma + SQLite + Radix UI + Tailwind v4
- **Phase:** Phase 2 COMPLETE | Phase 3 PENDING

## Recent Activities

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
