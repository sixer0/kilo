---
description: Generate or update documentation
agent: coder-execution
model: kilo/minimax/minimax-2.7
subtask: true
---

Generate documentation for: $ARGUMENTS

## Workflow

### 1. DISCOVER
- Find the code to document
- Identify existing documentation style
- Check for related docs (README, API docs, etc.)

### 2. ANALYZE
- Understand the component purpose
- Map public API/interface
- Identify usage patterns

### 3. DOCUMENT
- Write clear descriptions
- Document parameters and return values
- Add usage examples
- Follow existing doc format

### 4. INTEGRATE
- Place docs in appropriate location
- Update index/table of contents if needed
- Link related documentation

## Documentation Standards
- Use clear, concise language
- Include code examples
- Document all public interfaces
- Note edge cases and limitations

## Output Format

```
DOC_GENERATION_COMPLETE

## Documentation Created/Updated
| File | Type | Description |
|------|------|-------------|
| README.md | Guide | Project overview |

## Coverage
- [x] Purpose and usage
- [x] Function signatures
- [x] Examples
- [x] Edge cases noted

## Notes
- [Any additional observations]
```

If blocked:
```
DOC_BLOCKED: [reason]
Issue: [specific problem]
Needed: [what is required]
```
