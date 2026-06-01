# Historical Implementation Patterns and Configuration Examples for Kilo Agents and Sub-Agents

## Overview
This document summarizes historical implementation patterns, configuration choices, and lessons learned from memory records related to Kilo agents and sub-agents.

## Key Implementation Patterns

### 1. Agent Configuration Pattern
All Kilo agents follow a standardized YAML frontmatter format:
```yaml
---
name: [agent-name]
description: [agent description]
hidden: [true/false]  # Whether to hide from agent listings
mode: [subagent/primary]  # Execution mode
steps: [number]  # Maximum steps allowed (for primary agents)
color: [hex-color]  # UI color representation
---
```

Examples from memory:
- `explore.md`: name: explore, mode: subagent, hidden: true
- `master-controller.md`: name: master-controller, mode: primary, steps: 75, color: "#10B981"

### 2. Provider Pattern for Reusability
From the AI Agent Preview backend modularization (2026-05-19):
- Abstracted infrastructure (Runtime, Storage, Auth) behind interfaces
- Enables easy switching between providers (e.g., OpenClaw to KiloClaw)
- Allows service to remain environment-agnostic

### 3. Hybrid Authentication Flow
Implemented in AI Agent Preview (2026-05-19):
- Middleware that prioritizes API keys over JWTs
- Seamless integration for both human users (web) and service-to-service calls (VPS/Kiloclaw)
- Pattern: Check for API key first, fall back to JWT validation

### 4. Design System Implementation
From UI/UX redesign efforts:
- Dark-mode-first RGB tokens approach
- Semantic Tailwind colors (using `bg-color-foreground` / `text-color-muted`)
- Reusable component library (Button, Input, Badge, Modal, Card, Table, Alert)
- PostCSS config requirement: `postcss.config.js` with `plugins: { tailwindcss: {}, autoprefixer: {} }`

### 5. Testing and Reliability Patterns
- Puppeteer UAT reliability: Always `await page.waitForSelector(selector)` before `page.click()`
- Port verification before automation: Use `Get-NetTCPConnection -State Listen`
- Elimination strategy for hardcoded values: Migrate component-by-component, then repo-wide grep

## Configuration Examples

### 1. PostCSS Configuration (Tailwind 4)
From memory/2026-05-18.md:
```javascript
// postcss.config.js
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

### 2. Package.json Dependencies
From memory/2026-05-18.md:
```json
{
  "dependencies": {
    "jquery": "^3.6.0",
    "sweetalert2": "^11.0.0",
    "jspdf": "^2.5.0"
  }
}
```

### 3. Vite Configuration Reference
From memory/2026-05-18.md:
- jsPDF in Vite: Use `npm install jspdf` (avoid CDN UMD version)
- jQuery in React/Vite: Install via npm (`npm install jquery`), do NOT use CDN

### 4. Memory Architecture Pattern
From AGENTS.md and MEMORY.md:
- **Index**: `MEMORY.md` - Single entry point with summary + links to refs/tasks
- **Detail Storage**: `memory/refs/` - Lazy-loaded technical details
- **Task Reports**: `memory/tasks/` - Final reports + compaction snapshots
- **Daily Logs**: `memory/YYYY-MM-DD.md` - Activity chronology for reminders

### 5. Agent Delegation Pattern
From master-controller.md:
```javascript
Task(subagent_type="[agent-name]", prompt="
Task: [what needs to be done]
Target: [files or scope]
Command: [workflow name like /explore, /security]
Expected: [what result format]
")
```

### 6. Provider Configuration (YAML)
From provider-config.yaml:
```yaml
providers:
  ollama:
    enabled: true
    type: "local"
    baseURL: "http://localhost:11434"
    model: "qwen3.5:4b"
    parameters:
      temperature: 0.7
      top_p: 0.9
      max_tokens: 4096
      top_k: 40
```

## Lessons Learned

### From AI Agent Preview (2026-05-18 to 2026-05-19):
1. **PostCSS config is required**: Tailwind 4 needs explicit configuration
2. **Verify ports before automation**: Critical for reliable testing
3. **jQuery in React/Vite**: Must install via npm, avoid CDN to prevent duplicates
4. **jsPDF in Vite**: Use npm install, avoid CDN UMD version conflicts
5. **Puppeteer UAT reliability**: Explicit waits required for reliable tests
6. **Hex color elimination**: Migrate in batches, then repo-wide sweep
7. **Sequelize Class Fields Shadowing**: Use `declare` keyword in TS models
8. **Provider Pattern**: Enables environment-agnostic services
9. **Hybrid Auth Flow**: API key priority over JWT for dual-use scenarios

### From Certification Marketplace (Earlier session):
1. **Semantic Tailwind colors**: Ensure branding consistency
2. **Line ending handling**: Git config `core.autocrlf` on Windows
3. **React-native-style interactions**: Avoid DOM conflicts in SSR projects
4. **Role-aware navigation**: Improves UX by context-aware route visibility
5. **Global memory updates**: Track progress across sessions/devices

## Memory Management Patterns

### Memory Workflow:
1. **Capture**: Raw findings → `memory/YYYY-MM-DD.md`
2. **Distill**: High-value insights → `MEMORY.md` (index)
3. **Reference**: Complex details → `memory/refs/<slug>.md`
4. **Report**: Task completion → `memory/tasks/YYYY-MM-DD-<slug>.md`
5. **Correct**: Document mistakes to prevent recurrence
6. **Remind**: Review 3-7 day logs for proactive user reminders

### Memory Maintenance (Heartbeats):
- Periodic review of recent logs for significant insights
- Update MEMORY.md with distilled knowledge
- Move lengthy details to refs/
- Remove outdated information from MEMORY.md
- Scan for reminder-worthy items (commitments, pending tasks, ideas)

## Agent-Specific Patterns

### Explore Agent:
- Focuses on structure ONLY (no code logic analysis)
- Reports specific paths, not general descriptions
- Persists findings to output files with NEW/EXISTING markers
- Follows strict output format conventions

### Master Controller Agent:
- Orchestration-only: Receives requests, delegates via Task(), coordinates results
- Strict penalty system for rule violations
- Mandatory user approval workflow before execution
- Context management with compaction at 160,000 tokens
- Detailed subagent delegation with paid-first/free-fallback system

## Configuration File Locations
- Agent definitions: `~/.config/kilo/agent/*.md`
- Command definitions: `~/.config/kilo/command/*.md`
- Skills: `~/.config/kilo/skills/`
- Memory system: `~/.config/kilo/memory/`
- Output directory: `~/.config/kilo/output/`
- Configuration files: `kilo.json`, `provider-config.yaml`, `AGENTS.md`, `SOUL.md`, `MEMORY.md`
