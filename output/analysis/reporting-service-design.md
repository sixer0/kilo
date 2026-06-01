---
task: reporting-service-design
date: 2026-05-17
agent: data-analyst-free
type: requirements
confidence: HIGH
task_file: PRD/certification-platform.md
last_updated: 2026-05-17 16:30
---

# Data Analysis Report: Reporting Service Design

## Overview
Technical design for the Reporting Service of the Education & Certification Management Platform. This service is responsible for providing operational insights, KPI tracking, and data export for Admin and Finance personas.

## Original Task Reference
- **Task File**: `PRD/certification-platform.md`
- **Intent**: Design the technical implementation for the Reporting Service.
- **Scope**: Operational dashboard, KPI tracking, export functionality (Excel/PDF), and API contract definition.

## Input Sources Referenced
| Source | File | Items Used |
|--------|------|------------|
| PRD | `PRD/certification-platform.md` | Service responsibilities, NFRs, User Personas |
| Plan | `PRD/Plan.md` | Implementation phase (Phase 5), DB strategy |
| Explore | `.../certification-marketplace-exploration.md` | Existing service ports and DB schemas |
| Collector | `.../certification-marketplace-prd-services.md` | DB schema details for other services |

## Summary
The Reporting Service will act as a read-heavy aggregation layer. To meet the performance requirement of < 2s dashboard load, it will leverage the shared MySQL cluster for cross-database read-only queries instead of API aggregation, which would introduce significant latency.

## Requirements
- **Dashboard**: Real-time operational view for Admin (growth, completion) and Finance (revenue).
- **KPIs**: 
    - Total Revenue (Financial)
    - Completion Rate (Operational)
    - Participant Growth (Growth)
- **Export**: Generate and download reports in Excel and PDF formats.
- **API Contracts**: 
    - `GET /reports/dashboard`
    - `GET /reports/export`
- **Performance**: Dashboard load < 2 seconds.

## Proposed Approach

### 1. Data Access Strategy: Cross-Database Queries
Given that all services share a single MySQL cluster, the Reporting Service will be configured with a database user that has `SELECT` permissions across all relevant schemas (`platform_payment_db`, `platform_participant_db`, `platform_registration_db`, `platform_assessment_db`, `platform_certificate_db`).

**Reasoning**: 
- **Performance**: Joining tables across schemas in a single query is orders of magnitude faster than making 5-10 REST calls and aggregating in-memory.
- **Complexity**: Simplifies the logic for complex aggregations (e.g., "Revenue per Program").
- **Consistency**: Ensures a single point-in-time snapshot of the data for the report.

### 2. KPI Technical Definitions

| KPI | Formula / Logic | Source Tables |
|---|---|---|
| **Total Revenue** | `SUM(amount)` where `status = 'PAID'` | `platform_payment_db.payments` |
| **Completion Rate** | `(COUNT(DISTINCT cert_id) / COUNT(DISTINCT reg_id)) * 100` | `platform_certificate_db.certificates` $\bowtie$ `platform_registration_db.registrations` |
| **Participant Growth** | `COUNT(id)` grouped by `created_at` (month/day) | `platform_registration_db.registrations` |
| **Revenue per Program** | `SUM(amount)` grouped by `program_id` | `platform_payment_db.payments` $\bowtie$ `platform_program_db.programs` |

### 3. API Specifications

#### `GET /reports/dashboard`
**Description**: Fetches all summary KPIs and time-series data for the main dashboard.
**Query Params**: `startDate`, `endDate`, `organizationId` (optional).
**Response**:
```json
{
  "summary": {
    "totalRevenue": 150000000,
    "completionRate": 75.5,
    "totalParticipants": 1200,
    "growthRate": 12.4
  },
  "charts": {
    "revenueOverTime": [
      { "date": "2026-01-01", "value": 20000000 },
      { "date": "2026-02-01", "value": 25000000 }
    ],
    "registrationTrend": [
      { "date": "2026-01-01", "value": 100 },
      { "date": "2026-02-01", "value": 150 }
    ]
  }
}
```

#### `GET /reports/export`
**Description**: Triggers a report generation and provides a download link.
**Query Params**: `type` (pdf|excel), `reportType` (revenue|participants|completion), `startDate`, `endDate`.
**Workflow**:
1. Reporting Service generates the file.
2. File is uploaded to Document Service via internal API (`/docs/upload`).
3. Returns a signed download URL from Document Service.
**Response**:
```json
{
  "downloadUrl": "https://api.platform.com/docs/download/abc-123-xyz",
  "expiresAt": "2026-05-17T17:00:00Z"
}
```

### 4. Export Implementation
- **Excel**: Implementation using `exceljs` to create formatted spreadsheets with multiple sheets for detailed breakdowns.
- **PDF**: Implementation using an HTML-to-PDF approach (e.g., `puppeteer` or `pdfkit`) to ensure professional branding and layouts.

## Files to Create
- `services/reporting-service/src/index.js`: Entry point.
- `services/reporting-service/src/controllers/report.controller.js`: Request handling.
- `services/reporting-service/src/services/report.service.js`: Aggregation logic and KPI calculations.
- `services/reporting-service/src/repositories/report.repository.js`: Cross-db SQL queries.
- `services/reporting-service/src/config/db.js`: Multi-schema DB connection.
- `services/reporting-service/init.sql`: (Optional) Specific reporting tables if caching is needed.

## Implementation Order
1. **Database Setup**: Create DB user with read-only access to all schemas.
2. **Repository Layer**: Implement cross-db queries for the 3 core KPIs.
3. **Service Layer**: Implement logic for time-series aggregation and export generation.
4. **Controller Layer**: Implement `/dashboard` and `/export` endpoints.
5. **Integration**: Connect to Document Service for export file storage.
6. **Validation**: Verify load time for dashboard is < 2s.

## Risks
- **Read-Only Access**: If permissions are not strictly managed, the reporting service could accidentally modify data. *Mitigation: Use a dedicated MySQL user with only `SELECT` privileges.*
- **Performance Degradation**: Heavy reports might slow down the production cluster. *Mitigation: Use `READ UNCOMMITTED` isolation level or a Read Replica if available in future phases.*
- **Data Leakage**: Ensuring `organizationId` filters are applied to all queries for multi-tenant isolation. *Mitigation: Implement a mandatory filter middleware for all reporting queries.*

## Recommendations
1. **Materialized Views**: If data grows significantly, consider implementing a summary table (Materialized View) updated periodically to keep dashboard load times sub-second.
2. **Async Export**: For very large reports, change `/reports/export` to an asynchronous pattern (Return `jobId` $\rightarrow$ Poll for status $\rightarrow$ Download).

---
*Generated: 2026-05-17 16:30*
*Last Updated: 2026-05-17 16:30*
