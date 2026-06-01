---
task_id: certification-marketplace-frontend
task_slug: certification-marketplace-frontend
date: 2026-05-17
agent: request-translator
intent: Plan and implement the web frontend for the Certification Marketplace using Next.js, React, Tailwind CSS with specified user roles and pages, integrating with the API Gateway.
status: pending
---

# Task: Frontend Development for Certification Marketplace

## Original User Request
Task: Plan and implement the web frontend for the Certification Marketplace.
Target: PRD/certification-platform.md, PRD/Plan.md, and all implemented microservices.
Requirements:
1. Modern marketplace design reference (e.g., Udemy, Coursera).
2. Tech Stack: Next.js, React, Tailwind CSS (as specified in PRD).
3. User Roles: Participant, Admin, Finance, Assessor.
4. Key Pages:
   - Landing Page (Program Catalog).
   - Program Detail Page.
   - User Dashboard (Registration status, My Certificates).
   - Admin Dashboard (Program management, Participant verification).
   - Finance Dashboard (Invoices, Payment tracking).
   - Assessor Dashboard (Assessment scheduling, Scoring).
   - Public Certificate Verification Page.
5. Integration: Connect to the API Gateway for all backend communications.
Expected: A structured task breakdown in `~/.config/kilo/output/tasks/` including design analysis, scaffolding, page implementation, and integration testing.

## Intent
Plan and execute the complete frontend implementation for the Certification Marketplace, covering design analysis, project scaffolding, page development for all required user roles, API integration, and testing.

## Primary Task
Develop a full-featured, modern web frontend for the Certification Marketplace according to the PRD specifications.

## Structured Tasks
| Step | Task | Agent | Expected Output |
|------|------|-------|-----------------|
| 1 | Review PRD documents (certification-platform.md, Plan.md) and extract UI/UX requirements | explore | Summary of design requirements, component list, page flow |
| 2 | Conduct design analysis referencing Udemy/Coursera, create UI component library plan | pm-analyst | Design analysis report with style guide and component specs |
| 3 | Scaffold Next.js project with Tailwind CSS, configure ESLint/Prettier, set up folder structure | coder-execution | Initialized repo with `next-app` scaffold and Tailwind setup |
| 4 | Implement shared layout, navigation, authentication wrapper | coder-execution | Layout components, NavBar, AuthProvider |
| 5 | Build Landing Page (program catalog) with filters, search, program cards | coder-execution | `pages/index.tsx` and related components |
| 6 | Build Program Detail Page with enrollment flow | coder-execution | `pages/program/[id].tsx` and components |
| 7 | Implement Participant Dashboard (registration status, certificates) | coder-execution | `pages/dashboard/participant.tsx` and API hooks |
| 8 | Implement Admin Dashboard (program management, verification) | coder-execution | `pages/dashboard/admin.tsx` and admin API integration |
| 9 | Implement Finance Dashboard (invoices, payments) | coder-execution | `pages/dashboard/finance.tsx` and finance API hooks |
|10 | Implement Assessor Dashboard (scheduling, scoring) | coder-execution | `pages/dashboard/assessor.tsx` and assessor API hooks |
|11 | Implement Public Certificate Verification Page | coder-execution | `pages/certificate/verify.tsx` with QR/ID lookup |
|12 | Add role‑based route protection and UI visibility logic | coder-execution | Higher‑order auth components, role checks |
|13 | Integrate all pages with API Gateway (REST/GraphQL as defined) | coder-execution | Service layer (`services/api.ts`) with unified request handling |
|14 | Write unit tests for components and integration tests for pages | test-expert | Jest+React Testing Library test suite |
|15 | Perform end‑to‑end testing using Cypress/Playwright | verifier | E2E test scripts covering critical user flows |
|16 | Generate documentation (README, UI component guide) | document-writer | Markdown docs in `docs/` folder |
|17 | Create Pull Request targeting `frontend` branch, link to PRD files | git-specialist | PR URL with description and checklist |

## Scope
- **Files**: All files under the `frontend/` or `src/` directory of the repository, PRD markdown files, configuration files.
- **Folders**: `frontend/`, `frontend/components/`, `frontend/pages/`, `frontend/services/`, `frontend/styles/`.

## Constraints
- Must use Next.js (latest stable), React 18+, Tailwind CSS.
- Follow accessibility best practices (WCAG 2.1 AA).
- UI should be responsive and mobile‑first.
- Role‑based access control must defer to backend JWT tokens.
- Align visual design with Udemy/Coursera style (clean, card‑based, prominent CTAs).
- All code should pass existing linting and CI checks.

## Dependencies
- Completion of backend microservices and API Gateway specifications.
- Availability of authentication endpoints (login, token refresh).

## Source Documents
| Path | Type | Purpose | References |
|------|------|---------|------------|
| PRD/certification-platform.md | markdown | Functional requirements | Sections: Architecture, Roles, Pages |
| PRD/Plan.md | markdown | Project plan and timelines | Milestones, Sprint breakdown |

## Output Requirements
- **Format**: Markdown task file as created.
- **Destination**: `~/.config/kilo/output/tasks/2026-05-17_certification-marketplace-frontend.md`
- **Style**: Clear tables, headings, and concise descriptions.

## Notes
- Assumes repository is a monorepo; frontend will be in its own directory.
- Subsequent agents will read this task file to execute each step.

---
*Generated: 2026-05-17 17:42:00*
*Last Updated: 2026-05-17 17:42:00*
