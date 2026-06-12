---
task_id: map-skills-to-agents-001
task_slug: map-skills-to-agents
date: 2026-06-12
agent: data-analyst
type: analysis
confidence: HIGH
source_agents:
  - agent/task-architect.md
  - agent/master-controller.md
  - agent/verifier.md
  - agent/coder-execution.md
  - agent/security-review.md
source_skills:
  - skills/plan-and-execute/SKILL.md
  - skills/reflection-loop/SKILL.md
  - skills/self-healing-loop/SKILL.md
  - skills/dry-run-verify-fix/SKILL.md
  - skills/human-in-loop-gate/SKILL.md
  - skills/checkpoint-resume/SKILL.md
  - skills/context-engineering/SKILL.md
  - skills/security-review-gate/SKILL.md
  - skills/orchestrator-worker/SKILL.md
  - skills/eval-driven-improver/SKILL.md
  - skills/observability-tracer/SKILL.md
  - skills/tool-design-optimizer/SKILL.md
  - skills/skill-creator-kilo/SKILL.md
last_updated: 2026-06-12 06:20
---

# Skill-to-Agent Mapping & Refactor Plan

## 1. Skill Catalog (14 Skills)

| Skill | Category | Primary Purpose | Key Capability |
|-------|----------|----------------|----------------|
| `plan-and-execute` | Orchestration | Decompose complex tasks into staged, dependency-aware execution plans with explicit checkpoints and replan cycles | Phase decomposition, checkpoint gating, replan on failure |
| `checkpoint-resume` | Orchestration | Persist workflow state at explicit checkpoints for interruption-safe execution and resume | YAML checkpoint files, state capture, resume validation |
| `self-healing-loop` | Orchestration | Classify execution failures (TRANSIENT/LOGIC/PERMISSION/RESOURCE/UNEXPECTED) and route to recovery strategy | Error classification, retry with backoff, escalation paths |
| `orchestrator-worker` | Orchestration | Decompose into independent subtasks, delegate to specialists, synthesize results | Multi-agent decomposition, DAG dependency, conflict resolution |
| `context-engineering` | Optimization | Manage token context to prevent overflow via compaction, summarization, and memory files | Context audit, compaction strategies, fork/memory offloading |
| `tool-design-optimizer` | Optimization | Improve tool schemas, descriptions, examples for better ACI | ACI audit, name/description optimization |
| `reflection-loop` | Development | Self-critique and iterative refinement with evidence-based review | Success criteria, evidence-based critique, bounded iteration |
| `dry-run-verify-fix` | Development | Validate changes via simulation before final delivery | Delivery path simulation, diagnose/fix loop, bounded repair |
| `eval-driven-improver` | Development | Create evaluation prompts and assertions to benchmark skill quality | Baseline/target comparison, gap analysis, iterative improvement |
| `skill-creator-kilo` | Development | Create and improve Kilo skills following template standards | Frontmatter, triggers, phases, anti-patterns, verification |
| `human-in-loop-gate` | Safety | Pause execution at decision boundaries requiring human judgment | Gate classification, structured presentation, decision handling |
| `security-review-gate` | Safety | Structured security review before destructive or external actions | Credential leak check, injection check, destructive op check |
| `observability-tracer` | Observability | Record tool calls, state transitions, decisions, failures for debugging | Trace logs, statistics, anomaly detection |
| `mcp-integration` | Domain | Integrate MCP tools | (peripheral — not deeply analyzed here) |

## 2. Agent-to-Skill Mapping

### 2.1 master-controller (Primary Orchestrator)
**File:** `agent/master-controller.md` (426 lines — largest agent file)

| Agent Section | Lines | Current Function | Mapped Skill(s) | Overlap Severity |
|--------------|-------|-----------------|-----------------|-------------------|
| **Full Workflow** (step 1-15) | 207-259 | Multi-phase sequential orchestration with handoffs: receive → translate → architect → explore → collect → analyze → plan → present → execute | `orchestrator-worker`, `plan-and-execute` | **HIGH** — entire orchestration pipeline duplicates both skills |
| **User Approval Flow** | 260-308 | "Present to user → Wait for approval" with feedback handling table | `human-in-loop-gate` | **HIGH** — identical gate classification and resolution logic |
| **Context Management** (160K tokens) | 82-88 | Stop workflow, document progress, request compaction, resume | `context-engineering`, `checkpoint-resume` | **HIGH** — all four compaction strategies + checkpoint logic duplicated |
| **Error Handling** table | 310-319 | Condition → Action for CLARIFICATION_NEEDED, DATA_INCOMPLETE, RATE_LIMITED, BLOCKED | `self-healing-loop` | **HIGH** — error classification + recovery strategy already defined |
| **Verification/Security/Test Failure Protocol** | 322-368 | Severity assessment (🔴🟡🟢), halt/present/fix/re-verify cycle | `human-in-loop-gate`, `security-review-gate` | **HIGH** — severity-based gating matches gate classification |
| **Quality Gate** (Delegation-Ready) | 379-389 | Evaluate analysis/plan against criteria before delegation | `reflection-loop` | **MEDIUM** — evaluation against explicit criteria |
| **Enforcement Checklist** | 92-101 | Mandatory pre-response checklist | — | Low — agent-specific governance, not skill-replaceable |
| **Penalty System** | 15-57 | ZERO TOLERANCE / PENALTY LEVEL 1-3 | — | Low — agent governance, not skill-replaceable |

### 2.2 task-architect (Planning Subagent)
**File:** `agent/task-architect.md` (307 lines)

| Agent Section | Lines | Current Function | Mapped Skill(s) | Overlap Severity |
|--------------|-------|-----------------|-----------------|-------------------|
| **Agent Catalog** (table) | 29-63 | Domain → Agent mapping table | — | Low — reference data, not workflow |
| **STEP 1: Read source** | 88-107 | Read original_tasks.md + translated_tasks.md | — | Low — task-specific I/O |
| **STEP 2: Challenge & Refine** | 110-125 | Challenge intent, goals, scope, constraints, assumptions | — | Low — unique to task-architect's domain; not covered by any skill |
| **STEP 3: Design Structured Tasks** | 128-151 | Decompose into atomic delegation steps with agent mapping | `orchestrator-worker` (Phase 0) | **MEDIUM** — task decomposition mirrors orchestrator-worker's decomposition phase |
| **STEP 4: Integrate Verification & Security** | 153-161 | Specify testing/security/quality triggers per step | `security-review-gate`, `reflection-loop` | MEDIUM — could reference skills instead of re-describing approach |
| **STEP 6: Return to controller** | 248-278 | Structured response protocol | `plan-and-execute` (Phase 4 delivery) | LOW — mostly formatting convention |
| **Design Protocol** (point 8) | 142-151 | "Mandatory to create trackable checkpoint progress" | `checkpoint-resume` | **MEDIUM** — checkpoint requirement, but only as design instruction |

### 2.3 verifier (Verification Subagent)
**File:** `agent/verifier.md` (138 lines)

| Agent Section | Lines | Current Function | Mapped Skill(s) | Overlap Severity |
|--------------|-------|-----------------|-----------------|-------------------|
| **STEP 3: Verify** | 52-63 | Check syntax, logic, integration, regression; optional Puppeteer | `dry-run-verify-fix`, `reflection-loop` | **MEDIUM** — verification scope matches dry-run validation path |
| **STEP 4: Update tracking** | 65-68 | Update Status/Notes/Issues in implementation_plan.md | `checkpoint-resume` (Phase 1) | LOW — shared checkpoint/state update pattern |
| **STEP 5: Report format** | 70-126 | Implementation report with severity-coded issues | `observability-tracer` (trace log) | LOW — report format standardization |

### 2.4 coder-execution (Implementation Subagent)
**File:** `agent/coder-execution.md` (125 lines)

| Agent Section | Lines | Current Function | Mapped Skill(s) | Overlap Severity |
|--------------|-------|-----------------|-----------------|-------------------|
| **STEP 3: Implement** | 49-53 | Incremental changes, preserve existing, follow standards | — | Low — core implementation, not skill-replaceable |
| **STEP 4: Run tests and build** | 55-58 | Run unit tests, build/lint/typecheck | `dry-run-verify-fix` | **HIGH** — this is exactly the dry-run validation path |
| **STEP 6: Report format** | 66-113 | Implementation report with Changes, Test Results, Issues | `dry-run-verify-fix` (Phase 5), `observability-tracer` | MEDIUM — report template matches validation summary |
| **STEP 1-7 overall workflow** | 41-125 | Read → Set status → Implement → Test → Update → Report → Return | `plan-and-execute` | MEDIUM — single-phase execution, but the structure mirrors skill |

### 2.5 security-review (Security Subagent)
**File:** `agent/security-review.md` (136 lines)

| Agent Section | Lines | Current Function | Mapped Skill(s) | Overlap Severity |
|--------------|-------|-----------------|-----------------|-------------------|
| **STEP 3-4: Scan & Detect** | 52-66 | Vulnerability categories: injection, XSS, auth, secrets, input, crypto, config | `security-review-gate` | **HIGH** — hardcoded check categories that the skill already defines more comprehensively |
| **STEP 6: Report format** | 72-124 | Issues found table with Severity/Type/Location/Remediation | `security-review-gate` (Phase 2-3) | **HIGH** — report structure is a subset of security-review-gate's output template |

### 2.6 Additional Agent Observations

| Agent (not in primary scope) | Expected Overlap | Notes |
|------------------------------|-----------------|-------|
| `pm-planner` (exists at agent/pm-planner.md) | Likely HIGH with `plan-and-execute` | Should be checked in follow-up |
| `data-analyst` / `data-analyst-free` | MEDIUM with `reflection-loop` | Analysis → self-critique pattern |
| `test-expert` | HIGH with `dry-run-verify-fix`, `reflection-loop` | Test generation is a specific form of validation |

## 3. Redundant Prompts Identified

### 3.1 Master Controller: Full Workflow Pipeline (LINES 207-259)
**File:** `agent/master-controller.md`

```
1. RECEIVE USER REQUEST
2. TENTUKAN JUDUL TASK
3. CEK FOLDER /docs
4. Screening riwayat task
5. REQUEST TRANSLATOR
6. task-architect → structured tasks + plan
7. relay memory records
8. explore → output
9. data-collector → output
10. data-analyst → analysis.md
11. pm-planner → plan.md
12. PRESENT TO USER
13. RE-READ FILES
14. Execute plan
15. Summarize results
```

**Why Redundant:** This entire pipeline is a concrete instantiation of what `orchestrator-worker` + `plan-and-execute` provide abstractly. The controller is hardcoding a **specific orchestration script** rather than delegating orchestration strategy to the skill. The task decomposition (step 6), dependency ordering (steps 7→11), sequential execution (step 14), and delivery (step 15) are all covered.

**Replace With:** 
- Use `orchestrator-worker` for the top-level decomposition → subtask assignment → execution → synthesis cycle
- Use `plan-and-execute` for the phased execution with checkpoint gates between phases (translate → explore → analyze → approve → execute)

### 3.2 Master Controller: User Approval Flow (LINES 260-308)
**File:** `agent/master-controller.md`

```
Task Summary presentation → Wait for approval → 
Feedback handling table (approved/missing/wrong/edits/cancel)
```

**Why Redundant:** The `human-in-loop-gate` skill provides all of this: gate classification, structured presentation (operation, context, risk, options, recommendation), decision handling table, and gate logging. The controller's approval flow is a subset with less structure.

**Replace With:** Replace the entire "User Approval Flow" section with a reference to invoke `human-in-loop-gate` at decision boundaries. The gate presentation format in the skill is more robust (includes risk assessment, reversibility, cost, and recommendation).

### 3.3 Master Controller: Context Management (LINES 82-88)
**File:** `agent/master-controller.md`

```
If context > 160K tokens: STOP → Document → Request compact → Resume
```

**Why Redundant:** The `context-engineering` skill covers context audit (token estimation, composition analysis), strategy selection (summarize/prune/restructure/fork/memory file), compaction application, and integrity verification. The controller's approach is a simplified version with no strategy selection, no audit, and no post-compaction verification.

**Replace With:** Reference `context-engineering` with a trigger threshold of 160K. The skill provides better compaction results (multiple strategies, post-compaction verification).

### 3.4 Master Controller: Error Handling Table (LINES 310-319)
**File:** `agent/master-controller.md`

```
| CLARIFICATION_NEEDED | Present questions, wait, re-delegate |
| DATA_INCOMPLETE | Re-delegate to collector/explorer |
| ANALYSIS_INCOMPLETE | Re-delegate to analyst |
| Sub-agent BLOCKED | Retry once, then escalate |
| RATE_LIMITED | Switch to *-free fallback |
```

**Why Redundant:** The `self-healing-loop` skill provides a comprehensive 5-class error taxonomy (TRANSIENT/LOGIC/PERMISSION/RESOURCE/UNEXPECTED) with specific recovery strategies (retry with backoff, diagnose and fix, interrupt, stop). The controller's table covers only 5 mixed cases without classification logic. Additionally, `RATE_LIMITED` is a TRANSIENT error with explicit retry guidance in the skill.

**Replace With:** Replace the error table with a reference to `self-healing-loop`. Define the specific mapping of controller errors to skill classes (e.g., RATE_LIMITED → TRANSIENT, DATA_INCOMPLETE → LOGIC).

### 3.5 Master Controller: Verification/Security Failure Protocol (LINES 322-368)
**File:** `agent/master-controller.md`

```
Severity Assessment (🔴🟡🟢) → HALT on Critical → Present → Fix → Re-verify
```

**Why Redundant:** This is a domain-specific instantiation of `human-in-loop-gate` (for the approval step) combined with `security-review-gate` (for the security-specific findings). The severity-based gating logic is already built into `security-review-gate`'s decision rules (PASS/CAUTION/FAIL) and `human-in-loop-gate`'s HIGH-IMPACT classification.

**Replace With:** Delegate security-specific findings to `security-review-gate` which already produces PASS/CAUTION/FAIL with remediation. Use `human-in-loop-gate` for the user decision points (fix now / proceed anyway / modify scope).

### 3.6 Master Controller: Quality Gate (LINES 379-389)
**File:** `agent/master-controller.md`

```
Evaluate analysis.md and plan.md against: Intent Alignment, Documentation Standard, Actionability
```

**Why Redundant:** This is a lightweight application of `reflection-loop` — defining success criteria, evaluating against them, and looping on failure.

**Replace With:** Use `reflection-loop` for the quality check, providing the 3 criteria as success criteria for the evaluation phase.

### 3.7 task-architect: Design Protocol Checkpoint Requirement
**File:** `agent/task-architect.md` line 150

```
"it is mandatory to create trackable checkpoint progress"
```

**Why Redundant:** The `checkpoint-resume` skill already defines when/how to checkpoint. The mention here is only an instruction to the architect, not a workflow replacement. However, the architect's design should reference the skill rather than declaring it as a custom rule.

### 3.8 security-review: Vulnerability Detection Checklist (LINES 57-66)
**File:** `agent/security-review.md`

```
Check for: Injection, XSS, Auth, Secrets, Input, Crypto, Config
```

**Why Redundant:** The `security-review-gate` skill provides all these checks in Phase 1 with more depth — Credential Leak Check (with specific patterns like `sk-...`, `password=...`, `mongodb://...`), Destructive Operation Check (with rollback assessment), External Call Check (TLS, auth, rate limiting), Injection Check (shell, SQL, eval), Permission Escalation Check. The agent's version is a subset with less granularity.

**Replace With:** The entire STEP 3-4 (Scan → Detect) should be replaced with a reference to invoke `security-review-gate`. The skill produces structured output with PASS/FAIL/CAUTION assessment per check, which can be directly written to implementation_report.md.

### 3.9 coder-execution: Test/Build Step (LINES 55-58)
**File:** `agent/coder-execution.md`

```
Run unit tests → Run build/lint/typecheck → Record results
```

**Why Redundant:** The `dry-run-verify-fix` skill encapsulates this exact pattern as its validation path: define delivery path → dry-run → diagnose failures → fix → re-run → deliver.

**Replace With:** After implementation (STEP 3), invoke `dry-run-verify-fix` with the delivery path being: "run tests, build, lint, typecheck". The skill provides bounded iteration with proper escalation.

### 3.10 verifier: Verification Scope (LINES 54-63)
**File:** `agent/verifier.md`

```
Scope: Syntax, Logic, Integration, Regression
```

**Why Redundant:** While the verifier's domain is narrow enough that a full skill replacement is overkill, the `dry-run-verify-fix` skill provides better diagnostic depth (Phase 3: Diagnose with reproduction, root cause, scope, severity) and the `reflection-loop` skill provides evidence-based critique. A hybrid approach would improve verification quality.

## 4. Refactor Recommendations

### 4.1 Master Controller — High Priority

#### R1: Delegate orchestration to `orchestrator-worker`
**Action:** Replace the hardcoded 15-step workflow (lines 207-259) with structured task decomposition via `orchestrator-worker`.

**Current:**
```
master-controller hardcodes: translate → architect → explore → collect → analyze → plan → present → execute
```

**Proposed:**
```
master-controller invokes orchestrator-worker with subtasks:
  1. request-translator (parse intent)
  2. task-architect (structure tasks)
  3. explore + data-collector + data-analyst (discovery)
  4. pm-planner (detailed plan, if complex)
  5. Present to user (human-in-loop-gate)
  6. Execute via coder-execution + verifier + security-review
```

**Changes:**
- Remove the step-by-step narrative from lines 207-259
- Keep only: (1) receive request, (2) decompose via orchestrator-worker, (3) gate for approval, (4) execute
- This reduces master-controller from ~426 lines to ~200 lines

#### R2: Replace User Approval Flow with `human-in-loop-gate` reference
**Action:** Replace lines 260-308 with a brief mention that approval gates should use `human-in-loop-gate` with SAFETY or HIGH-IMPACT classification.

**Benefit:** Removes ~48 lines of hardcoded gate logic. The skill provides structured presentation (operation, context, risk, options, recommendation) that is more comprehensive.

#### R3: Replace Error Handling with `self-healing-loop` reference
**Action:** Replace the 10-line error table (lines 310-319) with a mapping table to self-healing-loop error classes.

**Benefit:** Removes error handling logic that has better taxonomy and recovery strategies in the skill.

#### R4: Replace Context Management with `context-engineering` reference
**Action:** Replace lines 82-88 with: "If token utilization exceeds 70%, run `context-engineering` skill."

**Benefit:** The skill provides 5 compaction strategies with strategy selection logic, post-compaction verification, and maintenance cadence — all absent from the current 7-line approach.

#### R5: Replace Quality Gate with `reflection-loop` reference
**Action:** Replace lines 379-389 with references to `reflection-loop` for evaluating analysis/plan quality against success criteria.

#### R6: Replace Failure Protocol with `security-review-gate` + `human-in-loop-gate`
**Action:** Replace lines 322-368 with: "When security-review reports findings, invoke `security-review-gate` for structured assessment. If FAIL, use `human-in-loop-gate` for user decision."

### 4.2 security-review — High Priority

#### R7: Replace Detection Logic with `security-review-gate`
**Action:** Replace STEP 3-4 (Scan → Detect, lines 52-66) with a reference to invoke `security-review-gate`.

**Current:**
- Hardcoded list of 7 vulnerability categories
- Manual scanning approach
- Simple reporting

**Proposed:**
- Invoke `security-review-gate` which provides:
  - 5 structured checks (credential leak, destructive, external, injection, permission)
  - PASS/FAIL/CAUTION decision framework
  - Specific remediation guidance per FAIL
  - Approval gate logic
  - Audit logging

**Changes:**
- security-review agent becomes a thin wrapper that:
  1. Reads source files (existing STEP 1-2)
  2. Invokes `security-review-gate` skill
  3. Transforms skill output to implementation_report.md format
  4. Reports to controller

### 4.3 coder-execution — Medium Priority

#### R8: Add `dry-run-verify-fix` for test/build step
**Action:** Replace STEP 4 (lines 55-58) with a reference to invoke `dry-run-verify-fix` after implementation.

**Changes:**
- After implementation (STEP 3), invoke `dry-run-verify-fix` with delivery path = test + build + lint + typecheck
- The skill handles bounded iteration (max 3 repair cycles), diagnosis, and escalation
- coder-execution keeps STEP 5-7 for reporting

### 4.4 verifier — Medium Priority

#### R9: Add `reflection-loop` for verification quality
**Action:** Add an explicit evidence-based critique phase to verification using `reflection-loop` criteria.

**Benefit:** The current "Syntax/Logic/Integration/Regression" scope is a checklist without explicit evidence requirements. The reflection-loop skill forces citing exact evidence for each pass/fail assessment, catching more false positives.

### 4.5 task-architect — Low Priority

#### R10: Add `orchestrator-worker` reference for task decomposition rules
**Action:** In the Design Protocol section, reference that task decomposition should follow orchestrator-worker's rules (3-7 subtasks, DAG dependencies, independent verifiability).

**Benefit:** Reuses established decomposition rules instead of maintaining parallel guidance in task-architect.

## 5. Implementation Order

### Phase 1: High-Impact, Low-Risk (Do First)
| Order | Refactor | Agent | Effort | Risk | Token Savings |
|-------|----------|-------|--------|------|---------------|
| 1 | R7: Replace detection logic with `security-review-gate` | `security-review.md` | Small (~30 lines removed) | Low — skill is a strict superset | ~50 lines |
| 2 | R3: Replace error handling with `self-healing-loop` | `master-controller.md` | Small (~10 lines→5) | Low — mapping only | ~10 lines |
| 3 | R4: Replace context management with `context-engineering` | `master-controller.md` | Small (~7 lines→3) | Low — skill is more robust | ~5 lines |
| 4 | R2: Replace user approval flow with `human-in-loop-gate` | `master-controller.md` | Medium (~48 lines→10) | Low — skill is more structured | ~40 lines |

### Phase 2: High-Impact, Medium-Risk (After Phase 1)
| Order | Refactor | Agent | Effort | Risk | Token Savings |
|-------|----------|-------|--------|------|---------------|
| 5 | R1: Delegate orchestration to `orchestrator-worker` | `master-controller.md` | Large (~52 lines→15) | Medium — changes workflow narrative | ~40 lines |
| 6 | R5+R6: Replace quality gate + failure protocol | `master-controller.md` | Medium (~68 lines→15) | Medium — multiple skill references | ~50 lines |
| 7 | R8: Add `dry-run-verify-fix` for test/build | `coder-execution.md` | Medium (~5 lines added) | Low — additive change | +5 lines |

### Phase 3: Improvement (After Phase 1-2 Verified)
| Order | Refactor | Agent | Effort | Risk | Token Savings |
|-------|----------|-------|--------|------|---------------|
| 8 | R9: Add `reflection-loop` for verification | `verifier.md` | Small (~3 lines added) | Low — additive | +3 lines |
| 9 | R10: Add `orchestrator-worker` reference | `task-architect.md` | Small (~1 line added) | Low — additive | Minimal |

### Estimated Impact Summary
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| master-controller.md | 426 lines | ~260 lines | **-39%** |
| security-review.md | 136 lines | ~80 lines | **-41%** |
| coder-execution.md | 125 lines | ~120 lines | -4% |
| verifier.md | 138 lines | ~135 lines | -2% |
| task-architect.md | 307 lines | ~305 lines | -1% |
| **Total agent code** | **~1,132 lines** | **~900 lines** | **-20%** |
| Unique workflow logic | ~400 lines (hardcoded) | ~100 lines (delegated) | **-75%** |

## 6. Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Skill doesn't load in subagent context (no `skill()` tool available) | Medium | HIGH — entire refactor invalid | Verify skill loading capability in subagent mode before refactoring |
| Skill triggers don't fire reliably for the specific use case | Low | MEDIUM — need to add new triggers | Add domain-specific trigger phrases to skill files if missing |
| Orchestrator-worker delegation breaks existing error propagation | Low | HIGH — subagents fail silently | Add explicit error propagation tests in the controller |
| Removing too much narrative makes agent less understandable | Medium | MEDIUM — harder to maintain | Keep high-level narrative; move detailed workflow to skill references |
| Some skill namespaces conflict (e.g., `human-in-loop-gate` vs custom gate) | Low | MEDIUM — inconsistent behavior | Rename agent-specific gates to avoid conflicts |

## 7. Key Edge Cases & Nuances

1. **master-controller's penalty system** (lines 15-57) is NOT skill-replaceable. It's agent-specific governance (zero tolerance, cooldown, demerit points) that has no equivalent in any skill. Must be preserved.

2. **task-architect's challenge/refine step** (STEP 2) is unique to the architectural role. No skill covers "challenge intent and expose hidden assumptions." This is core agent logic, not redundant.

3. **The `request-translator` -> `task-architect` handoff** is specific to this system's architecture. `orchestrator-worker` handles general decomposition but doesn't know about this specific pipeline. The refactor must preserve this unique routing.

4. **`security-review` agent still serves a purpose** even after replacing detection logic with `security-review-gate`. The agent provides the subagent isolation boundary, file reading, and report generation. The skill provides the detection algorithm. They complement, not replace, each other.

5. **`coder-execution` should NOT be fully replaced** by `dry-run-verify-fix`. The skill covers the test/build verification loop but not the actual implementation (write/edit code). Keep STEP 3 (implement), replace STEP 4 (test).

6. **`plan-and-execute` vs `orchestrator-worker` overlap**: Both skills decompose work. The distinction is scale: `orchestrator-worker` handles multi-agent decomposition (different agents per subtask), while `plan-and-execute` handles phased execution (same agent over time). Master controller needs both: `orchestrator-worker` for agent assignment, `plan-and-execute` for phase gating.

## 8. Verification Criteria for Refactored Agents

| Criterion | How to Verify |
|-----------|---------------|
| Master controller delegates to orchestrator-worker for multi-step tasks | Review workflow — first step after receiving request is `orchestrator-worker` invocation |
| Security review uses security-review-gate checks | Run a security review — output should match skill's check format |
| User approval gates use human-in-loop-gate format | Trigger an approval — output should include operation, context, risk, options, recommendation |
| Context compaction uses context-engineering strategies | Trigger compaction — verify audit performed before strategy selection |
| Error handling uses self-healing-loop classification | Cause a failure — verify error class diagnosis before recovery |
| Test/build step in coder-execution uses dry-run-verify-fix | Run implementation — verify delivery path + diagnose + bounded repair cycle |
| No skill-replaceable workflow logic remains hardcoded | Full audit — grep each skill trigger phrase in agent files to confirm reference replaces logic |

---
*Generated: 2026-06-12 06:20*
*Last Updated: 2026-06-12 06:20*
