---
description: Analyze git status and suggest commit actions
model: kilo/openrouter/free
subtask: false
---

Analyze current git status and provide actionable recommendations:

## Workflow

### 1. GET STATUS
```bash
git status
git diff --stat
git log -3 --oneline
```

### 2. ANALYZE CHANGES
- Categorize: modified, added, deleted, renamed
- Assess scope: cosmetic, feature, breaking
- Identify related changes that should be grouped

### 3. SUGGEST
- Propose commit message (conventional commits format)
- Group files into logical commits if multiple
- Identify any concerns (secrets, large files, etc.)

## Output Format

```
## Git Status Analysis

### Changes Summary
| Type | Files | Scope |
|------|-------|-------|
| Modified | 3 | Feature |
| Added | 1 | Feature |
| Deleted | 0 | - |

### Recommended Commit
```
type: description

- detail 1
- detail 2
```

### Warnings (if any)
- ⚠️ [warning 1]
- ⚠️ [warning 2]

### Next Steps
1. `git add [files]`
2. `git commit -m "message"`
3. `git push`
```
