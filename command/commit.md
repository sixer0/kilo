---
description: Create git commit with smart grouping
model: kilo/openrouter/free
subtask: false
---

Create git commit with smart grouping:

## Workflow

### 1. GET STATUS
```bash
git status
git diff --stat
git log -3 --oneline
```

### 2. ANALYZE CHANGES
- Categorize: modified, added, deleted, renamed
- Group related changes logically
- Assess scope: cosmetic, feature, breaking

### 3. CREATE COMMITS
For each group:
- Write conventional commit message
- Stage appropriate files
- Create commit

### 4. REPORT
Show created commits with summaries

## Output Format

```
## Git Commit

### Changes Analyzed
| Type | Files | Scope |
|------|-------|-------|
| Modified | 3 | Feature |

### Commit Created
```
[type]: [description]

- [detail 1]
- [detail 2]
```

### Files Included
- [file list]

### Next Steps
1. `git push`
2. [other suggestions]
```

If multiple logical commits needed:
```
## Git Commits

### Commit 1: [type]: [description]
Files: [list]

### Commit 2: [type]: [description]
Files: [list]

### Next Steps
1. `git push`
```
