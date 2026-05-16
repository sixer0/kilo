---
task: explore-openclaw-directory
date: 2026-05-16
agent: explore
scope: Full recursive exploration of C:\Users\sixer\.openclaw\
---

# Project Exploration Report: .openclaw Directory

## Overview

Exploration of `C:\Users\sixer\.openclaw\` - the OpenClaw AI agent configuration and data directory.

## Directory Structure

### Top-Level Directories
| Path | Purpose | Status |
|------|---------|--------|
| agents/ | Agent configurations and session data | NEW |
| canvas/ | Browser automation test page | NEW |
| completions/ | Shell completion scripts | NEW |
| credentials/ | (empty) | NEW |
| devices/ | Paired device information | NEW |
| flows/ | SQLite registry for flows | NEW |
| identity/ | Device identity keys | NEW |
| logs/ | Configuration audit and health logs | NEW |
| memory/ | Agent memory database | NEW |
| npm/ | NPM dependencies for plugins | NEW |
| plugin-skills/ | Plugin skill definitions | NEW |
| plugins/ | Plugin configuration | NEW |
| tasks/ | Task registry SQLite | NEW |
| tools/ | Node.js tools including npm | NEW |
| tui/ | Terminal UI session data | NEW |
| workspace/ | Agent workspace files | NEW |

### Root-Level Files
| File | Size | Description |
|------|------|-------------|
| openclaw.json | 6,133 bytes | Main configuration file |
| openclaw.json.last-good | 6,133 bytes | Last known good config |
| openclaw.json.bak | 6,132 bytes | Backup of config |
| openclaw.json.bak.1-4 | ~2.9 KB each | Historical config backups |
| openclaw.json.clobbered.2026-05-12T04-07-43-937Z | 5,545 bytes | Clobbered config backup |
| openclaw.json.pre-update | 6,132 bytes | Pre-update config |
| update-check.json | 189 bytes | Last update check info |
| gateway.cmd | 481 bytes | Windows batch script to run gateway |
| gateway-restart-intent.json | 64 bytes | Gateway restart metadata |
| exec-approvals.json | 182 bytes | Execution approval socket config |

## Key Files and Their Contents

### workspace/.openclaw/workspace-state.json
```json
{
  "version": 1,
  "bootstrapSeededAt": "2026-05-12T02:10:33.245Z"
}
```

### openclaw.json (Main Configuration)
Primary configuration with:
- **Default agent settings**: Model `ollama/gemma4`, workspace path
- **Gateway settings**: Port 18789, loopback binding, token `a95edd389656547bb01ded4b2ede492a389d863e64609fbd`
- **Google API key** configured in plugins section
- **Skills configuration**: All skills disabled except google, kilocode, ollama
- **Model providers**: kilocode (api.kilo.ai) and ollama (local at 127.0.0.1:11434)

### workspace/AGENTS.md
Agent workspace instructions including:
- Bootstrap process documentation
- Memory system (daily notes, MEMORY.md)
- Heartbeat guidelines for periodic tasks
- Group chat behavior guidelines
- Tools documentation reference

### workspace/SOUL.md
Agent personality configuration:
- Core truths about being helpful, having opinions
- Boundaries for privacy and external actions
- Vibe guidance for personality

### workspace/USER.md
Template for human user information (currently empty)

### workspace/TOOLS.md
Template for local tool configuration notes

### workspace/BOOTSTRAP.md
First-run bootstrap documentation

### workspace/HEARTBEAT.md
Commented instructions for heartbeat tasks

### devices/paired.json
Contains one paired device (openclaw-control-ui) with operator scopes

### identity/device.json
Device identity with:
- Device ID: `d3dadd657da198f10b12f857cd37a3500ae4b801ca4d63b683dfdbfb017977d2`
- Public/private key pair (Ed25519)

### plugins/installs.json
Plugin registry with:
- **Installed**: whatsapp plugin (v2026.5.12)
- **Bundled plugins**: 70+ plugins (anthropic, google, ollama, kilocode, etc.)
- Most plugins enabled by default: alibaba, anthropic, arcee, azure-speech, byteplus, canvas, cerebras, chutes, copilot-proxy, deepgram, deepinfra, deepseek, device-pair, document-extract, elevenlabs, fal, fireworks, github-copilot, google, groq, huggingface, inworld, kilocode, kimi-coding, etc.

### agents/main/ Directory Structure
```
agents/main/
├── agent/
│   ├── models.json         # Provider configurations
│   ├── auth-state.json     # Auth usage stats
│   └── auth-profiles.json  # (not read)
└── sessions/
    ├── sessions.json       # Session metadata
    ├── *.jsonl             # Session transcripts
    └── *.trajectory.jsonl  # Session trajectories
```

### tui/last-session.json
Session tracking with two session keys and timestamps.

### canvas/index.html
Interactive test page with buttons for Hello, Time, Photo, Dalek actions - used for browser automation testing.

### completions/
Shell completion scripts for bash, fish, powershell, and zsh with 40+ commands.

### npm/package.json
Dependencies: `@openclaw/whatsapp`, `jimp`, `keyv`, `sharp`, `audio-decode`

## File Type Summary

| Extension | Count | Purpose |
|-----------|-------|---------|
| .json | ~15 | Configuration and state files |
| .jsonl | 4+ | Session logs |
| .sqlite | 2 | Task and flow registries |
| .html | 1 | Canvas test page |
| .ps1 | 1 | PowerShell completion |
| .cmd | 1 | Gateway batch script |
| .md | 6 | Workspace documentation |

## Gaps / Needs Investigation
- credentials/ directory is empty
- No memory/YYYY-MM-DD.md files exist yet (fresh workspace)
- MEMORY.md not present in workspace
- .git/hooks samples exist but no custom hooks