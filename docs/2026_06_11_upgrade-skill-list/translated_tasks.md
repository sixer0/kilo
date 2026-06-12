---
task_id: upgrade-skill-list-anthropic-references
date: 2026-06-11
status: translated
---

# Translated Task: Upgrade Skill List Anthropic References

## Intent
Upgrade Kilo's skill list with new skills from Anthropic GitHub and other trusted sources, focusing on agentic workflow skills.

## Goals
- Research and identify high-value skills from Anthropic GitHub and other trusted agentic workflow sources.
- Evaluate the relevance of these skills to Kilo's master controller workflow.
- Integrate new skills into the `kilo.json` configuration.
- Validate that new skills adhere to Kilo's format and standards.

## Scope
- **In-Scope**: 
    - Research of Anthropic GitHub and other agentic workflow repos.
    - Selection of skills compatible with Kilo's architecture.
    - Modification of `kilo.json`.
    - Creation of skill definitions in the configuration.
- **Out-of-Scope**: 
    - Full implementation of complex custom tool logic if it requires engine changes.
    - Modifying the core engine of Kilo.

## Constraints
- New skills must follow the existing Kilo skill format.
- Must be sourced from trusted providers (Anthropic, etc.).
- Integration must not break existing skills.

## Current Skills
- agent-md-refactor
- canvas-design
- content-research-writer
- image-enhancer
- kilo-config
