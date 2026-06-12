---
task: locate-master-controller-request-translator-agent-configs
date: 2026-06-05
agent: explore
scope: Agent configuration files, Master Controller, Request Translator, workflow logic
---

# Agent Configuration Exploration Report

## Overview
Exploration of the Kilo workspace to map agent definitions, Master Controller configuration, Request Translator setup, and workflow logic locations.

## Directory Structure

### Directories Found
| Path | Purpose | Status |
|------|-------|-------|
| `agent/` | Agent definition files | EXISTING |
| `command/` | Command workflow definitions | EXISTING |
| `memory/refs/` | Reference knowledge storage | EXISTING |
| `memory/tasks/` | Task archives and snapshots | EXISTING |
| `output/explore/` | Exploration output files | EXISTING |
| `output/tasks/` | Task definition files | EXISTING |
| `output/analysis/` | Analysis output files | EXISTING |
| `output/collector/` | Data collection outputs | EXISTING |
| `output/plans/` | Implementation plans | EXISTING |
| `output/trading/` | Trading-related outputs | EXISTING |
| `temp/` | Temporary scripts | EXISTING |
| `test/` | Test files | EXISTING |

### Entry Points Identified
- `kilo.json` - Main configuration file (MCP, skills)
- `kilo.jsonc` - Commented configuration variant

### Configuration Files
- `kilo.json` - Main config with MCP (puppeteer) and skills paths
- `AGENTS.md` - Global workspace rules and memory management
- `SOUL.md` - Agent personality and behavior guidelines
- `MEMORY.md` - Knowledge index with project context
- `HEARTBEAT.md` - Heartbeat tracking configuration
- `package.json` - Node.js dependencies

## Agent Definitions

### Master Controller Agents
| File | Type | Notes |
|------|------|-------|
| `agent/master-controller.md` | Primary | Main orchestration agent with penalty enforcement |
| `agent/master-controller-free.md` | Fallback | Free tier version with reverse tiering rules |

### Request Translator
| File | Type | Notes |
|------|------|-------|
| `agent/request-translator.md` | Subagent (hidden) | Translates user requests to structured tasks |

### Specialized Domain Controllers
| File | Domain | Notes |
|------|--------|-------|
| `agent/pm-controller.md` | Project Management | PM workflow coordination |
| `agent/document-controller.md` | Documentation | Document lifecycle coordination |
| `agent/trading-controller.md` | Trading | Trading operations coordination |

### Execution Agents (Paid/Free Pairs)
| Agent Type | Paid Agent | Free Agent |
|------------|------------|------------|
| Data Analysis | `data-analyst.md` | `data-analyst-free.md` |
| Code Execution | `coder-execution.md` | `coder-execution-free.md` |
| Verification | `verifier.md` | `verifier-free.md` |
| Security Review | `security-review.md` | `security-review-free.md` |
| Testing | `test-expert.md` | `test-expert-free.md` |
| Git Operations | `git-specialist.md` | `git-specialist-free.md` |
| Docker | `docker-specialist.md` | `docker-specialist-free.md` |
| Database | `database-specialist.md` | `database-specialist-free.md` |
| Image | `image-specialist.md` | `image-specialist-free.md` |
| Document Reader | `document-reader.md` | `document-reader-free.md` |
| Document Writer | `document-writer.md` | `document-writer-free.md` |
| Document Converter | `document-converter.md` | `document-converter-free.md` |

### Utility Agents (No Pairs)
| Agent | Purpose |
|-------|---------|
| `explore.md` | Project structure mapping |
| `data-collector.md` | Context gathering |
| `pm-planner.md` | PM planning |
| `pm-analyst.md` | PM analysis |
| `pm-writer.md` | PM document creation |
| `pm-verifier.md` | PM verification |
| `document-analyst.md` | Document analysis |
| `document-writer.md` | Document creation |
| `document-reviewer.md` | Document review |
| `document-reader.md` | Document reading |
| `document-converter.md` | Format conversion |
| `image-analyst.md` | Image analysis |

### Trading Agents
| File | Purpose |
|------|---------|
| `trading/signal-verification-agent.md` | Signal verification |
| `trading/trade-executor-agent.md` | Trade execution |
| `trading/technical-analysis-agent.md` | Technical analysis |
| `trading/user-config.yaml` | Trading configuration |

## Command Definitions

### Available Commands
| File | Agent Used | Description |
|------|------------|-------------|
| `command/explore.md` | explore | Project structure exploration |
| `command/delegate.md` | (varied) | Task delegation |
| `command/trading.md` | trading-controller | Trading operations |
| `command/security.md` | security-review | Security scanning |
| `command/commit.md` | git-specialist | Git commits |
| `command/refactor.md` | (varied) | Code refactoring |
| `command/search-code.md` | (varied) | Code search |
| `command/plan.md` | pm-planner | Planning workflow |
| `command/doc.md` | document-controller | Document workflow |

## Workflow Logic

### Orchestration Flow (from master-controller.md)
1. RECEIVE_USER_REQUEST
2. Delegate to `request-translator` → writes task.md
3. Delegate to `explore` (reads task.md + memory)
4. Delegate to `data-collector` (reads task.md + explore)
5. Delegate to `data-analyst` (reads task.md + explore + collector)
6. [If complex] Delegate to `pm-planner` (reads task + analysis)
7. PRESENT TO USER → Summary + Permission request
8. RE-READ FILES BEFORE EXECUTE
9. Execute via appropriate agents
10. Summarize results

### Agent Selection Pattern
- **Request Translator**: Always first (parsing)
- **Explore**: Maps project structure
- **Data Collector**: Gathers code/documents
- **Data Analyst**: Analysis and planning
- **Free/Paid Tiering**: Paid agents first (master-controller) OR Free first (master-controller-free)

## File Type Summary
| Extension | Count | Purpose |
|-----------|-------|---------|
| .md | 60+ | Agent definitions, commands, memory |
| .json | 2 | Configuration (kilo.json, package.json) |
| .jsonc | 1 | Commented config variant |
| .yaml | 1 | Trading configuration |
| .js | 3 | Test files |
| .py | 5 | Test/data scripts |
| .ps1 | 4 | PowerShell test scripts |
| .docx | 1 | Test input |
| .pdf | 1 | Test output |

### Provider Configuration
| File | Purpose | Notes |
|------|---------|-------|
| `provider-config.yaml` | AI provider settings | Ollama local config (qwen3.5:4b model) |

## Gaps / Needs Investigation
- Memory refs/tasks subdirectories need deeper inspection
- Trading agent workflow integration with main controller

---
*Generated: 2026-06-05 05:14*