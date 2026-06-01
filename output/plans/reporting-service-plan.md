---
task: reporting-service-design
date: 2026-05-17
agent: data-analyst-free
type: plan
based_on: analysis/reporting-service-design.md
---

# Implementation Plan: Reporting Service

## Current State
The Reporting Service is currently a placeholder in the PRD and `docker-compose.yml`. No code exists. All other microservices share a MySQL cluster with separate schemas.

## Target State
A fully functional Reporting Service that provides:
1. A high-performance operational dashboard (< 2s load).
2. Automated KPI calculation (Revenue, Completion, Growth).
3. Excel and PDF export functionality integrated with the Document Service.
4. Secure cross-database read access to aggregated platform data.

## Steps

### Step 1: Infrastructure & Access
- [ ] Create a dedicated MySQL user `reporting_user` with `SELECT` privileges on all `platform_*_db` schemas.
- [ ] Configure `services/reporting-service/src/config/db.js` to use this user.
- [ ] Update `docker-compose.yml` to ensure the Reporting Service is correctly networked.

### Step 2: Data Access Layer (Repositories)
- [ ] Implement `ReportRepository` with methods for:
    - `getGlobalKPIs(startDate, endDate)`
    - `getRevenueTimeSeries(startDate, endDate)`
    - `getRegistrationTimeSeries(startDate, endDate)`
    - `getProgramPerformance()`
- [ ] Validate cross-db query syntax (e.g., `SELECT ... FROM platform_payment_db.payments ...`).

### Step 3: Business Logic (Services)
- [ ] Implement `ReportService`:
    - Logic to format raw DB data into dashboard-ready JSON.
    - Integration with `exceljs` for Excel generation.
    - Integration with `puppeteer` or `pdfkit` for PDF generation.
- [ ] Implement the "Export-to-Document-Service" workflow:
    - Generate file $\rightarrow$ Upload to `DocumentService` $\rightarrow$ Get signed URL.

### Step 4: API Layer (Controllers)
- [ ] Implement `GET /reports/dashboard` with organization-based filtering.
- [ ] Implement `GET /reports/export` with validation for `type` and `reportType`.
- [ ] Add RBAC middleware to restrict access to `Admin` and `Finance` roles.

### Step 5: Validation & Hardening
- [ ] **Performance Test**: Verify `/reports/dashboard` response time is < 2s under simulated load.
- [ ] **Security Audit**: Ensure no data from other organizations is leaked in reports.
- [ ] **Functional Test**: Verify PDF and Excel files are generated correctly and are downloadable.

## Dependencies
- `platform_payment_db`, `platform_participant_db`, `platform_registration_db`, `platform_assessment_db`, `platform_certificate_db` (Read access).
- `Document Service` (API for file upload and signed URLs).
- `Auth Service` (RBAC validation).

## Blockers/Challenges
| Blocker | Solution |
|---------|----------|
| DB Performance | Use `READ UNCOMMITTED` for reporting queries to avoid locking production tables. |
| File Size | For large exports, implement streaming instead of loading the entire report into memory. |
| Schema Changes | Use a mapping layer in the repository to decouple the reporting service from specific table names. |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Production DB Slowdown | Medium | High | Implement query timeouts and limit date ranges for requests. |
| Permission Over-grant | Low | High | Strictly enforce `GRANT SELECT` only; no `INSERT/UPDATE/DELETE` for reporting user. |
| Inaccurate KPIs | Low | Medium | Implement unit tests with a known dataset to verify KPI formulas. |

## Next Steps
1. Setup the `reporting_user` in MySQL.
2. Scaffold the service directory structure.
3. Implement the repository layer first to verify data access.

---
*Generated: 2026-05-17 16:35*
