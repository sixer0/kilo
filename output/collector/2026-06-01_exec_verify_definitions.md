---
task: exec_verify_definitions
date: 2026-06-01
agent: data-collector
items_collected: 2
last_updated: 2026-06-01 17:38
---

# Data Collection Report

## Task Overview
Collection of full definitions, command patterns, and expected output formats for the 'coder-execution' and 'verifier' agents.

## Files Collected

### Source Files
| File | Purpose | Lines |
|------|---------|-------|
| `C:\Users\sixer\.config\kilo\agent\coder-execution.md` | Definition for coder-execution agent | 124 |
| `C:\Users\sixer\.config\kilo\agent\verifier.md` | Definition for verifier agent | 114 |

### Configuration Files
| File | Purpose |
|------|---------|
| `C:\Users\sixer\.config\kilo\AGENTS.md` | Global agent rules and context |

## Agent Definitions

### 1. Coder-Execution Agent

**Basic Info**
- **Name:** `coder-execution`
- **Description:** Code implementation agent with standards
- **Mode:** `subagent`
- **Role:** Implement code changes based on analysis. Does NOT analyze code logic, plan architecture, or design systems.

**Command Patterns**

| Command | Workflow |
|---------|----------|
| `/refactor` | 1. ANALYZE: Read and understand current code<br>2. PLAN: List specific refactoring steps<br>3. EXECUTE: Apply incrementally<br>4. VERIFY: Check tests pass |
| `/debug` | 1. COLLECT: Get error context<br>2. INVESTIGATE: Trace execution flow<br>3. FIX: Apply the fix<br>4. VERIFY: Confirm fix works |
| `/doc` | 1. DISCOVER: Find code to document<br>2. ANALYZE: Understand purpose<br>3. DOCUMENT: Write clear docs<br>4. INTEGRATE: Place in location |

**Tools Access**
- `read`: Read before modifying
- `edit`: Make targeted changes
- `write`: Create new files
- `todowrite`: Track tasks
- `glob`: Find related files
- `grep`: Locate patterns

**Expected Output Formats**

- **Success:**
  ```
  IMPLEMENTATION_COMPLETE: [summary]

  ## Changes Made
  | File | Change |
  |------|--------|
  | path/file.js | [description] |

  ## Tasks Completed
  - [x] task 1
  - [x] task 2

  ## Verification
  - ✅ Syntax passed
  - ✅ No obvious errors
  ```

- **Blocked:**
  ```
  IMPLEMENTATION_BLOCKED: [reason]
  ```

---

### 2. Verifier Agent

**Basic Info**
- **Name:** `verifier`
- **Description:** Verification and testing agent
- **Mode:** `subagent`
- **Role:** Verify implementations are correct and complete. Does NOT implement code, write new functionality, or suggest architectural changes.

**Command Patterns**

| Command | Workflow |
|---------|----------|
| `/quick-review` | 1. READ: Read code to review<br>2. REVIEW: Analyze quality/issues<br>3. REPORT: Feedback with severity |
| `/security` | Coordinate for security checks (may delegate to security-review). Does NOT do security scanning personally. |
| **UI Verification** | 1. NAVIGATE: `puppeteer_navigate` to target URL<br>2. SCREENSHOT: `puppeteer_screenshot` for visual check<br>3. INTERACT: `puppeteer_click`, `puppeteer_fill` for testing flows<br>4. EVALUATE: `puppeteer_evaluate` for JS validation |

**Tools Access**
- `read`: Read code to verify
- `grep`: Find patterns, check imports
- `bash`: Run syntax checks, linters
- `puppeteer_navigate`: Navigate to URL for verification
- `puppeteer_screenshot`: Capture UI screenshots
- `puppeteer_evaluate`: Execute JS for browser testing

**Expected Output Formats**

- **Success:**
  ```
  VERIFICATION_PASSED: [summary]

  ## Summary
  All checks passed for [files]

  ## Checks
  - ✅ Syntax
  - ✅ Logic
  - ✅ Integration
  - ✅ Regression
  ```

- **Failure:**
  ```
  VERIFICATION_FAILED: [count] issues found

  ## Issues
  | Severity | File | Issue |
  |----------|------|-------|
  | 🔴 High | file.js | [desc] |
  ```

## Collection Log

| Timestamp | Action | Details |
|-----------|--------|---------|
| 17:35 | Collected | `coder-execution.md` |
| 17:36 | Collected | `verifier.md` |
| 17:36 | Collected | `AGENTS.md` (for context) |
| 17:37 | Assembled | Final report |

---
*Generated: 2026-06-01 17:38*
*Last Updated: 2026-06-01 17:38*
