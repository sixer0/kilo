---
description: Quick code review
agent: verifier
model: kilo/minimax/minimax-2.7
subtask: true
---

Review the code: $ARGUMENTS

## Workflow

### 1. READ
- Read the code files to review
- Identify language/framework used
- Note existing patterns

### 2. REVIEW
Analyze for:
- Code quality and best practices
- Potential bugs or issues
- Security vulnerabilities
- Performance considerations
- Error handling completeness
- Code maintainability

### 3. REPORT
Provide actionable feedback with severity ratings:
| Severity | Meaning |
|----------|---------|
| 🔴 High | Must fix before deploy |
| 🟡 Medium | Should address |
| 🟢 Low | Improvement suggestion |

## Output Format

```
## Code Review

### Files Reviewed
| File | Lines | Purpose |
|------|--------|---------|
| file.js | 150 | Feature X |

### Issues Found
| Severity | File | Line | Issue | Suggestion |
|----------|------|------|-------|------------|
| 🔴 High | file.js | 42 | Null check missing | Add validation |

### Positive Observations
- [Good practice 1]
- [Good practice 2]

### Summary
- 🔴 High: [count]
- 🟡 Medium: [count]
- 🟢 Low: [count]
```
