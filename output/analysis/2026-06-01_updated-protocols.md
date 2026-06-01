---
task: design-updated-operational-protocols
date: 2026-06-01
agent: data-analyst-free
type: requirements
confidence: HIGH
task_file: output/tasks/2026-06-01_design-updated-protocols.md
last_updated: 2026-06-01 18:10
---

# Operational Protocol Update Proposal

## Overview
This document proposes updates to the Kilo agent ecosystem protocols to address feedback regarding **Intent Erosion**, **Blind Verification**, and the **Reporting Gap**. The goal is to shift from a "Synthesis-Dependent" workflow to a "Document-Driven" workflow where executors and verifiers rely on detailed analysis/plan files as the single source of truth.

## Original Task Reference
- **Task File**: `output/tasks/2026-06-01_design-updated-protocols.md`
- **Intent**: Design updated operational protocols based on user feedback to prevent intent erosion and improve reporting efficiency.
- **Scope**: `master-controller.md`, `coder-execution.md`, `verifier.md`, `data-analyst.md`, and `pm-planner.md`.

## Summary
The proposed changes mandate that sub-agents (Coders and Verifiers) read detailed documentation (`task.md`, `analysis.md`, `plan.md`) directly rather than relying on Orchestrator summaries. Additionally, Analysts and Planners are required to adopt higher documentation standards (Why, Nuances, Edge Cases), and the Orchestrator will adopt a "Highlight -> Detail" reporting pattern.

## Proposed Changes

### 1. `agent/master-controller.md`
**Objective**: Improve delegation precision and synthesis efficiency.

#### Change A: Delegation Prompts
**Old**:
```markdown
Task(subagent_type="[agent-name]", prompt="
Task: [what needs to be done]
Target: [files or scope]
Command: [workflow name like /explore, /security]
Expected: [what result format]
")
```

**New**:
```markdown
Task(subagent_type="[agent-name]", prompt="
Task: [what needs to be done]
Target: [files or scope]
Command: [workflow name like /explore, /security]
Expected: [what result format]
Reference: [IMPORTANT: Explicitly instruct the agent to read task.md, analysis.md, and plan.md if applicable]
")
```

#### Change B: Synthesis Rules
**Old**:
*(No explicit rule for synthesis efficiency)*

**New (Add new section)**:
```markdown
### 📊 SYNTHESIS & REPORTING RULES

When summarizing results from sub-agents, use the **"Highlight -> Detail"** pattern to remain efficient yet evidence-based:

1. **HIGHLIGHT**: Provide a concise, high-level summary of the outcome (e.g., "✅ Implementation successful: 3 files modified, tests passed").
2. **DETAIL**: Provide specific evidence/details only where necessary (e.g., "Modified `src/auth.ts` to add JWT validation; verified via `npm test`").

Avoid long, conversational filler. Focus on impact and evidence.
```

#### Change C: Quality Gate
**New (Add new section)**:
```markdown
## Quality Gate

The Orchestrator MUST NOT blindly delegate. Before moving to implementation (`coder-execution`) or verification (`verifier`), you MUST assess if the `analysis.md` and `plan.md` are "Delegation-Ready" based on the following criteria:

### ⚖️ Evaluation Criteria
1. **Intent Alignment**: Does it fulfill the original intent and constraints defined in `task.md`?
2. **Documentation Standard**: Does it meet the mandatory standards (Explicit **WHY**, **NUANCES**, and **EDGE CASES**)?
3. **Actionability**: Is the implementation plan unambiguous, granular, and directly actionable?

### 🔄 Feedback Loop
If the output is deemed insufficient, DO NOT proceed. You MUST send the task back to the Analyst or Planner with specific, actionable feedback for improvement.
```

---

### 2. `agent/coder-execution.md`
**Objective**: Eliminate Intent Erosion.

**Old**:
*(No Source of Truth section)*

**New (Add new section)**:
```markdown
## Source of Truth

To prevent intent erosion, you MUST read the following files before any implementation:
1. `task.md` (Original user intent and constraints)
2. `analysis.md` (Detailed requirements, technical findings, and 'Why')
3. `plan.md` (The approved implementation roadmap)

**NEVER** rely solely on the Orchestrator's synthesis. The files are the ultimate Source of Truth.
```

---

### 3. `agent/verifier.md`
**Objective**: Eliminate Blind Verification.

**Old**:
*(No Source of Truth section)*

**New (Add new section)**:
```markdown
## Source of Truth

To prevent blind verification, you MUST read the following files before any verification:
1. `task.md` (Original user intent and requirements)
2. `analysis.md` (Technical findings and expected outcomes)
3. `plan.md` (The planned implementation steps)

**NEVER** rely solely on the Orchestrator's synthesis. The files are the ultimate Source of Truth.
```

---

### 4. `agent/data-analyst.md` & `agent/pm-planner.md`
**Objective**: Support direct consumption by executors through high-detail documentation.

#### Change A: `agent/data-analyst.md`
**Old**:
*(No explicit mandate for Why/Nuances/Edge Cases in a dedicated section)*

**New (Add new section)**:
```markdown
## Documentation Standards

To enable direct consumption by executors, all analysis and plans MUST explicitly document:
- **WHY**: The technical rationale behind recommendations or findings.
- **NUANCES**: Technical subtleties, complexities, or specific implementation details.
- **EDGE CASES**: Potential failure points, boundary conditions, or unexpected behaviors.

Avoid vague statements like "Update the file". Instead, use "Update the file to handle X because of Y, noting that Z might occur in case of W".
```

#### Change B: `agent/pm-planner.md`
**Old**:
*(No explicit mandate)*

**New (Add new section)**:
```markdown
## Documentation Standards

To ensure planners' outputs are directly actionable by `pm-writer` and `coder-execution`, you MUST explicitly document:
- **WHY**: The reasoning for specific task sequencing or resource allocation.
- **NUANCES**: Complexity levels, dependency subtleties, or phase transitions.
- **EDGE CASES**: Potential timeline risks, resource bottlenecks, or scope creep triggers.
```

## Implementation Order
1. Update `agent/master-controller.md`
2. Update `agent/coder-execution.md`
3. Update `agent/verifier.md`
4. Update `agent/data-analyst.md`
5. Update `agent/pm-planner.md`

## Risks
- **Token Usage**: Requiring multiple agents to read multiple large files may increase token consumption per task.
- **Compliance**: Agents might ignore the "Source of Truth" mandate if not strictly enforced via system prompt.

---
*Generated: 2026-06-01 18:10*
