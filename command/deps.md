---
description: Analyze and update dependencies
model: kilo/openrouter/free
subtask: false
---

Analyze project dependencies:

## Workflow

### 1. CHECK DEPENDENCIES
```bash
# Check for outdated packages
npm outdated 2>/dev/null || echo "checking..."

# Check for security vulnerabilities
npm audit --json 2>/dev/null || echo "checking..."

# List all dependencies
npm list --depth=0 2>/dev/null || echo "checking..."
```

### 2. ANALYZE
- Identify outdated packages
- Flag security vulnerabilities
- Detect unused dependencies
- Check for deprecated packages

### 3. RECOMMEND
- Prioritize critical updates
- Suggest safe updates (patch/minor)
- Flag breaking changes (major)
- Recommend removal of unused packages

## Output Format

```
## Dependency Analysis

### Outdated Packages
| Package | Current | Wanted | Latest |
|---------|---------|--------|--------|
| lodash | 4.17.15 | 4.17.21 | 5.0.0 |

### Security Vulnerabilities
| Severity | Package | Issue |
|----------|---------|-------|
| 🔴 High | package@1.0 | Remote code execution |

### Recommendations
1. [High priority update]
2. [Medium priority update]

### Safe Updates
- `npm update` for patch/minor updates

### Breaking Changes to Review
- [Major version updates requiring manual review]
```

If no issues:
```
DEPENDENCY_ANALYSIS_COMPLETE

## Summary
- ✅ All packages up to date
- ✅ No security vulnerabilities
- ✅ No unused dependencies
```
