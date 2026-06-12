---
name: tool-design-optimizer
description: >-
  Improve the Agent-Computer Interface (ACI) by refining tool names, schemas,
  descriptions, examples, error messages, and poka-yoke constraints. Clearer
  tool definitions reduce LLM confusion, lower token waste, and decrease
  incorrect tool selection rates.
license: MIT
metadata:
  category: optimization
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/tool-design-optimizer
    license_path: LICENSE
---

# Tool Design Optimizer

Optimize tool schemas, names, descriptions, and examples to make them
easier for LLMs to use correctly. Apply ACI (Agent-Computer Interface)
principles to every tool surface.

---

## Triggers

Use this skill when:
- "optimize tool definitions for clarity"
- "improve tool schema and descriptions"
- "ACI optimization for tools"
- "make tools easier for LLMs to use"
- "refine tool names and examples"
- "tool prompt engineering review"

Do NOT use for creating tools from scratch (use `mcp-integration` or
`skill-creator` for that) or for optimizing non-tool content.

---

## Process

### Phase 1: Inventory Tool Surfaces

List every tool the agent has access to. For each tool, collect:

```yaml
name: <tool name>
description: <current description>
parameters:
  - name: <param>
    type: <type>
    description: <current description>
    required: true|false
examples: <current examples, if any>
error_messages: <common error scenarios>
```

---

### Phase 2: Audit Each Surface

For each tool, evaluate against ACI criteria:

#### Names
- [ ] Does the name clearly indicate what the tool does?
- [ ] Is it consistent with similar tools (verb-noun pattern)?
- [ ] Could it be confused with another tool?
- [ ] Fix: Rename if ambiguous (e.g., `get-data` → `fetch-user-profiles`)

#### Descriptions
- [ ] Does the description explain WHEN to use this tool?
- [ ] Does it explain WHEN NOT to use it?
- [ ] Are edge cases mentioned?
- [ ] Is it concise (< 200 chars recommended)?
- [ ] Fix: Add "Use this when..." and "Do NOT use for..." clauses

#### Parameters
- [ ] Are parameter names self-explanatory?
- [ ] Are parameter descriptions detailed enough?
- [ ] Are required/optional distinctions clear?
- [ ] Are there poka-yoke (idiot-proof) constraints?
- [ ] Fix: Add `minimum`/`maximum`, `enum` values, format patterns

#### Examples
- [ ] Does each example show realistic usage?
- [ ] Do examples cover edge cases?
- [ ] Are failure examples included?
- [ ] Fix: Add 1-2 examples per tool; include at least one error example

#### Error Messages
- [ ] Are error messages actionable?
- [ ] Do they suggest what the LLM should do differently?
- [ ] Fix: Rewrite error messages to include "What happened" + "What to do"

---

### Phase 3: Apply Optimizations

For each issue found in Phase 2, apply the fix:

```markdown
### Tool: `<name>`

**Issue:** <what was wrong>
**Impact:** <why it matters (token waste, false positives, confusion)>
**Change:**
- Before: `<old value>`
- After: `<new value>`

**Rationale:** <why this change helps>
```

**Prioritize fixes by impact:**
1. HIGH: Ambiguous names, misleading descriptions, missing required params
2. MEDIUM: Missing examples, unclear error messages
3. LOW: Minor wording improvements, additional edge case docs

---

### Phase 4: Verify Improvements

After applying changes:

1. **Re-read each tool definition** — does the agent understand when to use it?
2. **Simulate tool selection** — given a realistic user request, is the right tool chosen?
3. **Check for regressions** — did the optimization break any existing workflows?

Output a verification summary:

```markdown
## Optimization Summary

**Tools audited:** N
**Changes applied:** N (HIGH: N, MEDIUM: N, LOW: N)
**Tokens saved (estimated):** ~N chars from description bloat
**Verification:** All tools pass selection simulation
```

---

## ACI Checklist Template

```markdown
## Tool ACI Audit: <tool-name>

| Criterion | Status | Before | After |
|-----------|--------|--------|-------|
| Name clarity | PASS/FAIL | X | Y |
| Description completeness | PASS/FAIL | X | Y |
| Parameter clarity | PASS/FAIL | X | Y |
| Examples coverage | PASS/FAIL | X | Y |
| Error message quality | PASS/FAIL | X | Y |
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Overly long descriptions (wastes tokens) | Concise < 200 chars with when/when-not |
| Generic parameter names (`input`, `data`) | Specific names with type hints |
| No failure examples | Include at least one error example |
| Descriptions that lie about defaults | Match description to actual behavior |
| Over-constraining parameters | Use poka-yoke sparingly; document edge cases |

---

## Execution Checklist

```
[ ] Phase 1: All tool surfaces inventoried
[ ] Phase 2: ACI audit completed (names, descriptions, params, examples, errors)
[ ] Phase 3: HIGH priority fixes applied
[ ] Phase 3: MEDIUM priority fixes applied
[ ] Phase 4: Verification simulation passed
[ ] Verify: Each tool uses verb-noun naming
[ ] Verify: Descriptions include "when/when-not"
[ ] Verify: At least 1 example per tool
[ ] Verify: Error messages are actionable
```

---

## Verification

After optimization:
1. Every tool was audited against all 5 ACI criteria
2. HIGH priority issues are fixed
3. Token count of descriptions is reduced (or at least not inflated)
4. Selection simulation confirms correct tool choice
