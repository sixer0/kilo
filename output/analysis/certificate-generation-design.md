---
task: design-pdf-certificate-generation-and-qr-verification
date: 2026-05-17
agent: data-analyst-free
type: requirements
confidence: HIGH
task_file: N/A
last_updated: 2026-05-17 15:45
---

# Technical Design: PDF Certificate Generation & QR Verification

## Overview
This document outlines the technical implementation for the issuance and verification of digital certificates within the Education & Certification Management Platform. The goal is to provide a secure, scalable, and verifiable way to issue professional certificates.

## Original Task Reference
- **Intent**: Design the technical implementation for PDF certificate generation and QR code verification.
- **Scope**: PDF generation, numbering strategy, QR flow, and digital signatures.

## Input Sources Referenced
| Source | File | Items Used |
|--------|------|------------|
| PRD | `PRD/certification-platform.md` | Core requirements, performance targets |
| DB Analysis | `.../analysis/certificate_db_analysis.md` | Proposed schema for `platform_certificate_db` |

## Summary
The system will utilize a template-based PDF generation approach, a structured unique numbering system, and a token-based QR verification mechanism. Digital signatures will be implemented as both visual assets and cryptographic hashes for authenticity.

## Requirements
- **PDF Generation**: High-quality PDF production in < 10 seconds.
- **Uniqueness**: Every certificate must have a globally unique, traceable number.
- **Verifiability**: Publicly verifiable certificates via QR code without requiring user login.
- **Integrity**: Prevention of certificate forgery through digital signatures and server-side validation.

## Proposed Approach

### 1. PDF Generation Strategy
To balance design flexibility and performance, a **Template-Based Filling** approach is recommended.

- **Recommended Library**: `pdf-lib` (for modifying existing PDF templates) or `puppeteer` (for HTML-to-PDF rendering).
- **Implementation**:
    - **Option A (pdf-lib)**: Designers create a professional PDF template with "form fields" or "placeholder coordinates". The service loads the template and fills in the Participant Name, Program, and Date. (Highest performance, best design control).
    - **Option B (Puppeteer)**: Create a high-fidelity HTML/CSS template. Puppeteer renders this in a headless browser and saves it as a PDF. (Easier to iterate on design, slightly higher resource usage).
- **Recommendation**: Use **`pdf-lib`** for the production environment to meet the < 10s target and ensure pixel-perfect branding across different environments.

### 2. Unique Numbering Strategy
The `certificate_number` will follow a structured format to allow for easy identification and audit.

- **Format**: `CERT-{YEAR}-{PROGRAM_ID}-{SEQUENCE}`
    - `CERT`: Constant prefix.
    - `{YEAR}`: 4-digit year of issuance (e.g., 2026).
    - `{PROGRAM_ID}`: Alphanumeric identifier for the certification scheme (e.g., JS-ADV).
    - `{SEQUENCE}`: A 5-to-8 digit padded sequential number (e.g., 00001).
- **Generation Logic**:
    - A database sequence or a counter table per program will be used to generate the `SEQUENCE` to avoid collisions and gaps.
    - The number is generated at the moment of issuance and stored in the `certificates` table.

### 3. QR Code & Verification Flow
The QR code serves as the bridge between the physical/digital document and the system's source of truth.

- **QR Content**: A secure URL pointing to the public verification endpoint.
    - `https://verify.platform.com/v/{verification_token}`
    - `{verification_token}`: A cryptographically secure random string (UUID v4) stored in the `certificates` table.
- **Verification Flow**:
    1. **Scan**: Third party scans the QR code.
    2. **Request**: Browser hits the `/v/{token}` endpoint.
    3. **Validation**:
        - `Certificate Service` lookups the token in `platform_certificate_db.certificates`.
        - Checks if `status == 'active'` and `expiry_date > current_date`.
    4. **Response**: 
        - **Valid**: Display a "Verified" badge with participant details, program name, and issue date.
        - **Invalid/Revoked**: Display a warning that the certificate is not valid.
    5. **Audit**: Every request is logged into `certificate_verification_logs` with IP address and timestamp.

### 4. Digital Signature Implementation
To prevent forgery, a two-layered signature approach will be used.

- **Layer 1: Visual Signature**:
    - Store high-resolution PNG signatures of authorized signers (e.g., CEO, Program Director).
    - The PDF generation process overlays these images onto the designated signature area of the template.
- **Layer 2: Cryptographic Signature (PKI)**:
    - Use a private key (stored in a secure Vault/KMS) to create a digital signature of the PDF's hash.
    - Embed the signature into the PDF metadata using the `node-signpdf` library.
    - This allows PDF readers (Adobe Acrobat, etc.) to show a "Signed and all signatures are valid" message.

## Key Findings

### QR Token vs. ID [Confidence: HIGH]
Using the internal database `id` in the QR code is a security risk (ID enumeration). A random `verification_token` (UUID) is mandatory to prevent unauthorized parties from guessing certificate URLs.

### Rendering Performance [Confidence: HIGH]
Puppeteer is powerful but can be slow and memory-intensive for bulk generation. For an MVP targeting < 10s, `pdf-lib` is the safer choice for performance.

## Files to Modify/Create
- `platform_certificate_db` (Schema as per `certificate_db_analysis.md`)
- `services/certificate-service/` (New service implementation)
- `services/certificate-service/templates/` (PDF templates)
- `services/certificate-service/src/generator.js` (PDF generation logic)
- `services/certificate-service/src/verifier.js` (QR verification logic)

## Implementation Order
1. **Database Setup**: Implement the `platform_certificate_db` schema in `init-all.sql`.
2. **Core Logic**: Implement the unique numbering generation logic.
3. **PDF Engine**: Setup `pdf-lib` and create the first certificate template.
4. **QR Integration**: Implement token generation and QR code embedding in the PDF.
5. **Verification Portal**: Build the public-facing verification endpoint and UI.
6. **Security**: Integrate digital signing (Visual $\rightarrow$ Cryptographic).

## Risks
- **Template Rigidity**: `pdf-lib` requires precise coordinates. Any change in template layout requires updating the code coordinates.
- **Key Management**: Loss of the private key used for cryptographic signing would make it impossible to sign new certificates with the same identity.
- **Performance at Scale**: Bulk issuance of thousands of certificates might spike CPU/Memory. Implementing a queue (RabbitMQ) for generation is recommended for future phases.

## Recommendations
1. **Asynchronous Issuance**: Use a task queue (e.g., BullMQ or RabbitMQ) for certificate generation to prevent API timeouts during peak issuance periods.
2. **Caching**: Cache verification results for popular certificates in Redis to reduce database load.
3. **Template Versioning**: Store template versions in the database so that old certificates can still be regenerated using the template that was active at the time of issuance.

---
*Generated: 2026-05-17 15:45*
*Last Updated: 2026-05-17 15:45*
