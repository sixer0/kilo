# Implementation Plan: Education & Certification Management Platform

## Current Progress Summary
- **Overall Status**: ~70% Complete
- **Completed Phases**: Phase 1, Phase 2, Phase 3
- **Partially Completed**: Phase 4 (Assessment implemented, Certificate missing)
- **Pending Phases**: Phase 5, Phase 6
- **Missing Services**: Certificate Service, Notification Service, Reporting Service

## Context
The goal is to implement a comprehensive digital platform for managing the lifecycle of education and certification programs in Indonesia. The system must replace manual, fragmented processes (spreadsheets, WhatsApp, manual docs) with a structured, scalable microservices architecture. 

The primary objective is to digitize the workflow from participant registration and payment through to assessment and certificate issuance, ensuring audit readiness and operational efficiency.

## Architecture Overview
The platform will use a **Microservices Architecture** with a **Shared MySQL Cluster (Domain Separation)**.

- **Frontend**: Next.js, React, Tailwind CSS.
- **Backend**: Node.js (NestJS/Express).
- **Database**: MySQL (one schema per service).
- **Infrastructure**: Docker, Docker Compose, Internal File Storage/NAS.
- **Key Integrations**: Midtrans/Xendit (Payments), WA Gateway, SMTP.

## Implementation Phases

### Phase 1: Foundation & Identity (The "Core") - ✅ COMPLETED
Establish the basic infrastructure and user management.
- [x] **Infrastructure Setup**:
    - Initialize Docker Compose for the entire stack.
    - Setup shared MySQL instance.
- [x] **Auth Service**:
    - Implement JWT authentication with refresh tokens.
    - Define RBAC (Super Admin, Admin, Finance, Assessor, Participant).
    - Endpoints: `/auth/login`, `/auth/logout`, `/auth/refresh`, `/auth/validate`.
- [x] **User & Participant Service**:
    - User profile management.
    - Organization membership mapping.
    - Endpoints: `/users/profile`, `/users/manage`, `/participants/biodata`.
- [x] **API Gateway**:
    - Implement request routing to services.
    - Integrate Auth Service for request validation.

### Phase 2: Program & Intake (The "Offering") - ✅ COMPLETED
Enable the creation of programs and the ability for users to register.
- [x] **Program Service**:
    - Program and Certification Scheme definitions.
    - Scheduling and Quota management.
    - Endpoints: `/programs/create`, `/programs/schedule`, `/programs/quota`.
- [x] **Registration Service**:
    - Online registration workflow.
    - Admin verification pipeline (Draft $\rightarrow$ Submitted $\rightarrow$ Verified).
    - Waitlist management.
    - Endpoints: `/register`, `/registration/verify`, `/registration/status`.

### Phase 3: Financials & File Management (The "Enablement") - ✅ COMPLETED
Handle payments and the storage of supporting documents.
- [x] **Document Service**:
    - Secure upload/download system.
    - File organization by domain (participants, certificates, etc.).
    - Signed access implementation.
    - Endpoints: `/docs/upload`, `/docs/download`, `/docs/validate`.
- [x] **Payment Service**:
    - Invoice generation.
    - Integration with Midtrans/Xendit.
    - Payment tracking and reconciliation.
    - Endpoints: `/payments/invoice`, `/payments/webhook`, `/payments/status`.

### Phase 4: Evaluation & Issuance (The "Outcome") - ⚠️ IN PROGRESS
The core value proposition: assessing competency and issuing certificates.
- [x] **Assessment Service**:
    - Digital assessment forms and scoring.
    - Competency checklist workflows.
    - Assessor review and decisioning (Competent / Not Yet Competent).
    - Endpoints: `/assess/schedule`, `/assess/score`, `/assess/decision`.
- [ ] **Certificate Service** (MISSING):
    - PDF certificate generation.
    - Unique numbering and QR code verification.
    - Digital signature support.
    - Endpoints: `/certificates/generate`, `/certificates/verify`, `/certificates/track`.

### Phase 5: Support & Intelligence (The "Optimization") - ❌ PENDING
Notifications and operational insights.
- [ ] **Notification Service** (MISSING):
    - Integration with WA Gateway and SMTP.
    - Event-driven triggers (Payment reminder, Cert issued).
    - Endpoints: `/notify/send`, `/notify/broadcast`.
- [ ] **Reporting Service** (MISSING):
    - Operational dashboards for Admin/Finance.
    - KPI tracking and export (PDF/Excel).
    - Endpoints: `/reports/dashboard`, `/reports/export`.

### Phase 6: Final Integration & Hardening - ❌ PENDING
- [ ] **End-to-End Workflow Testing**:
    - Validate the full sequence from Registration $\rightarrow$ Payment $\rightarrow$ Assessment $\rightarrow$ Certificate.
- [ ] **Performance Tuning**:
    - Optimize database queries for the dashboard (< 2s load).
    - Test concurrent user handling (1000+ users).
- [ ] **Security Audit**:
    - Verify RBAC enforcement across all services.
    - Validate signed access to sensitive documents.

## Database Strategy
Each service will have its own logical schema in the shared MySQL cluster to ensure domain separation.
- `auth_db`: Users, Roles, Permissions.
- `participant_db`: Profiles, OrgMemberships.
- `program_db`: Programs, Schemes, Schedules.
- `registration_db`: Registrations, Statuses.
- `payment_db`: Invoices, Payments, Refunds.
- `assessment_db`: Assessments, Scores.
- `certificate_db`: Certificates, QRLog.

## Verification Plan
1. **Unit/Integration Tests**: Each service must have a test suite for its core endpoints.
2. **Workflow Validation**: Use a test account for each role (Participant, Admin, Finance, Assessor) to walk through the "Certification Workflow Sequence".
3. **Integration Testing**: Verify webhooks from Payment Gateways and delivery of WA/Email notifications.
4. **Performance Test**: Simulate concurrent load using a tool like k6 or JMeter to verify NFRs.
