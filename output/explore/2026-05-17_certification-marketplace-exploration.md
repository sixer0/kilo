---
task: certification-marketplace-exploration
date: 2026-05-17
agent: explore
scope: Project structure mapping and PRD folder analysis
---

# Project Exploration Report: Certification Marketplace

## Overview
Education & Certification Management Platform using microservices architecture. The project is in the design phase with completed PRD documentation and skeleton code structure for all 8 services.

## Directory Structure

### Directories Found
| Path | Purpose | Status |
|------|---------|--------|
| `services/auth-service/` | Authentication & JWT management | NEW |
| `services/user-service/` | User & participant management | NEW |
| `services/program-service/` | Training program management | NEW |
| `services/registration-service/` | Registration workflow | NEW |
| `services/payment-service/` | Payment & invoice processing | NEW |
| `services/assessment-service/` | Assessment & competency workflow | NEW |
| `services/document-service/` | File storage & management | NEW |
| `services/api-gateway/` | API routing & validation | NEW |
| `PRD/` | Product Requirements Documents | NEW |

### Entry Points Identified
- `services/auth-service/src/index.js` - Auth service entry point
- `services/user-service/src/index.js` - User service entry point
- `services/program-service/src/index.js` - Program service entry point
- `services/registration-service/src/index.js` - Registration service entry point
- `services/payment-service/src/index.js` - Payment service entry point
- `services/assessment-service/src/index.js` - Assessment service entry point
- `services/document-service/src/index.js` - Document service entry point
- `services/api-gateway/src/index.js` - API Gateway entry point

### Configuration Files
- `.env` - Environment variables (DB config, NODE_ENV)
- `docker-compose.yml` - Container orchestration for 8 services
- `init-all.sql` - Database schema initialization script
- `CLAUDE.md` - Agent guidance documentation
- `PRD/certification-platform.md` - Main PRD document (848 lines)
- `PRD/Plan.md` - Implementation plan with 6 phases (109 lines)

### Service Architecture (per service)
Each service follows consistent structure:
```
services/{service-name}/
├── src/
│   ├── index.js           # Entry point
│   ├── controllers/       # Request handlers
│   ├── services/          # Business logic
│   ├── repositories/      # Database access
│   └── config/
│       └── db.js          # Database connection
├── Dockerfile
├── package.json
└── init.sql
```

## File Type Summary
| Extension | Count | Purpose |
|-----------|-------|---------|
| .js | 32 | Node.js source files |
| .md | 4 | Documentation (PRD, Plan, CLAUDE) |
| .sql | 8 | Database initialization scripts |
| .yml | 1 | Docker Compose configuration |
| Dockerfile | 7 | Service container definitions |
| package.json | 8 | Service dependencies |

## Microservices Overview

### Implemented Services
| Service | Port | Database Schema | Purpose |
|---------|------|-----------------|---------|
| API Gateway | 8080 | - | Request routing, auth validation |
| Auth Service | 3001 | platform_auth_db | JWT, RBAC, sessions |
| User Service | 3002 | platform_participant_db | Profiles, organizations |
| Program Service | 3003 | platform_program_db | Programs, schedules |
| Registration Service | 3004 | platform_registration_db | Registrations, waitlists |
| Document Service | 3005 | platform_document_db | File management |
| Payment Service | 3006 | platform_payment_db | Invoices, payments |

### PRD Service Scope (Planned)
| Service | Status | Notes |
|---------|--------|-------|
| Assessment Service | In docker-compose | Missing from compose comments |
| Certificate Service | PRD only | Not yet implemented |
| Notification Service | PRD only | Not yet implemented |
| Reporting Service | PRD only | Not yet implemented |

## Key Findings

### Technology Stack
- **Backend**: Node.js, Express.js
- **Database**: MySQL 8.0 (shared cluster with domain separation)
- **Infrastructure**: Docker, Docker Compose
- **Storage**: Internal NAS/storage volume

### Database Schemas Created
- `platform_auth_db` - Users, roles, permissions
- `platform_participant_db` - Profiles, organizations
- `platform_program_db` - Programs, schemes, schedules
- `platform_registration_db` - Registrations, documents, waitlists
- `platform_document_db` - Documents, access logs
- `platform_payment_db` - Invoices, payments, refunds
- `platform_assessment_db` - Assessments, scores, decisions

### Implementation Phases (from Plan.md)
1. **Phase 1**: Foundation & Identity (Auth, User, API Gateway)
2. **Phase 2**: Program & Intake (Program, Registration)
3. **Phase 3**: Financials & Files (Document, Payment)
4. **Phase 4**: Evaluation & Issuance (Assessment, Certificate)
5. **Phase 5**: Support & Intelligence (Notification, Reporting)
6. **Phase 6**: Integration & Hardening

## Gaps / Needs Investigation
- Assessment Service is referenced but not included in docker-compose services
- Certificate, Notification, and Reporting services exist in PRD but no skeleton code
- No frontend code present yet
- Missing .gitignore file
- No test files detected

---
*Generated: 2026-05-17 14:53*