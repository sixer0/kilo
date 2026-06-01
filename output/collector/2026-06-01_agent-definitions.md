---
task: agent-config-analysis
date: 2026-06-01
agent: data-collector
items_collected: 3
last_updated: 2026-06-01 17:15
---

# Data Collection Report

## Task Overview
Collect and analyze data from `AGENTS.md`, `kilo.jsonc`, and files in the `agent/` directory to understand agent definitions, roles, configuration parameters, and operational patterns.

## Files Collected

### Source Files
| File | Purpose | Lines |
|------|---------|-------|
| `AGENTS.md` | Workspace guide and memory management principles | 294 |
| `kilo.jsonc` | Main system and agent configuration | 530 |
| `agent/master-controller-free.md` | Example of a Primary Agent definition | 290 |
| `agent/coder-execution.md` | Example of a Subagent definition | 124 |

### Configuration Files
| File | Purpose |
|------|---------|
| `kilo.jsonc` | Central configuration for models, permissions, system settings, and agent registry |

### Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| N/A | N/A | N/A |

## Code Context

### kilo.jsonc (Agent Configuration Structure)
The `kilo.jsonc` file serves as the central registry for all agents. Agents are categorized into several functional groups:

- **Primary Agents**: Orchestration and high-level control (e.g., `master-controller`, `pm-controller`, `document-controller`).
- **Core Development Agents**: Analysis, coding, and testing (e.g., `data-analyst`, `coder-execution`, `verifier`, `security-review`, `test-expert`).
- **Infrastructure Agents**: Git, Docker, and Database operations (e.g., `git-specialist`, `docker-specialist`, `database-specialist`).
- **PM Agents**: Project management and business analysis (e.g., `pm-analyst`, `pm-planner`, `pm-writer`).
- **Image Agents**: Image creation and analysis (e.g., `image-specialist`).
- **Document Agents**: Document processing (e.g., `document-reader`, `document-writer`, `document-reviewer`).
- **Utility Agents**: Specialized low-level tasks (e.g., `request-translator`, `explore`, `data-collector`).
- **Default Agents**: Essential system-level agents (e.g., `ask`, `plan`, `debug`, `orchestrator`).

**Agent Definition Parameters in `kilo.jsonc`:**
- `model`: The LLM assigned to the agent.
- `hidden`: Boolean indicating if the agent is visible in the UI.
- `description`: Brief summary of the agent's role.
- `mode`: `primary` (orchestrator) or `subagent` (specialist).
- `color`: Hex color for UI representation.
- `steps`: Number of steps for complex orchestration.

### agent/*.md (Agent Instruction Patterns)
Individual agent files in the `agent/` directory define their specific behaviors. Two distinct patterns were identified based on the agent's `mode`:

#### 1. Primary Agent Pattern (e.g., `master-controller-free.md`)
- **Focus**: Orchestration, delegation, and user interaction.
- **Key Features**:
    - **Strict Enforcement**: Detailed "Penalty" systems to ensure adherence to orchestration rules (e.g., avoiding direct tool use, using `request-translator` first).
    - **Delegation Logic**: Explicit instructions on how to use the `Task()` command to call sub-agents.
    - **User Approval Workflow**: Mandatory steps to present a task summary and wait for user approval before execution.
    - **Complex Workflows**: High-level multi-step processes involving multiple sub-agents.

#### 2. Subagent Pattern (e.g., `coder-execution.md`)
- **Focus**: Specialized execution and implementation.
- **Key Features**:
    - **Task-Specific Workflows**: Use of command templates (e.g., `/refactor`, `/debug`, `/doc`) to guide execution.
    - **Tool Constraints**: Explicit list of permitted tools for the specific role.
    - **Operational Standards**: Detailed implementation steps (e.g., "Understand First", "Plan with Todo", "Verify").
    - **Defined Output Formats**: Standardized response formats (e.g., `IMPLEMENTATION_COMPLETE`) to facilitate structured reporting back to the Master Controller.

## Patterns & Observations

- **Tiered Execution (Free vs. Paid)**: A consistent "FREE FIRST" strategy is implemented across the system. For almost every specialized agent, a corresponding `-free` version exists (e.g., `coder-execution` vs `coder-execution-free`) to optimize for cost and rate limits.
- **Hierarchical Orchestration**: The system follows a clear hierarchy: `Master Controller` (Primary) $\rightarrow$ `Sub-agents` (Specialists). Sub-agents are prohibited from direct user interaction or high-level planning, focusing strictly on their defined domain.
- **Memory-Centric Design**: All agents are instructed to respect the global memory architecture defined in `AGENTS.md`, ensuring continuity and knowledge preservation through `MEMORY.md` and `memory/` logs.
- **Strict Communication Protocol**: Agents use structured response formats and specific commands (like `Task()`) to ensure clear, machine-readable communication within the orchestration loop.

## Collection Log

| Timestamp | Action | Details |
|-----------|--------|---------|
| 17:07 | Started | Initiated agent configuration analysis |
| 17:08 | Located | Identified `AGENTS.md`, `kilo.jsonc`, and `agent/` directory |
| 17:09 | Read | Analyzed `AGENTS.md` |
| 17:10 | Read | Analyzed `kilo.jsonc` |
| 17:11 | Read | Analyzed `agent/master-controller-free.md` |
| 17:12 | Read | Analyzed `agent/coder-execution.md` |
| 17:15 | Completed | Compiled findings into report |

---
*Generated: 2026-06-01 17:15*
*Last Updated: 2026-06-01 17:15*
