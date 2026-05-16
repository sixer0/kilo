---
description: Debug code issues
agent: coder-execution
model: kilo/minimax/minimax-2.7
subtask: true
---

Debug the following issue: $ARGUMENTS

## Workflow

### 1. COLLECT CONTEXT
- Get error message or unexpected behavior description
- Obtain relevant code snippets
- Get reproduction steps if available

### 2. INVESTIGATE
- Read and analyze the relevant code
- Trace the execution flow
- Identify root cause
- Check for related issues in codebase

### 3. FIX
- Apply the fix
- Ensure fix doesn't introduce new issues
- Add error handling if missing

### 4. VERIFY
- Confirm the fix works
- Test edge cases
- Verify no regression in related functionality

## Output Format

```
DEBUG_COMPLETE

## Problem
[Description of the issue]

## Root Cause
[What was causing the issue]

## Solution
[How it was fixed]

## Changes Made
| File | Line | Fix |
|------|------|-----|
| file.js | 42 | Fixed null check |

## Verification
- ✅ Error resolved
- ✅ Edge cases tested
- ✅ No regression
```

If blocked:
```
DEBUG_BLOCKED: [reason]
Issue: [specific problem]
Needed: [stack trace / reproduction steps]
```
