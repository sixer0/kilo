---
description: Command reference for agents - workflow templates available
---

# Kilo Commands - Workflow Templates

This file lists all available commands that agents can reference and use internally.

## Quick Reference Table

| Command | Purpose | Agent | Workflow Steps |
|---------|---------|-------|----------------|
| `/explore` | Map project structure | explore | glob → organize → report |
| `/search-code` | Find patterns in code | data-collector | glob → grep → assemble |
| `/explain` | Explain code/concept | data-collector | locate → analyze → explain |
| `/plan` | Create implementation plan | data-analyst | analyze → requirements → plan → challenges |
| `/refactor` | Refactor code | coder-execution | analyze → plan → execute → verify |
| `/test-gen` | Generate unit tests | test-expert | discover → analyze → generate → verify |
| `/debug` | Debug issues | coder-execution | collect → investigate → fix → verify |
| `/doc` | Generate documentation | coder-execution | discover → analyze → document → integrate |
| `/quick-review` | Code review | verifier | read → review → report |
| `/security` | Security scan | security-review | scan → detect → assess → report |
| `/perf` | Performance analysis | data-analyst | collect → analyze → measure → recommend |
| `/git-status` | Git status analysis | (direct) | get status → analyze → suggest |
| `/git-log` | Git history | (direct) | get info → analyze → report |
| `/commit` | Create git commit | (direct) | get status → analyze → create → report |
| `/rollback` | Undo commits | (direct) | analyze → assess → suggest → execute |
| `/deps` | Dependency analysis | (direct) | check → analyze → recommend |
| `/delegate` | Delegate to agent | master-controller | identify → craft → execute → handle |

## Workflow Templates

### Structure Mapping
```
/explore - Map project structure
Steps: glob dirs → identify entry points → report structure
```

### Data Gathering
```
/search-code - Find patterns
Steps: glob file patterns → grep content → assemble results

/explain - Explain code
Steps: locate files → analyze flow → explain with examples
```

### Analysis & Planning
```
/plan - Implementation plan
Steps: analyze current state → extract requirements → plan steps → identify challenges

/perf - Performance analysis
Steps: collect code → analyze bottlenecks → measure → recommend
```

### Implementation
```
/refactor - Code refactoring
Steps: analyze code → plan refactor → execute → verify

/debug - Debug issues
Steps: collect context → investigate → fix → verify

/doc - Documentation
Steps: discover code → analyze → document → integrate
```

### Verification
```
/quick-review - Code review
Steps: read code → analyze quality → report issues

/security - Security scan
Steps: scan code → detect vulnerabilities → assess severity → report
```

### Git Operations
```
/git-status - Analyze changes
/git-log - Show history
/commit - Create commit
/rollback - Undo commits
```

### Testing
```
/test-gen - Generate tests
Steps: discover source → analyze → generate → verify
```

## Agent-to-Command Mapping

| Agent | Primary Commands | Secondary Commands |
|-------|-----------------|-------------------|
| explore | `/explore` | `/search-code` |
| data-collector | `/search-code`, `/explain` | `/git-status` |
| data-analyst | `/plan`, `/perf` | `/security` (reference only) |
| coder-execution | `/refactor`, `/debug`, `/doc` | `/test-gen` (coordinate) |
| verifier | `/quick-review` | `/security` (coordinate) |
| security-review | `/security` | `/search-code`, `/explain` |
| test-expert | `/test-gen` | `/search-code` |

## Usage in Agent Prompts

Agents should reference commands like:
```
To explore structure, use /explore workflow
To gather data, use /search-code or /explain
To analyze, use /plan workflow
To implement, follow /refactor or /debug workflow
```

## Output Format Standards

All commands output in standardized formats:
- Success: `*_COMPLETE` with summary table
- Blocked: `*_BLOCKED` with reason and needed info
- Incomplete: `DATA_INCOMPLETE` with missing items
