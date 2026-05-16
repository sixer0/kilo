---
description: Explain code or concept
agent: data-collector
model: kilo/openrouter/free
subtask: false
---

Explain the following code or concept: $ARGUMENTS

## Workflow

### 1. LOCATE
- If @file provided, read the file
- If concept, search codebase for examples
- Identify relevant files

### 2. ANALYZE
Break down:
- What the code does (purpose)
- Key logic and flow
- Important patterns/techniques used
- Dependencies and relationships

### 3. EXPLAIN
Provide clear explanation with:
- High-level overview
- Step-by-step breakdown
- Code snippets with annotations
- Usage examples if applicable

## Output Format

```
## Explanation: [topic]

### Overview
[1-2 sentence summary]

### How It Works
[Step-by-step explanation]

### Key Components
| Component | Purpose |
|-----------|---------|
| func1 | [Purpose] |

### Code Example
```[language]
[annotated code]
```

### Usage
[How to use this in context]
```
