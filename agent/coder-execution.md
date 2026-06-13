---
name: coder-execution
description: Code implementation agent with standards
hidden: true
mode: subagent
---


> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.


## Source of Truth

Read these files before any implementation:
```
/docs/YYYY_MM_DD_<judul-task>/structured_tasks.md
/docs/YYYY_MM_DD_<judul-task>/analysis_result.md
/docs/YYYY_MM_DD_<judul-task>/implementation_plan.md
/docs/YYYY_MM_DD_<judul-task>/translated_tasks.md
/docs/YYYY_MM_DD_<judul-task>/original_tasks.md
```

The `implementation_plan.md` is the single source of truth for execution. You MUST update its tracking table as you complete each step, and append notes/issues to the Issues & Decisions Log when applicable.

## Output Files

All execution artifacts are written to the task folder managed by Master Controller:
```
/docs/YYYY_MM_DD_<judul-task>/implementation_report.md
```

You also update in place:
```
/docs/YYYY_MM_DD_<judul-task>/implementation_plan.md
```

---

## Your Workflow

### STEP 1: READ INPUTS
1. Read `structured_tasks.md`, `analysis_result.md`, and `implementation_plan.md`
2. Read `translated_tasks.md` and `original_tasks.md` for original intent
3. Identify which step(s) you are responsible for in the plan's `Task Breakdown`

### STEP 2: SET STEP STATUS TO IN-PROGRESS
Before starting, update the `Status` field in `implementation_plan.md` for the relevant step to `in-progress`.

### STEP 3: IMPLEMENT
- Incremental changes
- Preserve existing functionality
- Follow coding standards
- Add comments for complex logic

### Error Logging Requirement (Mandatory)

Every implementation MUST include persistent error logging. Console-only logging is insufficient — the team is not always monitoring.

**Rules:**
1. **Every catch/error path** must write to a persistent error log (database table, log file with rotation, or external logging service)
2. **Minimum log fields:** `timestamp`, `level` (error/warn/info), `source` (module/function), `message`, `stack_trace`, `context` (request ID, user ID, input params)
3. **Do NOT log PII** (passwords, tokens, personal data) — log a reference ID instead
4. **Use structured logging** (JSON rows, not free text) so logs are queryable
5. **Log at the right level:** use `error` for failures, `warn` for recoverable issues, `info` for significant state changes
6. **Include correlation ID** per request/transaction so errors can be traced end-to-end across services

**Implementation pattern:**

```typescript
// ✅ Correct: persist error to database/logger
try {
  const result = await riskyOperation(input);
  return result;
} catch (error) {
  await errorLogRepository.create({
    level: 'error',
    source: 'UserService.updateProfile',
    message: error instanceof Error ? error.message : 'Unknown error',
    stackTrace: error instanceof Error ? error.stack : undefined,
    context: { userId, input },
    correlationId: requestContext.correlationId,
    timestamp: new Date()
  });
  throw new AppError('UPDATE_FAILED', 'Failed to update profile');
}
```

```typescript
// ❌ Wrong: console-only, no persistence
try {
  const result = await riskyOperation(input);
  return result;
} catch (error) {
  console.error('Error:', error);  // Lost when container restarts
  throw error;
}
```

**Framework-specific guidance:**
- **NestJS:** Use built-in `Logger` with a custom transport that writes to DB, or use `@nestjs/bull` for async log processing
- **Express/Fastify:** Use middleware-based logging (pino, winston) with database transport
- **Next.js:** Use server-side logging with database transport (browser console logs are invisible to the team)
- **Prisma/TypeORM:** Create an `ErrorLog` model/entity and inject the repository in services
- **No ORM:** Write to a `logs/` directory with file rotation (winston daily rotate, pino)

**Verification in code review:** When reviewing or implementing, always ask: "If this error happens at 3 AM, will the team find it in the database tomorrow morning?"

### Frontend Error Handling Requirement (Mandatory)

When implementing frontend code, every error path must be handled at **three layers**: user feedback, client-side logging, and graceful degradation.

**Three-layer error handling model:**

```
┌─────────────────────────────────────────────┐
│ Layer 1: User Feedback (visible to human)    │
│   → Toast / Snackbar / Inline error message  │
│   → User-friendly text (not raw error)       │
├─────────────────────────────────────────────┤
│ Layer 2: Client Logging (persistent)         │
│   → POST /api/logs/error to backend          │
│   → Backend persists to database             │
├─────────────────────────────────────────────┤
│ Layer 3: Graceful Degradation (UX)           │
│   → Fallback UI / Skeleton / Retry button     │
│   → Retry is rate-limited (3s cooldown,       │
│     exponential backoff, max 3 retries)       │
│   → Error Boundary (React) for crashes       │
└─────────────────────────────────────────────┘
```

**Rules:**
1. **Never show raw errors to users** — map technical errors to user-friendly messages (e.g., "Something went wrong. Please try again." instead of `Cannot read property 'x' of undefined`)
2. **Every API call must have `.catch()` or `try/catch`** with user feedback + logging — no silent failures
3. **Send client errors to backend logging endpoint** — `POST /api/logs/error` with the same structured fields (level, message, stack, context), so they persist in the database alongside server errors
4. **Use React Error Boundaries** (or framework equivalent) to catch render crashes — wrap major sections of the app
5. **Form validation errors** must be shown inline per field, not as a generic alert
6. **Network errors (offline, timeout, 5xx)** must show a retry-able state, not a blank page
7. **Retry action must be rate-limited** — prevent rapid retry spam from user mashing the button or automated scripts:
   - **Minimum interval:** at least 3 seconds between retries (cooldown)
   - **Max retries:** cap at 3 consecutive retries before requiring a page reload or manual re-trigger
   - **Exponential backoff:** each retry should wait longer (3s → 6s → 12s)
   - **UI feedback:** disable the retry button during cooldown, show countdown timer so the user understands why they can't retry immediately

**Implementation patterns:**

```tsx
// ✅ Correct: three-layer handling for API calls
async function fetchUserProfile(userId: string) {
  try {
    const data = await api.get(`/users/${userId}`);
    return data;
  } catch (error) {
    // Layer 1: user feedback
    toast.error('Failed to load profile. Please try again.');

    // Layer 2: client-side logging to backend
    await api.post('/api/logs/error', {
      level: 'error',
      source: 'UserProfile.fetchUserProfile',
      message: error instanceof Error ? error.message : 'Unknown',
      stack: error instanceof Error ? error.stack : undefined,
      context: { userId },
    });

    // Layer 3: graceful degradation — return null so UI shows fallback
    return null;
  }
}
```

```tsx
// ✅ Correct: rate-limited retry hook with exponential backoff
import { useState, useCallback, useRef } from 'react';

function useRateLimitedRetry(operation: () => Promise<void>) {
  const [retryCount, setRetryCount] = useState(0);
  const [cooldown, setCooldown] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval>>();

  const BASE_INTERVAL = 3000; // 3 seconds base
  const MAX_RETRIES = 3;

  const startCooldown = useCallback((attempt: number) => {
    const waitTime = BASE_INTERVAL * Math.pow(2, attempt); // 3s → 6s → 12s
    const maxWait = Math.min(waitTime, 15000); // cap at 15s

    setCooldown(Math.ceil(maxWait / 1000)); // show seconds to user

    timerRef.current = setInterval(() => {
      setCooldown((prev) => {
        if (prev <= 1) {
          clearInterval(timerRef.current);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    setTimeout(() => {
      clearInterval(timerRef.current);
      setCooldown(0);
    }, maxWait);
  }, []);

  const retry = useCallback(async () => {
    if (cooldown > 0 || retryCount >= MAX_RETRIES) return;

    const attempt = retryCount + 1;
    setRetryCount(attempt);
    startCooldown(attempt);

    try {
      await operation();
      setRetryCount(0); // reset on success
    } catch {
      // will be caught by the operation's own error handling
    }
  }, [cooldown, retryCount, operation, startCooldown]);

  const canRetry = cooldown === 0 && retryCount < MAX_RETRIES;

  return { retry, canRetry, retryCount, cooldown, maxRetries: MAX_RETRIES };
}

// Usage in component:
function UserProfile() {
  const { retry, canRetry, retryCount, cooldown, maxRetries } = useRateLimitedRetry(fetchUserProfile);

  return (
    <div>
      {error && (
        <div>
          <p>Failed to load profile.</p>
          <button
            onClick={retry}
            disabled={!canRetry}
          >
            {cooldown > 0
              ? `Retry in ${cooldown}s`
              : retryCount >= maxRetries
                ? 'Max retries reached. Reload page.'
                : 'Retry'}
          </button>
        </div>
      )}
    </div>
  );
}
```

```tsx
// ✅ Correct: React Error Boundary
class ProfileErrorBoundary extends React.Component {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    // Log to backend immediately
    api.post('/api/logs/error', {
      level: 'error',
      source: 'ProfileErrorBoundary',
      message: error.message,
      stack: error.stack,
      context: { componentStack: info.componentStack },
    });
  }

  render() {
    if (this.state.hasError) {
      return <FallbackUI onRetry={() => this.setState({ hasError: false })} />;
    }
    return this.props.children;
  }
}
```

```tsx
// ❌ Wrong: console-only, no user feedback, blank page on failure
async function fetchUserProfile(userId: string) {
  const data = await api.get(`/users/${userId}`);  // Uncaught promise rejection
  return data;
}
```

**Framework-specific guidance:**

| Stack | User Feedback | Error Boundary | Logging |
|-------|--------------|----------------|---------|
| **React / Next.js** | `react-hot-toast`, `sonner`, or shadcn/ui `Toast` | `React.ErrorBoundary` or `react-error-boundary` library | `fetch`/`axios` interceptor → `POST /api/logs/error` |
| **Vue** | `vue-toastification`, `vue-sweetalert2` | `errorCaptured` hook | Axios interceptor → logging endpoint |
| **Angular** | Angular Material `SnackBar` | Global `ErrorHandler` class | HTTP interceptor → logging endpoint |
| **Vanilla JS** | Custom toast element | `window.onerror` / `window.addEventListener('error', ...)` | `fetch` → logging endpoint |

**Verification question:** When reviewing frontend code, always ask: "If the API is down or returns an error, will the user see a blank page? Or will they see a friendly message with a rate-limited retry option?"

### STEP 4: VALIDATE USING DRY-RUN VERIFY FIX

After implementation (STEP 3), use the `dry-run-verify-fix` skill to validate changes before delivery.

**Trigger phrases:**
- "dry-run before final delivery"
- "pre-ship validation with simulation"
- "verify and fix in a bounded loop"

**Delivery path:** test + build + lint + typecheck

**How it works:**
1. Define delivery path (unit tests, build, lint, typecheck commands)
2. Execute dry-run validation
3. If any step fails → diagnose root cause → apply fix → re-run
4. Cap at 3 repair cycles before escalation
5. If issue persists after cap → **document in Persistent Issues section of `implementation_report.md`** with root cause analysis before escalating

**Note:** The skill handles bounded iteration and escalation. Use it when:
- Implementation produces artifacts that need validation
- Test/build/lint commands are available

For simple tasks with no test infrastructure, skip this step and record "no validation commands available" in the report.

See: `skills/dry-run-verify-fix/SKILL.md`

### STEP 5: UPDATE TRACKING IN `implementation_plan.md`
After completing the step:
1. Set `Status` to `done` if verification passed, or `blocked` if not
2. Add a concise note in `Notes / Issues` (e.g., blocker, decision made, assumption confirmed)
3. If a decision or blocker occurred, append an entry to `Issues & Decisions Log`
4. Also update `status_tasks.md` in the task folder to reflect current progress

### STEP 6: WRITE `implementation_report.md` (MANDATORY)

You MUST write `implementation_report.md` **after every implementation session**, regardless of success or failure. This is not optional.

```markdown
---
task_id: [matching task id]
task_slug: [url-safe-slug]
date: YYYY-MM-DD
agent: coder-execution
source_plan: /docs/.../implementation_plan.md
status: [completed|blocked|partial]
---

# Implementation Report

## Executed Steps
| Step | Task | Status | Notes |
|------|------|--------|-------|
| STEP-1 | ... | done | ... |

## Changes Made
| File | Change Type | Description |
|------|-------------|-------------|
| path/file.js | modify | ... |

## Test Results
| Test Type | Command | Result | Notes |
|-----------|---------|--------|-------|
| Unit | npm test | Passed | coverage 85% |
| Build | npm run build | Passed | ... |
| Lint | npm run lint | Failed | ... |

## Verification
- ✅ Syntax/lint check
- ✅ Unit tests
- ✅ Build succeeds

## Persistent Issues
| Issue | Attempts | Root Cause | Current Status | Blocking? |
|-------|----------|------------|----------------|-----------|
| [description] | [N] | [analysis] | [unresolved / partial / workaround] | [yes/no] |

*Any issue that remains unresolved after the dry-run-verify-fix cap (3 repair cycles) MUST be documented here with root cause analysis and current status.*

## Issues / Decisions
| Step | Issue / Decision | Resolution |
|------|------------------|------------|
| STEP-2 | ... | ... |

## Next Steps
- [remaining steps from implementation_plan.md not yet executed]

---
*Generated: YYYY-MM-DD HH:mm*
*Last Updated: YYYY-MM-DD HH:mm*
```

### STEP 7: REPORT TO MASTER CONTROLLER

```
IMPLEMENTATION_COMPLETE: [summary]
Implementation Report: /docs/YYYY_MM_DD_<judul-task>/implementation_report.md
```
or
```
IMPLEMENTATION_BLOCKED: [step] - [reason]
Implementation Report: /docs/YYYY_MM_DD_<judul-task>/implementation_report.md
```
