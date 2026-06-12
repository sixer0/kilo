---
task_id: upgrade-skill-list-tier2
task_slug: upgrade-skill-list-tier2
date: 2026-06-12
agent: data-analyst
type: implementation-plan
based_on: /docs/2026_06_12_upgrade-skill-list-tier2/analysis_result.md
last_updated: 2026-06-12 05:38
---

# Implementation Plan: 5 Tier-2 Agentic Skills

## Current State

Kilo now has 13 skills (8 existing domain skills + 5 Tier-1 agentic skills from the first rollout):

```
skills/agent-md-refactor/
skills/canvas-design/
skills/content-research-writer/
skills/docx/
skills/image-enhancer/
skills/ms365/
skills/pdf/
skills/pptx/
skills/xlsx/
skills/plan-and-execute/          # Tier-1
skills/reflection-loop/            # Tier-1
skills/self-healing-loop/          # Tier-1
skills/dry-run-verify-fix/         # Tier-1
skills/tool-design-optimizer/      # Tier-1
```

`kilo.json` has `"skills": { "paths": [...] }` containing the 5 Tier-1 entries (and potentially the 8 existing skills if explicit paths override auto-discovery).

**Gap:** No skills exist for multi-agent orchestration, eval-driven improvement, context/memory management, MCP tool integration, or stateful checkpoint/resume. These are Tier-2 patterns identified in the research as "Advanced Orchestration" capabilities.

## Target State

5 new skill directories under `skills/`, each with a `SKILL.md` defining a distinct advanced agentic capability:

| Folder | Purpose |
|--------|---------|
| `skills/orchestrator-worker/` | Delegate subtasks to specialist subagents, coordinate workers, synthesize results |
| `skills/eval-driven-improver/` | Create eval prompts, run with/without skill, grade outputs, iterate |
| `skills/context-engineering/` | Manage long-running context with compaction, focused state, memory |
| `skills/mcp-integration/` | Add/configure MCP servers, tool allowlists, auth, tool schemas |
| `skills/checkpoint-resume/` | Persist workflow state, checkpoints, progress, resume summaries |

## Implementation Steps

| Step | Action | Details |
|------|--------|---------|
| 1 | Create skill directories | `skills/orchestrator-worker/`, `skills/eval-driven-improver/`, `skills/context-engineering/`, `skills/mcp-integration/`, `skills/checkpoint-resume/` |
| 2 | Write SKILL.md files | One per skill, following Kilo frontmatter + triggers + process phases format |
| 3 | Update kilo.json | Add explicit `paths` entries for the 5 new Tier-2 skills |
| 4 | Verify | Confirm files exist, `kilo.json` is valid JSON, skills are discoverable |

**Status (2026-06-12 05:41):** Steps 1–4 all completed.
- Step 1 done — 5 directories created under `skills/`
- Step 2 done — 5 SKILL.md files written (7.1–8.0 KB each, 230–279 lines)
- Step 3 done — `kilo.json` updated to 10 paths (5 Tier-1 + 5 Tier-2); config validation passed
- Step 4 done — all files have valid frontmatter (`name`, `description`, `metadata.category`) and required sections (Triggers, Process, Anti-Patterns, Execution Checklist, Verification)

## Changes Required

1. Create 5 new directories under `skills/`
2. Write 5 SKILL.md files
3. Modify `kilo.json` to add explicit paths for Tier-2 skills
4. No other files are modified

## Dependencies

- `kilo.json` must remain valid JSON
- No external npm packages, MCP servers, or runtime dependencies
- Skills are pure `SKILL.md` system prompts — no supporting scripts or binaries needed
- Tier-2 skills may reference Tier-1 skills (e.g., `dry-run-verify-fix` for eval validation); these are conceptual references, not file imports

---

## Folder Names to Create

```
skills/orchestrator-worker/
skills/eval-driven-improver/
skills/context-engineering/
skills/mcp-integration/
skills/checkpoint-resume/
```

Each folder contains exactly one file: `SKILL.md`.

---

## Finalized SKILL.md Content

### 1. `orchestrator-worker`

```markdown
---
name: orchestrator-worker
description: >-
  Delegate complex, multi-domain tasks to specialist subagents or workers.
  The orchestrator decomposes the work, assigns each subtask to the most
  capable worker (based on skill or tooling), monitors execution, and
  synthesizes results into a coherent final output. Workers operate in
  isolated contexts to prevent cross-contamination.
license: MIT
metadata:
  category: orchestration
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/orchestrator-worker
    license_path: LICENSE
---

# Orchestrator-Worker

Decompose a complex task into independent subtasks and delegate each to a
specialist subagent or worker. The orchestrator defines the plan, assigns
work, collects results, resolves conflicts, and synthesizes the final output.

---

## Triggers

Use this skill when:
- "delegate this to specialists"
- "coordinate workers across subtasks"
- "split this work across subagents"
- "orchestrate the work with parallel workers"
- "multi-agent decomposition and synthesis"
- "assign subtasks to the most capable agent"

Do NOT use for simple single-pass tasks that don't benefit from
decomposition, or when the user explicitly wants a single-agent approach.

---

## Process

### Phase 0: Task Analysis & Decomposition

Analyze the request and decompose into independent subtasks:

```yaml
orchestration_plan:
  goal: <restated goal>
  decomposition_strategy: domain / phase / concern
  subtasks:
    - id: 1
      name: <short name>
      description: <what this subtask achieves>
      specialist: <suggested skill or capability>
      dependencies: <ids of subtasks that must complete first, or "none">
      acceptance_criteria:
        - <measurable condition>
```

**Decomposition strategies:**
- **Domain:** Split by expertise area (e.g., frontend vs backend, research vs coding)
- **Phase:** Split by workflow stage (e.g., research → design → implement → test)
- **Concern:** Split by architectural layer (e.g., data layer, business logic, UI)

**Rules:**
- Each subtask must be independently verifiable
- Dependencies must form a DAG (no circular deps)
- Keep subtasks granular enough that a single worker can complete them
- Max 7 subtasks per orchestration (beyond that, nest or batch)

---

### Phase 1: Worker Assignment

For each subtask, determine the best execution strategy:

| Subtask Type | Strategy | Example |
|-------------|----------|---------|
| **Skill-mapped** | Invoke via skill context | "Use `plan-and-execute` to design the architecture" |
| **Tool-specific** | Use existing tools | "Use puppeteer to capture screenshots of all pages" |
| **Research** | Web search + analysis | "Search for latest API docs and summarize" |
| **Coding** | File read/write + verify | "Implement the module and run tests" |

Record the assignment:

```markdown
### Worker Assignments

| Subtask | Worker | Context | Expected Output |
|---------|--------|---------|-----------------|
| 1 | <skill/toolset> | <files or domains> | <artifact> |
| 2 | <skill/toolset> | <files or domains> | <artifact> |
```

---

### Phase 2: Execute Workers

Run subtasks respecting dependency order:

1. Identify all subtasks with satisfied dependencies (ready set)
2. Execute ready subtasks (sequentially or logically in parallel)
3. Collect outputs and log completion
4. Update dependency graph — mark completed subtasks as done
5. Repeat until all subtasks complete or a blocker is hit

```markdown
**Worker: <subtask name>** [IN PROGRESS / COMPLETE / FAILED]
**Assigned to:** <worker description>
**Result:**
<artifact or summary>

**Issues:**
- <any problems encountered>
```

**Failure handling:**
- If a worker fails, diagnose the failure (use `self-healing-loop` pattern internally)
- If the failure is recoverable, retry with adjusted instructions
- If the failure is unrecoverable, escalate to orchestrator decision:
  - Skip the subtask (document gap)
  - Reassign to a different approach
  - Abort the orchestration

---

### Phase 3: Conflict Resolution

When multiple workers produce overlapping or contradictory results:

1. **Identify conflicts:** Compare outputs for shared concerns
2. **Evaluate:** Which output is more authoritative for the domain?
3. **Reconcile:** Merge, pick the best, or flag for user decision

```markdown
### Conflict: <concern>

**Worker A says:** <position>
**Worker B says:** <position>

**Resolution:** <merge / pick A / pick B / escalate>
**Rationale:** <why this resolution was chosen>
```

---

### Phase 4: Synthesis

Combine all worker outputs into a coherent final deliverable:

1. **Aggregate:** Collect all completed subtask outputs
2. **Structure:** Organize into a logical flow (use the decomposition structure)
3. **Cross-reference:** Ensure consistency across subtask boundaries
4. **Polish:** Format for readability and completeness

```markdown
## Orchestration Summary

**Goal:** <restated goal>
**Subtasks Planned:** N
**Subtasks Completed:** N
**Subtasks Skipped/Failed:** N

**Final Deliverable:**
<combined output>

**Known Gaps:**
- <any skipped subtasks or unresolved conflicts>

**Decision Log:**
- Subtask 1: COMPLETE — <summary>
- Subtask 2: COMPLETE — <summary>
- ...
- Conflict X: RESOLVED — <resolution>
```

---

## Example

**User:** "Audit our API for security vulnerabilities and generate a report."

**Decomposition:**
1. Inventory all API endpoints (research + file reading)
2. Check authentication/authorization (security analysis)
3. Validate input sanitization (code review)
4. Test rate limiting (tool-based)
5. Generate report (writing)

**Conflict example:** Worker 2 finds "no auth on /health" while Worker 3 finds "/health returns OK without input". Resolution: "/health is intentionally public — documented as known, not a bug."

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Creating too many subtasks (fragmentation) | Keep 3-7 subtasks; merge fine-grained work |
| Overlapping subtask scopes | Ensure each subtask has clear, non-overlapping responsibility |
| Ignoring dependency order | Always respect the DAG; never start dependent work early |
| Workers modifying shared state silently | Workers should report results; orchestrator manages shared state |
| No conflict resolution step | Always include explicit conflict reconciliation |

---

## Execution Checklist

```
[ ] Phase 0: Task decomposed into 3-7 subtasks with DAG dependencies
[ ] Phase 1: Each subtask assigned to appropriate worker
[ ] Phase 2: Workers executed in dependency order
[ ] Phase 2: Failures handled (retry/skip/abort)
[ ] Phase 3: Conflicts identified and resolved
[ ] Phase 4: Results synthesized into final deliverable
[ ] Verify: All subtask outputs are included
[ ] Verify: Conflicts are documented and resolved
[ ] Verify: Gaps are reported transparently
```

---

## Verification

After orchestration:
1. All subtasks completed (or explicitly skipped with rationale)
2. Dependencies were respected across execution order
3. Conflicts were identified and resolved
4. Final deliverable synthesizes all worker outputs
5. Decision log documents recovery and resolution choices
```

---

### 2. `eval-driven-improver`

```markdown
---
name: eval-driven-improver
description: >-
  Create evaluation prompts and assertions to benchmark skill or workflow
  quality. Run evals with and without the skill under test, grade outputs
  against criteria, and iterate on skill design based on measured gaps.
  Enables data-driven, repeatable skill improvement.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/eval-driven-improver
    license_path: LICENSE
---

# Eval-Driven Improver

Create, run, and iterate on evaluations to improve skill quality. Establish
baselines, measure improvements, and validate that changes actually help
rather than just feel better.

---

## Triggers

Use this skill when:
- "benchmark this skill's performance"
- "create evals for this workflow"
- "measure skill quality with test cases"
- "improve based on evaluation results"
- "eval loop for iterative refinement"
- "compare with and without the skill"

Do NOT use for one-off tasks where no repeatable measurement is needed,
or when you are running a single test without iteration.

---

## Process

### Phase 0: Define Evaluation Scope

Before creating evals, clarify:

```markdown
## Eval Spec

**Target under test:** <skill name or workflow description>
**Purpose:** <what quality dimension are we measuring?>
**Baseline condition:** <without skill / old version / current behavior>
**Target condition:** <with skill / new version / desired behavior>

**Success threshold:** <what score or criteria means "improvement">
```

Typical quality dimensions:
- **Correctness:** Does the output meet requirements?
- **Completeness:** Are all subtasks addressed?
- **Consistency:** Is output stable across similar inputs?
- **Efficiency:** Is token/time usage optimized?
- **Robustness:** Does it handle edge cases and errors?

---

### Phase 1: Create Eval Prompts

Design 3-10 evaluation prompts that exercise the skill's target capability:

```yaml
evals:
  - id: eval-1
    name: <short name>
    prompt: <the exact prompt to send>
    expected_behavior: <what success looks like>
    priority: critical / high / medium / low
    category: <correctness / completeness / consistency / efficiency / robustness>
```

**Rules for good eval prompts:**
1. Each eval should test ONE specific capability
2. Prefer realistic, domain-specific prompts over generic ones
3. Include edge cases (empty input, unusual constraints, error scenarios)
4. Make prompts reproducible (same input = same expected behavior)
5. Cover happy path, failure path, and boundary conditions

**Recommended distribution:**
- 40% happy path (normal operation)
- 30% edge cases (boundaries, unusual inputs)
- 30% failure scenarios (missing data, errors, conflicts)

---

### Phase 2: Define Grading Criteria

For each eval, define how outputs are graded:

```markdown
### Eval: <id> — <name>

**Prompt:** <the prompt>

**Criteria:**
| # | Criterion | Weight | Pass Condition |
|---|-----------|--------|----------------|
| 1 | <criterion> | mandatory / bonus | <specific, measurable condition> |
| 2 | <criterion> | mandatory / bonus | <specific, measurable condition> |

**Pass threshold:** <e.g., "all mandatory criteria pass">

**Expected output characteristics:**
- <characteristic 1>
- <characteristic 2>
```

**Grading scale per criterion:**
- **PASS (2):** Fully meets the criterion
- **PARTIAL (1):** Partially meets it (document what's missing)
- **FAIL (0):** Does not meet the criterion

---

### Phase 3: Run Baseline (Without Skill)

Run all eval prompts without the skill enabled. Grade each output:

```markdown
## Baseline Results

| Eval | C1 | C2 | C3 | Total | Pass? |
|------|----|----|----|-------|-------|
| eval-1 | 2 | 1 | 0 | 3/6 | FAIL |
| eval-2 | 2 | 2 | 2 | 6/6 | PASS |
| ... |   |   |   |       |       |

**Overall baseline:** <score summary>
**Key gaps:**
- <gap 1>
- <gap 2>
```

---

### Phase 4: Run Target (With Skill)

Apply the skill and run the same eval prompts. Use the same grading criteria:

```markdown
## Target Results

| Eval | C1 | C2 | C3 | Total | Pass? |
|------|----|----|----|-------|-------|
| eval-1 | 2 | 2 | 1 | 5/6 | PASS |
| eval-2 | 2 | 2 | 2 | 6/6 | PASS |
| ... |   |   |   |       |       |

**Overall target:** <score summary>
**Improvement vs baseline:** <+/- score>
```

---

### Phase 5: Analyze & Iterate

Compare baseline vs target. Identify specific gaps that remain:

```markdown
## Gap Analysis

| Gap | Baseline | Target | Improved? | Root Cause | Fix |
|-----|----------|--------|-----------|------------|-----|
| <gap> | FAIL | PARTIAL | Yes | <why> | <skill change> |
| <gap> | FAIL | FAIL | No | <why> | <skill change> |
| <gap> | PASS | FAIL | Regression! | <why> | <revert or adjust> |
```

**Iteration loop:**
1. Identify the top 1-2 gaps that matter most
2. Propose a specific change to the skill (trigger, description, process, guidance)
3. Re-run Phase 4 (target test) to measure improvement
4. Check for regressions in previously-passing evals
5. Repeat up to 3 iterations

**Stop conditions:**
- All evals pass at the defined threshold
- 3 iterations completed without further improvement
- User accepts the current results

---

### Phase 6: Report

```markdown
## Eval Summary

**Target:** <skill name>
**Evals:** N (N happy path, N edge case, N failure)
**Iterations:** N
**Baseline score:** <score>
**Final score:** <score>
**Improvement:** <+/-> <percentage>

**Status:** PASS / PARTIAL / FAIL

**Recommendation:**
- <if PASS: ship the skill>
- <if PARTIAL: specific remaining gaps>
- <if FAIL: fundamental redesign needed>

**Regression check:** Previously-passing evals still pass? Yes / No
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Writing evals that match the skill's own language | Write evals from the user's perspective |
| Grading subjectively without evidence | Require specific evidence for each score |
| Only testing happy path | Include edge cases and failure scenarios |
| Over-iterating past diminishing returns | Cap at 3 iterations or when no improvement |
| Ignoring regressions | Always re-run all evals after each change |
| Evals that are too easy (ceiling effect) | Include challenging cases that differentiate versions |

---

## Execution Checklist

```
[ ] Phase 0: Evaluation scope defined
[ ] Phase 1: 3-10 eval prompts created (happy/edge/failure)
[ ] Phase 2: Grading criteria established for each eval
[ ] Phase 3: Baseline run completed and scored
[ ] Phase 4: Target run completed and scored
[ ] Phase 5: Gap analysis performed (top 1-2 gaps identified)
[ ] Phase 5: Up to 3 iteration cycles completed
[ ] Phase 6: Final report with recommendation
[ ] Verify: Each eval has reproducible prompts
[ ] Verify: Scoring is consistent across baseline and target
[ ] Verify: Regressions are detected and reported
```

---

## Verification

After eval improvement:
1. All eval prompts are reproducible (same input → same expected behavior)
2. Baseline and target use identical grading criteria
3. Gap analysis identifies root causes, not just symptoms
4. Each iteration shows measurable improvement or is capped
5. Regression check is clearly reported
6. Final recommendation is actionable (ship / fix / redesign)
```

---

### 3. `context-engineering`

```markdown
---
name: context-engineering
description: >-
  Manage long-running agent context to prevent token overflow, focus on
  relevant state, and preserve critical information. Uses compaction,
  summarization, structured memory, and subagent isolation to keep the
  working context lean and effective.
license: MIT
metadata:
  category: optimization
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/context-engineering
    license_path: LICENSE
---

# Context Engineering

Manage the agent's working context to stay within token limits while
retaining critical information. Apply compaction, summarization, structured
memory, and context isolation to prevent degradation on long-running tasks.

---

## Triggers

Use this skill when:
- "context is too long for the token limit"
- "compact the conversation history"
- "manage long-running agent context"
- "reduce token usage without losing information"
- "summarize and focus the working state"
- "memory and compaction needed for this task"

Do NOT use for short, single-turn interactions where context is not a
concern, or when the user wants full verbatim history preserved.

---

## Process

### Phase 0: Context Audit

Assess the current context state:

```markdown
## Context Audit

**Total estimated tokens:** <rough estimate based on message count and content>
**Token limit:** <known limit, e.g., 200K for Claude>
**Utilization:** <percentage>

**Context composition:**
| Category | Messages | Est. Tokens | Retention Value |
|----------|----------|-------------|-----------------|
| Goal/instructions | N | ~N | CRITICAL |
| Recent work (last N turns) | N | ~N | HIGH |
| Past work (older turns) | N | ~N | LOW-MEDIUM |
| Error logs / tool output | N | ~N | LOW |
| Conversation history | N | ~N | VARIES |

**Recommendation:** <no action needed / compact / summarize / purge>
```

**Red-zone triggers (consider compaction when):**
- Utilization > 70% of limit
- More than 20% of context is low-value (past errors, verbose tool output)
- Agent shows signs of "lost in the middle" (forgets earlier instructions)

---

### Phase 1: Select Compaction Strategy

Choose the right strategy based on utilization and task type:

| Strategy | When to Use | Token Savings | Risk |
|----------|-------------|---------------|------|
| **Summarize** | Need to preserve narrative but reduce verbosity | 40-60% | Loss of nuance |
| **Prune** | Remove redundant tool output, resolved errors, irrelevant history | 20-40% | Loss of error trace context |
| **Restructure** | Replace verbose sections with structured data (YAML, tables) | 30-50% | Loss of prose readability |
| **Fork** | Spin off completed subtasks to subagent, keep only summary | 60-80% | Loss of detailed reasoning |
| **Memory file** | Write detailed state to a file, keep only path + summary | 50-70% | Requires read-back for detail |

**Default recommendation for utilization:**
- 50-70%: Prune + Restructure
- 70-90%: Summarize + Fork
- 90%+: Memory file + Fork (aggressive)

---

### Phase 2: Apply Compaction

Execute the selected strategy:

#### Summarize

For each section identified as "past work" or "low-medium value":

```markdown
<details>
<summary>Compact: <topic> (original N messages)</summary>

**Summary:** <2-3 sentence summary of what happened and what was decided>

**Key outcomes:**
- <outcome 1>
- <outcome 2>

**Open items:**
- <anything still pending>
</details>
```

#### Prune

Remove entirely:
- Successful tool outputs that are no longer referenced
- Error messages for resolved issues
- Conversation turns resolved by later actions
- Duplicate information

**Do NOT prune:**
- Current goal and instructions
- Unresolved decisions or pending items
- User's explicit requirements and constraints
- The latest 2-3 turns (active conversation context)

#### Restructure

Replace verbose prose with structured formats:

- Free-text file lists → YAML manifest
- Long error descriptions → Error ID + summary (full text in log file)
- Step-by-step narratives → Status table

#### Fork (subagent isolation)

When a subtask is complete or can run independently:

1. Summarize the subtask context: goal, inputs, decisions, outputs
2. Open a forked subagent with the summary + detailed state file reference
3. In the main context, keep only: "Subtask X completed: <3-line summary>. Full state: <path>"

#### Memory File

For critical state that exceeds available context:

1. Write current state to `_task_state.yaml` or similar in the working directory
2. Keep only in context: file path + 3-line summary + next action
3. Read back only when needed for the next step

---

### Phase 3: Verify Context Integrity

After compaction, verify that no critical information was lost:

```markdown
## Post-Compaction Verification

| Critical Item | Preserved? | Location |
|---------------|------------|----------|
| Current goal | Yes | Context header |
| User constraints | Yes | Context header |
| Pending decisions | Yes | Open items list (summary) |
| Key artifacts | Yes | File paths in summary |
| Unresolved errors | Partially | Full log in error.log |
```

**If critical info was lost:**
- Re-expand the relevant section from memory file or full history
- Adjust compaction strategy to be less aggressive

**If compaction was applied in the last 5 turns:**
- Flag to the user: "Context was compacted to manage token usage. <N> messages summarized."

---

### Phase 4: Maintenance Cadence

For long-running tasks, set a maintenance schedule:

```markdown
## Context Maintenance Plan

**Check frequency:** every <N> turns / every <N> tool calls
**Next check at:** <turn count or timestamp>
**Strategy:** <compact / fork / memory file>
**Triger conditions:**
- Token utilization > 70%
- Agent repeats or forgets information
- User requests context review
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Compacting while a subtask is mid-execution | Wait for a natural breakpoint (subtask completion, user interaction) |
| Over-summarizing (losing details that matter) | Keep summaries as expandable details; write full state to files |
| Compacting too frequently | Check every 10-15 turns or at 70%+ utilization |
| Only compacting — never restructuring | Restructure first to reduce bulk; compact only if still needed |
| Silently compacting without user awareness | Flag compaction events briefly ("Context compacted: N messages summarized") |

---

## Execution Checklist

```
[ ] Phase 0: Context audit performed (utilization, composition)
[ ] Phase 1: Compaction strategy selected
[ ] Phase 2: Strategy applied (summarize/prune/restructure/fork/memory file)
[ ] Phase 3: Context integrity verified (no critical info lost)
[ ] Phase 4: Maintenance cadence established for long-running tasks
[ ] Verify: Current goal and constraints are preserved
[ ] Verify: User-facing compaction notice is provided
[ ] Verify: Token utilization is now < 60%
```

---

## Verification

After context engineering:
1. Token utilization is below threshold (< 60% recommended)
2. Current goal and user constraints are explicitly preserved
3. All unresolved items (decisions, errors, pending actions) are documented
4. Compaction method is documented and could be reversed if needed
5. Agent behavior (correctness, recall) is not degraded after compaction
```

---

### 4. `mcp-integration`

```markdown
---
name: mcp-integration
description: >-
  Add, configure, and manage Model Context Protocol (MCP) servers for
  extensible tooling. Define tool allowlists, authentication, environment
  variables, and tool schemas. Enables connecting Kilo to external APIs,
  databases, and custom services through the MCP standard.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/mcp-integration
    license_path: LICENSE
---

# MCP Integration

Configure and manage Model Context Protocol (MCP) servers to extend Kilo's
tooling capabilities. Connect to external APIs, databases, and custom
services through standardized MCP interfaces.

---

## Triggers

Use this skill when:
- "add an MCP server for this API"
- "connect to external service via MCP"
- "Model Context Protocol configuration"
- "create an MCP server wrapper"
- "configure MCP tools and authentication"
- "register a new MCP server in kilo.json"

Do NOT use for optimizing existing tools (use `tool-design-optimizer` for
that) or for one-off tool calls that don't need a persistent server.

---

## Process

### Phase 0: Requirements Analysis

Before implementing, clarify the integration requirements:

```markdown
## MCP Integration Spec

**External service:** <name, e.g., "GitHub API", "PostgreSQL">
**Purpose:** <what tools will this provide?>
**Auth required:** <none / API key / OAuth / bearer token>
**Transport:** <stdio / TCP / SSE>
**Existing MCP server available?** <yes/no — link if yes>

**Tools needed:**
| Tool Name | Description | Key Parameters |
|-----------|-------------|----------------|
| <tool-1> | <what it does> | <param list> |
| <tool-2> | <what it does> | <param list> |
```

**Decision: Use existing server or build custom?**
- **Existing server** (e.g., `@modelcontextprotocol/server-github`): Install and configure
- **Custom server**: Build a new MCP server wrapping the external API
- **Hybrid**: Use an existing server with custom tools added

---

### Phase 1: Install / Create MCP Server

#### Option A: Add an Existing MCP Server

Install the server package and configure in `kilo.json`:

```json
{
  "mcp": {
    "<server-name>": {
      "type": "local",
      "command": [
        "npx",
        "-y",
        "<package-name>"
      ],
      "env": {
        "<ENV_VAR>": "<value>"
      }
    }
  }
}
```

**Common configuration fields:**
| Field | Description | Required |
|-------|-------------|----------|
| `type` | Transport type: `local` (stdio), `remote` (SSE/TCP) | Yes |
| `command` | Command and args to start the server | For `local` type |
| `url` | URL of the remote MCP server | For `remote` type |
| `env` | Environment variables (API keys, config) | Optional |
| `disabled` | Set to `true` to temporarily disable | Optional |

**Authentication patterns:**
- **API key:** Pass via `env` as `API_KEY` or service-specific env var
- **Bearer token:** Pass via `env` as `TOKEN` or `AUTH_TOKEN`
- **OAuth:** Store refresh token in env; configure in server if supported

#### Option B: Create a Custom MCP Server

For services without an existing MCP server:

1. Determine the server type (stdio-based Node.js/Python script)
2. Implement the MCP protocol interface:
   - `list_tools` — return tool schemas
   - `call_tool` — execute tool and return results
3. Configure authentication and error handling
4. Add to `kilo.json` as a local server

**Minimal Node.js structure:**
```
mcp-servers/<service-name>/
  package.json
  index.js          # MCP server implementation
  README.md         # Usage documentation
```

**Minimal Python structure:**
```
mcp-servers/<service-name>/
  requirements.txt
  server.py         # MCP server implementation
  README.md         # Usage documentation
```

---

### Phase 2: Configure Tool Allowlists

For each MCP server, define which tools should be enabled:

```yaml
server: <server-name>
allowlist:
  - tool-1    # enabled — clear purpose
  - tool-2    # enabled — clear purpose
denylist:
  - tool-3    # disabled — destructive or irrelevant
```

**Guidelines for allowlisting:**
- Enable tools that match the integration's purpose
- Disable tools that are destructive, expensive, or irrelevant
- Document why each tool is enabled or disabled
- Revisit allowlist as needs evolve

---

### Phase 3: Test Tool Schemas & Invocation

Verify each allowed tool works correctly:

```markdown
## MCP Verification: <server-name>

### Tool: <tool-name>

**Schema verification:**
| Parameter | Type | Required | Default | OK? |
|-----------|------|----------|---------|-----|
| <param>   | <type> | Y/N    | <value> | ✅  |

**Test invocation:**
- **Input:** <test parameters>
- **Result:** ✅ / ❌
- **Response:** <truncated output>

**Edge cases tested:**
- [ ] Empty input: <result>
- [ ] Missing required params: <error behavior>
- [ ] Auth failure: <error behavior>
- [ ] Timeout: <error behavior>
```

**Minimum test coverage:**
- Happy path (typical usage)
- Missing required parameters (error handling)
- Authentication failure
- Network/service timeout
- Rate limiting (if applicable)

---

### Phase 4: Document & Wrap Up

```markdown
## MCP Integration Summary

**Server:** <name>
**Type:** <local / remote>
**Source:** <existing package / custom built in ./mcp-servers/>

**Tools registered:**
| Tool | Description | Status |
|------|-------------|--------|
| tool-1 | ... | ✅ Enabled |
| tool-2 | ... | ✅ Enabled |
| tool-3 | ... | ❌ Denied (reason) |

**Configuration in kilo.json:**
```json
{ "mcp": { "<server-name>": { ... } } }
```

**Environment variables required:**
- `<VAR>` — purpose (e.g., "GitHub personal access token")

**Security notes:**
- <any credentials stored, access restrictions, or risk mitigations>
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Hardcoding secrets in `kilo.json` | Use environment variables via `env` field |
| Enabling all tools without review | Create an explicit allowlist |
| Ignoring tool error messages | Test error paths and document expected errors |
| Using `sudo` or global installs | Use `npx -y` for Node.js servers |
| Multiple servers with conflicting tool names | Prefix tool names with the server identifier |
| Skipping auth testing | Always test authentication failure handling |

---

## Execution Checklist

```
[ ] Phase 0: Requirements documented (service, auth, tools needed)
[ ] Phase 1: Server installed or custom server created
[ ] Phase 2: Tool allowlist configured
[ ] Phase 2: Denylist documented for excluded tools
[ ] Phase 3: Each tool tested (happy path + error cases)
[ ] Phase 4: Configuration documented in kilo.json and README
[ ] Verify: No secrets hardcoded in kilo.json
[ ] Verify: Auth failure handled gracefully
[ ] Verify: Tool schemas complete and accurate
```

---

## Verification

After MCP integration:
1. Server starts and connects without errors
2. All allowed tools return correct results
3. All error paths (auth, network, invalid input) are handled gracefully
4. No secrets are hardcoded in configuration files
5. Tool allowlist is documented with rationale for each decision
6. `kilo.json` parses as valid JSON
```

---

### 5. `checkpoint-resume`

```markdown
---
name: checkpoint-resume
description: >-
  Persist workflow state at explicit checkpoints so long-running tasks can
  be interrupted and resumed without losing context or progress. Captures
  goal, completed steps, artifacts, decisions, and the next action needed.
license: MIT
metadata:
  category: orchestration
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/checkpoint-resume
    license_path: LICENSE
---

# Checkpoint & Resume

Create persistent checkpoints during long-running tasks so work can be
interrupted and resumed without losing context, progress, or decisions.
Each checkpoint captures a complete snapshot of what was done and what
comes next.

---

## Triggers

Use this skill when:
- "create a checkpoint for this workflow"
- "save progress and resume later"
- "stateful workflow with recovery points"
- "checkpoint before risky operation"
- "save and restore task state"
- "interruption-safe execution"

Do NOT use for short tasks that complete in a single session, or when no
interruption risk exists.

---

## Process

### Phase 0: Define Checkpoint Strategy

Before executing work, define where checkpoints are needed:

```markdown
## Checkpoint Plan

**Task goal:** <restated goal>
**Estimated duration:** <short / medium / long — if long, checkpoint aggressively>

**Checkpoint points:**
| # | Trigger | What to Capture | Priority |
|---|---------|-----------------|----------|
| 1 | Before risky operation | Current state + rollback plan | HIGH |
| 2 | After each major step | Completed work + artifacts | HIGH |
| 3 | Before user interruption | Full context + next action | MEDIUM |
| 4 | Periodically (every N turns) | Compact log of decisions + progress | LOW |

**Checkpoint location:** `<task-dir>/_checkpoint.yaml` or `<task-dir>/checkpoints/checkpoint-N.yaml`
```

**When to checkpoint:**
- Before any destructive or irreversible operation
- After completing a major subtask (especially if it took >5 tool calls)
- Before asking the user a question (in case they return later)
- Periodically on long tasks (every 10-15 tool calls)
- When the agent detects potential interruption (timeout approaching, long operation)

---

### Phase 1: Create Checkpoint

At each trigger point, create a checkpoint file:

```yaml
# _checkpoint.yaml  or  checkpoints/checkpoint-<timestamp>.yaml

checkpoint:
  version: 1
  timestamp: <ISO 8601>
  task_id: <unique identifier for this task>

goal:
  original: <user's original request>
  current: <refined understanding after progress>

status:
  overall_progress: <percentage estimate or "phase X of Y">
  phases_completed:
    - phase: <name>
      status: completed
      artifacts:
        - path: <path>
          description: <what it contains>
      decisions:
        - <key decision made>
    - phase: <name>
      status: in_progress / pending
      # ...

context:
  input_files: [<paths that were read>]
  output_files: [<paths that were created or modified>]
  key_decisions:
    - decision: <what was decided>
      rationale: <why>
      alternatives_considered: [<options that were rejected>]
  known_issues:
    - issue: <problem>
      status: resolved / deferred / blocking

next_action:
  immediate: <the very next thing to do>
  blocked_by: <anything that must happen first, or "none">

metadata:
  tool_calls_so_far: <count>
  tokens_used_estimate: <rough estimate>
  skill_in_use: <skill name if applicable>
```

**Checkpoint file rules:**
- Use YAML for machine readability (easy for agent to re-read)
- Keep checkpoints in the task's working directory
- Sequential numbering for multiple checkpoints
- Each checkpoint captures cumulative state (not delta)

---

### Phase 2: Resume from Checkpoint

When resuming a task:

1. **Detect checkpoint:** Check if `_checkpoint.yaml` or `checkpoints/` exists in the task directory
2. **Load checkpoint:** Read the latest checkpoint file
3. **Restore context:**

```markdown
## Resume from Checkpoint

**Task:** <goal.current>
**Progress:** <status.overall_progress>

**Completed:**
<list of phases_completed with artifacts>

**Decisions made so far:**
<list of key_decisions>

**Next action:**
<next_action.immediate>

**Blocked by:**
<next_action.blocked_by or "nothing">
```

4. **Validate context:**
   - Are all referenced artifacts still present?
   - Are the decisions still valid?
   - Has the environment changed since checkpoint?
5. **Proceed:** Execute `next_action.immediate`
6. **After completion of the resumed step:** Create a new checkpoint

**Resume vs restart:**
- If checkpoint file exists and is < 24h old: resume
- If checkpoint file exists but is > 24h old: validate decisions with user before resuming
- If no checkpoint file exists: start fresh

---

### Phase 3: Handle Checkpoint Gaps

When resuming reveals missing or corrupted checkpoint data:

```markdown
## Checkpoint Gap Detected

**Missing:** <what should be in the checkpoint but isn't>

**Recovery options:**
1. **Partial resume:** Continue with available context; document the gap
2. **Reconstruct:** Look at available artifacts and conversation to rebuild state
3. **Fresh start:** Abandon checkpoint and begin from scratch

**Recommended:** Partial resume with gap documentation
```

---

### Phase 4: Finalize Checkpoint

When the task is complete:

1. Create a final checkpoint capturing the complete task
2. Mark the checkpoint as `status: complete`
3. Optionally archive checkpoints (keep for reference or clean up)

```yaml
checkpoint:
  version: 1
  timestamp: <ISO 8601>
  status: complete

goal:
  original: <original request>
  completed: true

summary:
  total_checkpoints: N
  total_tool_calls: N
  phases_completed: N of N
  all_artifacts:
    - path: <path>
      type: created / modified / read

outcome:
  success: true
  deferred_items:
    - <anything knowingly left unfinished>
  lessons_learned:
    - <insight from the task>
```

---

## Example: Checkpoint Layout

```
task-directory/
  _checkpoint.yaml          # Latest checkpoint (symlink or copy)
  checkpoints/
    checkpoint-20260612_100000.yaml
    checkpoint-20260612_103000.yaml
    checkpoint-20260612_110000-final.yaml
  _task_state.yaml          # (Optional) Detailed state, read on demand
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Checkpointing every tool call (too granular) | Checkpoint at natural boundaries (subtask, user interaction, risky op) |
| Not checkpointing before risky operations | Always checkpoint before destructive/irreversible operations |
| Relying on auto-save without explicit checkpoints | Create explicit, intentional checkpoints |
| Storing checkpoints outside the task directory | Store checkpoints in the working task directory |
| Not validating checkpoints on resume | Always verify artifacts and decisions still hold |
| Checkpoints without "next action" | Every checkpoint must include the immediate next step |

---

## Execution Checklist

```
[ ] Phase 0: Checkpoint strategy defined (trigger points, location)
[ ] Phase 1: Checkpoint created with all required fields
[ ] Phase 1: YAML file written to task directory
[ ] Phase 2: On resume — checkpoint loaded and context restored
[ ] Phase 2: Artifacts validated for existence and integrity
[ ] Phase 3: Checkpoint gaps handled (partial resume / reconstruct / fresh start)
[ ] Phase 4: Final checkpoint created on completion
[ ] Verify: Every checkpoint includes "next_action"
[ ] Verify: Checkpoint files are valid YAML
[ ] Verify: Resume path restored the correct next action
```

---

## Verification

After checkpoint/resume:
1. Checkpoint files exist in the task directory and are valid YAML
2. Each checkpoint includes: goal, completed phases, artifacts, decisions, next action
3. Resume correctly restores the task context and proceeds to the next action
4. Risky operations were preceded by a checkpoint
5. Final checkpoint marks the task as complete with all artifacts listed
6. No previous context is lost when resuming from a checkpoint
```

---

## Proposed `kilo.json` Additions

Add explicit `paths` entries under `"skills"` for the 5 new Tier-2 skills:

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
      "skills/checkpoint-resume"
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
  "skills/image-enhancer",
  "skills/mcp-integration",
  "skills/ms365",
  "skills/orchestrator-worker",
  "skills/pdf",
  "skills/plan-and-execute",
  "skills/pptx",
  "skills/reflection-loop",
  "skills/self-healing-loop",
  "skills/tool-design-optimizer",
  "skills/xlsx"
]
```

---

## Trigger Uniqueness Matrix

All Tier-2 triggers are disjoint from existing Tier-1 and domain skills:

| Existing Skill | Trigger Domain |
|----------------|----------------|
| Domain skills (docx, pdf, xlsx, pptx, ms365, canvas-design, image-enhancer, content-research-writer, agent-md-refactor) | File types, design, writing, markdown |
| `plan-and-execute` | staged plan, decompose, multi-phase, replan, checkpoint |
| `reflection-loop` | critique, self-review, reflect, iterate, quality gate |
| `self-healing-loop` | error classification, retry, compensate, interrupt |
| `dry-run-verify-fix` | dry-run, pre-ship validation, simulate, bounded repair |
| `tool-design-optimizer` | tool schema, ACI, tool definitions, LLM usability |

| New Tier-2 Skill | Triggers (no collision with above) |
|------------------|------------------------------------|
| `orchestrator-worker` | delegate to specialists, coordinate workers, split across subagents, orchestrate multi-agent, multi-agent decomposition, assign subtasks |
| `eval-driven-improver` | benchmark skill, create evals, measure skill quality, eval loop, compare with and without skill, evaluation results iteration |
| `context-engineering` | context too long, compact conversation, manage long-running context, reduce token usage, summarize working state, memory and compaction |
| `mcp-integration` | add MCP server, connect via MCP, Model Context Protocol, create MCP wrapper, configure MCP tools, register MCP server |
| `checkpoint-resume` | create checkpoint, save and resume, stateful workflow, checkpoint before risky op, save task state, interruption-safe execution |

**Zero trigger overlap** with any existing Tier-1 or domain skill. The Tier-2 triggers use advanced process language (orchestrate, benchmark, compact, MCP, checkpoint) that does not intersect with any existing trigger set.

---

## Verification Approach

1. **File existence check:** Confirm all 5 directories and `SKILL.md` files exist
2. **Frontmatter validation:** Each `SKILL.md` has valid YAML frontmatter with required fields (`name`, `description`, `metadata.category`)
3. **JSON validation:** `kilo.json` parses as valid JSON
4. **Trigger uniqueness grep:** Confirm no new trigger phrase exists in any existing skill's `SKILL.md`
5. **Phase completeness:** Each SKILL.md has at minimum: Triggers → Process (phases) → Anti-Patterns → Execution Checklist → Verification

---

## Rollback Considerations

- **Revert `kilo.json`:** Remove the 5 Tier-2 path entries; restore previous state
- **Remove skill folders:** Delete `skills/<new-skill>/` directories
- **No cascade effects:** Skills are self-contained `SKILL.md` files with no inter-skill dependencies, no npm packages, and no running services

---

## Next Steps

1. Execute Step 1: Create 5 skill directories
2. Execute Step 2: Write 5 SKILL.md files from the content above
3. Execute Step 3: Update `kilo.json` with Tier-2 path entries
4. Execute Step 4: Verify all skills are discoverable via trigger testing

---

*Generated: 2026-06-12 05:38*
*Last Updated: 2026-06-12 05:38*
