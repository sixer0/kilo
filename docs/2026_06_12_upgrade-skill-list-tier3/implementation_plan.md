---
task_id: upgrade-skill-list-tier3
task_slug: upgrade-skill-list-tier3
date: 2026-06-12
agent: data-analyst
type: implementation-plan
based_on: /docs/2026_06_12_upgrade-skill-list-tier3/analysis_result.md
last_updated: 2026-06-12 05:49
---

# Implementation Plan: 4 Tier-3 Agentic Skills

## Current State

Kilo now has 18 skills (8 domain skills + 5 Tier-1 agentic + 5 Tier-2 agentic):

```
skills/agent-md-refactor/          # Domain
skills/canvas-design/              # Domain
skills/content-research-writer/    # Domain
skills/docx/                       # Domain
skills/image-enhancer/             # Domain
skills/pdf/                        # Domain
skills/pptx/                       # Domain
skills/xlsx/                       # Domain
skills/plan-and-execute/           # Tier-1
skills/reflection-loop/            # Tier-1
skills/self-healing-loop/          # Tier-1
skills/dry-run-verify-fix/         # Tier-1
skills/tool-design-optimizer/      # Tier-1
skills/orchestrator-worker/        # Tier-2
skills/eval-driven-improver/       # Tier-2
skills/context-engineering/        # Tier-2
skills/mcp-integration/            # Tier-2
skills/checkpoint-resume/          # Tier-2
```

`kilo.json` has `"skills": { "paths": [...] }` containing all 10 Tier-1 + Tier-2 entries.

**Gap:** No skills exist for human-in-the-loop gating, skill creation/improvement, observability/tracing, or security review. These are Tier-3 patterns identified in the research as "Additional High-Impact Skills Worth Considering."

## Target State

4 new skill directories under `skills/`, each with a `SKILL.md` defining a distinct high-impact agentic capability:

| Folder | Purpose | Category |
|--------|---------|----------|
| `skills/human-in-loop-gate/` | Pause for user input when ambiguity, safety, or high-impact decisions require human approval | safety |
| `skills/skill-creator-kilo/` | Create and improve Kilo skills using evals, trigger tuning, and progressive disclosure | development |
| `skills/observability-tracer/` | Record tool calls, state transitions, failures, costs, and decisions for debugging and eval improvement | observability |
| `skills/security-review-gate/` | Run security-focused review before destructive or external actions | security |

## Implementation Steps

| Step | Action | Details |
|------|--------|---------|
| 1 | Create skill directories | `skills/human-in-loop-gate/`, `skills/skill-creator-kilo/`, `skills/observability-tracer/`, `skills/security-review-gate/` |
| 2 | Write SKILL.md files | One per skill, following Kilo frontmatter + triggers + process phases + anti-patterns + execution checklist + verification format |
| 3 | Update kilo.json | Add explicit `paths` entries for the 4 new Tier-3 skills |
| 4 | Verify | Confirm files exist, `kilo.json` is valid JSON, triggers are unique across all 22 skills |

## Changes Required

1. Create 4 new directories under `skills/`
2. Write 4 SKILL.md files
3. Modify `kilo.json` to add explicit paths for Tier-3 skills
4. No other files are modified

## Dependencies

- `kilo.json` must remain valid JSON
- No external npm packages, MCP servers, or runtime dependencies
- Skills are pure `SKILL.md` system prompts — no supporting scripts or binaries needed
- Tier-3 skills may reference Tier-1/Tier-2 skills (e.g., `self-healing-loop` for error recovery within a gate); these are conceptual references, not file imports

---

## Folder Names to Create

```
skills/human-in-loop-gate/
skills/skill-creator-kilo/
skills/observability-tracer/
skills/security-review-gate/
```

Each folder contains exactly one file: `SKILL.md`.

---

## Finalized SKILL.md Content

### 1. `human-in-loop-gate`

```markdown
---
name: human-in-loop-gate
description: >-
  Pause execution and request user input when ambiguity, safety concerns,
  high-impact decisions, or destructive operations are detected. The gate
  presents the situation, available options, and recommended action, then
  waits for user approval before proceeding. Prevents automated decisions
  that should involve human judgment.
license: MIT
metadata:
  category: safety
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/human-in-loop-gate
    license_path: LICENSE
---

# Human-in-the-Loop Gate

Pause execution at decision boundaries where human judgment is required.
Present the context, options, and recommendation, then wait for explicit
user approval before proceeding.

---

## Triggers

Use this skill when:
- "pause for user approval"
- "human-in-the-loop"
- "require user confirmation"
- "ask before proceeding"
- "high-impact decision gate"
- "safety check needed"
- "confirm this action before execution"
- "interrupt for user decision"

Do NOT use for routine decisions that clearly fall within the agent's
authority, or when the user has explicitly granted blanket approval for
a category of actions.

---

## Process

### Phase 0: Gate Classification

When a decision point is reached, classify the gate type immediately:

| Gate Class | Signal | Example | Action |
|------------|--------|---------|--------|
| **AMBIGUITY** | Unclear intent, multiple valid interpretations | "Do you want to refactor the entire module or just one function?" | Present options with trade-offs |
| **SAFETY** | Destructive operation, data loss, irreversible change | "Delete 50 files matching pattern" | Require explicit approval |
| **HIGH-IMPACT** | Significant cost, time, scope, or external effect | "Deploy to production" or "Spend $500 on API credits" | Require explicit approval with impact summary |
| **PERMISSION** | External action, credential use, data sharing | "Email this report to client@example.com" | Require confirmation of recipients and content |
| **AUTHORITY** | Decision outside stated scope or policy | "Override the security policy configured in project settings" | Escalate — require explicit override |
| **CONFIRMATION** | User asked a question back to the agent | (Any user query that expects a decision) | Gate is automatically satisfied when user responds |

---

### Phase 1: Build Gate Presentation

For each gate, construct a structured presentation:

```markdown
## ⏸ Gate: <class>

**Operation:** <what is about to happen>

**Context:**
- <relevant facts, inputs, state>
- <why this gate was triggered>

**Risk assessment:**
- **Impact:** <high / medium / low — what's at stake>
- **Reversibility:** <reversible / partially reversible / irreversible>
- **Cost:** <monetary, time, or resource estimate if applicable>

**Options:**
1. **Proceed** — <what happens, any conditions>
2. **Modify** — <suggested adjustment, if appropriate>
3. **Abort** — <stop and return to previous state>
4. <any additional options>

**Recommendation:** <option #, with rationale>

**Awaiting your decision...**
```

**Gate presentation rules:**
1. State the operation in plain language — no jargon
2. Quantify impact when possible ("will delete 12 files", "will cost ~$0.50")
3. Always include the "recommendation" — the agent should have an opinion
4. Include an "abort" option that restores prior state or stops cleanly
5. Never present a false choice (e.g., "proceed or abort" when both do the same thing)

---

### Phase 2: Present Gate to User

Output the gate presentation and pause:

```markdown
**Gate active:** Waiting for user input before proceeding.

The task is paused at this decision point. Once you respond, execution
will continue based on your choice.
```

**Pause behavior:**
- Do NOT take further actions until user responds
- Do NOT make assumptions about the user's choice
- If the user's response is ambiguous, clarify before proceeding
- If the user asks a question about the options, answer and re-present the gate

---

### Phase 3: Process User Decision

When the user responds:

```markdown
## Gate Resolved

**User decision:** <proceed / modify / abort / custom>
**User input:** <verbatim response>

**Action taken:**
- <what happens next>

**Gate log:**
| Gate | Class | Decision | Time |
|------|-------|----------|------|
| <operation> | <class> | <decision> | <timestamp> |
```

**Decision handling:**

| User Says | Action |
|-----------|--------|
| "Proceed" / "Yes" / "Go ahead" | Execute the operation as presented |
| "Modify" / "Change X" | Apply the modification, re-present gate if scope changes significantly |
| "Abort" / "No" / "Stop" | Abort the operation, return to prior state |
| "Let me think..." / "What does X mean?" | Answer the question, re-present the gate |
| Ambiguous / unclear | Ask for clarification: "I understood <X>. Is that correct?" |

**After resolution:**
- Log the decision to the gate log
- If proceeding: execute the operation
- If aborting: execute any cleanup / rollback
- If modifying: adjust parameters and either execute directly (low-risk) or re-gate (if modification changes risk profile)

---

### Phase 4: Gate Logging

Maintain a running log of all gates triggered during a session:

```markdown
## Gate Log

| # | Timestamp | Operation | Class | Decision | Duration |
|---|-----------|-----------|-------|----------|----------|
| 1 | 12:00:00 | Delete temp files | SAFETY | Proceed | 5s |
| 2 | 12:05:00 | Email draft to client | PERMISSION | Modify | 30s |
| 3 | 12:10:00 | Refactor auth module | AMBIGUITY | Abort | 15s |
```

**Gate log rules:**
- Record every gate, regardless of outcome
- Include the time between gate presentation and resolution
- If gates are too frequent (> 3 in a session), flag to the user:
  "Gates triggered N times. Would you like to adjust the gate sensitivity?"

---

### Phase 5: Gate Sensitivity Adjustment

If the user expresses frustration with too many (or too few) gates:

```markdown
## Gate Sensitivity Settings

**Current sensitivity:** <normal / high / low>

**Adjustment options:**
1. **High sensitivity** — Gate on AMBIGUITY, SAFETY, HIGH-IMPACT, PERMISSION, AUTHORITY (default)
2. **Normal sensitivity** — Gate on SAFETY, HIGH-IMPACT, AUTHORITY only
3. **Low sensitivity** — Gate on SAFETY and AUTHORITY only
4. **Custom** — Define specific gate classes or operations to always/never gate

**How to change:**
- "Set gate sensitivity to low"
- "Never gate on file deletions under 10 files"
- "Always gate on any deployment operation"
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Gating trivial decisions (analysis paralysis) | Only gate when impact, ambiguity, or risk is substantial |
| Presenting options without a recommendation | Always recommend a specific course of action |
| Making the user read a wall of text | Keep gate presentations concise and scannable |
| Proceeding without waiting for a response | Truly pause — no actions until user input |
| Re-gating the same operation multiple times | If the user said "proceed", proceed without re-gating |
| Gate on every tool call | Gate on decision boundaries, not individual operations |
| Assuming user intent from partial input | Wait for a clear, unambiguous response |

---

## Execution Checklist

```
[ ] Phase 0: Gate classified (AMBIGUITY / SAFETY / HIGH-IMPACT / PERMISSION / AUTHORITY / CONFIRMATION)
[ ] Phase 1: Gate presentation built (operation, context, risk, options, recommendation)
[ ] Phase 2: Gate presented to user, execution paused
[ ] Phase 3: User decision received and processed
[ ] Phase 3: Decision logged in gate log
[ ] Phase 4: Gate log maintained for the session
[ ] Phase 5: Sensitivity adjusted if user feedback indicates
[ ] Verify: No actions were taken before user responded
[ ] Verify: Gate presentation includes all 5 elements (operation, context, risk, options, recommendation)
[ ] Verify: Abort option always present and includes cleanup/rollback
```

---

## Verification

After gate execution:
1. No action was taken before the user responded to the gate
2. Gate presentation included: operation, context, risk assessment, options, and recommendation
3. The user's decision was correctly interpreted and executed
4. Gate log captures: operation, class, decision, and duration
5. Abort path cleanly restores prior state
6. Gate sensitivity is appropriate for the session (not too many, not too few)
```

---

### 2. `skill-creator-kilo`

```markdown
---
name: skill-creator-kilo
description: >-
  Create and improve Kilo skills (SKILL.md files) using structured evaluation,
  trigger tuning, and progressive disclosure. Guides the author through
  defining the skill's purpose, crafting triggers, designing process phases,
  identifying anti-patterns, and verifying completeness against the
  established skill template.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/skill-creator-kilo
    license_path: LICENSE
---

# Skill Creator for Kilo

Design, build, and refine Kilo skills following progressive disclosure
principles. Each skill is a self-contained `SKILL.md` with frontmatter,
triggers, process phases, anti-patterns, execution checklist, and
verification criteria.

---

## Triggers

Use this skill when:
- "create a new skill"
- "improve this skill"
- "add a trigger phrase"
- "skill development"
- "design a skill workflow"
- "build a Kilo skill"
- "author a skill for this capability"
- "refine an existing skill"

Do NOT use for one-off instructions or scripts that don't represent a
reusable capability, or when modifying non-skill configuration files
like `kilo.json`.

---

## Process

### Phase 0: Requirements Analysis

Before writing any content, define the skill's purpose:

```markdown
## Skill Specification

**Skill name:** <kebab-case-name>
**Category:** <development / orchestration / safety / optimization / observability / domain>

**Problem it solves:**
<what gap does this skill fill — 2-3 sentences>

**Who will use it:**
<target audience — e.g., "agent executing file operations", "developer authoring skills">

**Key capabilities (3-7):**
- <capability 1>
- <capability 2>
- <capability 3>

**Related skills it may invoke or reference:**
- <skill name>: <how it relates>

**Trigger phrases (draft 5-8):**
- "<phrase 1>"
- "<phrase 2>"

**Do NOT use (anti-triggers):**
- <situations where this skill should NOT be invoked>
```

**Skill naming conventions:**
- Use kebab-case: `human-in-loop-gate`, not `humanInLoopGate` or `Human In Loop Gate`
- Name should describe the capability, not the implementation: `skill-creator-kilo`, not `write-skills-md`
- Keep names under 30 characters

---

### Phase 1: Author Frontmatter

Write the YAML frontmatter (between `---` delimiters):

```yaml
---
name: <kebab-case-name>
description: >-
  <single-paragraph description of what this skill does, when to use it,
  and what it achieves. Approximately 2-4 sentences.>
license: MIT
metadata:
  category: <development / orchestration / safety / optimization / observability / domain>
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/<skill-name>
    license_path: LICENSE
---
```

**Frontmatter rules:**
- `name` must match the folder name exactly
- `description` uses YAML folded block scalar (`>-`) for multi-line
- `metadata.category` must be one of the allowed categories
- `source.repository` points to the skills repo
- `source.path` is `skills/<name>`

---

### Phase 2: Design Triggers

Create the triggers section:

```markdown
## Triggers

Use this skill when:
- "<trigger phrase 1>"
- "<trigger phrase 2>"
- "<trigger phrase 3>"
- "<trigger phrase 4>"
- "<trigger phrase 5>"
- "<trigger phrase 6>"

Do NOT use for <situations where this skill should not be invoked>.
```

**Trigger design principles:**
1. **6 trigger phrases minimum** — ensures sufficient coverage
2. **User-language, not system-language** — triggers should match what a user would naturally say
3. **Broad coverage** — cover intent, not just exact wording
4. **No overlap** — verify each trigger is unique across all existing skills
5. **Anti-trigger** — always include "Do NOT use for..." to prevent false positives

**How to check for overlap:**
- Search existing `SKILL.md` files with grep for each candidate trigger
- If a match is found, rephrase the trigger to be distinct
- Document uniqueness in the skill's specification

---

### Phase 3: Design Process Phases

Break the skill's workflow into 3-7 sequential phases:

```markdown
## Process

### Phase <N>: <Phase Name>

<what happens in this phase — 1-3 sentences>

<detailed steps, templates, decision tables, code blocks, or examples>
```

**Phase design guidelines:**

| Aspect | Rule |
|--------|------|
| Number of phases | 3-7 (too few = vague, too many = fragmented) |
| Phase names | Verb-driven: "Analyze", "Design", "Verify" |
| First phase | Always an analysis/assessment phase |
| Last phase | Always a summary/verification/delivery phase |
| Outputs | Each phase should produce a tangible output |
| Templates | Include markdown templates for structured outputs |
| Tables | Use decision tables for branching logic |

**Required tables by phase type:**

| Phase Type | Include |
|------------|---------|
| Analysis/classification | Decision table with classes, signals, examples |
| Design/creation | Template or schema for the artifact being created |
| Execution | Step-by-step instructions or algorithm |
| Verification | Checklist or verification criteria |

**Common phase patterns:**
- **Phase 0/1: Assess** — Evaluate the current state, classify the situation
- **Phase 2: Design** — Plan the approach, choose a strategy
- **Phase 3: Execute** — Implement the plan
- **Phase 4: Verify** — Check correctness and completeness
- **Phase 5: Log/Report** — Summarize what was done

---

### Phase 4: Add Supporting Sections

Every skill must include these supporting sections:

#### Anti-Patterns

```markdown
## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| <bad practice> | <better approach> |
| <bad practice> | <better approach> |
```

**Rules:**
- Minimum 4 anti-pattern entries
- Each entry should describe a real, observed mistake
- The "Avoid" column describes the anti-pattern (don't just name it)
- The "Instead" column gives actionable guidance

#### Execution Checklist

```markdown
## Execution Checklist

```
[ ] Phase N: <step>
[ ] Phase N: <step>
[ ] Verify: <verification item>
[ ] Verify: <verification item>
```
```

**Rules:**
- One checkbox per phase step
- 3-5 `[ ] Verify:` items at the end
- Each checkbox is something that can be objectively confirmed

#### Verification

```markdown
## Verification

After <skill operation>:
1. <measurable criterion>
2. <measurable criterion>
3. <measurable criterion>
```

**Rules:**
- Minimum 4 verification criteria
- Each criterion must be objectively verifiable (not "looks good")
- Criteria should span: correctness, completeness, safety

---

### Phase 5: Trigger Uniqueness Validation

Before finalizing, validate that all trigger phrases are unique:

```markdown
## Trigger Uniqueness Check

**Skill:** <name>
**Candidate triggers:**
- "<phrase 1>"
- "<phrase 2>"
- ...

**Search results across all skills:**
| Trigger | Matches in other skills | Verdict |
|---------|------------------------|---------|
| "<phrase 1>" | 0 | ✅ UNIQUE |
| "<phrase 2>" | 0 | ✅ UNIQUE |

**Result:** All triggers are unique / N triggers collide (rephrase: <details>)
```

**When collisions are found:**
1. Determine if the collision is actual overlap (same intent) or just shared vocabulary
2. If actual overlap, rephrase to distinguish intent
3. If false positive (same words, different context), add clarifying context in the trigger

---

### Phase 6: Final Review

Complete a final review of the complete skill file:

```markdown
## Skill Final Review

### Structure Check
- [ ] Frontmatter with all required fields (name, description, license, metadata)
- [ ] Triggers section with 6+ phrases and "Do NOT use" clause
- [ ] Process section with 3-7 phases, each with clear outputs
- [ ] Anti-Patterns section with 4+ entries
- [ ] Execution Checklist with phase steps + verification items
- [ ] Verification section with 4+ measurable criteria

### Quality Check
- [ ] All trigger phrases are unique (no overlap with existing skills)
- [ ] Descriptions use user language, not system jargon
- [ ] Templates and examples are filled with realistic content
- [ ] Phase order is logical (assess → design → execute → verify)
- [ ] Anti-patterns describe real, observed mistakes
- [ ] Verification criteria are objectively measurable

### Content Check
- [ ] No hardcoded paths, names, or secrets
- [ ] No references to nonexistent skills or tools
- [ ] Consistent kebab-case naming
- [ ] Consistent formatting (heading levels, code blocks, tables)
- [ ] License is MIT
- [ ] `source.path` matches the folder name
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Writing triggers in technical jargon | Use language the user would naturally say |
| Creating a skill for a one-time task | Skills should solve reusable, repeatable problems |
| Skipping the anti-patterns section | Anti-patterns are essential for preventing misuse |
| Writing verification criteria that are subjective ("looks good") | Use objectively measurable criteria |
| Only 1-2 process phases | Minimum 3 phases for a meaningful workflow |
| Copying triggers from another skill verbatim | Craft unique, specific trigger phrases |
| Nesting phases too deep (sub-sub-phases) | Keep flat phase structure; use tables for branching |

---

## Execution Checklist

```
[ ] Phase 0: Skill specification defined (problem, audience, capabilities, triggers)
[ ] Phase 1: Frontmatter written (name, description, category, source)
[ ] Phase 2: Triggers designed (6+ phrases, anti-trigger, user-language)
[ ] Phase 3: Process phases designed (3-7 phases, templates, tables)
[ ] Phase 4: Anti-Patterns, Execution Checklist, Verification written
[ ] Phase 5: Trigger uniqueness validated (no overlap with existing skills)
[ ] Phase 6: Final review completed (structure, quality, content checks)
[ ] Verify: All required sections are present
[ ] Verify: All trigger phrases are unique
[ ] Verify: Verification criteria are objectively measurable
[ ] Verify: Skill name matches folder name and source.path
```

---

## Verification

After skill creation:
1. All required sections are present (frontmatter, triggers, process, anti-patterns, checklist, verification)
2. Trigger uniqueness is validated — no overlap with existing 18+ skills
3. Process has 3-7 phases with clear inputs, actions, and outputs
4. Verification criteria are objectively measurable
5. Anti-patterns describe real misuse scenarios with actionable alternatives
6. The skill follows the established Kilo SKILL.md template format
```

---

### 3. `observability-tracer`

```markdown
---
name: observability-tracer
description: >-
  Record tool calls, state transitions, decisions, failures, and resource
  usage during execution for debugging, evaluation, and improvement.
  Captures a structured trace log that can be reviewed post-hoc to
  understand agent behavior, diagnose failures, and identify optimization
  opportunities.
license: MIT
metadata:
  category: observability
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/observability-tracer
    license_path: LICENSE
---

# Observability Tracer

Record structured traces of agent execution — tool calls, state transitions,
decisions, failures, and costs — so you can debug failures, evaluate
performance, and improve workflows with data-driven insight.

---

## Triggers

Use this skill when:
- "trace this execution"
- "debug this workflow"
- "record state transitions"
- "observability for this task"
- "log tool calls and decisions"
- "monitor execution flow"
- "instrument this workflow for debugging"
- "capture execution trace for analysis"

Do NOT use for simple one-shot tasks where no debugging or analysis is
needed, or when the user explicitly asks not to log execution details.

---

## Process

### Phase 0: Define Trace Scope

Before tracing begins, define what to capture:

```markdown
## Trace Configuration

**Trace ID:** <unique-id>
**Task goal:** <what is being traced>

**Capture scope:**
- [ ] **All tool calls** — name, input params (sanitized), output summary, duration
- [ ] **State transitions** — before/after snapshots at decision points
- [ ] **Decisions** — what was decided, why, alternatives considered
- [ ] **Failures** — error messages, stack traces, retry attempts
- [ ] **Costs** — token estimates per tool call / per phase
- [ ] **State snapshots** — full context state at checkpoints

**Output location:** `<trace-dir>/trace-<trace-id>.md`
**Max trace entries:** <N> (sliding window — oldest entries pruned when exceeded)
```

**Scope selection guidelines:**
| Scenario | Recommended Scope |
|----------|-------------------|
| Debugging a specific failure | Tool calls + Failures + State at failure point |
| Performance optimization | All tool calls + Costs + Duration per call |
| Eval improvement | Tool calls + Decisions + State transitions |
| General monitoring | Tool calls + Failures + Duration (lightweight) |
| Full audit | All categories |

---

### Phase 1: Initialize Trace

Create the trace log file:

```markdown
# Execution Trace: <trace-id>

**Task:** <goal>
**Started:** <ISO 8601 timestamp>
**Trace scope:** <captured categories>

## Trace Entries

| # | Time | Type | Component | Detail | Duration | Tokens (est.) | Status |
|---|------|------|-----------|--------|----------|---------------|--------|
```

**Trace file rules:**
- Use markdown for human readability
- Each entry is a row in the trace table
- Type is one of: `tool_call`, `state_transition`, `decision`, `failure`, `checkpoint`
- Status is one of: `success`, `failure`, `in_progress`, `skipped`

---

### Phase 2: Record Events

For each event during execution, append a trace entry:

#### Tool Call

```markdown
| 1 | 12:00:01 | tool_call | read_file | "Read config.yaml (512 bytes)" | 0.3s | ~150 | success |
```

**What to capture for tool calls:**
- Tool name
- Input summary (sanitize secrets — never log API keys, passwords, tokens)
- Output summary (truncate to 100 chars or first N lines)
- Duration in seconds (if measurable)
- Token estimate (input + output tokens where available)
- Status

#### Decision

```markdown
| 2 | 12:00:05 | decision | orchestrator | "Chose reflection-loop over plan-and-execute because task is small and quality-focused" | 0.1s | ~200 | success |
```

**What to capture for decisions:**
- What was decided
- Why (rationale — avoid "seemed right", prefer "because X criteria")
- Alternatives considered (briefly)
- Any trade-offs acknowledged

#### State Transition

```markdown
| 3 | 12:00:30 | state_transition | context | "Phase: research → implement. Files loaded: 3. Decisions made: 2." | 0s | ~50 | success |
```

**What to capture for state transitions:**
- From state → to state
- Key state changes (files loaded, context compacted, subtasks completed)
- Trigger for the transition (what caused it)

#### Failure

```markdown
| 4 | 12:01:00 | failure | read_file | "ENOENT: path not found 'missing.txt'" | 0.2s | ~100 | failure |
```

**What to capture for failures:**
- Error type and message
- Where it occurred (component, phase, line)
- Recovery attempted (if any) and outcome
- Full error context written to separate error log if needed

---

### Phase 3: Generate Trace Summary

When tracing is complete or at regular intervals:

```markdown
## Trace Summary

**Trace ID:** <trace-id>
**Duration:** <total time>
**Total entries:** N

### Statistics

| Metric | Value |
|--------|-------|
| Total tool calls | N |
| Successful | N |
| Failed | N |
| Retries | N |
| Total decisions | N |
| State transitions | N |
| Estimated tokens | N |
| Total duration | <time> |

### Category Breakdown

**By tool type:**
| Tool | Calls | Avg Duration | Failures |
|------|-------|-------------|----------|
| read_file | 15 | 0.3s | 1 |
| write_file | 5 | 0.5s | 0 |
| web_search | 3 | 1.2s | 0 |

**By failure type:**
| Failure | Count | Root Cause |
|---------|-------|------------|
| ENOENT | 1 | Typo in filename |
| ETIMEDOUT | 2 | Network issues |

### Anomalies Detected

- <unusual patterns, e.g., "read_file called 15 times — possible inefficiency">
- <repeated failures, e.g., "ENOENT occurred twice in same directory">
- <long-running operations, e.g., "web_search took 1.2s avg — slowest tool">

### Recommendations

- <actionable insight from trace analysis>
```

---

### Phase 4: Analyze Trace for Improvement

Use the trace data to drive improvements:

```markdown
## Improvement Analysis

### Efficiency opportunities:
- <tool> called N times but could be batched: <suggestion>
- <tool> returns large responses but only <N>% used: <suggestion>

### Failure patterns:
- <error> occurs in <N>% of traces: <root cause and fix>
- <decision> was reversed N times: <suggestion>

### Cost optimization:
- Top 3 most expensive operations: <list>
- Estimated tokens saved if <change>: <estimate>
```

**Analysis approaches:**
| Pattern | What It Indicates | Action |
|---------|-------------------|--------|
| High retry count on same tool | Tool unreliable or misused | Review tool definition or error handling |
| Many small file reads | Fragmented I/O pattern | Batch reads or restructure data access |
| Long decision time on routine choices | Missing context or confusing options | Add clearer guidance or defaults |
| Repeated state transitions | Context thrashing | Restructure phase boundaries |
| Expensive tool calls for trivial results | Poor tool selection | Improve tool descriptions or ordering |

---

### Phase 5: Archive or Clean Up

After analysis:

```markdown
## Trace Archival

**Trace ID:** <trace-id>
**Status:** <archived / deleted / retained for comparison>

**Retention decision:**
- Keep for comparison with future traces? <yes/no>
- Contains sensitive data? <yes/no — if yes, sanitize>
- Reference in eval improvement? <yes/no — eval-id if applicable>
```

**Trace retention rules:**
- Keep traces from failed/debugged tasks for at least 7 days
- Keep traces referenced by eval improvements indefinitely
- Sanitize traces containing secrets before retention
- Prune traces older than 30 days unless explicitly retained

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Logging secrets, API keys, or credentials | Sanitize all sensitive data before recording |
| Capturing everything without focus | Define scope in Phase 0 based on the objective |
| Verbose output summaries that bloat traces | Truncate outputs to 100 chars or key lines |
| Only capturing success, never failure | Failures are the most valuable trace entries |
| Measuring without acting on data | Always extract recommendations from trace analysis |
| Infinite trace growth with no pruning | Set max entries and retention policy |
| Trace as an afterthought (too late to capture) | Initialize trace at the start of execution |

---

## Execution Checklist

```
[ ] Phase 0: Trace scope defined (which categories to capture)
[ ] Phase 1: Trace log initialized with ID, goal, scope, table header
[ ] Phase 2: Each event recorded (tool_call, decision, state_transition, failure)
[ ] Phase 2: Secrets sanitized in all entries
[ ] Phase 3: Trace summary generated (statistics, breakdown, anomalies)
[ ] Phase 4: Improvement analysis performed from trace data
[ ] Phase 5: Trace archived or pruned with retention decision
[ ] Verify: No secrets or credentials in any trace entry
[ ] Verify: Every failure has a corresponding trace entry
[ ] Verify: Trace summary includes actionable recommendations
[ ] Verify: Trace scope matches the analysis objective
```

---

## Verification

After tracing:
1. A trace log exists with structured entries for all captured event types
2. No sensitive data (secrets, keys, tokens) appears in any trace entry
3. Trace summary provides statistics and anomaly detection
4. Improvement analysis identifies at least one actionable recommendation
5. Trace retention policy is applied (archive / delete / retain)
6. Trace data is usable for eval-driven improvement (referenced by eval ID if applicable)
```

---

### 4. `security-review-gate`

```markdown
---
name: security-review-gate
description: >-
  Run a structured security-focused review before destructive operations,
  external actions, or changes with security implications. Checks for
  common vulnerability patterns, credential leaks, unsafe operations, and
  data exposure risks. Provides a pass/fail assessment with actionable
  remediation guidance.
license: MIT
metadata:
  category: safety
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/security-review-gate
    license_path: LICENSE
---

# Security Review Gate

Run a structured security review before executing actions that could
introduce vulnerabilities, leak credentials, expose data, or cause
harm. The gate evaluates the proposed action against a checklist of
common security risks and returns a pass/fail decision with remediation
steps.

---

## Triggers

Use this skill when:
- "security review before action"
- "check for vulnerabilities"
- "scan for security issues"
- "review destructive command"
- "security gate for external calls"
- "audit this change for risks"
- "run a security check on this operation"
- "security audit required"

Do NOT use for routine, read-only operations with no security impact
(e.g., reading a file, searching the web), or when a security review
was already performed and no relevant changes have occurred since.

---

## Process

### Phase 0: Action Classification

Classify the proposed action by its security risk profile:

```markdown
## Security Review: <action description>

**Action type:** <operation being reviewed>
**Proposed by:** <who initiated>

**Risk profile:**
| Dimension | Assessment |
|-----------|------------|
| **Data access** | <read / write / delete / transmit / execute> |
| **Data sensitivity** | <public / internal / confidential / secret> |
| **External interaction** | <none / outbound API / inbound / credential use> |
| **Destructive potential** | <none / moderate / high / irreversible> |
| **Scope** | <local / network / filesystem / cross-service> |
```

**Security review levels:**

| Level | Trigger | Effort |
|-------|---------|--------|
| **L1 — Quick Scan** | Read-only access to non-sensitive data | ~30s |
| **L2 — Standard Review** | Write/modify operations, external API calls, credential use | ~2min |
| **L3 — Deep Audit** | Destructive operations, sensitive data access, cross-service actions | ~5min |
| **L4 — Full Security Audit** | Production deployment, auth changes, encryption operations | Requires user approval for each check |

---

### Phase 1: Run Security Checks

Based on the risk profile, run applicable checks:

#### 1. Credential Leak Check

For any action involving file write, API call, or data transmission:

```markdown
### Credential Leak Check

**Scope:** <what is being inspected>
**Patterns scanned:**
- [ ] API keys / tokens (`sk-...`, `api_key=...`, `token=...`)
- [ ] Passwords / secrets (`password=...`, `secret=...`, `PASSWORD`)
- [ ] Connection strings (`connection_string=...`, `mongodb://...`)
- [ ] Private keys (`-----BEGIN ... PRIVATE KEY-----`)
- [ ] Environment variable exports with secrets (`export SECRET=`)

**Findings:** <none / pattern found at <location>>
**Result:** PASS / FAIL
```

**Rules:**
- Scan all file contents being written for credential patterns
- Scan command strings for inline secrets
- Scan API call parameters for sensitive values
- If credentials are found: FAIL with location and remediation

#### 2. Destructive Operation Check

For any action that modifies or deletes data:

```markdown
### Destructive Operation Check

**Operation:** <command or action>
**What it does:** <plain language description>

**Impact assessment:**
- [ ] Files affected: <count> — <paths>
- [ ] Irreversible: <yes/no — if yes, describe>
- [ ] Data loss risk: <none / partial / complete>
- [ ] Rollback available: <yes/no — describe>

**Dry-run available?** <yes/no — if yes, recommend dry-run first>
**Result:** PASS / FAIL / CAUTION
```

**Rules:**
- FAIL if operation is irreversible with no rollback plan
- CAUTION if operation affects >10 files or modifies critical paths
- Always note if a dry-run is available

#### 3. External Call Check

For any action that reaches an external service:

```markdown
### External Call Check

**Target:** <URL or service>
**Method:** <HTTP method / protocol>
**Data being sent:** <summary of payload>

**Risk assessment:**
- [ ] TLS/HTTPS: <yes/no>
- [ ] Authentication: <method>
- [ ] Data sensitivity matched to destination trust level: <yes/no>
- [ ] Rate limiting respected: <yes/no>
- [ ] Proper error handling for network failures: <yes/no>

**Result:** PASS / FAIL
```

**Rules:**
- FAIL if non-TLS endpoint receives sensitive data
- FAIL if destination trust level is unknown or lower than data sensitivity
- CAUTION if no error handling for network or auth failures

#### 4. Code/Command Injection Check

For any action that constructs or executes commands:

```markdown
### Injection Check

**Context:** <shell command, SQL query, eval, or dynamic execution>

**Checks:**
- [ ] Input properly escaped/sanitized: <yes/no/na>
- [ ] No string concatenation of untrusted input into commands: <yes/no/na>
- [ ] Parameterized queries used where applicable: <yes/no/na>
- [ ] Shell metacharacters handled: <yes/no/na>

**Result:** PASS / FAIL
```

**Rules:**
- FAIL if untrusted input is concatenated into shell commands or SQL
- FAIL if `eval()` or `exec()` is used with unsanitized input
- CAUTION if any string interpolation of user input into commands

#### 5. Permission Escalation Check

For any action that changes access or permissions:

```markdown
### Permission Escalation Check

**Action:** <chmod, chown, ACL change, role assignment>

**Checks:**
- [ ] Least privilege principle maintained: <yes/no>
- [ ] Change is scoped to minimum required: <yes/no>
- [ ] No unintended access granted: <yes/no>

**Result:** PASS / FAIL
```

---

### Phase 2: Assess Results

Aggregate all check results into a decision:

```markdown
## Security Review Results

| Check | Result | Details |
|-------|--------|---------|
| Credential Leak | PASS / FAIL | <summary> |
| Destructive Operation | PASS / FAIL / CAUTION | <summary> |
| External Call | PASS / FAIL / CAUTION | <summary> |
| Injection | PASS / FAIL | <summary> |
| Permission Escalation | PASS / FAIL / NA | <summary> |

**Overall:** PASS / FAIL / CAUTION

### Decision Rules

| Overall | Meaning | Action |
|---------|---------|--------|
| **PASS** | No security issues found | Safe to proceed |
| **CAUTION** | Minor risks identified (≥1 CAUTION, no FAIL) | Proceed with noted mitigations, or gate for user approval |
| **FAIL** | Critical security issues found (≥1 FAIL) | Do NOT proceed. Present remediation steps. |
```

---

### Phase 3: Remediation Guidance

If the review FAILs, provide specific remediation:

```markdown
## Remediation Required

### Issue 1: <check name> — FAIL

**Location:** <exact path or code location>
**Vulnerability:** <what is wrong>
**Risk:** <what could happen>

**Fix:**
```
<before>  →  <after>
```

**Verification:** <how to confirm the fix works>
```

**Remediation rules:**
- Each FAIL must have a corresponding remediation entry
- Remediation must be specific and actionable (not "fix the issue")
- Include before/after examples where applicable
- After remediation, re-run the specific failed check

---

### Phase 4: Approval Gate

If the review results in FAIL or CAUTION:

```markdown
## Security Gate Active

**Review level:** <L1 / L2 / L3 / L4>
**Result:** <FAIL / CAUTION>
**Findings:** <summary>

**Awaiting user decision:**
1. **Apply remediation** — Let me fix the issues and re-review
2. **Override** — Proceed despite findings (user accepts the risk)
3. **Abort** — Cancel the operation entirely
```

**Gate rules:**
- FAIL requires user decision before proceeding (never auto-override)
- CAUTION may proceed if user pre-approved caution-level risks, or gate
- L4 level always requires user approval regardless of result

---

### Phase 5: Log Security Review

Record the review for audit trail:

```markdown
## Security Review Log

| # | Timestamp | Action | Level | Result | Decision | Reviewer |
|---|-----------|--------|-------|--------|----------|----------|
| 1 | 12:00:00 | rm -rf ./temp | L2 | FAIL → PASS | Applied fix | agent |
| 2 | 12:05:00 | POST to api.example.com | L2 | CAUTION | Proceeded | user |
```

**Log rules:**
- Record every review, regardless of result
- Include the before/after if remediation was applied
- Store log in a dedicated security log file when performing multiple reviews

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Skipping credential checks on file write operations | Always check written content for credential patterns |
| Auto-overriding FAIL results | FAIL always requires user decision |
| Using regex-only credential detection (high false positive) | Use pattern matching + context validation |
| Only scanning for known patterns (misses novel vulnerabilities) | Apply principle of least privilege and common-sense checks |
| Security theater — checking everything superficially | Tailor check depth to the action's risk profile |
| Treating CAUTION the same as PASS | CAUTION means "proceed with awareness" — not "nothing to see" |
| No remediation for findings | Every FAIL must have a corresponding fix suggestion |

---

## Execution Checklist

```
[ ] Phase 0: Action classified (risk profile, review level)
[ ] Phase 1: Credential Leak Check (scan written content and commands)
[ ] Phase 1: Destructive Operation Check (impact, reversibility, rollback)
[ ] Phase 1: External Call Check (TLS, auth, data sensitivity)
[ ] Phase 1: Injection Check (shell, SQL, eval — input sanitization)
[ ] Phase 1: Permission Escalation Check (least privilege, scope)
[ ] Phase 2: Results aggregated and decision (PASS / CAUTION / FAIL)
[ ] Phase 3: Remediation provided for each FAIL
[ ] Phase 4: Approval gate applied if FAIL or CAUTION
[ ] Phase 5: Security review logged for audit trail
[ ] Verify: No FAIL results were auto-overridden
[ ] Verify: Credential check scanned all written content
[ ] Verify: Remediation is specific and actionable
[ ] Verify: Dry-run availability noted for destructive operations
```

---

## Verification

After security review:
1. All applicable checks (credential, destructive, external, injection, permission) were run
2. No sensitive data (credentials, secrets) was included in any written output or command
3. Every FAIL finding has a corresponding, actionable remediation
4. User approval was obtained for FAIL results before proceeding
5. Security review log captures the action, level, result, and decision
6. Dry-run was recommended (and ideally executed) for destructive operations
7. The review did not introduce new security issues (e.g., credential scanning didn't log secrets)
```

---

## Proposed `kilo.json` Additions

Add explicit `paths` entries under `"skills"` for the 4 new Tier-3 skills:

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
      "skills/tool-design-optimizer",
      "skills/orchestrator-worker",
      "skills/eval-driven-improver",
      "skills/context-engineering",
      "skills/mcp-integration",
      "skills/checkpoint-resume",
      "skills/human-in-loop-gate",
      "skills/skill-creator-kilo",
      "skills/observability-tracer",
      "skills/security-review-gate"
    ]
  }
}
```

### Fallback: Full Path List (if explicit paths replace auto-discovery)

```json
"paths": [
  "skills/agent-md-refactor",
  "skills/canvas-design",
  "skills/checkpoint-resume",
  "skills/content-research-writer",
  "skills/context-engineering",
  "skills/docx",
  "skills/dry-run-verify-fix",
  "skills/eval-driven-improver",
  "skills/human-in-loop-gate",
  "skills/image-enhancer",
  "skills/mcp-integration",
  "skills/observability-tracer",
  "skills/orchestrator-worker",
  "skills/pdf",
  "skills/plan-and-execute",
  "skills/pptx",
  "skills/reflection-loop",
  "skills/security-review-gate",
  "skills/self-healing-loop",
  "skills/skill-creator-kilo",
  "skills/tool-design-optimizer",
  "skills/xlsx"
]
```

---

## Trigger Uniqueness Matrix

All Tier-3 triggers are disjoint from existing Tier-1, Tier-2, and domain skills:

### Existing Skills (18 total)

| Skill | Trigger Domain |
|-------|---------------|
| Domain skills (docx, pdf, xlsx, pptx, canvas-design, image-enhancer, content-research-writer, agent-md-refactor) | File types, design, writing, markdown, visual art — no structured trigger phrase lists |
| `plan-and-execute` | staged plan, decompose, multi-phase, step-by-step with replan, milestones, task decomposition with verification gates |
| `reflection-loop` | critique, self-review, reflect, iterative refinement, review against explicit criteria, self-critique loop |
| `self-healing-loop` | error classification, retry, compensate, interrupt, tool failure, transient failure |
| `dry-run-verify-fix` | dry-run, pre-ship validation, simulate, verify and fix, validate changes, bounded repair |
| `tool-design-optimizer` | tool definitions, tool schema, ACI optimization, LLM usability, tool prompt engineering |
| `orchestrator-worker` | delegate to specialists, coordinate workers, split across subagents, orchestrate, multi-agent decomposition |
| `eval-driven-improver` | benchmark skill, create evals, measure quality, eval loop, compare with and without skill |
| `context-engineering` | context too long, compact conversation, manage long-running context, reduce token usage, summarize state |
| `mcp-integration` | add MCP server, connect via MCP, Model Context Protocol, create MCP wrapper, configure MCP tools |
| `checkpoint-resume` | create checkpoint, save and resume, stateful workflow, checkpoint before risky op, interruption-safe execution |

### New Tier-3 Skills (no collision with any existing trigger)

| New Tier-3 Skill | Triggers (no collision with above) |
|------------------|------------------------------------|
| `human-in-loop-gate` | pause for user approval, human-in-the-loop, require user confirmation, ask before proceeding, high-impact decision gate, safety check needed, confirm this action before execution, interrupt for user decision |
| `skill-creator-kilo` | create a new skill, improve this skill, add a trigger phrase, skill development, design a skill workflow, build a Kilo skill, author a skill for this capability, refine an existing skill |
| `observability-tracer` | trace this execution, debug this workflow, record state transitions, observability for this task, log tool calls and decisions, monitor execution flow, instrument this workflow for debugging, capture execution trace for analysis |
| `security-review-gate` | security review before action, check for vulnerabilities, scan for security issues, review destructive command, security gate for external calls, audit this change for risks, run a security check on this operation, security audit required |

**Zero trigger overlap** with any existing Tier-1, Tier-2, or domain skill. The Tier-3 triggers use distinct vocabulary domains:

- `human-in-loop-gate` — approval/confirmation/gate language, distinct from `self-healing-loop` (error-focused) and `checkpoint-resume` (state persistence)
- `skill-creator-kilo` — skill authoring/metaskill language, distinct from `eval-driven-improver` (benchmarking/evaluation, not creation)
- `observability-tracer` — tracing/recording/instrumentation language, distinct from `reflection-loop` (self-critique, not external recording) and `self-healing-loop` (error recovery, not monitoring)
- `security-review-gate` — security/vulnerability/audit language, distinct from all existing skills — this is the only safety/security-focused skill

---

## Verification Approach

1. **File existence check:** Confirm all 4 directories and `SKILL.md` files exist
2. **Frontmatter validation:** Each `SKILL.md` has valid YAML frontmatter with required fields (`name`, `description`, `metadata.category`)
3. **JSON validation:** `kilo.json` parses as valid JSON with 14 paths (or 22 paths for full list)
4. **Trigger uniqueness grep:** Use `grep -r` across all `skills/**/SKILL.md` to confirm no new trigger phrase collides with any existing skill
5. **Phase completeness:** Each SKILL.md has at minimum: Triggers (6+ phrases + anti-trigger) → Process (3-7 phases) → Anti-Patterns (4+ entries) → Execution Checklist → Verification (4+ criteria)

---

## Rollback Considerations

- **Revert `kilo.json`:** Remove the 4 Tier-3 path entries; restore previous state
- **Remove skill folders:** Delete `skills/<new-skill>/` directories
- **No cascade effects:** Skills are self-contained `SKILL.md` files with no inter-skill dependencies, no npm packages, and no running services

---

## Next Steps

1. Execute Step 1: Create 4 skill directories (`human-in-loop-gate`, `skill-creator-kilo`, `observability-tracer`, `security-review-gate`)
2. Execute Step 2: Write 4 SKILL.md files from the content above
3. Execute Step 3: Update `kilo.json` with Tier-3 path entries
4. Execute Step 4: Verify all skills are discoverable via trigger testing and uniqueness validation

---

*Generated: 2026-06-12 05:49*
*Last Updated: 2026-06-12 05:49*
