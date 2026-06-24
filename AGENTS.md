---
title: Borrowed Space — Agent Workflow Contract
status: locked
last_edited: 2026-06-24
tags:
  - workflow
  - convention
  - cross-agent
aliases:
  - AGENTS
phase: 2
related:
  - "[[_CONVENTIONS]]"
  - "[[ROADMAP]]"
  - "[[VISION]]"
---

# AGENTS.md — Workflow Contract

This file is the contract for any agent or contributor working on `borrowed-space`. Work proceeds under discipline, not improvisation.

---

## Your job

- Advance the TODO without leaving ambiguity for the next agent.
- Do not ship undocumented history; prefer a TODO over invented content.
- Do not make claims about remote URLs or tests without verified evidence.

## Pre-flight

Before any implementation session:

1. Identify the **corresponding GitHub issue**. Issues are the queue; pick the highest-priority unassigned item.
2. Write **one sentence** (in the issue body or a scratch note) defining what "done" looks like for this session.
3. Identify the **verification primitive** — the test, demo, or manual check that proves the change works.
4. Only then touch code or narrative.

Skipping this step means regenerating from scratch on every loop.

---

## First actions (every session, every agent, every machine)

Before editing code or writing narrative:

1. **Read these three files (mandatory):**
   - `docs/VISION.md` — what we're making and why
   - `docs/ROADMAP.md` — where we are and what's next
   - `HANDOFF.md` — current state, verified-working features, known issues

2. **Read the GitHub issue** for the current task. Issues are the *authoritative source* of what to do. Issues take priority over local docs.

3. **Read related docs** based on wikilinks in the issue and in the docs above. If an issue references `[BIAS_GUARDRAILS]`, read it. If it references `[NPCS]`, read it. The wiki node system is your map.

4. **Check `git status`** for uncommitted work before starting.

5. **Confirm Godot CLI is available** before claiming any Phase 2 work done. Dry-run workflow. If Godot CLI is missing, log it in `ISSUES.md` and stop.

---

## Code rules

### Where things live

- **Code lives in `godot/`** (after Phase 2b). Phase 1 has no code.
- **Narrative content in `narrative/beats/`** (Ink files) and `narrative/data/` (JSON).
- **Markdown docs in `docs/`** (with Obsidian-compatible YAML frontmatter per `docs/_CONVENTIONS.md`).
- **Never** edit generated files (dist/, build/, narrative/build/).

### Phase 2 sub-deliverables

For Phase 2, code lives under:

```
godot/
├── project.godot
├── assets/
│   ├── sprites/
│   └── data/
├── scenes/
│   ├── run_start.tscn
│   ├── overworld.tscn
│   ├── station.tscn
│   └── combat/
├── scripts/
├── test/
└── packaging/             # export presets
```

(Full path conventions in `ROADMAP.md` Phase 2b.)

### Bias check

- **Every write** is checked against `docs/BIAS_GUARDRAILS.md` before merging.
- If a write drifts toward stereotyping or politically-suspect tropes, **flag it and rewrite**.

### Persistence

- Reads/writes go through the `Persist` singleton (Phase 2d), not directly to disk.
- Schema is governed by `docs/PERSISTENCE.md`.

### Narrative

- Ink runs through the `ink_runner.gd` wrapper (Phase 2c), not direct inkjs calls.
- The wrapper API is the only contract.

---

## Permissions and limits

- Do not run destructive commands without explicit user approval.
- Do not make claims about public URLs without verified evidence from the workflow.
- If blocked, log it, stop. Don't invent around blockers.

---

## Commit message conventions

Adopted from Metis Trail V2's contract plus two extensions:

### Format

```
<type>(<scope>): <concise description>

[optional body]

[optional footer(s)]
```

### Type — exactly one

| Type | Use |
|---|---|
| `feat` | New feature or content (events, items, nodes, UI panels, narrative) |
| `fix` | Bug fix (engine logic, UI rendering, broken behavior) |
| `docs` | Documentation only (AGENTS, HANDOFF, CHANGELOG, ISSUES, comments) |
| `chore` | Tooling, build, dependencies, formatting — no game logic changes |
| `balance` | Win rate, difficulty, economy tuning |
| `art` | Art assets only |
| `lore` | World bible / lore file changes |
| `narrative` | Ink files and narrative templates |
| `scaffold` | Project structure files |
| `bias-check` | Anti-stereotype watch-list updates |

### Scope — required, single-word or short kebab-case

Common scopes for this project:

- `world` — lore paragraphs in world bible
- `narrative` — Ink files
- `scaffold` — `godot/`, project structure
- `assets` — `godot/assets/`
- `scripts` — `godot/scripts/`
- `scenes` — `godot/scenes/`
- `test` — test files
- `docs` — markdown documentation
- `roadmap` — `ROADMAP.md` updates
- `bias-check` — `BIAS_GUARDRAILS.md`

### Footer

Two footers preferred:

- `Closes #N` — auto-links to GitHub Issue and closes it on merge
- `Phase: <X>` — phase tag for archival

Optional:

- `Decision: <text>` — when committing a contested choice

### Examples

```
docs(roadmap): add phase boundaries + scaffold plan

Adds ROADMAP.md with phase 2-5 sub-deliverables.
Cross-links all docs.

Closes #1
Phase: 2a
```

```
feat(narrative): add run-start.ink with crew archetypes

Captain origin selection, He-3 literacy tier, blessing slot,
first-decision logic.

Closes #2g
Phase: 2g
```

```
fix(scripts): persist.save() now flushes before exit
```

```
lore(world): rename [G1-NorthAmerica PLACEHOLDER] to Final Name
```

### Imperative mood

"Add feature" not "added feature" or "adds feature."

### Subject rules

- Imperative mood.
- No period at end of subject line.
- Keep subject under 72 characters.
- One logical change per commit — don't bundle unrelated fixes.

---

## Handoff loop

### After every change

1. Run any test that touches the change.

2. Update files in this order:
   - **Code change first.** `git status` should show only the change.
   - `TODO.md` — flip status of completed work.
   - `CHANGELOG.md` — append a dated note.
   - `HANDOFF.md` — write current state, verified-working features, known issues.
   - If architectural decision or pitfall discovered: `AGENTS.md` (this file).

3. **Bias-check the change** before commit.

4. **Commit and push.** No uncommitted work left behind.

### GitHub Issues policy

- GitHub Issues are the **authoritative** backlog. Bugs take priority over enhancements.
- Local `ISSUES.md` is a snapshot, not source of truth.
- Phase issues are labeled `phase-2`, `phase-3`, etc.

---

## Known pitfalls

*Section to populate as they're encountered. Lessons learned, saved for the next agent.*

[End of AGENTS.md]
