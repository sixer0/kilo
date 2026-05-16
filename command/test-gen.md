---
description: Generate unit tests for code
agent: test-expert
model: kilo/minimax/minimax-2.7
subtask: true
---

Generate unit tests for: $ARGUMENTS

## Workflow

### 1. DISCOVER
- Find the source code to test
- Identify testing framework (Jest, Mocha, pytest, JUnit)
- Check existing test patterns in project

### 2. ANALYZE
- List functions/methods to test
- Identify dependencies needing mocks
- Map test categories:
  - Happy path (main success)
  - Edge cases
  - Error handling
  - Boundary conditions
  - Input validation

### 3. GENERATE
- Write test files following project conventions
- Use proper describe/it or test block structure
- Add descriptive test names
- Cover positive and negative cases
- Include setup/teardown if needed
- Add mocks for dependencies

### 4. VERIFY
- Ensure tests are syntactically valid
- Verify all imports resolve
- Check test coverage adequate

## Test Coverage Requirements
- Happy path: 100% coverage
- Edge cases: High priority only
- Error handling: All error paths
- Input validation: All rules

## Output Format

```
TEST_GENERATION_COMPLETE

## Test Files Created/Updated
| File | Tests | Coverage | Framework |
|------|-------|----------|-----------|
| auth.test.js | 8 | +25% | Jest |

## Test Cases Added
- [x] should login with valid credentials (happy path)
- [x] should fail with invalid password (error handling)
- [x] should handle network error (edge case)

## Verification
- ✅ Syntax valid
- ✅ All imports resolved
- ✅ Follows project conventions
```

If blocked:
```
TEST_GENERATION_BLOCKED: [reason]
Issue: [specific problem]
Needed: [source file / test framework info]
```
