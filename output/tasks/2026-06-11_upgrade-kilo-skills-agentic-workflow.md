---
task_id: upgrade-skills-20260611
task_slug: upgrade-kilo-skills-agentic-workflow
date: 2026-06-11
agent: request-translator
intent: Upgrade Kilo's available skills library by researching and implementing new skills focused on agentic workflows, referencing Anthropic's GitHub and other trusted sources.
status: pending
---

# Task: Upgrade Kilo Skills for Agentic Workflows

## Original User Request
"hey kilo, bisakah kamu mengupgrade daftar skill kamu. kamu bisa ambil referensi skill di github anthropic atau sumber terpercaya lain terutama yang menyediakan skill untuk agentic workflow"

## Intent
The user wants to expand Kilo's capabilities by adding new "skills". Specifically, the focus is on "agentic workflows"—patterns and tools that allow an agent to plan, reason, execute, and self-correct more effectively. The user points to Anthropic's GitHub as a primary reference.

## Primary Task
Research, design, and implement a set of new skills for Kilo that enhance its agentic workflow capabilities.

## Structured Tasks
| Step | Task | Expected Output |
|------|------|-----------------|
| 1    | Research agentic workflow patterns and skills from Anthropic's GitHub and other trusted sources (e.g., LangChain, AutoGPT, OpenAI cookbooks). | A list of identified potential skills with descriptions and reference links. |
| 2    | Audit current Kilo skills to identify gaps and ensure no redundancy. | Gap analysis report. |
| 3    | Select and prioritize the most impactful skills for implementation. | Final list of skills to be added. |
| 4    | Design and write `SKILL.md` files for each new skill, following the existing Kilo skill structure. | Set of `SKILL.md` files. |
| 5    | Create the corresponding directory structure in `C:\Users\sixer\.config\kilo\skills/`. | Physical skill directories and files. |
| 6    | Update `kilo.json` or relevant configuration files to register the new skills. | Updated configuration. |
| 7    | Verify that the new skills are correctly loaded and recognized by the system. | Verification report/logs. |

## Scope
- **Files**: `C:\Users\sixer\.config\kilo\kilo.json`, `C:\Users\sixer\.config\kilo\skills\**\SKILL.md`
- **Folders**: `C:\Users\sixer\.config\kilo\skills/`

## Constraints
- **Source Quality**: Only use reputable sources (Anthropic, OpenAI, industry-standard agent frameworks).
- **Structural Consistency**: New skills must strictly adhere to the existing `SKILL.md` format and directory structure.
- **Agentic Focus**: Prioritize skills that enable autonomous planning, iterative refinement, and complex tool orchestration.

## Dependencies
- Requires understanding of the current skill loading mechanism (likely defined in `kilo.json` or the core system).

## Notes
- "Agentic workflows" often include patterns like "Plan-and-Execute", "Self-Reflection", "Tool-Use Optimization", and "Multi-Agent Orchestration".
- The implementation should be iterative; high-impact, low-complexity skills should be added first.

---
*Generated: 2026-06-11 23:15*
*Last Updated: 2026-06-11 23:15*
