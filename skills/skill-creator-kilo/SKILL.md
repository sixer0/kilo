---
name: skill-creator-kilo
description: >-
  Create and improve Kilo skills (SKILL.md files) using structured evaluation,
  trigger tuning, and progressive disclosure. Guides the author through
  defining the skill's purpose, crafting triggers, designing process phases,
  identifying anti-patterns, and verifying completeness against the
  established skill template.
license: MIT
metadata:
  category: development
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/skill-creator-kilo
    license_path: LICENSE
---

# Skill Creator for Kilo

Design, build, and refine Kilo skills following progressive disclosure
principles. Each skill is a self-contained `SKILL.md` with frontmatter,
triggers, process phases, anti-patterns, execution checklist, and
verification criteria.

---

## Triggers

Use this skill when:
- "create a new skill"
- "improve this skill"
- "add a trigger phrase"
- "skill development"
- "design a skill workflow"
- "build a Kilo skill"
- "author a skill for this capability"
- "refine an existing skill"

Do NOT use for one-off instructions or scripts that don't represent a
reusable capability, or when modifying non-skill configuration files
like `kilo.json`.

---

## Process

### Phase 0: Requirements Analysis

Before writing any content, define the skill's purpose:

```markdown
## Skill Specification

**Skill name:** <kebab-case-name>
**Category:** <development / orchestration / safety / optimization / observability / domain>

**Problem it solves:**
<what gap does this skill fill — 2-3 sentences>

**Who will use it:**
<target audience — e.g., "agent executing file operations", "developer authoring skills">

**Key capabilities (3-7):**
- <capability 1>
- <capability 2>
- <capability 3>

**Related skills it may invoke or reference:**
- <skill name>: <how it relates>

**Trigger phrases (draft 5-8):**
- "<phrase 1>"
- "<phrase 2>"

**Do NOT use (anti-triggers):**
- <situations where this skill should NOT be invoked>
```

**Skill naming conventions:**
- Use kebab-case: `human-in-loop-gate`, not `humanInLoopGate` or `Human In Loop Gate`
- Name should describe the capability, not the implementation: `skill-creator-kilo`, not `write-skills-md`
- Keep names under 30 characters

---

### Phase 1: Author Frontmatter

Write the YAML frontmatter (between `---` delimiters):

```yaml
---
name: <kebab-case-name>
description: >-
  <single-paragraph description of what this skill does, when to use it,
  and what it achieves. Approximately 2-4 sentences.>
license: MIT
metadata:
  category: <development / orchestration / safety / optimization / observability / domain>
  source:
    repository: 'https://github.com/anthropics/skills'
    path: skills/<skill-name>
    license_path: LICENSE
---
```

**Frontmatter rules:**
- `name` must match the folder name exactly
- `description` uses YAML folded block scalar (`>-`) for multi-line
- `metadata.category` must be one of the allowed categories
- `source.repository` points to the skills repo
- `source.path` is `skills/<name>`

---

### Phase 2: Design Triggers

Create the triggers section:

```markdown
## Triggers

Use this skill when:
- "<trigger phrase 1>"
- "<trigger phrase 2>"
- "<trigger phrase 3>"
- "<trigger phrase 4>"
- "<trigger phrase 5>"
- "<trigger phrase 6>"

Do NOT use for <situations where this skill should not be invoked>.
```

**Trigger design principles:**
1. **6 trigger phrases minimum** — ensures sufficient coverage
2. **User-language, not system-language** — triggers should match what a user would naturally say
3. **Broad coverage** — cover intent, not just exact wording
4. **No overlap** — verify each trigger is unique across all existing skills
5. **Anti-trigger** — always include "Do NOT use for..." to prevent false positives

**How to check for overlap:**
- Search existing `SKILL.md` files with grep for each candidate trigger
- If a match is found, rephrase the trigger to be distinct
- Document uniqueness in the skill's specification

---

### Phase 3: Design Process Phases

Break the skill's workflow into 3-7 sequential phases:

```markdown
## Process

### Phase <N>: <Phase Name>

<what happens in this phase — 1-3 sentences>

<detailed steps, templates, decision tables, code blocks, or examples>
```

**Phase design guidelines:**

| Aspect | Rule |
|--------|------|
| Number of phases | 3-7 (too few = vague, too many = fragmented) |
| Phase names | Verb-driven: "Analyze", "Design", "Verify" |
| First phase | Always an analysis/assessment phase |
| Last phase | Always a summary/verification/delivery phase |
| Outputs | Each phase should produce a tangible output |
| Templates | Include markdown templates for structured outputs |
| Tables | Use decision tables for branching logic |

**Required tables by phase type:**

| Phase Type | Include |
|------------|---------|
| Analysis/classification | Decision table with classes, signals, examples |
| Design/creation | Template or schema for the artifact being created |
| Execution | Step-by-step instructions or algorithm |
| Verification | Checklist or verification criteria |

**Common phase patterns:**
- **Phase 0/1: Assess** — Evaluate the current state, classify the situation
- **Phase 2: Design** — Plan the approach, choose a strategy
- **Phase 3: Execute** — Implement the plan
- **Phase 4: Verify** — Check correctness and completeness
- **Phase 5: Log/Report** — Summarize what was done

---

### Phase 4: Add Supporting Sections

Every skill must include these supporting sections:

#### Anti-Patterns

```markdown
## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| <bad practice> | <better approach> |
| <bad practice> | <better approach> |
```

**Rules:**
- Minimum 4 anti-pattern entries
- Each entry should describe a real, observed mistake
- The "Avoid" column describes the anti-pattern (don't just name it)
- The "Instead" column gives actionable guidance

#### Execution Checklist

```markdown
## Execution Checklist

```
[ ] Phase N: <step>
[ ] Phase N: <step>
[ ] Verify: <verification item>
[ ] Verify: <verification item>
```
```

**Rules:**
- One checkbox per phase step
- 3-5 `[ ] Verify:` items at the end
- Each checkbox is something that can be objectively confirmed

#### Verification

```markdown
## Verification

After <skill operation>:
1. <measurable criterion>
2. <measurable criterion>
3. <measurable criterion>
```

**Rules:**
- Minimum 4 verification criteria
- Each criterion must be objectively verifiable (not "looks good")
- Criteria should span: correctness, completeness, safety

---

### Phase 5: Trigger Uniqueness Validation

Before finalizing, validate that all trigger phrases are unique:

```markdown
## Trigger Uniqueness Check

**Skill:** <name>
**Candidate triggers:**
- "<phrase 1>"
- "<phrase 2>"
- ...

**Search results across all skills:**
| Trigger | Matches in other skills | Verdict |
|---------|------------------------|---------|
| "<phrase 1>" | 0 | ✅ UNIQUE |
| "<phrase 2>" | 0 | ✅ UNIQUE |

**Result:** All triggers are unique / N triggers collide (rephrase: <details>)
```

**When collisions are found:**
1. Determine if the collision is actual overlap (same intent) or just shared vocabulary
2. If actual overlap, rephrase to distinguish intent
3. If false positive (same words, different context), add clarifying context in the trigger

---

### Phase 6: Final Review

Complete a final review of the complete skill file:

```markdown
## Skill Final Review

### Structure Check
- [ ] Frontmatter with all required fields (name, description, license, metadata)
- [ ] Triggers section with 6+ phrases and "Do NOT use" clause
- [ ] Process section with 3-7 phases, each with clear outputs
- [ ] Anti-Patterns section with 4+ entries
- [ ] Execution Checklist with phase steps + verification items
- [ ] Verification section with 4+ measurable criteria

### Quality Check
- [ ] All trigger phrases are unique (no overlap with existing skills)
- [ ] Descriptions use user language, not system jargon
- [ ] Templates and examples are filled with realistic content
- [ ] Phase order is logical (assess → design → execute → verify)
- [ ] Anti-patterns describe real, observed mistakes
- [ ] Verification criteria are objectively measurable

### Content Check
- [ ] No hardcoded paths, names, or secrets
- [ ] No references to nonexistent skills or tools
- [ ] Consistent kebab-case naming
- [ ] Consistent formatting (heading levels, code blocks, tables)
- [ ] License is MIT
- [ ] `source.path` matches the folder name
```

---

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| Writing triggers in technical jargon | Use language the user would naturally say |
| Creating a skill for a one-time task | Skills should solve reusable, repeatable problems |
| Skipping the anti-patterns section | Anti-patterns are essential for preventing misuse |
| Writing verification criteria that are subjective ("looks good") | Use objectively measurable criteria |
| Only 1-2 process phases | Minimum 3 phases for a meaningful workflow |
| Copying triggers from another skill verbatim | Craft unique, specific trigger phrases |
| Nesting phases too deep (sub-sub-phases) | Keep flat phase structure; use tables for branching |

---

## Execution Checklist

```
[ ] Phase 0: Skill specification defined (problem, audience, capabilities, triggers)
[ ] Phase 1: Frontmatter written (name, description, category, source)
[ ] Phase 2: Triggers designed (6+ phrases, anti-trigger, user-language)
[ ] Phase 3: Process phases designed (3-7 phases, templates, tables)
[ ] Phase 4: Anti-Patterns, Execution Checklist, Verification written
[ ] Phase 5: Trigger uniqueness validated (no overlap with existing skills)
[ ] Phase 6: Final review completed (structure, quality, content checks)
[ ] Verify: All required sections are present
[ ] Verify: All trigger phrases are unique
[ ] Verify: Verification criteria are objectively measurable
[ ] Verify: Skill name matches folder name and source.path
```

---

## Verification

After skill creation:
1. All required sections are present (frontmatter, triggers, process, anti-patterns, checklist, verification)
2. Trigger uniqueness is validated — no overlap with existing 18+ skills
3. Process has 3-7 phases with clear inputs, actions, and outputs
4. Verification criteria are objectively measurable
5. Anti-patterns describe real misuse scenarios with actionable alternatives
6. The skill follows the established Kilo SKILL.md template format
