---
task_id: upgrade-skill-list-anthropic-references
task_slug: upgrade-skill-list-anthropic-references
date: 2026-06-11
agent: task-architect
source_translated_task: docs\2026_06_11_upgrade-skill-list\translated_tasks.md
source_original_task: docs\2026_06_11_upgrade-skill-list\original_tasks.md
status: pending
---

# Structured Tasks: Upgrade Skill List Anthropic References

## Source Translation

- **Translated Task**: docs\2026_06_11_upgrade-skill-list\translated_tasks.md
- **Original Intent**: Upgrade Kilo's skill list with new skills from Anthropic GitHub and other trusted sources, focusing on agentic workflow skills.
- **Goals**: 
    - Research and identify high-value skills from Anthropic GitHub and other trusted agentic workflow sources.
    - Evaluate the relevance of these skills to Kilo's master controller workflow.
    - Integrate new skills into the `kilo.json` configuration.
    - Validate that new skills adhere to Kilo's format and standards.
- **Parsed Scope**: 
    - In-Scope: Research, Selection, `kilo.json` modification, Skill directory creation.
    - Out-of-Scope: Modifying Kilo core engine, implementing external tool logic if not already available.
- **Identified Constraints**: Must follow Kilo skill format, use trusted sources, and maintain config integrity.

## Architecture Challenge & Refinement

### Original Intent Analysis
- **Clarity Assessment**: 4/5. The goal is clear, but "skills" in the context of Anthropic (which uses Tool Use/Computer Use) differs from Kilo's "Skills" (which are system prompts/workflows).
- **Hidden Assumptions Identified**: 
    - Assumes Anthropic has a structured "skill list" similar to Kilo's. In reality, we are looking for *agentic patterns* and *system prompts* that can be converted into Kilo Skills.
    - Assumes adding to the list includes creating the necessary metadata and file structure.
- **Ambiguity Points Challenged**: Resolved "upgrade daftar skill" as: Research $\rightarrow$ Select $\rightarrow$ Configure $\rightarrow$ Verify.

### Scope Refinement
- **Explicit In-Scope Items**: 
    - Identification of "Agentic Workflows" (e.g., Planning, Self-Correction, Tool-Chain optimization).
    - Mapping these to Kilo's `.kilo/skills/` structure.
    - Updating `kilo.json` for system visibility.
- **Explicit Out-of-Scope Items**: 
    - Implementing new low-level tools/functions (Kilo's tools are provided by the environment/skills).
- **Boundary Conditions**: New skills must reside in `.kilo/skills/` and be referenced in `kilo.json`.
- **Edge Cases Identified**: 
    - Skills requiring non-existent tools (these should be noted as "requires [Tool X]" in the `SKILL.md`).
    - Redundant skills overlapping with existing ones.

### Constraint Enhancement
- **Functional Requirements**: New skills must be discoverable via the skill loader.
- **Non-Functional Requirements**: `kilo.json` must remain valid JSON; folder names must be `snake_case`.
- **Technical Constraints**: Must align with Kilo's skill loading mechanism (searching `.kilo/skills/`).
- **Acceptance Criteria**: 
    - 3-5 new high-value agentic skills integrated.
    - `kilo.json` updated and verified.
    - Corresponding `SKILL.md` files created.

## Structured Task Breakdown

| Step | Task Description | Agent_to_Invoke | Expected Output | Depends On | Verification | Phase |
|------|------------------|-----------------|-----------------|------------|--------------|-------|
| 1    | Research Anthropic GitHub, CLAUDE.md examples, and other trusted agentic workflow sources for skill patterns. | `data-collector` | Research report listing potential skills and their sources. | - | Report contains at least 5 viable agentic workflow patterns. | discovery |
| 2    | Analyze researched patterns and select those most compatible and beneficial for Kilo's Master Controller. | `data-analyst` | Selection list with justification and a high-level description of each selected skill. | 1 | Selection is technically feasible within Kilo's architecture. | analysis |
| 3    | Define the configuration metadata for selected skills (names, slugs, descriptions, and paths). | `data-analyst` | Draft of `kilo.json` additions and a list of proposed folder names. | 2 | Metadata adheres to the Kilo config schema. | analysis |
| 4    | Create skill directories in `.kilo/skills/` and write initial `SKILL.md` files based on the research. | `coder-execution` | New folders and `SKILL.md` files in `.kilo/skills/`. | 3 | Files exist and follow the prescribed format. | execution |
| 5    | Update `kilo.json` to include the new skills in the `available_skills` section. | `coder-execution` | Updated `kilo.json`. | 4 | `kilo.json` is syntactically correct. | execution |
| 6    | Verify that the new skills are recognized by the system and accessible. | `verifier` | Verification report. | 5 | All new skills are listed in the system's available skills. | verification |

## Dependencies

- `kilo.json` must be accessible and editable.
- `.kilo/skills/` directory must be available.

## Verification & Testing Strategy

- **Unit Testing**: `verifier` will check the JSON syntax of `kilo.json`.
- **Integration Testing**: `verifier` will ensure that every entry in `kilo.json` has a corresponding folder and `SKILL.md` in `.kilo/skills/`.
- **Security Testing**: `security-review` will scan the researched patterns to ensure no prompt-injection vulnerabilities are introduced into the system prompts.
- **Acceptance Criteria**: The system successfully recognizes and loads the new skills without error.

## Risk Assessment

- **Technical Risks**: Incorrect `kilo.json` formatting could crash the agent loader.
- **Mitigation Strategies**: Use a JSON validator before committing changes.
- **Assumptions & Caveats**: Assumes the current `kilo.json` is the source of truth for available skills.

## Agent Mapping Rationale

- **`data-collector`**: Best for web research and gathering raw data from GitHub/External sources.
- **`data-analyst`**: Required to filter raw data into a technical selection and design the config.
- **`coder-execution`**: Required for file system operations and JSON modification.
- **`verifier`**: Required for final validation and regression check of the config.

---
*Generated: 2026-06-11 23:45*
*Last Updated: 2026-06-11 23:45*
