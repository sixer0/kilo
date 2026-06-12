---
task_id: upgrade-skill-list-anthropic-references
task_slug: upgrade-skill-list-anthropic-references
date: 2026-06-11
agent: data-analyst
type: implementation-plan
based_on: /docs/2026_06_11_upgrade-skill-list/analysis_result.md
last_updated: 2026-06-11 23:47
---

# Implementation Plan: 5 Tier-1 Agentic Skills

## Current State

Kilo has 8 existing domain-specific skills under `skills/`:
- `agent-md-refactor`, `canvas-design`, `content-research-writer`, `docx`, `image-enhancer`, `ms365`, `pdf`, `pptx`, `xlsx`

These cover document processing, design, writing, and file manipulation — but **zero skills target agentic workflow patterns** (planning, reflection, error recovery, verification, tool optimization).

`kilo.json` has `"skills": { "paths": [] }`, suggesting auto-discovery from `skills/`. The 8 existing skills are already detected without explicit paths.

## Target State

5 new skill directories under `skills/`, each with a `SKILL.md` defining a distinct agentic meta-capability:

| Folder | Purpose |
|--------|---------|
| `skills/plan-and-execute/` | Task decomposition → staged execution → checkpoint-based replanning |
| `skills/reflection-loop/` | Generate → evidence-critique → revise → bounded iteration |
| `skills/self-healing-loop/` | Error classification → decision tree (retry/compensate/interrupt/stop) |
| `skills/dry-run-verify-fix/` | Pre-ship validation → simulated execution → bounded repair loop |
| `skills/tool-design-optimizer/` | ACI optimization for tool schemas, names, descriptions, examples |

## Implementation Steps

| Step | Action | Details |
|------|--------|---------|
| 1 | Create skill directories | `skills/plan-and-execute/`, `skills/reflection-loop/`, `skills/self-healing-loop/`, `skills/dry-run-verify-fix/`, `skills/tool-design-optimizer/` |
| 2 | Write SKILL.md files | One per skill, following Kilo frontmatter + triggers + process phases format |
| 3 | Update kilo.json | Add explicit `paths` entries for the 5 new skills |
| 4 | Verify | Confirm files exist, `kilo.json` is valid JSON, skills are discoverable |

## Changes Required

1. Create 5 new directories under `skills/`
2. Write 5 SKILL.md files
3. Modify `kilo.json` to add explicit paths
4. No other files are modified

## Dependencies

- `kilo.json` must remain valid JSON (use JSON schema validator before committing)
- No external npm packages, MCP servers, or runtime dependencies
- Skills are pure `SKILL.md` system prompts — no supporting scripts or binaries needed

---

## Folder Names to Create

```
skills/plan-and-execute/
skills/reflection-loop/
skills/self-healing-loop/
skills/dry-run-verify-fix/
skills/tool-design-optimizer/
```

Each folder contains exactly one file: `SKILL.md`.

---

## Finalized SKILL.md Content

### 1. `plan-and-execute`

```markdown
---
name: plan-and-execute
description: >-
  Decompose complex tasks into staged, dependency-aware execution plans with
  explicit checkpoints. After each phase, evaluate progress, update the plan,
  and proceed to the next stage. Prevents "lost in the middle" failures by
  maintaining a visible, revisable roadmap.
license: MIT
metadata:
  category: orchestration
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/plan-and-execute
    license_path: LICENSE
---

# Plan and Execute

Break complex requests into a staged plan with explicit checkpoints, dependency
ordering, and completion criteria. After each major phase, replan based on
what was learned.

---

## Triggers

Use this skill when:
- "create staged plan with checkpoints"
- "decompose and execute step by step"
- "multi-phase execution plan"
- "plan with milestones and dependencies"
- "step-by-step with replan after each phase"
- "task decomposition with verification gates"

Do NOT use for simple single-step tasks or when the user only needs a
straightforward answer.

---

## Process

### Phase 0: Scope & Goal Clarification

Before drafting the plan, confirm:
- What is the **final deliverable**?
- What are the **constraints** (time, tools, quality bar)?
- What can be **assumed** vs what needs **validation**?
- What is the **acceptance criteria** for completion?

Output: One-paragraph restatement of goal with constraints.

---

### Phase 1: Decompose into Phases

Break the work into 3-7 sequential phases. For each phase, document:

```yaml
phase: <ordinal>
name: <short name>
goal: <what this phase achieves>
depends_on: <phase numbers this depends on, or "none">
checkpoint_criteria:
  - <measurable condition 1>
  - <measurable condition 2>
output: <artifact or state produced>
```

**Rules:**
- Each phase must produce a **verifiable artifact** or **measurable state change**
- Dependencies must form a DAG (no circular deps)
- Keep phases granular enough that a single phase is 1-3 execution blocks

---

### Phase 2: Execute Phases Sequentially

For each phase in dependency order:

1. Announce which phase is starting
2. Execute the work
3. Run checkpoint verification
4. If checkpoint passes → stage the output, log progress
5. If checkpoint fails → enter Phase 3 (replan)

```markdown
**Phase N: <name>** [IN PROGRESS]
Goal: <goal>
Checkpoint: <criteria>
Decision: PASS / FAIL → [continue / replan]
```

---

### Phase 3: Replan on Checkpoint Failure

When a checkpoint fails:

1. **Diagnose**: What went wrong? Unexpected input? Missing information? Wrong approach?
2. **Adjust**: Modify remaining phases or the current phase's approach
3. **Re-verify**: If the fix is local, retry the phase. If the fix changes scope, update future phases.
4. **Escalate**: If replanning fails twice, surface to the user with options.

Replanning resets the retry counter. Maximum 2 replans per phase before escalation.

---

### Phase 4: Deliver

When all phases complete successfully:
1. Summarize what was done (one paragraph)
2. List all artifacts/outputs
3. Note any unfinished items or known limitations
4. Present the deliverable

---

## Output Template

```markdown
## Execution Summary

**Goal:** <restated goal>
**Phases Completed:** N of N
**Decision Log:**
- Phase 1: PASS — <artifact>
- Phase 2: PASS — <artifact>
- Phase 3: REPLAN (1) → PASS — <artifact>

**Artifacts:**
- <path/file>: <description>

**Limitations:**
- <any known trade-offs or incomplete items>
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Planning every detail upfront | Discover details during execution |
| Phases without checkpoints | Every phase must have a pass/fail gate |
| Ignoring dependency order | Execute phases in strict dependency sequence |
| Replanning without diagnosing root cause | Diagnose first, then replan |
| More than 7 phases for most tasks | Break into coarser phases; use sub-tasks if needed |

---

## Execution Checklist

```
[ ] Phase 0: Goal clarified with user
[ ] Phase 1: Decomposition created (3-7 phases, DAG deps)
[ ] Phase 2: Each phase executed sequentially
[ ] Phase 2: Checkpoint verified after each phase
[ ] Phase 3: Replan applied only when checkpoint fails (max 2)
[ ] Phase 4: Delivery summary produced
[ ] Verify: All checkpoints passed
[ ] Verify: Replan count ≤ 2 per phase
```

---

## Verification

After execution:
1. All phases completed with PASS checkpoints
2. Delivery summary includes all artifacts
3. No circular dependencies in the original decomposition
4. Replan limit was respected
```

---

### 2. `reflection-loop`

```markdown
---
name: reflection-loop
description: >-
  Self-critique and iterative refinement with explicit evidence-based review.
  After generating output, critique it against success criteria, identify
  specific gaps, revise, and repeat. Bounded iteration prevents infinite loops
  while maximizing output quality.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/reflection-loop
    license_path: LICENSE
---

# Reflection Loop

Generate → critique → revise in a bounded loop. Each critique must cite
specific evidence from the output, and each revision must address every
identified gap.

---

## Triggers

Use this skill when:
- "critique and revise this output"
- "evidence-based self-review"
- "reflect on the result and improve"
- "iterative refinement with quality gates"
- "review against explicit criteria and fix gaps"
- "self-critique loop with bounded iterations"

Do NOT use for trivial outputs where a single pass is sufficient, or when
the user explicitly says "no review needed."

---

## Process

### Phase 1: Establish Success Criteria

Before reflecting, define what "good" looks like. If the user provided
criteria, use those. Otherwise, infer from context:

- **Correctness**: Does it do what was asked?
- **Completeness**: Are all requirements addressed?
- **Clarity**: Is the output understandable?
- **Conciseness**: Is it appropriately scoped?
- **Consistency**: Are there internal contradictions?

Output: Explicit list of 3-5 criteria with brief definitions.

---

### Phase 2: Generate Initial Output

Produce the best output you can in one pass, given the criteria above.
Do not hold back — this is the baseline.

---

### Phase 3: Evidence-Based Critique

For each criterion, evaluate the output:

```markdown
### Criterion: <name>

**Assessment:** PASS / FAIL / PARTIAL

**Evidence (exact quote or specific reference):**
> "<quoted passage from the output>"

**Gap:**
<specific, actionable description of what is missing or wrong>

**Severity:** HIGH / MEDIUM / LOW
```

**Rules for critique:**
1. Every assessment MUST cite exact quotes or line numbers
2. "Looks good" without evidence is NOT a valid critique
3. HIGH severity gaps must be fixed; MEDIUM should be fixed; LOW may be deferred
4. If all criteria are PASS with no HIGH severity, skip to Phase 5

---

### Phase 4: Revise

Produce a new version that addresses every gap identified in Phase 3:

1. For each FAIL or PARTIAL criterion, apply the specific fix
2. For HIGH severity gaps: must fix
3. For MEDIUM severity gaps: should fix (document if skipped)
4. For LOW severity gaps: may fix or defer with explanation

After revision, if iteration count < max:
- Go back to Phase 3 (re-critique the revised output)
- If iteration count >= max: proceed to Phase 5

**Default max iterations:** 3 (configurable: user may say "iterate 5 times")

---

### Phase 5: Final Delivery

When all criteria pass or max iterations reached:

```markdown
## Reflection Summary

**Criteria:** N criteria defined
**Iterations:** N
**Final Status:**
- Criterion 1: PASS
- Criterion 2: PASS
- Criterion 3: PARTIAL → deferred (reason)

**Unresolved Gaps:**
- <gap> (deferred, severity LOW)
```

---

## Example

**User:** "Write a Python function to merge two sorted lists."

**Phase 2 output:** Simple `sorted(a + b)` approach.

**Phase 3 critique:**
```
Criterion: Correctness — FAIL
Evidence: "sorted(a + b)" has O(n log n) not O(n)
Gap: Should use two-pointer merge for O(n)
Severity: HIGH
```

**Phase 4 revision:** Two-pointer merge implementation.

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Vague critique ("could be better") | Cite exact text, describe the gap |
| Ignoring LOW severity gaps | Defer with explanation |
| Changing what works | Only change what was flagged |
| Infinite iterations | Hard cap at configured max |
| Siloing | Consider interaction between criteria |

---

## Execution Checklist

```
[ ] Phase 1: Success criteria defined (3-5 items)
[ ] Phase 2: Initial output generated
[ ] Phase 3: Evidence-based critique for each criterion
[ ] Phase 4: Revision addresses all gaps
[ ] Phase 4: Iteration count tracked (max N)
[ ] Phase 5: Final summary delivered
[ ] Verify: Each critique cites specific evidence
[ ] Verify: Each HIGH severity gap is addressed
[ ] Verify: Iteration count did not exceed max
```

---

## Verification

After reflection:
1. Every criterion was evaluated with specific evidence
2. All HIGH severity gaps are fixed
3. Iteration count ≤ max (default 3)
4. Final summary documents deferred items
```

---

### 3. `self-healing-loop`

```markdown
---
name: self-healing-loop
description: >-
  Classify execution failures into discrete categories (transient, logic,
  permission, resource, or unexpected) and route each to the appropriate
  recovery strategy: automatic retry, compensation, user interrupt, or
  graceful stop. Prevents cascading failures by containing errors and
  applying structured responses.
license: MIT
metadata:
  category: orchestration
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/self-healing-loop
    license_path: LICENSE
---

# Self-Healing Loop

When an error occurs during execution, classify it and apply the right
recovery strategy. Never silently retry the same operation without
understanding why it failed.

---

## Triggers

Use this skill when:
- "classify and recover from this error"
- "self-heal on execution failure"
- "error recovery strategy needed"
- "retry compensate interrupt or stop"
- "handle tool failure gracefully"
- "recover from transient failure"

Do NOT use for expected errors in normal control flow (e.g., "file not found"
when checking existence is part of the algorithm).

---

## Process

### Phase 0: Error Classification

When an error occurs, classify it immediately:

| Class | Signal | Example | Recovery |
|-------|--------|---------|----------|
| **TRANSIENT** | Timeout, network blip, rate limit | `ETIMEDOUT`, `429 Too Many Requests` | Retry with backoff (max 3) |
| **LOGIC** | Wrong approach, bad assumption | "SQL syntax error", "file not found at expected path" | Fix → retry once |
| **PERMISSION** | Access denied, auth failure | `EACCES`, `401 Unauthorized` | Interrupt — notify user |
| **RESOURCE** | Disk full, OOM, missing dependency | `ENOSPC`, `MODULE_NOT_FOUND` | Interrupt — notify user |
| **UNEXPECTED** | Unrecognized crash | Null pointer, assertion failure | Stop — log full context |

---

### Phase 1: Apply Recovery Strategy

Based on classification:

#### TRANSIENT → Retry with Backoff

```
Attempt 1 → fail → wait 2s
Attempt 2 → fail → wait 4s
Attempt 3 → fail → escalate to user
```

- Maximum 3 retries
- Exponential backoff: 2s, 4s, 8s
- After 3 failures: escalate with "Operation failed after 3 retries: <error>"

#### LOGIC → Diagnose and Fix

1. Understand the root cause (not just the symptom)
2. Apply a targeted fix
3. Retry exactly once
4. If the fix fails: escalate with "Logical approach failed: <diagnosis>"

#### PERMISSION → Interrupt and Notify

1. Stop the current operation
2. Inform the user: "Access denied to <resource>. Needs <permission>."
3. If the user provides credentials/approval, retry once

#### RESOURCE → Interrupt and Notify

1. Stop the current operation
2. Report: "<Resource> unavailable. <detail>"
3. If the user resolves the issue, resume from checkpoint

#### UNEXPECTED → Stop and Log

1. Capture full error context (stack trace, inputs, state)
2. Stop immediately — do not retry
3. Report: "Unexpected error: <summary>. Full context: <path to log>"

---

### Phase 2: Escalation Path

If recovery fails (all retries exhausted, fix didn't work, etc.):

```markdown
## Error Recovery Failed

**Error:** <original error>
**Classification:** <class>
**Recovery Attempted:** <what was tried>
**Failed At:** <step that still fails>

**Options for user:**
1. Provide additional context/credentials to unblock
2. Skip this step and continue (may produce partial results)
3. Abort the operation entirely
```

---

### Phase 3: Compensation (Optional)

For LOGIC errors where the fix changes the approach:
- Document the change: "Initial approach used X but failed because Y. Changed to Z."
- Re-verify any assumptions that may have changed

For other error classes, compensation does not apply (the operation either
succeeds or is interrupted cleanly).

---

## Error Log Template

```markdown
## Error Log

| # | Phase | Error | Class | Recovery | Result |
|---|-------|-------|-------|----------|--------|
| 1 | fetch-data | ETIMEDOUT | TRANSIENT | retry×3 | success |
| 2 | validate-schema | EACCES | PERMISSION | interrupt | user provided key |
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Blind retry without classification | Classify first, then choose strategy |
| Same retry count for all error types | TRANSIENT=3, LOGIC=1, OTHERS=0 |
| Ignoring retry-exhausted | Always escalate after max retries |
| Continuing after UNEXPECTED | Stop and report |
| Swallowing errors silently | Always log the error and recovery outcome |

---

## Execution Checklist

```
[ ] Phase 0: Error classified (TRANSIENT|LOGIC|PERMISSION|RESOURCE|UNEXPECTED)
[ ] Phase 1: Recovery strategy applied
[ ] Phase 1: Retry count ≤ max (3 for TRANSIENT, 1 for LOGIC)
[ ] Phase 2: Escalation to user if recovery failed
[ ] Phase 3: Compensation documented if applicable
[ ] Verify: All errors are logged with classification
[ ] Verify: No silent retries
```

---

## Verification

After healing:
1. Every error was classified before recovery
2. Retry limits were respected per class
3. UNEXPECTED errors stopped execution
4. User was informed of any escalated failures
```

---

### 4. `dry-run-verify-fix`

```markdown
---
name: dry-run-verify-fix
description: >-
  Validate changes before final delivery by simulating realistic execution
  paths, inspecting errors, applying targeted fixes, and repeating in a
  bounded loop. Prevents "hallucinated success" where the agent believes
  work is complete despite latent failures.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/dry-run-verify-fix
    license_path: LICENSE
---

# Dry Run → Verify → Fix

Before declaring work complete, run a realistic simulation of the delivery
path. Inspect any failures, fix them, and repeat. Cap iterations to prevent
runaway loops.

---

## Triggers

Use this skill when:
- "dry-run before final delivery"
- "pre-ship validation with simulation"
- "verify and fix in a bounded loop"
- "simulate the execution path and fix errors"
- "validate changes before finishing"
- "bounded repair iteration before ship"

Do NOT use for analysis-only tasks (reading, researching, planning without
execution) or when immediate delivery is requested with no validation step.

---

## Process

### Phase 1: Define the Delivery Path

Identify what needs to happen for the work to be "shipped":

```markdown
## Delivery Path

**What was produced:** <files, config, or artifacts>
**How to validate:** <the steps to verify correctness>
**Expected results:** <what success looks like>
```

Examples of validation steps:
- Running a script and checking its output
- Syntax-checking generated files
- Simulating tool calls with expected inputs
- Running dry-mode builds or lints
- Querying a test endpoint

---

### Phase 2: Dry-Run Execution

Execute the validation path without side effects (or with sandboxed side
effects). For each step:

```markdown
### Step: <name>
**Command/Action:** <what was run>
**Expected:** <what should happen>
**Actual:** <what happened>
**Result:** PASS / FAIL
```

**If ALL steps pass:** → Phase 5 (deliver)

**If ANY step fails:** → Phase 3 (diagnose), then Phase 4 (fix)

---

### Phase 3: Diagnose Failure

For each failure:

1. **Reproduce:** Is the failure consistent or flaky?
2. **Root cause:** What is the actual source of the failure?
3. **Scope:** Is this a local fix or does it affect other parts?
4. **Severity:** BLOCKER (must fix) / WARNING (should fix) / INFO (note)

```markdown
### Failure: <step name>

**Symptom:** <what failed, including error messages>
**Root Cause:** <why it failed>
**Scope:** <local / cross-cutting>
**Severity:** BLOCKER / WARNING / INFO

**Fix:** <specific change needed>
```

---

### Phase 4: Apply Fix

1. Apply the fix from Phase 3 diagnosis
2. Return to Phase 2 (re-run the dry-run from scratch)
3. Increment repair counter

**Repair limits:**
- Maximum 3 repair cycles per session
- After 3 failures → escalate with summary and options
- If the fix introduces new failures → revert and try a different approach

---

### Phase 5: Deliver

When all steps pass or repair limit reached:

```markdown
## Validation Summary

**What was validated:** <delivery path>
**Dry-run cycles:** N
**Repairs applied:** N
**Final status:** ALL PASS / PARTIAL (N failures deferred)

**Deferred items (if any):**
- <failure>: deferred because <reason>

**Verification evidence:**
- Step 1: PASS — <artifact/log>
- Step 2: PASS — <artifact/log>
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Dry-running with mocked data that hides real failures | Use realistic inputs that exercise real code paths |
| Fixing without re-running the full path | Always re-run the full dry-run from scratch |
| Ignoring WARINING severity | Document and defer with reason |
| More than 3 repair cycles | Escalate after limit |
| Skipping dry-run on "trivial" changes | Even small changes may break things |

---

## Execution Checklist

```
[ ] Phase 1: Delivery path defined
[ ] Phase 2: Dry-run executed (realistic simulation)
[ ] Phase 3: Failures diagnosed with root cause
[ ] Phase 4: Fix applied and retry initiated
[ ] Phase 4: Repair counter ≤ 3
[ ] Phase 5: Validation summary delivered
[ ] Verify: All failures documented with root cause
[ ] Verify: BLOCKER items resolved before delivery
```

---

## Verification

After validation:
1. All BLOCKER-severity failures are fixed
2. Repair cycles ≤ 3
3. Each repair cycle re-ran the full dry-run path
4. Delivery summary documents all results
```

---

### 5. `tool-design-optimizer`

```markdown
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
```

---

## Proposed `kilo.json` Additions

Add explicit `paths` entries under `"skills"` to ensure the new skills are
discoverable even if auto-discovery behavior changes:

```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "mcp": {
    "puppeteer": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "@modelcontextprotocol/server-puppeteer"
      ]
    }
  },
  "skills": {
    "paths": [
      "skills/plan-and-execute",
      "skills/reflection-loop",
      "skills/self-healing-loop",
      "skills/dry-run-verify-fix",
      "skills/tool-design-optimizer"
    ]
  }
}
```

**Note:** The existing `kilo.json` has `"paths": []` and the 8 existing skills
are auto-discovered. If Kilo supports both explicit paths and auto-discovery,
the paths above should be additive. If explicit paths disable auto-discovery,
add the 8 existing skill paths as well to avoid losing them.

### Fallback: Full Path List

If explicit paths replace auto-discovery, use this expanded list instead:

```json
"paths": [
  "skills/agent-md-refactor",
  "skills/canvas-design",
  "skills/content-research-writer",
  "skills/docx",
  "skills/image-enhancer",
  "skills/ms365",
  "skills/pdf",
  "skills/plan-and-execute",
  "skills/pptx",
  "skills/reflection-loop",
  "skills/self-healing-loop",
  "skills/dry-run-verify-fix",
  "skills/tool-design-optimizer",
  "skills/xlsx"
]
```

---

## Trigger Uniqueness Matrix

All triggers across 13 skills (8 existing + 5 new) are disjoint:

| Existing Skill | Triggers (collision risk) |
|----------------|---------------------------|
| `agent-md-refactor` | AGENTS.md, CLAUDE.md, agent instructions, progressive disclosure |
| `content-research-writer` | writing, research, content, blog, article, citations |
| `canvas-design` | poster, art, design philosophy, visual, canvas |
| `image-enhancer` | image quality, screenshot, upscale, sharpen, enhance |
| `docx` | docx, Word document |
| `pptx` | pptx, PowerPoint, slide |
| `xlsx` | xlsx, Excel, spreadsheet |
| `pdf` | PDF, document |

| New Skill | Triggers (no collision with above) |
|-----------|------------------------------------|
| `plan-and-execute` | staged plan, decompose and execute, multi-phase plan, task decomposition with checkpoint, step-by-step with replan, verification gates |
| `reflection-loop` | critique and revise, evidence-based self-review, reflect on output, iterative refinement with quality gates, self-critique loop, bounded iteration |
| `self-healing-loop` | classify and recover error, self-heal on failure, error classification, retry compensate interrupt stop, handle tool failure gracefully, transient failure recovery |
| `dry-run-verify-fix` | dry-run before delivery, pre-ship validation, verify and fix loop, simulate and fix errors, bounded repair iteration, validate before finishing |
| `tool-design-optimizer` | optimize tool definitions, improve tool schema, ACI optimization, make tools easier, refine tool names and examples, tool prompt engineering review |

**Zero trigger overlap** with any existing skill. The new triggers use
process-oriented language (decompose, critique, classify, validate, optimize)
that does not intersect with domain-oriented triggers (PDF, image, canvas,
writing, AGENTS.md).

---

## Verification Approach

1. **File existence check:** Confirm all 5 directories and `SKILL.md` files exist
2. **Frontmatter validation:** Each `SKILL.md` has valid YAML frontmatter with required fields (`name`, `description`, `metadata.category`)
3. **JSON validation:** `kilo.json` parses as valid JSON
4. **Trigger uniqueness grep:** Confirm no new trigger phrase exists in any existing skill's `SKILL.md`
5. **Phase completeness:** Each SKILL.md has at minimum: Triggers → Process (phases) → Execution Checklist → Verification

---

## Rollback Considerations

- **Revert `kilo.json`:** Restore `"paths": []` from backup (keep copy of original)
- **Remove skill folders:** Delete `skills/<new-skill>/` directories
- **No cascade effects:** Skills are self-contained `SKILL.md` files with no inter-skill dependencies, no npm packages, and no running services

---

## Next Steps

1. Execute Step 1: Create 5 skill directories
2. Execute Step 2: Write 5 SKILL.md files from the content above
3. Execute Step 3: Update `kilo.json` with path entries
4. Execute Step 4: Verify all skills are discoverable

---
*Generated: 2026-06-11 23:47*
*Last Updated: 2026-06-11 23:47*
