---
description: Security vulnerability scan
agent: security-review
model: kilo/minimax/minimax-2.7
subtask: true
---

Scan code for security vulnerabilities: $ARGUMENTS

## Workflow

### 1. SCAN
- Read the code to analyze
- Search for common vulnerability patterns

### 2. DETECT
Check for:
- SQL/NoSQL/Command injection
- XSS vulnerabilities (unescaped output)
- Authentication/authorization issues
- Hardcoded secrets, API keys, passwords
- Input validation missing
- Insecure direct object references
- Missing HTTPS usage
- Unsafe deserialization

### 3. ASSESS
- Rate severity (Critical/High/Medium/Low)
- Determine exploitability
- Assess impact if exploited

### 4. REPORT
List all findings with:
- Severity level
- Type of vulnerability
- Exact location (file:line)
- Description
- Remediation steps

## Output Format

```
SECURITY_SCAN_COMPLETE

## Summary
- Total issues: [count]
- 🔴 Critical/High: [count]
- 🟡 Medium: [count]
- 🟢 Low: [count]

## Issues Found
| Severity | Type | Location | Description | Remediation |
|----------|------|----------|-------------|-------------|
| 🔴 High | SQL Injection | query.js:42 | Unsanitized input | Use parameterized queries |

## Recommendations
1. [Priority fix 1]
2. [Priority fix 2]
```

If no issues:
```
SECURITY_SCAN_COMPLETE

## Summary
No security vulnerabilities found.

## Positive Observations
- [Good security practices observed]
```
