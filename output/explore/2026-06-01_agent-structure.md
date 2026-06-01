---
task: agent-config-analysis
date: 2026-06-01
agent: explore
scope: Explored Kilo project structure to identify all configuration files related to agents and sub-agents in ~/.config/kilo
---

# Project Exploration Report

## Overview
Explored the Kilo project structure in the ~/.config/kilo directory to identify configuration files related to agents and sub-agents. Focused on locating agent definition files, agent-specific configuration files, and system-level configuration that governs agent behavior.

## Directory Structure

### Directories Found
| Path | Purpose | Status |
|------|---------|--------|
| / | Root directory containing system configuration | NEW |
| agent/ | Contains agent definition files (.md) for various agents | NEW |
| agent/trading/ | Subdirectory containing trading-specific agent definitions and configurations | NEW |
| output/ | Directory for exploration and other outputs | NEW |
| test/ | Directory containing test files | NEW |
| temp/ | Temporary files directory | NEW |
| command/ | Contains command definition files (.md) | NEW |

### Entry Points Identified
- `kilo.json` - Main system configuration file
- `agent/master-controller.md` - Master controller agent definition
- `agent/trading/user-config.yaml` - Configuration for trading sub-agents
- `agent/trading/risk-config.yaml` - Risk management configuration for trading agents

### Configuration Files
- `kilo.json` - System-level configuration for MCP (Model Context Protocol) and skills paths
- `kilo.jsonc` - Commented version of kilo.json (likely used for development)
- `agent/trading/user-config.yaml` - User-specific configuration for trading agents
- `agent/trading/risk-config.yaml` - Risk parameters and limits for trading agents

### Naming Conventions
- Agent definition files: Use kebab-case with `.md` extension (e.g., `master-controller.md`, `signal-verification-agent.md`)
- Trading agent files: Located in `agent/trading/` directory, follow pattern `<agent-name>-agent.md`
- Configuration files: Use `.yaml` extension for agent-specific settings (e.g., `user-config.yaml`, `risk-config.yaml`)
- System configuration: Uses `.json` and `.jsonc` extensions in root directory
- Free agent variants: Append `-free` to agent name (e.g., `verifier-free.md`)

## File Type Summary
| Extension | Count | Purpose |
|-----------|-------|---------|
| .md | 45 | Agent definitions, command definitions, documentation |
| .yaml | 2 | Agent-specific configuration files (trading sub-agents) |
| .json | 1 | Main system configuration (kilo.json) |
| .jsonc | 1 | Commented system configuration (kilo.jsonc) |
| .js | 2 | Test files and scripts |
| .py | 4 | Python utility scripts |

## Gaps / Needs Investigation
- No additional agent-specific configuration files found outside the trading directory
- Unclear if other agent types (e.g., document, PM, git) have similar YAML configuration files
- The purpose of `kilo.jsonc` vs `kilo.json` needs clarification (likely development vs production)
- No visible schema or documentation for agent configuration format

---
*Generated: 2026-06-01 16:57:08*