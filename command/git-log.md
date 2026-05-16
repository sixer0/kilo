---
description: Show recent commits and branches
model: kilo/openrouter/free
subtask: false
---

Show git history and branch information:

## Workflow

### 1. GET INFO
```bash
# Recent commits
git log -10 --oneline --graph --decorate

# Branch status
git branch -vva

# Stash list
git stash list

# Remote info
git remote -v
```

### 2. ANALYZE
- Current branch status
- Recent commit history
- Working tree status
- Remote tracking

### 3. REPORT
Provide clear status overview

## Output Format

```
## Git Status

### Current Branch
| Branch | Status | Upstream |
|--------|---------|----------|
| main | ✅ Current | origin/main |

### Recent Commits
| Commit | Message | Author |
|--------|---------|--------|
| abc123 | feat: add login | User |

### Working Tree
| Status | Count |
|--------|-------|
| Modified | 3 |
| Staged | 1 |

### Stashes
| Stash | Message | Date |
|-------|---------|------|
| stash@{0} | WIP | Apr 8 |

### Remotes
| Remote | URL |
|--------|-----|
| origin | https://github.com/... |
```
