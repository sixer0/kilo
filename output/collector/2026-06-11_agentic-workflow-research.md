---
task: upgrade-skills-20260611
date: 2026-06-11
agent: data-collector
items_collected: 21
last_updated: 2026-06-11 23:45
---

# Data Collection Report

## Task Overview
Research agentic workflow patterns and specific skills from Anthropic GitHub, Claude Code docs, LangChain/LangGraph, AutoGPT, and OpenAI Agents SDK sources for Kilo skill upgrades focused on agentic workflows.

Reference files read before collection:
- `C:\Users\sixer\.config\kilo\output\tasks\2026-06-11_upgrade-kilo-skills-agentic-workflow.md`
- `C:\Users\sixer\.config\kilo\output\plans\2026-06-11_architect-upgrade-kilo-skills-agentic-workflow.md`

## Files Collected

### Source Files
| File | Purpose | Lines |
|------|---------|------:|
| `C:\Users\sixer\.config\kilo\output\tasks\2026-06-11_upgrade-kilo-skills-agentic-workflow.md` | Original translated task, scope, constraints, structured tasks | 50 |
| `C:\Users\sixer\.config\kilo\output\plans\2026-06-11_architect-upgrade-kilo-skills-agentic-workflow.md` | Architecture plan and implementation blueprint | 135 |
| `C:\Users\sixer\.config\kilo\kilo.json` | Current Kilo config; `skills.paths` is empty, implying auto-discovery from `skills/` | 16 |
| `C:\Users\sixer\.config\kilo\skills\agent-md-refactor\SKILL.md` | Existing Kilo skill structure sample | 296 |
| `C:\Users\sixer\.config\kilo\skills\content-research-writer\SKILL.md` | Existing Kilo skill structure sample | 547 |

### External Documentation and GitHub Sources
| Source | Type | Relevance |
|--------|------|-----------|
| Anthropic, “Building effective agents” | Research article | Core patterns: prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer, agents, tool prompt engineering |
| Claude Code docs, “Extend Claude with skills” | Product docs | Claude Code skill structure, frontmatter, invocation control, dynamic context, subagent execution, skill lifecycle |
| `anthropics/skills` README | GitHub repo | Anthropic’s public skills implementation; Agent Skills standard; folder + `SKILL.md` model |
| `anthropics/claude-cookbooks/claude_agent_sdk/README.md` | GitHub cookbook | Claude Agent SDK agent-building tutorial: plan mode, hooks, subagents, MCP, memory/context, error recovery |
| `anthropics/skills/skills/skill-creator/SKILL.md` | GitHub skill | Skill creation/evaluation loop, baseline comparisons, benchmark viewer, trigger-description optimization |
| `anthropics/skills/skills/mcp-builder/SKILL.md` | GitHub skill | MCP/tool design, implementation, review/test, evaluation questions |
| `anthropics/skills/skills/claude-api/shared/agent-design.md` | GitHub skill | Agent design heuristics: tool surfaces, PTC, tool search, skills, context editing, compaction, memory |
| Claude Code docs, “Commands” | Product docs | Bundled skills/workflows: `/batch`, `/code-review`, `/debug`, `/loop`, `/run`, `/verify`, `/plan`, `/agents`, `/fork` |
| `anthropics/claude-code/plugins/code-review/commands/code-review.md` | GitHub command/skill | Multi-agent code review, confidence scoring, high-signal issue filtering |
| LangChain, “Plan-and-Execute Agents” | Blog/docs | Planner, executors, replanning, ReWOO, LLMCompiler DAG planning |
| LangChain, “Reflection Agents” | Blog/docs | Basic reflection, Reflexion, LATS, reflection/evaluation/search |
| LangGraph docs, “Thinking in LangGraph” | Docs | Nodes/state/errors/retries/interrupts/error handlers/checkpoint tradeoffs |
| LangGraph docs, “Workflows and agents” | Docs | Prompt chaining, parallelization, routing, orchestrator-worker, evaluator-optimizer, ToolNode |
| AutoGPT docs, “Data Flow & Execution” | Docs | Block-based workflow execution, data dependencies, error pins, fallback routing |
| AutoGPT docs, “Agent Builder Guide” | Docs | Input/action/output blocks, typed pins, incremental testing, error handling |
| AutoGPT docs, “Agent Generation Guide” | Docs | Decompose goal, validate graph, dry-run, fix loop, orchestrator iteration caps |
| OpenAI Agents SDK, “Orchestration and handoffs” | Docs | Agents-as-tools vs handoffs, specialist ownership, eval/iteration guidance |
| OpenAI Agents SDK, “Guardrails” | Docs | Input/output/tool guardrails, tool-level validation before/after execution |

## Current Kilo Skill Context

Existing skill directories found:
- `pdf`
- `pptx`
- `xlsx`
- `docx`
- `image-enhancer`
- `content-research-writer`
- `canvas-design`
- `agent-md-refactor`

Observed gap from current inventory:
- No existing Kilo skill is explicitly focused on agentic workflow patterns such as planning, reflection, tool-use optimization, self-healing, orchestration, or eval-driven improvement.
- Current `kilo.json` has `"skills": { "paths": [] }`; implementation should preserve existing config unless discovery is not working.

## High-Impact Agentic Workflow Skill Candidates

### 1. Planning / Task Decomposition

| Candidate Kilo skill | Pattern / capability | Source references | Suggested trigger phrases |
|----------------------|----------------------|-------------------|---------------------------|
| `plan-and-execute` | Break a complex request into a staged plan, dependency graph, checkpoints, and execution steps. Use explicit re-planning after each major phase. | Anthropic “Building effective agents” — orchestrator-workers, planning transparency; LangChain “Plan-and-Execute Agents” — planner + executors + replanning; Claude Code `/plan` docs | “make a plan”, “break this down”, “plan and execute”, “task decomposition”, “create implementation plan” |
| `exec-plan-writer` | Write a self-contained execution plan with scope, assumptions, decision log, progress, test plan, and observable completion criteria. | OpenAI Codex `ExecPlan` cookbook; Anthropic Claude Agent SDK chief-of-staff plan mode; Anthropic Building Effective Agents — transparency | “write an exec plan”, “create an execution plan”, “plan this feature”, “document the implementation plan” |
| `orchestrator-worker` | Orchestrate unknown/variable subtasks by delegating to specialized subagents or workers, then synthesize results. | Anthropic Building Effective Agents — orchestrator-workers; LangGraph “Workflows and agents” — `Send` API / worker nodes; OpenAI Agents SDK — agents-as-tools and handoffs | “delegate this”, “use subagents”, “coordinate workers”, “split this across specialists”, “orchestrate the work” |
| `batch-workflow` | Decompose large codebase changes into independent units, run units in isolated contexts/worktrees, and merge results. | Claude Code `/batch` docs; LangGraph parallelization; OpenAI orchestration docs | “batch change”, “large codebase change”, “parallel worktrees”, “split into independent units” |

### 2. Reflection / Self-Critique

| Candidate Kilo skill | Pattern / capability | Source references | Suggested trigger phrases |
|----------------------|----------------------|-------------------|---------------------------|
| `reflection-loop` | Generate → critique → revise loop. Require evidence-based critique, explicit success criteria, and bounded iterations. | LangChain “Reflection Agents” — generator/reflector, Reflexion, LATS; Anthropic Building Effective Agents — evaluator-optimizer; OpenAI Agents SDK orchestration — introspect and improve | “review your answer”, “critique this”, “reflect and improve”, “self-review”, “iterate until it passes” |
| `confidence-review` | Run parallel review agents with confidence scoring and high-signal filtering to reduce false positives. | Anthropic Claude Code code-review command; LangChain Reflection Agents; Anthropic Building Effective Agents — parallelization/voting | “high-confidence review”, “confidence-scored review”, “multi-agent review”, “filter false positives” |
| `eval-driven-improver` | Create eval prompts/assertions, run with/without skill or old/new versions, grade outputs, and iterate. | Anthropic `skill-creator` skill; OpenAI Cookbook HALO / agent improvement loop; Anthropic Building Effective Agents — measure and iterate | “test this skill”, “create evals”, “benchmark this workflow”, “improve based on evals” |
| `decision-log-review` | Maintain decision logs, detect repeated failures, and force class-level fixes instead of instance-by-instance patching. | Anthropic Claude Code issue patterns around repeated external review; LangGraph state persistence; Anthropic Building Effective Agents — transparency | “why did this fail repeatedly”, “decision log”, “review failure pattern”, “class-level fix” |

### 3. Tool-Use Optimization

| Candidate Kilo skill | Pattern / capability | Source references | Suggested trigger phrases |
|----------------------|----------------------|-------------------|---------------------------|
| `tool-design-optimizer` | Improve tool names, schemas, descriptions, examples, error messages, and poka-yoke constraints. | Anthropic Building Effective Agents — ACI/tool prompt engineering; Anthropic `mcp-builder`; Anthropic `agent-design` — Bash vs dedicated tools | “improve tools”, “tool schema”, “MCP tool design”, “make this tool easier to use” |
| `programmatic-tool-calling` | Use scripts to compose many tool calls, filter large intermediate results, and return only final summaries to the agent context. | Anthropic `agent-design` — programmatic tool calling; Anthropic PTC cookbook; Claude Agent SDK Bash tool integration | “reduce tool calls”, “script this workflow”, “programmatic tool calling”, “batch these calls” |
| `context-engineering` | Manage long-running agent context with memory, compaction, tool-result clearing, subagents, and focused state. | Anthropic `agent-design`; Anthropic context engineering cookbook; Claude Code skills lifecycle docs | “context is too long”, “manage context”, “long-running agent”, “memory and compaction” |
| `mcp-integration` | Add or configure MCP servers, tool allowlists, auth, tool schemas, and workflow tools. | Anthropic `mcp-builder`; Claude Agent SDK notebook 02/03; Claude Code `/mcp`; Anthropic plugin-dev `mcp-integration` | “add MCP”, “connect external API”, “Model Context Protocol”, “create MCP server” |
| `guardrail-hook-design` | Add deterministic PreToolUse/PostToolUse/Stop hooks for validation, policy, context injection, and completion standards. | Claude Code hooks docs; Anthropic plugin-dev `hook-development`; OpenAI Agents SDK guardrails | “add hook”, “validate tool use”, “block dangerous command”, “PostToolUse hook” |

### 4. Error Recovery / Self-Healing

| Candidate Kilo skill | Pattern / capability | Source references | Suggested trigger phrases |
|----------------------|----------------------|-------------------|---------------------------|
| `self-healing-loop` | Classify failures into transient, LLM-recoverable, user-fixable, retry-exhausted, and unexpected; route each to retry, compensation, interrupt, or stop. | LangGraph “Thinking in LangGraph” — error handling table; AutoGPT “Data Flow & Execution” — error pins and fallback behavior; Anthropic Building Effective Agents — ground truth and stopping conditions | “fix the failure”, “recover from error”, “self-heal”, “retry strategy”, “handle this error” |
| `dry-run-verify-fix` | Validate before shipping: dry-run realistic paths, inspect errors, fix, repeat, and cap iterations. | AutoGPT Agent Generation Guide — create → dry-run → fix loop; AutoGPT Agent Builder Guide — test incrementally; Claude Code `/verify` docs | “dry run”, “verify before finish”, “fix failing tests”, “validate this workflow” |
| `checkpoint-resume` | Persist workflow state, checkpoints, progress, and resume summaries so long tasks can restart without losing context. | LangGraph persistence/checkpointing; Claude Code skills lifecycle; Anthropic Claude Agent SDK memory/context; AutoGPT stateful workflows | “resume this”, “checkpoint”, “recover after interruption”, “stateful workflow” |
| `autofix-pr` | Watch CI/review failures, diagnose root cause, apply minimal fixes, re-run verification, and stop after bounded retries. | Claude Code `/autofix-pr` docs; Anthropic Claude Code code-review; LangGraph error handlers; AutoGPT dry-run/fix loop | “fix CI”, “autofix PR”, “recover from failing tests”, “fix review comments” |

## Additional High-Impact Skills Worth Considering

| Candidate Kilo skill | Why it matters | Source references |
|----------------------|----------------|-------------------|
| `subagent-manager` | Manage specialist subagents, preloaded skills, isolated contexts, and synthesis. High leverage for complex tasks. | Claude Code subagent docs; Anthropic Claude Agent SDK; OpenAI Agents SDK orchestration |
| `human-in-loop-gate` | Pause for user input when ambiguity, safety, or high-impact decisions require human approval. | LangGraph `interrupt()`; OpenAI human intervention guidance; Claude Code permissions/approval patterns |
| `skill-creator-kilo` | Create and improve Kilo skills themselves using evals, trigger tuning, and progressive disclosure. | Anthropic `skill-creator`; Claude Code skills docs; Anthropic `skills` README |
| `observability-tracer` | Record tool calls, state transitions, failures, costs, and decisions for debugging and eval improvement. | LangGraph/LangSmith observability; Anthropic hooks; AutoGPT monitoring/analytics docs |
| `security-review-gate` | Run security-focused review before destructive or external actions. | OpenAI tool guardrails; Anthropic hooks; Claude Code `/security-review` command docs |

## Source Notes and Extracted Patterns

### Anthropic / Claude Code
- Anthropic’s “Building effective agents” recommends simple, composable patterns over complex frameworks, and identifies workflow patterns: prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer, and autonomous agents.
- Anthropic emphasizes transparency by explicitly showing planning steps and investing in agent-computer interfaces: clear tool definitions, examples, edge cases, input requirements, and poka-yoke tool arguments.
- Claude Code skills are reusable `SKILL.md` workflows with frontmatter, automatic invocation, optional dynamic context injection, subagent execution via `context: fork`, and invocation control via `disable-model-invocation` / `user-invocable`.
- Anthropic’s public `skills` repo demonstrates production-style skills such as `skill-creator`, `mcp-builder`, and Claude API agent design patterns.
- Claude Code bundled commands include agentic workflow primitives: `/batch`, `/code-review`, `/debug`, `/loop`, `/run`, `/verify`, `/plan`, `/agents`, `/fork`, `/autofix-pr`.

### LangChain / LangGraph
- LangChain’s plan-and-execute pattern separates a planner LLM from executor(s), then replans based on execution results.
- LangChain reflection patterns include basic reflection, Reflexion, and LATS, all trading extra inference for higher-quality outputs.
- LangGraph models agents as nodes connected by shared state. It provides explicit patterns for retries, LLM-recoverable errors, user interrupts, error handlers, compensation branches, and checkpointing.
- LangGraph workflow patterns overlap strongly with Anthropic’s: prompt chaining, parallelization, routing, orchestrator-worker, evaluator-optimizer, and ToolNode.

### AutoGPT
- AutoGPT Platform models workflows as typed blocks with input/action/output roles. Execution order is data-flow driven: a block runs when all required inputs are satisfied.
- AutoGPT error handling uses error pins. Failed blocks do not automatically stop the whole agent; the workflow creator can surface, handle, ignore, or route errors to fallback behavior.
- AutoGPT agent generation guidance includes clarifying questions, goal decomposition, graph validation, dry-run verification, and fix loops.

### OpenAI Agents SDK
- OpenAI distinguishes two common orchestration patterns: agents-as-tools for manager-controlled workflows and handoffs for specialist ownership transfer.
- OpenAI recommends good prompts, monitoring, iteration, self-introspection, specialized agents, and evals.
- OpenAI guardrails include input, output, and tool-level checks; tool guardrails run before/after custom function-tool execution.

## Recommended First Implementation Set

High-impact / low-to-medium complexity skills to add first:

1. `plan-and-execute`
   - Covers the core planning/decomposition requirement.
   - Can be implemented as a pure `SKILL.md` with optional state files.
2. `reflection-loop`
   - Covers self-critique and iterative refinement.
   - Can reuse LangChain/Anthropic evaluator-optimizer patterns.
3. `tool-design-optimizer`
   - Covers tool-use optimization and ACI quality.
   - Directly maps to Anthropic’s tool prompt engineering and MCP-builder guidance.
4. `self-healing-loop`
   - Covers error recovery and self-healing.
   - Can be implemented as a decision tree skill: classify error → retry/compensate/pause/stop.
5. `dry-run-verify-fix`
   - Covers verification and bounded repair loops.
   - Strongly supported by AutoGPT and Claude Code `/verify` patterns.

Secondary implementation set:
- `orchestrator-worker`
- `eval-driven-improver`
- `context-engineering`
- `mcp-integration`
- `guardrail-hook-design`
- `checkpoint-resume`

## Collection Log

| Timestamp | Action | Details |
|-----------|--------|---------|
| 2026-06-11 23:15 | Read task file | Loaded original user request, scope, constraints, and structured tasks |
| 2026-06-11 23:15 | Read architecture plan | Loaded blueprint and implementation guidance |
| 2026-06-11 23:16 | Inventory current Kilo skills | Found 8 existing skills and empty `kilo.json` skill paths |
| 2026-06-11 23:20 | Collected Anthropic sources | Building effective agents, Claude Code skills/docs, Anthropic GitHub skills, Claude Agent SDK, code-review |
| 2026-06-11 23:25 | Collected LangChain/LangGraph sources | Planning agents, reflection agents, Thinking in LangGraph, Workflows and agents |
| 2026-06-11 23:30 | Collected AutoGPT sources | Data flow/execution, agent builder, agent generation guide |
| 2026-06-11 23:35 | Collected OpenAI sources | Agents SDK orchestration/handoffs and guardrails |
| 2026-06-11 23:40 | Mapped patterns to Kilo skill candidates | Grouped into planning, reflection, tool-use, error recovery |
| 2026-06-11 23:45 | Wrote collector report | Produced this markdown report |

## Gaps / Needs More Data

- Verify exact Kilo skill loading behavior before implementation. Current `kilo.json` has empty paths, but existing skills are present under `skills/`; confirm whether this is auto-discovery or requires config changes.
- If implementing new skills, audit existing skill trigger descriptions to avoid collisions with `content-research-writer` and `agent-md-refactor`.
- For production-grade skills, add local references under `memory/refs/agentic-patterns.md` or skill-specific `references/` folders to preserve source context.

---
*Generated: 2026-06-11 23:45*
*Last Updated: 2026-06-11 23:45*
