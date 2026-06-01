# Notification Service Technical Design

## 1. Overview
The Notification Service is responsible for delivering communications to users via multiple channels (WhatsApp and Email). It acts as a centralized hub for all system-generated alerts and manual broadcasts.

## 2. Requirements Analysis
### 2.1 Notification Events
Based on the PRD, the following events must trigger notifications:
- **Registration Approved**: Sent to Participant when their registration is verified.
- **Payment Reminder**: Sent to Participant when an invoice is nearing its due date.
- **Assessment Schedule**: Sent to Participant and Assessor when an assessment is scheduled.
- **Certificate Issued**: Sent to Participant when their certificate is ready for download.

### 2.2 Supported Channels
- **WhatsApp**: Primary channel for urgent alerts and reminders.
- **Email**: Used for official documents, invoices, and backups.

## 3. Architecture Design
### 3.1 API Specification
| Endpoint | Method | Description | Payload |
|----------|--------|-------------|---------|
| `/notify/send` | POST | Sends a notification to a specific user | `{ userId, templateId, params }` |
| `/notify/broadcast` | POST | Sends a notification to a list of users | `{ userIds, templateId, params }` |
| `/notify/status/:id` | GET | Retrieves the delivery status of a notification | N/A |

### 3.2 Database Schema (`platform_notification_db`)
#### Table: `notification_templates`
- `id` (INT, PK)
- `channel` (ENUM: 'email', 'whatsapp')
- `template_name` (VARCHAR)
- `subject` (VARCHAR) - for email
- `body` (TEXT) - with placeholders (e.g., `{{name}}`)
- `created_at` (TIMESTAMP)

#### Table: `notifications`
- `id` (INT, PK)
- `user_id` (INT)
- `template_id` (INT, FK)
- `status` (ENUM: 'pending', 'sent', 'failed')
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### Table: `notification_logs`
- `id` (INT, PK)
- `notification_id` (INT, FK)
- `channel` (ENUM: 'email', 'whatsapp')
- `provider_response` (TEXT)
- `sent_at` (TIMESTAMP)

## 4. Implementation Strategy
### 4.1 Integration Adapters
- **WhatsApp Adapter**: Will use an HTTP client to communicate with a third-party WhatsApp Gateway.
- **Email Adapter**: Will use `nodemailer` for SMTP communication.

### 4.2 Trigger Mechanism
The Notification Service will be called via REST API from other services:
- `Registration Service` $\rightarrow$ `/notify/send` (Event: Registration Approved)
- `Payment Service` $\rightarrow$ `/notify/send` (Event: Payment Reminder)
- `Assessment Service` $\rightarrow$ `/notify/send` (Event: Assessment Schedule)
- `Certificate Service` $\rightarrow$ `/notify/send` (Event: Certificate Issued)

## 5. Success Metrics
- Delivery rate > 95%.
- Latency from event trigger to notification send < 30 seconds.
- Complete audit trail of all sent notifications.
