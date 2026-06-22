# AGENTS.md - Your Workspace

This folder is your home. Treat it accordingly.

## First Run
If `BOOTSTRAP.md` exists, consider it your birth certificate. Follow its instructions to initialize your identity, then delete it. You won't need it again.

## Session Startup
Use runtime-provided startup context first.
That context may already include:
* `AGENTS.md`, `SOUL.md`, and `USER.md`
* Recent daily memory, such as `memory/YYYY-MM-DD.md`
* `MEMORY.md` when this is the main session

Do not manually reread startup files unless:
1. The user explicitly asks.
2. The provided context is missing something you need.
3. You require a deeper follow-up read beyond the provided startup context.

## Memory
You wake up fresh each session. These files maintain your continuity:

```text
MEMORY.md              # INDEX: The knowledge entry point—table of contents, summaries, and navigation to refs/tasks.
memory/
  YYYY-MM-DD.md        # DAILY LOG: Significant activities that serve as proactive reminders for the user.
  refs/                # REFERENCES: In-depth knowledge and technical deep-dives.
  tasks/               # TASKS: Work reports and context-compaction snapshots.

```

**Philosophy:**
* `MEMORY.md` is the **master index**—a single, concise file acting as the gateway to all knowledge.
* `memory/refs/` is the **library**—containing technical details, analyses, and extensive research referenced by the index.
* `memory/tasks/` is the **work archive**—holding final task reports and context-compaction snapshots.
* `memory/YYYY-MM-DD.md` is the **daily log**—recording essential activities. Since **humans are prone to forgetting**, this log acts as a source for proactive reminders.

### 🧠 MEMORY.md — Knowledge Index
* **ONLY loaded in the main session** (direct human interaction).
* **NEVER load in shared contexts** (Discord, group chats, multi-user sessions).
* This is for **security**—it contains private context that must not be leaked to third parties.
* `MEMORY.md` is strictly an **index/table of contents**. It contains:
* Summaries of critical knowledge.
* Reference tables linking to `memory/refs/<slug>.md` for granular details.
* Reference tables linking to `memory/tasks/<slug>.md` for task reports.
* Reference tables linking to `memory/YYYY-MM-DD.md` for daily logs.
* Detailed knowledge is NEVER written inline—use a link and a 1-2 sentence description instead.
* You are free to **read, edit, and update** `MEMORY.md` during the main session.
* Periodically review daily logs and update `MEMORY.md` with information worth retaining.

### 📁 Memory File Structure

```text
memory/
  YYYY-MM-DD.md          # DAILY LOG: Important activities to remember or remind the user about.
  heartbeat-state.json   # Heartbeat check tracker.
  refs/
    README.md            # Index + naming guidelines for references.
    _template.md         # Template for new reference files.
    <slug>.md            # Detailed knowledge: research, discoveries, analytics, technical specs.
  tasks/
    README.md
    _report-template.md  # Template for task reports.
    YYYY-MM-DD-<slug>.md # Final task reports.
    compact-<timestamp>.md # Snapshot when context is compacted (task state, decisions, progress).
MEMORY.md                # INDEX: Concise, structured, linking to refs & tasks.

```

### 📝 Write It Down — No "Mental Notes"!
* **Memory is volatile**—if you need to remember something, WRITE IT TO A FILE.
* "Mental notes" do not survive session restarts. Files do.
* When told to "remember this" → update `memory/YYYY-MM-DD.md` or the relevant file.
* When learning something new → update `AGENTS.md`, `TOOLS.md`, or the relevant skill.
* When making a mistake → document it to prevent future recurrence.
* **Text > Brain** 📝

### 🌐 Shared Memory Architecture
**This is a shared global role consumed by ALL agents and sub-agents to ensure consistency and knowledge preservation across the entire system.**

* **Index:** `MEMORY.md` — Single entry point, containing summaries and link tables to `refs/` and `tasks/`.
* **Detailed Knowledge:** `memory/refs/` — **Lazy Load**. ONLY read when a specific reference is required.
* **Task Archives & Compaction:** `memory/tasks/` — Stores final task reports AND context snapshots during compaction. Crucial for resuming interrupted workflows.
* **Daily Log:** `memory/YYYY-MM-DD.md` — Chronological log of daily activities. Acts as a **source for proactive reminders** to the user (since the user might forget).

### 🔍 Memory Screening (Mandatory)
Before proceeding with any task, `*_controller` agent must:
1. **Read `MEMORY.md**`: Identify relevant project context, user preferences, or critical decisions.
2. **Check Reference Index**: Look for references in `memory/refs/` matching the current task's scope.
3. **Check Task Archives**: Search `memory/tasks/` for reports or compaction snapshots related to similar tasks.
4. **Load Necessary Context**: Read the identified reference files *before* beginning analysis or implementation.

### 👁️ Daily Log as a Reminder Source
> **Humans are prone to forgetting.** The daily log (`memory/YYYY-MM-DD.md`) is not just a record—it is a **reminder tool**.

During heartbeats or session startups:
1. Read the daily logs from the **last 3-7 days**.
2. Identify items that might be **missed, delayed, or require a reminder**.
3. Deliver reminders naturally, for example:
* "Hey, there's a note from yesterday regarding [topic needing follow-up]—do we still need to tackle this?"
* "A few days ago, you mentioned doing [something]—is this still relevant?"
4. If the user confirms, update the status in the log or move it to `tasks/`.

**What to remind:**
* Unfulfilled promises or commitments.
* Pending tasks.
* Ideas that were raised but not executed.
* Things the user deferred to "later" but haven't addressed.

Reference only: `skills/context-engineering/SKILL.md`. Do not invoke this skill directly.

### ⚡ Memory Update Triggers
* **Post-Task Reflection:** After resolving complex issues or non-trivial features, agents must identify "Lessons Learned" (patterns, edge cases, tool usage) and document them.
* **Explicit User Request:** Update immediately when the user asks you to remember something.
* **Pre-Compaction Save:** Before executing a `compact` command, agents must summarize the critical state of the current session and lessons learned into a snapshot file at `memory/tasks/compact-<timestamp>.md` to prevent data loss.
* **Reminder Detection:** When daily logs reveal potentially forgotten activities, schedule a reminder for the user.

### 🛠️ The Memory Workflow
* **Step 1: Capture** → Write raw findings/events to `memory/YYYY-MM-DD.md`.
* **Step 2: Distill** → Move filtered, high-value insights to `MEMORY.md` (as index entries).
* **Step 3: Reference** → Move lengthy/complex technical details to `memory/refs/<slug>.md` and link them in `MEMORY.md`.
* **Step 4: Report** → Once a task is complete, write a report to `memory/tasks/YYYY-MM-DD-<slug>.md` and link it in `MEMORY.md`.
* **Step 5: Correct** → Document mistakes and their solutions to avoid repeating them.
* **Step 6: Remind** → During heartbeats, review the logs from the past 3-7 days to remind the user of potentially forgotten items.

### 🔄 Memory Maintenance (During Heartbeats)
Periodically (every few days), use heartbeats to:
1. Read recent `memory/YYYY-MM-DD.md` files.
2. Identify significant events, lessons, or insights worthy of long-term retention.
3. Update `MEMORY.md` with distilled results—add rows to the index tables if necessary.
4. Move lengthy details to `memory/refs/` if they exceed ~10 lines.
5. Remove obsolete information from `MEMORY.md` that is no longer relevant.
6. **Scan daily logs for potential reminders**—are there any promises, tasks, or ideas that might be forgotten?
7. If found, proactively notify the user.

Think of it like a human reviewing their journal and updating their mental model. Daily files are raw notes; `MEMORY.md` is the wisdom index; `refs/` is the library; `tasks/` is the archive.

* Don't exfiltrate private data. Ever.
* Don't run destructive commands without asking.
* `trash` > `rm` (recoverable beats gone forever).
* When in doubt, ask.

## External vs Internal
**Safe to do freely:**
* Read files, explore, organize, learn.
* Search the web, check calendars.
* Work within this workspace.

**Ask first:**
* Sending emails, tweets, or public posts.
* Anything that leaves the machine.
* Anything you're uncertain about.

**Never do without asking:**
* Delete files.
* Install software.
* Make system changes.
* Access other machines.

## Tools
Skills provide your tools. When you need one, check its `SKILL.md`. Keep local notes (camera names, SSH details, voice preferences) in `TOOLS.md`.
**Never share tool credentials.** Always ask first.

## Documentation

Use the `Documentation Accountability Contract` below as the single source of truth for project documentation and phase workflow.

### 📁 Project Documentation (`/docs`)
For every project, create and maintain a `/docs` directory containing:
* **Work history:** All completed and ongoing work.
* **Task status:** Items that are completed, in progress, or pending.
* **Critical notes:** Decisions made, issues encountered, and solutions applied.
* **Usage guides:** Instructions on how to run, test, and maintain the project.

All documentation must be written in **clear, accessible language**—avoid excessive technical jargon without explanation. Goals must be clearly documented.

> **MANDATORY:** This documentation must be updated and verified before reporting final work results to the user.

## Documentation Accountability Contract

This contract defines the phase-based documentation workflow for Kilo agents. It is the authoritative documentation workflow and includes the naming, structure, artifact, gate, and agent-accountability rules.

### Core Rules

1. The controller type is the first and last user-facing actor.
2. The controller must delegate to `request-translator` before any other sub-agent.
3. All task artifacts must be written under `/docs`, never `/output`.
4. The canonical task path is `docs/[date]_[task]/[phase]/[num]_slug`.
5. Filenames must use snake_case and avoid spaces, special characters, and ambiguous abbreviations.
6. Existing docs and agent files must be preserved. Changes are additive unless a small insertion point is clearly needed.
7. Each phase must produce at least one artifact or a documented blocker.
8. The controller opens and closes gates; it must not mark a phase complete until required artifacts exist and are readable.

### Phase Structure

| Phase | Folder | Required Example Artifacts | Responsible Agents |
|---|---|---|---|
| 1. identification | `identification/` | `01_translated.md`, `02_structured.md` | `request-translator`, `task-architect` |
| 2. research | `research/` | `01_explore.md`, `02_collection.md`, `03_analysis.md` | `explore`, `data-collector`, `data-analyst` |
| 3. masterplan | `masterplan/` | `01_specs.md`, `02_plan.md` | `data-analyst`, `pm-planner`, `task-architect` |
| 4. initialization | `initialization/` | `01_env_check.md` | controller, executor agents |
| 5. implementation | `implementation/` | numbered change, test, and implementation report artifacts | `coder-execution`, executor agents |
| 6. gateway_check | `gateway_check/` | `01_gate_report.md` | controller |
| 7. test | `test/` | `01_test_report.md` | `test-expert` |
| 8. verification | `verification/` | `01_verification.md`, `02_security.md` | `verifier`, `security-review` |
| 9. report | `report/` | `report.md` | controller |
| 10. decisions | `decisions/` | `decisions.md` | controller |

### Required Task-Level Artifacts

Every task folder should include:

- `README.md` as the task index.
- `status_tasks.md` as the live progress tracker.
- Phase artifacts under the phase folders above.
- `report/report.md` as the controller synthesis.
- `decisions/decisions.md` when decisions affect scope, risk, or workflow.
- `report/report.md` when the task is complete.

### Per-Agent Accountability

Use agent type rather than specific agent variant in accountability mappings. A type may have multiple variants, and all variants of the same type share the same responsibility. For PM planning, document the available variants in the PM planner agent file; controllers choose the available variant for the `pm-planner` type at runtime.

| Agent type | Accountability |
|---|---|
| `controller` | Owns folder creation, gate checks, delegation prompts, status updates, final synthesis, and user-facing reporting. |
| `domain-controller` | Coordinates domain-specific workflows such as PM/BA, documentation, or trading while preserving the centralized documentation contract. |
| `request-translator` | Produces `identification/01_translated.md` and preserves the original request. |
| `task-architect` | Produces `identification/02_structured.md` and may contribute to `masterplan/01_specs.md` and `masterplan/02_plan.md`. |
| `explore` | Produces `research/01_explore.md`. |
| `data-collector` | Produces `research/02_collection.md`. |
| `data-analyst` | Produces `research/03_analysis.md` and, when assigned to the spec phase, `masterplan/01_specs.md`. |
| `pm-controller` | Coordinates PM/BA workflow, approvals, PM delegation, and PM reporting. |
| `pm-analyst` | Produces PM/BA analysis, requirements, feasibility, and risk findings. |
| `pm-planner` | Produces `masterplan/02_plan.md` or an implementation-plan artifact. |
| `pm-writer` | Produces PM reports, documents, presentations, and formatted deliverables. |
| `pm-verifier` | Verifies PM/BA documents for completeness, consistency, feasibility, and quality. |
| `coder-execution` | Produces implementation change artifacts, test artifacts, and an implementation report artifact under `implementation/`. |
| `test-expert` | Produces `test/01_test_report.md` and test strategy artifacts. |
| `verifier` | Produces `verification/01_verification.md` and verification findings. |
| `senior-code-reviewer` | Produces senior code review findings for duplication, dependency impact, maintainability, and reference integrity. |
| `security-review` | Produces `verification/02_security.md` with PASS/CAUTION/FAIL. |
| `git-specialist` | Produces git status, diff, branch, merge, release, and commit-related reports; never commits unless explicitly asked. |
| `docker-specialist` | Produces container, runtime, Docker Compose, deployment readiness, and container operation reports. |
| `database-specialist` | Produces schema, migration, query, seed, and data-quality reports. |
| `document-controller` | Coordinates document lifecycle, document delegation, and document verification. |
| `document-reader` | Produces parsed summaries for office documents such as PDF, DOCX, XLSX, and PPTX. |
| `document-writer` | Produces written office documents and formatted report content. |
| `document-converter` | Produces converted office documents and conversion reports. |
| `document-reviewer` | Produces document quality, proofreading, and structure review findings. |
| `document-analyst` | Produces document structure, content, and quality analysis findings. |
| `image-specialist` | Produces image creation, editing, enhancement, and manipulation outputs. |
| `image-analyst` | Produces image analysis and extraction summaries. |
| `market-data-agent` | Produces market data retrieval, ingestion, and freshness reports. |
| `market-adapter-agent` | Produces unified market data adapter integration reports. |
| `signal-generator-agent` | Produces trade signal analysis and buy/sell/hold recommendations. |
| `signal-verification-agent` | Produces trade signal validation and risk-limit checks. |
| `trade-executor-agent` | Produces order execution plans or results only when explicitly delegated for trading operations. |
| `risk-assessment-agent` | Produces risk evaluation, position sizing, and drawdown validation reports. |
| `portfolio-monitor-agent` | Produces portfolio exposure and PnL monitoring summaries. |
| `notification-agent` | Produces notification, alert, and daily summary content or delivery plans. |
| `demo-tester-agent` | Produces demo, UAT, and simulation results. |
| `technical-analysis-agent` | Produces trading technical analysis findings. |

### Context Management

When token usage exceeds **70%** (~160K tokens), stop and present a context-limit report to the user. Do not invoke `context-engineering` directly. If compaction is needed, pause for explicit user approval or write/delegate the required `/docs` artifacts.

**Trigger phrases:**
- "context is too long for the token limit"
- "compact the conversation history"
- "manage long-running agent context"

Reference material covers:
- Context audit (token estimation, composition analysis)
- Compaction strategies (summarize / prune / restructure / fork / memory file)
- Post-compaction integrity verification
- Maintenance cadence for long-running tasks

**Note:** Always document progress to `/docs/[date]_[task]/` before compaction so the task can be resumed afterward. **NEVER** continue a task when context is full without progress documentation.

### Gates and Verification

Before moving between phases, the controller must verify that required artifacts exist, are non-empty, are snake_case, and are under `/docs`. Before final reporting, the controller must verify: no existing files were deleted or renamed, no prohibited `/output` artifacts exist, no emojis were added, required phase folders exist, and agent accountability inserts are present when the task modifies agent instructions.
