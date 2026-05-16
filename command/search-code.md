---
description: Search codebase for patterns
agent: data-collector
model: kilo/openrouter/free
subtask: true
---

Search the codebase for: $ARGUMENTS

## Workflow

### 1. GLOB
Find files matching patterns:
- Use glob patterns like `**/*.js`, `**/*.ts`, `**/*.json`

### 2. GREP
Search for content:
- Function names, class names
- Keywords, variables
- Error messages
- Configuration values

### 3. ASSEMBLE
- Read relevant file sections
- Note file paths and line numbers
- Group related findings

## Output Format

```
## Search Results: [query]

### Files Found
| File | Type | Relevance |
|------|------|-----------|
| path/file.js | Source | High |

### Matches
| File | Line | Match |
|------|------|-------|
| file.js | 42 | function handleClick() |

### Summary
- Total files: [count]
- Total matches: [count]
- Most relevant: [top 3]
```
