---
task: notification-service-design
date: 2026-05-17
agent: data-analyst-free
type: plan
based_on: analysis/notification-service-design.md
---

# Implementation Plan: Notification Service

## Current State
The Notification Service is currently missing. Other services (Registration, Payment, etc.) have no centralized way to send alerts to users.

## Target State
A standalone microservice that manages notification templates and delivers messages via WhatsApp and Email based on system events.

## Steps
1. **Database Infrastructure**
   - Create `notification_db` schema in the shared MySQL cluster.
   - Implement `notification_templates` and `notifications` tables.
2. **Template Management**
   - Create a seed script to populate mandatory templates defined in the PRD.
   - Implement internal logic to parse `{{placeholder}}` in templates.
3. **Adapter Layer**
   - Implement `SmtpAdapter` for email delivery.
   - Implement `WhatsAppAdapter` for WA Gateway integration.
   - Create a `NotificationDispatcher` to route messages based on channel.
4. **API Implementation**
   - Implement `POST /notify/send` for single-user transactional messages.
   - Implement `POST /notify/broadcast` for segment-based bulk messages.
5. **Inter-Service Integration**
   - Integrate Registration Service $\rightarrow$ Notify (Approval/Rejection).
   - Integrate Payment Service $\rightarrow$ Notify (Invoice/Reminder/Confirmation).
   - Integrate Assessment Service $\rightarrow$ Notify (Schedule/Results).
   - Integrate Certificate Service $\rightarrow$ Notify (Issuance).
6. **Verification & Testing**
   - Unit tests for template parsing.
   - Integration tests for each adapter.
   - End-to-end test: Trigger a payment and verify email/WA delivery.

## Dependencies
- **User Service**: Required to fetch user contact details (phone/email).
- **WA Gateway**: External API for WhatsApp delivery.
- **SMTP Server**: External/Internal server for email delivery.

## Blockers/Challenges
| Blocker | Solution |
|---------|----------|
| WA Gateway API Keys | Coordinate with DevOps for credentials |
| SMTP Relay Config | Ensure firewall allows SMTP traffic from the service |
| User Data Latency | Implement caching for user contact details |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Gateway Rate Limits | High | Medium | Implement a request queue with delayed retries |
| Incorrect Contact Data | Medium | High | Validate phone/email format in User Service before sending |
| Template Mismatch | Low | Medium | Use strict slug-based template IDs |

## Next Steps
1. Execute DB migrations.
2. Implement the adapter interfaces.
3. Build the `/notify/send` endpoint.

---
*Generated: 2026-05-17 16:20*
