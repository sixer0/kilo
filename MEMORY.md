# MEMORY.md — Long-Term Memory

> Curated knowledge. Keep this lean. Link out to `memory/refs/` for deep content.
> Raw daily logs live in `memory/YYYY-MM-DD.md`.
> Task logs live in `memory/tasks/`.

---

## About the User

- Timezone: Asia/Bangkok
- Location: Pondokpucung Satu, Indonesia
- Preferences: _(fill in over time)_

---

## Active Projects

| Project | Description | Status | Ref |
|---------|-------------|--------|-----|
| Nailla Customer Service Agent | AI agent for Sixer0 portfolio website to handle inquiries and guide prospects | Setup complete | `memory/refs/nailla-agent-setup.md` |
| Office Utilities | xlsx/docx/pptx/pdf manipulation + chart generation | Ready | `memory/refs/office-utils.md` |

---

## Key Decisions & Lessons

- **Agent Global Alignment**: Enforce global rules for all agents (primary & subagents) by using the `instructions` field in `kilo.jsonc` and adding explicit reference blocks in agent prompt files.
- **Memory Screening Workflow**: Implemented a mandatory screening step in `AGENTS.md` where agents must consult `MEMORY.md` and `memory/refs/` before executing tasks to ensure continuity and adherence to past decisions.
- OneDrive Excel work: prefer download→edit locally (openpyxl/pandas)→reupload. OneDrive versioning preserves originals automatically.
- Office file handling: use `/root/.openclaw/workspace/scripts/office_utils.py` for xlsx/docx/pptx/pdf manipulation and chart generation.

---

## Reference Index

| File | Topic | Updated |
|------|-------|---------|
| `memory/refs/onedrive-excel-workflow.md` | OneDrive + Excel: download→edit→reupload with versioning | 2026-05-13 |
| `memory/refs/office-utils.md` | Office utilities: xlsx/docx/pptx/pdf manipulation + chart generation | 2026-05-13 |
| `memory/refs/nailla-agent-setup.md` | Nailla CS agent: setup, rules, and integration guide | 2026-05-15 |

> Files live in `memory/refs/<slug>.md`
> Add a row here whenever you create a new ref file.

---

## End-of-Day Reports

| Date | File | One-line Summary |
|------|------|-----------------|
| _(none yet)_ | | |

> Reports live in `memory/tasks/YYYY-MM-DD-report.md`

---

_Last reviewed: 2026-05-15_