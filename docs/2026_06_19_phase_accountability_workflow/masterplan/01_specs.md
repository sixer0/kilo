---
task_id: phase-accountability-documentation-workflow
task_slug: phase_accountability_workflow
date: 2026-06-19
agent: task-architect
status: completed
---

# Specification

## Functional Specification

The Kilo workspace must define and demonstrate a phase-based accountability workflow that:

1. Keeps `AGENTS.md` as the authoritative source for agent rules, communication protocol, and documentation accountability.
2. Makes the controller the first and last user-facing actor.
3. Requires request-translator as the first delegated actor.
4. Requires all task artifacts under `/docs`, never `/output`.
5. Uses the canonical path `docs/[date]_[task]/[phase]/[num]_slug`.
6. Defines exactly these phases:
   - `identification`
   - `research`
   - `masterplan`
   - `initialization`
   - `implementation`
   - `gateway_check`
   - `test`
   - `verification`
   - `report`
   - `decisions`
7. Requires each task folder to include `README.md`, `status_tasks.md`, and final/report artifacts.
8. Defines per-agent accountability at a high level.
9. Defines gates/checkpoints and verification requirements.
10. Adds concrete per-agent artifact responsibilities to relevant agent instruction files.

## Non-Functional Specification

- Additive changes only unless an existing section clearly needs a small insertion point.
- Preserve existing `AGENTS.md` sections and master-controller orchestration/gating/error-handling sections.
- Preserve existing docs and agent files.
- Use snake_case filenames.
- Avoid emojis in files.
- No external actions.
- Keep the centralized `AGENTS.md` contract concise, ideally no more than 150 lines.

## Acceptance Criteria

- `AGENTS.md` contains `Documentation Accountability Contract`.
- Required agent files contain a phase accountability insert.
- Required phase folders exist.
- Required phase artifacts exist.
- `structured_tasks.md` remains present and is linked from `README.md`.
- Verification confirms no `/output` artifacts, no emojis, and snake_case filenames.
