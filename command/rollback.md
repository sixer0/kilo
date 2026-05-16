---
description: Undo commits with safety checks
model: kilo/openrouter/free
subtask: false
---

Undo commits safely with analysis:

## Workflow

### 1. ANALYZE
```bash
# Show recent commits
git log -5 --oneline

# Show what will be undone
git show --stat <commit>

# Check if pushed
git log origin/main..HEAD --oneline
```

### 2. ASSESS
- How many commits to undo
- Has content been pushed?
- What files will be affected
- Risk level

### 3. SUGGEST OPTIONS
Based on analysis:

| Scenario | Recommended Action |
|----------|-------------------|
| Local uncommitted | git reset --soft HEAD~1 |
| Last commit not pushed | git reset --soft HEAD~1 |
| Want to keep changes | git revert HEAD |
| Want to discard | git reset --hard HEAD~1 |
| Already pushed | git revert HEAD |

### 4. EXECUTE (with confirmation)
Never auto-force push. Present options and let user choose.

## Output Format

```
## Git Undo Analysis

### Commit to Undo
| Hash | Message | Date | Author |
|------|---------|------|--------|
| abc123 | feat: add feature | Apr 8 | User |

### Already Pushed?
- ⚠️ Yes - use `git revert` instead

### Options
1. **Keep changes** (recommended): `git revert HEAD`
2. **Discard completely**: `git reset --hard HEAD~1`

### Warning
- This will [effect description]
- Undo with: [command]

### Recommended
[Recommended action with reasoning]
```
