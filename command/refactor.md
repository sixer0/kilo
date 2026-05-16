---
description: Refactor code with best practices
agent: coder-execution
model: kilo/minimax/minimax-2.7
subtask: true
---

Refactor the following code: $ARGUMENTS

## Workflow

### 1. ANALYZE
- Read and understand the current code
- Identify code smells (duplication, long methods, etc.)
- Map dependencies and usage patterns

### 2. PLAN
- List specific refactoring steps
- Prioritize changes (high impact first)
- Identify risks and rollback points

### 3. EXECUTE
- Apply refactoring incrementally
- Preserve all existing functionality
- Update tests if behavior changes

### 4. VERIFY
- Run tests to ensure nothing breaks
- Check that refactoring goals are met
- Verify code quality improved

## Focus Areas
- Improve code readability and maintainability
- Follow SOLID principles
- Reduce complexity and duplication
- Clean up naming and formatting
- Add comments for complex logic

## Output Format

```
REFACTOR_COMPLETE

## Changes Made
| File | Refactoring Type | Impact |
|------|-------------------|--------|
| file.js | Extract Method | + readability |

## Code Quality Improvements
- [improvement 1]
- [improvement 2]

## Verification
- ✅ Tests pass
- ✅ Functionality preserved
```

If blocked:
```
REFACTOR_BLOCKED: [reason]
Issue: [specific problem]
Needed: [what is required]
```
