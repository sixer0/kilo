---
task_id: upgrade-skills-20260611
architect_slug: upgrade-kilo-skills-agentic-workflow
date: 2026-06-11
agent: task-architect
source_task: C:\Users\sixer\.config\kilo\output\tasks\2026-06-11_upgrade-kilo-skills-agentic-workflow.md
status: pending
---

# Task Architecture: Upgrade Kilo Skills for Agentic Workflows

## Source Request Translation
- **Task File**: `C:\Users\sixer\.config\kilo\output\tasks\2026-06-11_upgrade-kilo-skills-agentic-workflow.md`
- **Original Intent**: Upgrade Kilo's available skills library by researching and implementing new skills focused on agentic workflows, referencing Anthropic's GitHub and other trusted sources.
- **Parsed Scope**: `C:\Users\sixer\.config\kilo\kilo.json`, `C:\Users\sixer\.config\kilo\skills\**\SKILL.md`, and the creation of new skill directories.
- **Identified Constraints**: Source quality (Anthropic, OpenAI, industry standards), structural consistency (existing `SKILL.md` format), and agentic focus (planning, iterative refinement).

## Architecture Challenge & Refinement

### Original Intent Analysis
- **Clarity Assessment**: 4/5. The goal is well-defined, but "agentic workflows" is a broad category that requires decomposition into specific, actionable patterns to avoid generic and ineffective skills.
- **Hidden Assumptions Identified**:
    - Assumption that `SKILL.md` files alone are sufficient. Some agentic workflows might require new backend tools or MCP servers to be truly effective.
    - Assumption that `kilo.json` is the sole registration point, though current configuration shows empty paths, implying auto-discovery in the `skills/` folder.
- **Ambiguity Points Challenged**:
    - What specifically defines an "agentic workflow" for Kilo? (Clarified as: Planning, Reflection, Self-Correction, and Tool-Use Optimization).
    - How to prioritize? (Clarified as: High-impact/Low-complexity first).

### Scope Refinement
- **Explicit In-Scope Items**:
    - Researching agentic patterns from Anthropic, OpenAI, LangChain, and AutoGPT.
    - Auditing the existing 12 skills in `C:\Users\sixer\.config\kilo\skills/` for gaps.
    - Designing high-fidelity `SKILL.md` files following the `agent-md-refactor` template.
    - Implementing the directory structure and registration.
    - Functional verification of skill triggers.
- **Explicit Out-of-Scope Items**:
    - Modifying the core Kilo runtime engine.
    - Creating complex external MCP servers (unless a simple one is required for a specific skill).
- **Boundary Conditions**:
    - New skills must not override or conflict with the global rules defined in `AGENTS.md`.
    - Skill descriptions must be concise enough to avoid excessive token consumption during loading.
- **Edge Cases Identified**:
    - Skill trigger overlap (two skills reacting to the same prompt).
    - circular dependencies between new agentic skills (e.g., a reflection skill that triggers a planning skill that triggers reflection).

### Constraint Enhancement
- **Functional Requirements**:
    - All new skills must be correctly indexed and triggerable via the specified phrases in `## Triggers`.
    - Each skill must follow the 5-phase process structure (Analyze -> Extract -> Categorize -> Structure -> Prune) where applicable.
- **Non-Functional Requirements**:
    - **Maintainability**: Standardized metadata in frontmatter for easy auditing.
    - **Performance**: Skills should be designed to be "lazy-loaded" or minimal in root to save context.
- **Technical Constraints**:
    - Strict adherence to the existing directory structure: `C:\Users\sixer\.config\kilo\skills\{skill-name}\SKILL.md`.
- **Acceptance Criteria**:
    - New skills are present in the `skills/` directory.
    - Skills are triggerable in a live session.
    - Each skill provides a measurable improvement in agentic behavior (e.g., a "Plan-and-Execute" skill results in a structured plan before action).

## Production Blueprint Design

### Detailed Implementation Steps

| Step | Description | Subagent | Expected Output | Dependencies | Verification Needed |
|------|-------------|----------|-----------------|--------------|---------------------|
| 1    | **Research Agentic Patterns**: Deep dive into Anthropic's GitHub, OpenAI cookbooks, and LangGraph/AutoGPT to identify 5-10 high-impact agentic patterns. | `data-collector` | Research report with pattern names, descriptions, and source links. | None | Source credibility check. |
| 2    | **Existing Skill Audit**: Analyze current skills in `\skills\` to identify redundancies or areas where agentic patterns can enhance existing skills. | `data-analyst` | Gap analysis report (Current vs. Target). | Step 1 | No duplication. |
| 3    | **Skill Prioritization & Spec**: Select the top 5 skills to implement. Define the "Trigger" phrases and "Expected Workflow" for each. | `pm-analyst` | Prioritized Implementation Roadmap & Specifications. | Step 2 | Alignment with user intent. |
| 4    | **Skill Design (`SKILL.md`)**: Draft high-fidelity `SKILL.md` files for the prioritized skills, following the `agent-md-refactor` format. | `document-writer` | Draft `SKILL.md` files for each selected skill. | Step 3 | Structural consistency check. |
| 5    | **Physical Implementation**: Create directories and write `SKILL.md` files to `C:\Users\sixer\.config\kilo\skills/`. Update `kilo.json` if necessary. | `coder-execution` | New skill directories and files physically present. | Step 4 | File path verification. |
| 6    | **Registration Verification**: Verify that the system recognizes the new skills (check logs or use a discovery command). | `verifier` | Verification report confirming skills are loaded. | Step 5 | Load success logs. |
| 7    | **Functional UAT**: Simulate user prompts that should trigger the new skills and verify the agent follows the new agentic workflow. | `demo-tester-agent` | UAT report with "Pass/Fail" for each skill trigger. | Step 6 | Workflow adherence check. |
| 8    | **Final Commit**: Commit all new skills and config changes to the repository. | `git-specialist` | Git commit hash and summary of changes. | Step 7 | Commit message quality. |

### Subagent Assignment Justification
- **`data-collector`**: Best for broad web/repo research across multiple external sources.
- **`data-analyst`**: Specialized in comparing data sets (current skills vs. desired patterns).
- **`pm-analyst`**: Necessary for prioritizing based on "impact vs. complexity" and defining clear specs.
- **`document-writer`**: Optimized for creating structured markdown documentation like `SKILL.md`.
- **`coder-execution`**: The most reliable agent for creating files and modifying JSON configurations.
- **`verifier`**: Focuses on technical correctness and "does it load" checks.
- **`demo-tester-agent`**: Specialized in simulating user flows to verify the actual *behavior* of the agent.
- **`git-specialist`**: Ensures the changes are committed according to project standards.

## Subagent Selection Guide
(Standard guide as per system instructions)

### Verification & Testing Strategy
- **Unit Testing**: Verification of `SKILL.md` frontmatter syntax and directory structure.
- **Integration Testing**: Ensuring the new skills don't cause trigger collisions with existing skills.
- **Security Testing**: Checking that new skills don't encourage the agent to bypass safety guards or execute dangerous commands.
- **Performance Testing**: Measuring the impact of new skill instructions on the prompt's context window.
- **Code Quality**: Linting the markdown for consistency and broken links.

### Risk Assessment & Mitigation
- **Technical Risk**: Trigger Overlap. If "Plan this task" triggers both a new "Planning" skill and a general "Project Management" skill.
- **Mitigation**: Create a "Trigger Matrix" during Step 3 to ensure phrases are unique and mutually exclusive.
- **Dependency Risk**: Reliance on external GitHub repos that might change.
- **Mitigation**: Archive the researched patterns in a local `memory/refs/agentic-patterns.md` file.

### Production Readiness Checklist
- [ ] Research based on top-tier sources (Anthropic/OpenAI).
- [ ] No overlap with existing 12 skills.
- [ ] `SKILL.md` files strictly follow the required structure.
- [ ] All skills are physically present in the correct directory.
- [ ] `kilo.json` updated if registration is required.
- [ ] Every skill has been triggered successfully in a test session.
- [ ] No regression in existing skill triggers.
- [ ] Changes committed to git.

## Implementation Guidelines
### Coding Standards to Follow
- **Markdown**: Use GitHub Flavored Markdown.
- **Naming**: Use `kebab-case` for skill directories (e.g., `plan-and-execute`).
- **Frontmatter**: Always include `name`, `description`, `license`, and `metadata`.
- **Structure**: Always include `## Triggers`, `## Process`, and `## Verification`.

### Files to be Created/Modified
| File Path | Purpose | Complexity | Risk Level |
|-----------|---------|------------|------------|
| `C:\Users\sixer\.config\kilo\skills\{skill-name}\SKILL.md` | New Skill Definition | Medium | Low |
| `C:\Users\sixer\.config\kilo\kilo.json` | Skill Registration | Low | Medium |
| `memory/refs/agentic-patterns.md` | Research Archive | Low | Low |

### Deployment & Operations Considerations
- **Observability**: Use logs to track which skills are being triggered most frequently to refine them.
- **Rollback**: Since these are just files, rollback is a simple `git revert`.

## Notes
- Focus heavily on the "Reflection" and "Planning" patterns as they provide the most immediate value for agentic workflows.
- Ensure the `document-writer` uses the `agent-md-refactor` skill as a template for the new `SKILL.md` files to ensure perfect consistency.

---
*Generated: 2026-06-11 23:25*
*Last Updated: 2026-06-11 23:25*
