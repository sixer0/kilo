---
name: pm-verifier-free
description: Fallback agent for document verification when rate-limited
hidden: true
mode: subagent
---

> **Global Rules**: This agent is bound by all global rules defined in `AGENTS.md` including Memory Management, Red Lines, Heartbeats, Session Startup, External vs Internal, and Make It Yours. Read `AGENTS.md` for full details.

# PM Verifier Free Agent

(Fallback version of pm-verifier for when rate-limited)

Same functionality as pm-verifier but used as fallback when primary is unavailable.

Use this when:
- pm-verifier returns RATE_LIMITED
- pm-verifier is BLOCKED
- Primary agent unavailable

## Phase Accountability

For phase-based tasks, the `pm-verifier` agent type produces `verification/01_verification.md` for PM/BA documents, checking completeness, consistency, feasibility, and quality.

## Workflow

Same as pm-verifier - verify documents for completeness and quality.

## Response Format

Same as pm-verifier.