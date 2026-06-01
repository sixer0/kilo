---
task: certification-marketplace-e2e-user-journey
date: 2026-05-17
agent: data-analyst-free
type: requirements
confidence: HIGH
task_file: PRD/certification-platform.md
last_updated: 2026-05-17 16:50
---

# User Journey Specification for E2E Testing

## Overview
This document defines the complete end-to-end user journey for the Certification Marketplace platform, mapping the flow from the initial participant registration to the final issuance of a certificate. It serves as the primary specification for E2E test case development.

## Original Task Reference
- **Intent**: Define the complete user journey for E2E testing.
- **Scope**: Registration $\rightarrow$ Payment $\rightarrow$ Assessment $\rightarrow$ Certification.
- **Target**: Detailed specification for E2E testing.

## Input Sources Referenced
| Source | File | Items Used |
|--------|------|------------|
| PRD | `PRD/certification-platform.md` | General Certification Workflow, Core Services |
| Plan | `PRD/Plan.md` | Implementation Phases, Service Endpoints |
| Analysis | `output/analysis/2026-05-17_certification-marketplace-implementation-gap.md` | Implementation status, gaps |

## Summary
The user journey is divided into four primary stages: Intake (Registration), Financial Enablement (Payment), Evaluation (Assessment), and Outcome (Certification). Each stage involves specific microservices and status transitions.

## User Journey Map

### Stage 1: Intake (Registration)
**Goal**: Move the participant from a prospective lead to an active participant.

| Step | Action | Service | API Call (Example) | Expected Output | Status Transition |
|------|--------|---------|-------------------|------------------|-------------------|
| 1.1 | Participant registers for a program | `Registration Service` | `POST /register` | Registration ID created | $\rightarrow$ Draft $\rightarrow$ Submitted |
| 1.2 | Participant uploads required biodata/docs | `Document Service` | `POST /docs/upload` | File stored, doc ID returned | N/A |
| 1.3 | Admin verifies registration documents | `Registration Service` | `PATCH /registration/verify` | Verification success | Submitted $\rightarrow$ Verified |
| 1.4 | Admin approves participant for program | `Registration Service` | `PATCH /registration/approve` | Participant added to program | Verified $\rightarrow$ Approved $\rightarrow$ Active Participant |

---

### Stage 2: Financial Enablement (Payment)
**Goal**: Ensure the participant has paid the required fees before proceeding to assessment.

| Step | Action | Service | API Call (Example) | Expected Output | Status Transition |
|------|--------|---------|-------------------|------------------|-------------------|
| 2.1 | System generates invoice upon verification | `Payment Service` | `POST /payments/invoice` | Invoice PDF/Link generated | $\rightarrow$ Payment Pending |
| 2.2 | Participant makes payment via Gateway | `Payment Gateway` | (External Call) | Payment confirmation | N/A |
| 2.3 | Gateway sends webhook to system | `Payment Service` | `POST /payments/webhook` | Payment recorded in DB | Payment Pending $\rightarrow$ Payment Complete |
| 2.4 | Notification of payment success | `Notification Service` | `POST /notify/send` | WA/Email sent to participant | N/A |

---

### Stage 3: Evaluation (Assessment)
**Goal**: Evaluate the participant's competency through a structured assessment.

| Step | Action | Service | API Call (Example) | Expected Output | Status Transition |
|------|--------|---------|-------------------|------------------|-------------------|
| 3.1 | Admin schedules assessment date/time | `Assessment Service` | `POST /assess/schedule` | Schedule confirmed | $\rightarrow$ Assessment Scheduled |
| 3.2 | Participant undergoes assessment | `Assessment Service` | `POST /assess/conduct` | Assessment record created | Scheduled $\rightarrow$ Assessment Conducted |
| 3.3 | Assessor enters scores/competency check | `Assessment Service` | `POST /assess/score` | Scores saved | Conducted $\rightarrow$ Assessor Review |
| 3.4 | Assessor makes final competency decision | `Assessment Service` | `POST /assess/decision` | Decision (Competent/NYC) | Review $\rightarrow$ Competent / Not Yet Competent |

---

### Stage 4: Outcome (Certification)
**Goal**: Issue a valid, verifiable certificate to competent participants.

| Step | Action | Service | API Call (Example) | Expected Output | Status Transition |
|------|--------|---------|-------------------|------------------|-------------------|
| 4.1 | System triggers certificate generation | `Certificate Service` | `POST /certificates/generate` | PDF Cert created with QR | $\rightarrow$ Certificate Issued |
| 4.2 | Certificate file stored securely | `Document Service` | `POST /docs/upload` | File stored in /certificates/ | N/A |
| 4.3 | Notification of certificate issuance | `Notification Service` | `POST /notify/send` | WA/Email with download link | N/A |
| 4.4 | Participant downloads certificate | `Document Service` | `GET /docs/download` | PDF downloaded via signed link | N/A |
| 4.5 | Third-party verifies QR code | `Certificate Service` | `GET /certificates/verify` | Validation status (Valid/Invalid) | N/A |

---

## Test Path Definitions

### 1. Happy Path (Success Sequence)
`Registration (Submitted)` $\rightarrow$ `Admin Verify` $\rightarrow$ `Payment (Complete)` $\rightarrow$ `Admin Approve` $\rightarrow$ `Assessment (Scheduled)` $\rightarrow$ `Assessment (Conducted)` $\rightarrow$ `Assessor Decision (Competent)` $\rightarrow$ `Certificate Issued` $\rightarrow$ `Downloaded`.

### 2. Failure Paths (Edge Cases)
| Failure Scenario | Point of Failure | Expected System Behavior | Recovery/End State |
|------------------|------------------|---------------------------|---------------------|
| **Registration Rejected** | Step 1.3 | Admin marks as "Rejected" | Status: Rejected. Notification sent. User cannot proceed to payment. |
| **Payment Timeout/Failed** | Step 2.3 | Gateway returns failure or no webhook | Status: Payment Pending. Payment reminder sent via Notification Service. |
| **Assessment Not Competent** | Step 3.4 | Assessor marks as "Not Yet Competent" | Status: Not Yet Competent. Trigger remediation workflow (if applicable). No certificate issued. |
| **Invalid Document Upload** | Step 1.2 | Document Service rejects file type/size | API returns 400 Bad Request. Participant prompted to re-upload. |
| **Certificate QR Invalid** | Step 4.5 | Verification service finds no matching record | Returns "Invalid Certificate". |

## Implementation Order for E2E Tests
1. **Core Identity**: Verify `Auth Service` and `User Service` for all roles.
2. **Intake & Finance**: Test `Registration` $\rightarrow$ `Payment` $\rightarrow$ `Approval` flow.
3. **Assessment**: Test `Scheduling` $\rightarrow$ `Scoring` $\rightarrow$ `Decision` flow.
4. **Full Circle**: Test the complete chain including `Certificate` and `Notification` services.
5. **Negative Testing**: Execute all Failure Paths.

---
*Generated: 2026-05-17 16:50*
*Last Updated: 2026-05-17 16:50*
