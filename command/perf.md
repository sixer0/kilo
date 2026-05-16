---
description: Performance bottleneck analysis
agent: data-analyst
model: kilo/google/gemini-3.1-flash-lite-preview
subtask: true
---

Analyze performance issues in: $ARGUMENTS

## Workflow

### 1. COLLECT
- Read relevant code
- Identify performance-critical sections
- Get execution context (load, data size, etc.)

### 2. ANALYZE
Check for:
- Slow algorithms (O(n²) or worse)
- N+1 query problems
- Missing indexes in queries
- Memory leaks
- Unnecessary re-renders (UI)
- Large data transformations
- Synchronous blocking operations
- Uncached expensive computations

### 3. MEASURE (if possible)
```bash
# Check bundle size
npm run build -- --analyze 2>/dev/null || echo "checking..."

# Run profiler if available
node --prof file.js 2>/dev/null || echo "checking..."
```

### 4. RECOMMEND
- Prioritize bottlenecks by impact
- Suggest specific optimizations
- Provide implementation guidance
- Estimate improvement potential

## Output Format

```
PERFORMANCE_ANALYSIS_COMPLETE

## Bottlenecks Identified
| Severity | Location | Issue | Impact |
|----------|----------|-------|--------|
| 🔴 High | query.js:42 | N+1 query | 1000ms/req |

## Recommendations
1. [High impact fix]
2. [Medium impact fix]

## Estimated Improvements
- Response time: -40%
- Memory usage: -25%

## Implementation Plan
1. [Step 1]
2. [Step 2]
```

If no issues:
```
PERFORMANCE_ANALYSIS_COMPLETE

## Summary
No significant performance issues found.

## Observations
- [Good practices observed]
```
