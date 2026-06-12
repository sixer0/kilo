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
