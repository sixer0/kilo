---
description: Delegate task to sub-agent for execution
agent: master-controller
model: kilo/minimax/minimax-m2.7
subtask: false
---

Delegate task to appropriate sub-agent: $ARGUMENTS

## Architecture Overview

```
User Request
     ↓
Master Controller (orchestrates)
     ↓
Delegates to Sub-Agent
     ↓
Sub-Agent uses Command Workflow internally
     ↓
Returns result to Master Controller
     ↓
Master Controller summarizes to User
```

## Sub-Agents Available (7)

| Agent | Purpose | Command Workflows |
|-------|---------|------------------|
| `explore` | Map project structure | `/explore` |
| `data-collector` | Gather data | `/search-code`, `/explain` |
| `data-analyst` | Analyze and plan | `/plan`, `/perf` |
| `coder-execution` | Implement changes | `/refactor`, `/debug`, `/doc` |
| `verifier` | Verify correctness | `/quick-review` |
| `security-review` | Security scan | `/security` |
| `test-expert` | Generate tests | `/test-gen` |

## Delegation Format

### Simple Task
```
/delegate explore src/components
```
Agent will use `/explore` workflow internally.

### Complex Task
```
/delegate security-review Scan all API routes for SQL injection and XSS
```
Agent will use `/security` workflow internally.

### With Specific Instructions
```
/delegate coder-execution Refactor the authentication module following /refactor workflow. Focus on: extract methods over 50 lines, reduce duplication.
```

## How Master Controller Delegates

When delegating, construct the prompt with:

1. **Task** - What needs to be done
2. **Target** - Files/modules to affect
3. **Command Reference** - Which workflow to use
4. **Constraints** - Any specific requirements

Example:
```
Task(subagent_type="security-review", prompt="
Task: Scan src/api/* for security vulnerabilities
Target: src/api/auth.js, src/api/users.js
Command: Use /security workflow
Constraints: Focus on injection attacks and authentication issues
Expected Output: SECURITY_SCAN_COMPLETE with severity table
")
```

## Workflow Command Reference

| Task Type | Command | Steps |
|-----------|---------|-------|
| Map structure | `/explore` | glob → organize → report |
| Find patterns | `/search-code` | glob → grep → assemble |
| Understand code | `/explain` | locate → analyze → explain |
| Create plan | `/plan` | analyze → requirements → plan → challenges |
| Refactor | `/refactor` | analyze → plan → execute → verify |
| Debug | `/debug` | collect → investigate → fix → verify |
| Document | `/doc` | discover → analyze → document → integrate |
| Review code | `/quick-review` | read → review → report |
| Security scan | `/security` | scan → detect → assess → report |
| Performance | `/perf` | collect → analyze → recommend |
| Generate tests | `/test-gen` | discover → analyze → generate → verify |

## Status Reporting

Master Controller will report:

### Delegating
```
🔄 Delegating to [agent]...
   Task: [description]
   Target: [files]
   Command: [/workflow]
```

### Result Received
```
✅ [agent] completed
   Status: [success/blocked]
   Result: [summary]
```

### Error Handling
```
⚠️ [agent] blocked
   Reason: [why]
   Needed: [what's required]
   Action: [recommendation]
```

## Direct User Commands (skip Master Controller)

These commands can be used directly without delegation:
- `/git-status` - Direct git analysis
- `/git-log` - Direct git history
- `/commit` - Direct commit creation
- `/rollback` - Direct undo
- `/deps` - Direct dependency check

For all other tasks, use `/delegate` to route through appropriate agent.
