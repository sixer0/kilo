---
description: Explore project structure
agent: explore
model: kilo/openrouter/free
subtask: true
---

Explore the project structure: $ARGUMENTS

## Workflow

### 1. GLOB
Map directory structure:
- List top-level folders
- Find entry points (index.js, main.js, app.js)
- Identify config files (package.json, tsconfig.json, etc.)

### 2. ORGANIZE
Categorize folders by purpose:
- Source code locations
- Test locations
- Configuration locations
- Documentation locations
- Build/deploy configurations

### 3. REPORT
Provide clear structure map with purposes

## Output Format

```
## Project Structure

### Directory Overview
| Folder | Purpose |
|---------|---------|
| src/ | Source code |
| tests/ | Test files |

### Key Files
| File | Purpose |
|------|---------|
| src/index.js | Entry point |

### Entry Points
- src/index.js
- src/App.js

### Naming Conventions
- Components: PascalCase
- Utils: camelCase
```

## What NOT to Do
- ❌ Read full file contents
- ❌ Analyze code logic
- ❌ Explain implementation details
