---
task: design-professional-ui-ux-certification-marketplace
date: 2026-05-17
agent: data-analyst
type: requirements
confidence: HIGH
task_file: output/tasks/2026-05-17_certification-marketplace-frontend.md
based_on: output/analysis/2026-05-17_ui-ux-analysis-part1.md
---

# Data Analysis Report: UI/UX Redesign (Part 2)

## Overview
Component architecture blueprint for scalable, consistent UI implementation. Defines primitives, state patterns, and Tailwind integration.

## Component Architecture

### `components/ui/` Primitives Directory Structure
```
components/
  ui/
    layout/
      Navbar.tsx      # Role-aware navigation with collapsible mobile menu
      Sidebar.tsx     # Collapsible with active state indicators, grouped nav
      Footer.tsx      # Simple footer with links
    form/
      Input.tsx       # Text, email, password variants with validation states
      Button.tsx      # Primary, secondary, ghost variants with loading state
      Select.tsx      # Dropdown with search filter
    display/
      Card.tsx        # Course/program card with image, badge, CTA
      Table.tsx       # Data table with sorting, pagination
      Badge.tsx       # Status, category, trust badges
    feedback/
      Modal.tsx       # Headless UI Dialog wrapper with Framer Motion
      Toast.tsx       # Auto-dismiss notifications (replaces alert())
      Skeleton.tsx    # Loading placeholders matching component shape
      EmptyState.tsx  # Empty data illustration with action CTA
```

### Component Props Interface (Concise)
```typescript
// Button.tsx
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'ghost'
  loading?: boolean
  disabled?: boolean
  onClick?: () => void
}

// Card.tsx
interface CardProps {
  title: string
  description?: string
  badge?: string
  progress?: number
  onEnroll?: () => void
}

// Skeleton.tsx
interface SkeletonProps { type: 'card' | 'table-row' | 'text' | 'circle' }
```

## Consistency Strategy

### Tailwind Design Tokens
```javascript
// tailwind.config.js additions
theme: {
  extend: {
    colors: {
      primary: { DEFAULT: '#1A45C5', hover: '#1E40AF' }
      surface: { DEFAULT: '#FFFFFF', elevated: '#F9FAFB', subtle: '#F3F4F6' }
      status: { success: '#10B981', error: '#EF4444', warning: '#F59E0B' }
    },
    borderRadius: { lg: '0.5rem', xl: '0.75rem' }
  }
}
```

### Global Style Enforcement
- Use `className="container mx-auto px-4"` for consistent horizontal padding
- Card spacing: `p-6` for content, `gap-4` for internal spacing
- Typography: `text-base` body, `text-lg` section titles, `text-2xl` page headers

## State-Driven UI Patterns

### Skeleton Implementation
- Render during API fetch
- Match component dimensions exactly
- Animate with `animate-pulse`
```tsx
{loading ? <Skeleton type="card" /> : <ProgramCard {...data} />}
```

### EmptyState Implementation
- Triggered when data array is empty
- Show relevant illustration + action CTA
- Example: Empty cart → "Browse programs" button

### Modal + Toast State Flow
```tsx
const [modalOpen, setModalOpen] = useState(false)
const [toast, setToast] = useState(null)

// Trigger via React state only
<button onClick={() => setModalOpen(true)}>Enroll</button>
```

## Files to Create (Priority)
1. `frontend/src/components/ui/layout/Navbar.tsx`
2. `frontend/src/components/ui/layout/Sidebar.tsx`
3. `frontend/src/components/ui/form/Button.tsx`
4. `frontend/src/components/ui/form/Input.tsx`
5. `frontend/src/components/ui/display/Card.tsx`
6. `frontend/src/components/ui/display/Table.tsx`
7. `frontend/src/components/ui/feedback/Modal.tsx`
8. `frontend/src/components/ui/feedback/Toast.tsx`
9. `frontend/src/components/ui/feedback/Skeleton.tsx`
10. `frontend/src/components/ui/feedback/EmptyState.tsx`

## Implementation Order
1. **Atoms**: Button, Input (form/)
2. **Molecules**: Card, Badge (display/)
3. **Organisms**: Modal, Toast (feedback/)
4. **Layout**: Navbar, Sidebar (layout/)
5. **States**: Skeleton, EmptyState (feedback/)

---
*Generated: 2026-05-17 22:48*