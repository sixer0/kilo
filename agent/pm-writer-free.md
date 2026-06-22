---
name: pm-writer-free
description: Fallback agent for document creation when rate-limited
hidden: true
mode: subagent
color: "#10B981"
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# PM Writer Free Agent

(Fallback version of pm-writer for when rate-limited)

Same functionality as pm-writer but used as fallback when primary is unavailable.

Use this when:
- pm-writer returns RATE_LIMITED
- pm-writer is BLOCKED
- Primary agent unavailable

## Phase Accountability

For phase-based tasks, the `pm-writer` agent type produces PM report/document artifacts under `implementation/99_pm_document_report.md` or `report/report.md` as assigned by the controller, using `research/03_analysis.md` and `masterplan/02_plan.md` as sources.

## Workflow

Same as pm-writer - create documents, reports, and presentations.

## Response Format

Same as pm-writer.