# Frontend Design Analysis: Certification Marketplace

## 1. Design Reference & Inspiration
The design will follow the "Educational Marketplace" pattern seen in platforms like **Udemy** and **Coursera**.

### Key Design Patterns:
- **Discovery-First Landing Page**: A clean, search-centric homepage with categorized program cards.
- **Conversion-Focused Program Pages**: Detailed a-z information with a prominent "Enroll Now" CTA.
- **Role-Based Dashboard Architecture**: A unified layout with a sidebar for navigation, but dynamic content based on user role.
- **Status-Driven Progress Tracking**: Visual steppers for participants to see where they are in the Registration $\rightarrow$ Payment $\rightarrow$ Assessment $\rightarrow$ Certification flow.

## 2. Style Guide

### Color Palette (Professional & Academic)
- **Primary**: `#1C4ED8` (Deep Royal Blue) - Trust, Professionalism, Authority.
- **Secondary**: `#F3F4F6` (Light Grey/White) - Cleanliness, Modernity.
- **Accent**: `#10B981` (Emerald Green) - Success, Competency, Completion.
- **Warning**: `#F59E0B` (Amber) - Pending, Review Required.
- **Danger**: `#EF4444` (Red) - Rejected, Failed.
- **Text**: `#111827` (Near Black) for headers, `#4B5563` (Grey) for body.

### Typography
- **Headings**: Inter / Montserrat (Bold, Sans-Serif) - Strong, modern, readable.
- **Body**: Open Sans / Roboto (Regular, Sans-Sered) - Optimized for long-form content.

### Spacing & Layout
- **Grid**: 12-column responsive grid.
- **Border Radius**: `8px` (Medium) for a modern, friendly but professional look.
- **Shadows**: Soft `shadow-sm` for cards, `shadow-lg` for modals.

## 3. Component Library Plan

### 3.1 Common Components (Atomic)
- **Button**: Variants: `Primary`, `Secondary`, `Outline`, `Ghost`, `Danger`.
- **Input**: Text, Email, Password with integrated validation states.
- **Modal**: Centered overlay for confirmations and quick edits.
- **Card**: Versatile container with optional image, title, and description.
- **Badge**: Status indicators (e.g., "Verified", "Pending", "Competent").

### 3.2 Layout Components (Molecules)
- **NavBar**: Search bar, User Profile dropdown, Role-based links.
- **Sidebar**: Navigation links based on role (Admin: Program Mgmt | Finance: Invoice Mgmt).
- **Footer**: Site map, Contact, Legal.
- **AuthWrapper**: Higher-order component for protected routes.

### 3.3 Domain Components (Organisms)
- **ProgramCard**: Image, title, short desc, price, and "View Details" button.
- **RegistrationStepper**: Visual progress bar (Draft $\rightarrow$ Verified $\rightarrow$ Paid $\rightarrow$ Active).
- **CertificatePreview**: A mini-version of the issued certificate with "Download" and "Verify" links.
- **InvoiceItem**: Row-based payment detail with status badge and "Pay Now" action.
- **Scorecard**: Assessment result display with competency marks (Yes/No).

## 4. User Experience (UX) Flows

### 4.1 Participant Flow
`Landing Page` $\rightarrow$ `Program Detail` $\rightarrow$ `Registration Form` $\rightarrow$ `Payment Gateway` $\rightarrow$ `Dashboard (Tracking)` $\rightarrow$ `Certificate Download`.

### 4.2 Admin Flow
`Login` $\rightarrow$ `Admin Dashboard` $\rightarrow$ `Program Management` $\rightarrow$ `Participant List` $\rightarrow$ `Verification Action` $\rightarrow$ `Approval`.

### 4.3 Finance Flow
`Login` $\rightarrow$ `Finance Dashboard` $\rightarrow$ `Invoice List` $\rightarrow$ `Payment Reconciliation` $\rightarrow$ `Financial Report Export`.

### 4.4 Assessor Flow
`Login` $\rightarrow$ `Assessor Dashboard` $\rightarrow$ `Assigned Assessments` $\rightarrow$ `Scoring Interface` $\rightarrow$ `Final Decision`.

## 5. Technical Stack Implementation
- **Framework**: Next.js 14 (App Router).
- **Styling**: Tailwind CSS.
- **State Management**: React Context API (Auth) & TanStack Query (Server State).
- **API Client**: Axios with Interceptors for JWT handling.
