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
- **Frontend-Backend (API Contract First):** When the work spans both frontend and backend, define the API contract (endpoints, request/response types, error schemas) as a shared prerequisite BEFORE splitting into frontend and backend subtasks. This prevents integration failures caused by mismatched assumptions.

**Rules:**
- Each subtask must be independently verifiable
- Dependencies must form a DAG (no circular deps)
- Keep subtasks granular enough that a single worker can complete them
- Max 7 subtasks per orchestration (beyond that, nest or batch)
- **API Contract First (mandatory for frontend+backend tasks):** When decomposition involves both frontend and backend workers, an explicit API contract definition step MUST precede both. The contract is a single source of truth that both sides depend on. Without it, frontend and backend will drift and integration will fail.
- **No overlapping tasks for the same agent:** When two subtasks are assigned to the **same agent**, their scopes MUST be mutually exclusive — no overlapping files, modules, concerns, or responsibilities. If overlap is detected (e.g., both subtask A and B modify the same file or service), either:
  - Merge them into a single subtask, OR
  - Split the overlapping concern into its own subtask, OR
  - Reroute one subtask to a different agent type

---

### Phase 0a: API Contract & Cross-Layer Dependency Management

When the task involves both frontend and backend work, the orchestrator MUST manage the API contract as a first-class concern before any implementation begins.

**Why this matters:**
- Frontend assumes a specific API shape (endpoints, method, request body, response fields, status codes, error format)
- Backend implements those API shapes
- If they are built independently without a shared contract, integration produces mismatches, rework, and delays

**API Contract First workflow:**

```yaml
orchestration_plan:
  api_contract:
    status: required / skip (if no frontend-backend split)
    definition_method: openapi / graphql-schema / types-interface / markdown-spec
    artifacts:
      - path: docs/api/contract.yaml
        format: OpenAPI 3.x
      - path: packages/shared/src/types/api.ts
        format: TypeScript types (shared package)
    shared_types:
      - request_dtos
      - response_dtos
      - error_schemas
      - enums_and_constants
    prerequisite_for:
      - frontend-implementation
      - backend-implementation
  subtasks:
    - id: 0
      name: Define API Contract
      description: "Design and document the API contract that both frontend and backend will implement against"
      specialist: data-analyst (architecture) or senior engineer
      dependencies: none
      acceptance_criteria:
        - All endpoints, methods, and paths are defined
        - Request and response schemas are fully typed
        - Error responses are documented
        - Authentication/authorization model is specified
        - Contract is reviewed and approved by both frontend and backend stakeholders
    - id: 1
      name: Backend Implementation
      description: "Implement backend APIs conforming to the contract"
      specialist: coder-execution (backend)
      dependencies: [0]
      acceptance_criteria:
        - All contract endpoints are implemented and pass contract tests
    - id: 2
      name: Frontend Implementation
      description: "Implement frontend consuming the contract"
      specialist: coder-execution (frontend)
      dependencies: [0]
      acceptance_criteria:
        - All contract endpoints are consumed correctly
        - UI renders data from every contract response type
```

**Contract validation at each phase boundary:**
| Phase | Check |
|-------|-------|
| After contract definition | Contract is reviewed for completeness (no missing endpoints, types, error codes) |
| Before frontend starts | Backend stub/mock is available OR contract is locked (no further changes) |
| Before backend starts | Backend understands all frontend-consumed fields |
| After backend completes | Contract conformance tests pass (backend returns what contract promises) |
| After frontend completes | Integration test confirms frontend renders backend responses correctly |
| Before synthesis | No drift between contract, backend implementation, and frontend implementation |

For each subtask, determine the best execution strategy:

| Subtask Type | Strategy | Example |
|-------------|----------|---------|
| **Skill-mapped** | Invoke via skill context | "Use `plan-and-execute` to design the architecture" |
| **Tool-specific** | Use existing tools | "Use puppeteer to capture screenshots of all pages" |
| **Research** | Web search + analysis | "Search for latest API docs and summarize" |
| **Coding** | File read/write + verify | "Implement the module and run tests" |

---

### Phase 0b: Context Awareness & Task Splitting (MANDATORY for Heavy Tasks)

**This phase prevents hallucination and context compaction when tasks exceed ~150k estimated tokens.**

**0b.1 Estimate Context Usage:**

Before executing any subtask, estimate its context footprint:

```yaml
context_estimation:
  subtask_id: 1
  estimated_tokens: 180000  # rough estimate based on:
                             # - input files size
                             # - expected output size
                             # - complexity
  
  # Token thresholds
  THRESHOLD_WARNING: 100000   # Start monitoring
  THRESHOLD_SPLIT: 150000    # MUST split if exceeded
  THRESHOLD_CRITICAL: 200000 # Split immediately
```

**How to estimate:**
| Factor | Estimation Method |
|--------|-----------------|
| Input files | Count lines × avg 4 chars/line × 1.3 (token overhead) |
| Code complexity | Loop through large files = multiply estimate |
| Expected output | Based on typical output size for similar tasks |
| History context | If running in existing session, add 20-50k baseline |

**0b.2 Determine Split Strategy:**

```yaml
if estimated_tokens <= 150000:
  strategy: "proceed_normal"  # Single agent execution
elif estimated_tokens <= 300000:
  strategy: "split_by_file"   # Split by files/modules
else:
  strategy: "split_by_phase"  # Split by execution phase
```

**Split strategies:**

| Strategy | When to Use | How |
|----------|-------------|-----|
| `split_by_file` | Multiple independent files | Assign each file to a separate subtask |
| `split_by_feature` | Large feature with sub-features | Break into per-feature subtasks |
| `split_by_phase` | Sequential workflow | Break into phase-1, phase-2, etc. |
| `checkpoint_split` | Long-running with state | Use checkpoint-resume pattern |

**0b.3 Execute Split:**

```yaml
split_plan:
  original_task: "Implement full user authentication system"
  estimated_tokens: 350000
  split_strategy: "by_concern"
  
  subtasks:
    - id: 1a
      name: "Auth - JWT & Token Logic"
      scope: ["src/auth/jwt.ts", "src/auth/token.service.ts"]
      estimated_tokens: 85000
      dependencies: []
      
    - id: 1b
      name: "Auth - Password Hashing"
      scope: ["src/auth/password.service.ts", "src/auth/argon2.ts"]
      estimated_tokens: 45000
      dependencies: []
      
    - id: 1c
      name: "Auth - Login Endpoint"
      scope: ["src/auth/login.controller.ts", "src/auth/login.service.ts"]
      estimated_tokens: 65000
      dependencies: [1a, 1b]
      
    - id: 1d
      name: "Auth - Register Endpoint"
      scope: ["src/auth/register.controller.ts", "src/auth/register.service.ts"]
      estimated_tokens: 70000
      dependencies: [1a, 1b]
      
    - id: 1e
      name: "Auth - Integration & Tests"
      scope: ["src/auth/__tests__/", "src/auth/integration.test.ts"]
      estimated_tokens: 80000
      dependencies: [1c, 1d]
```

**0b.4 Continuity & Integrity Protocol:**

When tasks are split, maintain continuity with checkpoints:

```yaml
continuity_protocol:
  checkpoint_frequency: "after_each_subtask"
  
  artifacts:
    - path: "/docs/YYYY_MM_DD_task/checkpoints/subtask_1a_summary.md"
      content:
        - completed_work: "Summary of what 1a did"
        - decisions_made: "Key decisions during execution"
        - state_for_next: "What 1b needs to know"
        
    - path: "/docs/YYYY_MM_DD_task/checkpoints/subtask_1b_summary.md"
      content:
        - completed_work: "Summary of what 1b did"
        - decisions_made: "Key decisions during execution"
        - state_for_next: "What 1c needs to know"
  
  integrity_checks:
    - type: "file_count"
      expected: 5
      verified: true
      
    - type: "import_chain"
      verified: "All imports resolve correctly"
      
    - type: "api_contract"
      verified: "1c and 1d use consistent interfaces"
```

**0b.5 Verify Integrity Between Splits:**

Before continuing to next split, verify continuity:

```markdown
### Integrity Check: Subtask 1a → 1b

**1a Output Summary:**
- Created `src/auth/jwt.ts` with `generateToken()` and `verifyToken()`
- Created `src/auth/token.service.ts` with `TokenService` class

**1b Expected Context:**
- Uses `jwt.ts` for token generation
- Password hashing uses bcrypt (NOT argon2 per decision)

**Integrity Verification:**
| Check | Result |
|-------|--------|
| File `jwt.ts` exists | ✅ |
| Export `generateToken()` exists | ✅ |
| Import in `password.service.ts` correct | ✅ |
| No circular dependencies | ✅ |

**Continuity Note for 1c:**
1b decided to use bcrypt (not argon2) due to [reason]. Token service interface:
```typescript
interface TokenService {
  generateToken(payload: object): string;
  verifyToken(token: string): object;
}
```
```

**0b.6 Checkpoint Template:**

```markdown
---
checkpoint_id: SUBTASK_1A
timestamp: YYYY-MM-DD HH:mm
next_subtask: 1B
status: COMPLETE
---

## Completed Work

- [List of files created/modified]
- [Key functions implemented]

## Decisions Made

- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

## State for Next Task (1B)

### What 1B needs to know
1. [Context item 1]
2. [Context item 2]

### Interfaces/Contracts established
```typescript
// src/auth/jwt.ts
export function generateToken(payload: object): string;
export function verifyToken(token: string): object;
```

### Files to NOT modify
- `src/auth/other-file.ts` — owned by another subtask

---
```

---

### Phase 0c: Worker Assignments & Overlap Check

Record the assignment:

```markdown
### Worker Assignments

| Subtask | Worker | Context | Expected Output |
|---------|--------|---------|----------------|
| 1 | <skill/toolset> | <files or domains> | <artifact> |
| 2 | <skill/toolset> | <files or domains> | <artifact> |
```

**Overlap check (mandatory before execution):** After all assignments are recorded, scan for same-agent overlap:

| Check | Pass Criteria |
|-------|---------------|
| Same agent assigned to multiple subtasks? | If yes, verify their scopes (Context column) are mutually exclusive — no overlapping files, modules, or concerns |
| Overlap detected? | Merge the subtasks, split the overlap into a separate subtask, or reassign one to a different agent |
| All overlaps resolved? | Proceed to execution |

---

### Phase 2: Execute Workers

Run subtasks respecting dependency order:

1. Identify all subtasks with satisfied dependencies (ready set)
2. **For split tasks: Read previous checkpoint before starting**
3. Execute ready subtasks (sequentially or logically in parallel)
4. Collect outputs and log completion
5. **Write checkpoint artifact (for split tasks or tasks with dependents)**
6. Update dependency graph — mark completed subtasks as done
7. Repeat until all subtasks complete or a blocker is hit

```markdown
**Worker: <subtask name>** [IN PROGRESS / COMPLETE / FAILED]
**Assigned to:** <worker description>
**Context from checkpoint:** <if split task - read state_for_next>
**Result:**
<artifact or summary>

**Issues:**
- <any problems encountered>
```

**Checkpoint Writing (MANDATORY for split tasks):**
After completing a subtask that will have dependents:
```markdown
---
checkpoint_id: SUBTASK_<ID>
timestamp: YYYY-MM-DD HH:mm
next_subtask: <dependent_id>
status: COMPLETE
---

## Completed Work
- [Files created/modified]
- [Key implementations]

## Decisions Made
- [Decision 1]: [Rationale]

## State for Next Task (<next_id>)
- [What the next task needs to know]
- [Interface contracts established]
- [Files to NOT modify]
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

## Examples

### Example 1: Security Audit
**User:** "Audit our API for security vulnerabilities and generate a report."

**Decomposition:**
1. Inventory all API endpoints (research + file reading)
2. Check authentication/authorization (security analysis)
3. Validate input sanitization (code review)
4. Test rate limiting (tool-based)
5. Generate report (writing)

**Conflict example:** Worker 2 finds "no auth on /health" while Worker 3 finds "/health returns OK without input". Resolution: "/health is intentionally public — documented as known, not a bug."

### Example 2: Frontend + Backend Feature (API Contract First)
**User:** "Add a user profile page with settings management."

**Decomposition (with API Contract First):**

```yaml
orchestration_plan:
  goal: Build user profile page with settings management
  decomposition_strategy: frontend-backend (API Contract First)
  api_contract:
    status: required
    definition_method: openapi
    prerequisite_for: [frontend, backend]
  subtasks:
    - id: 0
      name: Define API Contract
      description: "Define /api/profile (GET, PUT), /api/profile/settings (GET, PATCH), /api/profile/avatar (POST, DELETE) with full schemas"
      specialist: data-analyst
      dependencies: none
      acceptance_criteria:
        - All endpoints documented with request/response types
        - Error schemas defined for 400, 401, 403, 404, 500
        - Auth model specified (JWT Bearer token)
    - id: 1
      name: Backend — Implement Profile API
      description: "Implement profile CRUD + settings + avatar endpoints conforming to contract"
      specialist: coder-execution (backend)
      dependencies: [0]
    - id: 2
      name: Frontend — Profile Page UI
      description: "Build React profile page consuming the contract via generated API client"
      specialist: coder-execution (frontend)
      dependencies: [0]
    - id: 3
      name: Integration Test
      description: "Verify frontend renders all profile data from backend, test error states"
      specialist: test-expert
      dependencies: [1, 2]
```

**Conflict scenario:** Worker 1 (backend) returns `avatar_url` as a string, but Worker 2 (frontend) expects a `{ url, updated_at }` object. Resolution: Contract is updated to use `{ url, updated_at }` since frontend needs both fields. Backend re-delegated to fix. Contract is the source of truth for resolution.

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Creating too many subtasks (fragmentation) | Keep 3-7 subtasks; merge fine-grained work |
| Overlapping subtask scopes when using the same agent | Verify scopes are mutually exclusive before execution; merge, split, or reroute if overlap found |
| Ignoring dependency order | Always respect the DAG; never start dependent work early |
| Workers modifying shared state silently | Workers should report results; orchestrator manages shared state |
| No conflict resolution step | Always include explicit conflict reconciliation |
| **Frontend and backend built independently without shared contract** | **Define API contract first as a shared prerequisite (Phase 0a); both sides depend on it** |
| **Frontend assumes API shape that backend never agreed to** | **Lock the contract before implementation begins; enforce conformance tests at integration** |
| **Backend changes response fields without updating the contract** | **The contract is the single source of truth; any change must update the contract first, then both workers** |
| **Skipping contract validation at phase boundaries** | **Validate contract conformance at every phase: after contract def, after backend impl, after frontend impl** |
| **Ignoring context size — letting subtasks grow unbounded** | **Estimate tokens before execution; split at 150k threshold to prevent hallucination and context compaction** |
| **No checkpoint between split tasks — losing state** | **Write checkpoint after each subtask; next task reads checkpoint before starting** |
| **Assuming split tasks are independent without verifying continuity** | **Run integrity check: verify imports resolve, interfaces match, state transfers are consistent** |
| **Not documenting decisions in split tasks** | **Each checkpoint includes `decisions_made` and `state_for_next` so context isn't lost** |

---

## Execution Checklist

```
[ ] Phase 0: Task decomposed into 3-7 subtasks with DAG dependencies
[ ] Phase 0: Decomposition strategy chosen (domain / phase / concern / frontend-backend)
[ ] Phase 0a: If frontend+backend split exists → API Contract First step defined as subtask 0
[ ] Phase 0a: API contract validation gates specified at each phase boundary
[ ] Phase 0b: CONTEXT ESTIMATION — Estimated tokens for each subtask
[ ] Phase 0b: If any subtask exceeds 150k tokens → SPLIT REQUIRED
[ ] Phase 0b: Split plan created with checkpoint continuity protocol
[ ] Phase 0b: Each split has checkpoint file with state_for_next
[ ] Phase 0c: Each subtask assigned to appropriate worker
[ ] Phase 0c: Same-agent overlap check performed
[ ] Phase 2: Workers executed in dependency order
[ ] Phase 2: Failures handled (retry/skip/abort)
[ ] Phase 2: After each subtask → write checkpoint artifact
[ ] Phase 2: Before next subtask → verify integrity from checkpoint
[ ] Phase 3: Conflicts identified and resolved
[ ] Phase 4: Results synthesized into final deliverable
[ ] Verify: All subtask outputs are included
[ ] Verify: Conflicts are documented and resolved
[ ] Verify: Gaps are reported transparently
[ ] Verify: If frontend+backend, contract conformance is confirmed
[ ] Verify: CONTEXT INTEGRITY — All checkpoints present and consistent
[ ] Verify: No subtask exceeded token threshold (or was properly split)
```

---

## Verification

After orchestration:
1. All subtasks completed (or explicitly skipped with rationale)
2. Dependencies were respected across execution order
3. Conflicts were identified and resolved
4. Final deliverable synthesizes all worker outputs
5. Decision log documents recovery and resolution choices
6. **For frontend+backend tasks:** the API contract is enforced
7. **Context integrity verified:**
   - All checkpoint files present for split tasks
   - State transfers are consistent (no lost context)
   - No subtask exceeded 150k tokens without splitting
8. **Continuity verified:**
   - Each split subtask has `state_for_next` in checkpoint
   - Next subtask reads previous checkpoint before starting
   - Integrity checks pass between splits
