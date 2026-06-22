---
task_id: phase-accountability-documentation-workflow
task_slug: phase_accountability_workflow
date: 2026-06-19
agent: master-controller
status: completed
---

# Phase Accountability Workflow

This folder is the self-documenting example for the approved phase-based accountability and documentation workflow in the Kilo workspace.

## Canonical Structure

```text
docs/[date]_[task]/
  README.md
  status_tasks.md
  structured_tasks.md
  identification/01_translated.md
  research/01_explore.md
  research/02_collection.md
  research/03_analysis.md
  masterplan/01_specs.md
  masterplan/02_plan.md
  initialization/01_env_check.md
  initialization/checkpoint.yaml
  implementation/01_changes.md
  implementation/02_agent_rule_inserts.md
  gateway_check/01_gate_report.md
  test/01_test_report.md
  verification/01_verification.md
  verification/02_security.md
  report/report.md
  decisions/decisions.md
  final_report.md
  implementation_report.md
```

## Phase Index

| Phase | Folder | Primary Artifact | Owner |
|---|---|---|---|
| 1. identification | `identification/` | [identification/01_translated.md](identification/01_translated.md) | `request-translator`, `task-architect` |
| 2. research | `research/` | [research/01_explore.md](research/01_explore.md), [research/02_collection.md](research/02_collection.md), [research/03_analysis.md](research/03_analysis.md) | `explore`, `data-collector`, `data-analyst` |
| 3. masterplan | `masterplan/` | [masterplan/01_specs.md](masterplan/01_specs.md), [masterplan/02_plan.md](masterplan/02_plan.md) | `task-architect`, `pm-planner` |
| 4. initialization | `initialization/` | [initialization/01_env_check.md](initialization/01_env_check.md), [initialization/checkpoint.yaml](initialization/checkpoint.yaml) | `controller`, executor agents |
| 5. implementation | `implementation/` | [implementation/01_changes.md](implementation/01_changes.md), [implementation/02_agent_rule_inserts.md](implementation/02_agent_rule_inserts.md) | `coder-execution` |
| 6. gateway_check | `gateway_check/` | [gateway_check/01_gate_report.md](gateway_check/01_gate_report.md) | `controller` |
| 7. test | `test/` | [test/01_test_report.md](test/01_test_report.md) | `test-expert` |
| 8. verification | `verification/` | [verification/01_verification.md](verification/01_verification.md), [verification/02_security.md](verification/02_security.md) | `verifier`, `security-review` |
| 9. report | `report/` | [report/report.md](report/report.md) | `controller` |
| 10. decisions | `decisions/` | [decisions/decisions.md](decisions/decisions.md) | `controller` |

## Linked Artifacts

### Existing Structured Task

- [structured_tasks.md](structured_tasks.md)

### Task Index and Status

- [README.md](README.md)
- [status_tasks.md](status_tasks.md)

### Identification

- [identification/01_translated.md](identification/01_translated.md)

### Research

- [research/01_explore.md](research/01_explore.md)
- [research/02_collection.md](research/02_collection.md)
- [research/03_analysis.md](research/03_analysis.md)

### Masterplan

- [masterplan/01_specs.md](masterplan/01_specs.md)
- [masterplan/02_plan.md](masterplan/02_plan.md)

### Initialization

- [initialization/01_env_check.md](initialization/01_env_check.md)
- [initialization/checkpoint.yaml](initialization/checkpoint.yaml)

### Implementation

- [implementation/01_changes.md](implementation/01_changes.md)
- [implementation/02_agent_rule_inserts.md](implementation/02_agent_rule_inserts.md)

### Gateway Check

- [gateway_check/01_gate_report.md](gateway_check/01_gate_report.md)

### Test

- [test/01_test_report.md](test/01_test_report.md)

### Verification

- [verification/01_verification.md](verification/01_verification.md)
- [verification/02_security.md](verification/02_security.md)

### Report

- [report/report.md](report/report.md)

### Decisions

- [decisions/decisions.md](decisions/decisions.md)

### Final Reports

- [final_report.md](final_report.md)
- [implementation_report.md](implementation_report.md)

## Agent Accountability Summary

| Agent type | Required Artifact |
|---|---|
| `controller` | Coordinates `README.md`, `status_tasks.md`, gates, final report, and closure. |
| `request-translator` | [identification/01_translated.md](identification/01_translated.md). |
| `task-architect` | [structured_tasks.md](structured_tasks.md) and [masterplan/02_plan.md](masterplan/02_plan.md) or linked plan artifact. |
| `explore` | [research/01_explore.md](research/01_explore.md). |
| `data-collector` | [research/02_collection.md](research/02_collection.md). |
| `data-analyst` | [research/03_analysis.md](research/03_analysis.md). |
| `pm-planner` | [masterplan/02_plan.md](masterplan/02_plan.md) or implementation plan artifact. |
| `coder-execution` | [implementation/01_changes.md](implementation/01_changes.md), [implementation/02_agent_rule_inserts.md](implementation/02_agent_rule_inserts.md), and test artifacts. |
| `test-expert` | [test/01_test_report.md](test/01_test_report.md). |
| `verifier` | [verification/01_verification.md](verification/01_verification.md). |
| `security-review` | [verification/02_security.md](verification/02_security.md) with PASS/CAUTION/FAIL. |

## Verification Summary

- Phase folders exist.
- Required artifacts are present.
- `README.md` links to `structured_tasks.md` and each phase artifact.
- Existing `structured_tasks.md` is preserved.
- No `/output` artifacts were created.
- All filenames in this workflow use snake_case.
