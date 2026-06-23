---
title: Borrowed Space — Handoff State
status: review
last_edited: 2026-06-22
tags:
  - workflow
  - handoff
  - state
aliases:
  - HANDOFF
phase: 2
related:
  - "[[_CONVENTIONS]]"
  - "[[ROADMAP]]"
  - "[[VISION]]"
---

# HANDOFF.md

Current state. Verified-working features. Known issues. Updated at the end of every phase change.

---

## Project state

- **Phase:** 2a (scaffold)
- **Last commit:** see git log
- **Repo:** https://github.com/Bayarddevries/borrowed-space (private)
- **Working tree:** clean as of last verification
- **Headline achievement:** github.com/Bayarddevries/borrowed-space is live with phase 1 docs + phase 2 plan.

---

## Verified-working

- ✅ Repo + GitHub remote + initial commit.
- ✅ Phase 1 docs (9 .md files) committed with cross-references.
- ✅ Two Ink sample beats exist (prologue.ink, run-start.ink).
- ✅ Obsidian-compatible YAML frontmatter on every doc.
- ✅ GitHub Issues opened for Phase 2 sub-deliverables #1 through #7.
- ✅ AGENTS.md drafted with cross-agent workflow + commit-message convention.
- ✅ ROADMAP.md drafted with phase boundaries and sub-deliverables.
- ✅ Godot 4.6.2.stable imports the project cleanly with `--headless --import`.
- ✅ Placeholder scenes (run_start, overworld, station, combat) + scripts (captain, crew, ai, ink_runner, tool/dice) committed.
- ✅ **Phase 2d Persistence singleton (`godot/scripts/persist.gd`) works** — registered as autoload `Persist`. Round-trip verified via test/smoke_test_persist.gd.

---

## In-progress

- ⏳ Phase 2e: Narrative-data shape (3 JSON files).
- ⏳ Phase 2f: Test harness (formal GUT setup; smoke test exists already).
- ⏳ Phase 2g: Sample playable run (Phase 2's ONLY product).

---

## Known issues

- ⚠️ Some docs use placeholder names like `[G1-NorthAmerica PLACEHOLDER]`. **Rename pass** at end of phase 1 has not been run yet. Defer to a separate issue.
- ⚠️ Phase 1 has not been "read" by the player-of-record yet. Bias-check on the project's tone has not been formally done. **Read pass** to land before phase 3+.
- ⚠️ Godot CLI smoke runs print warnings the first time (no save file yet). The persist load_state handles this gracefully.
- ⚠️ `load()` was renamed to `load_state()` in persist.gd to avoid conflict with the built-in `ResourceLoader.load()`. Module 1 (State machine) consumers must use the renamed API.

---

## What to read first (next agent)

1. `docs/VISION.md`
2. `docs/ROADMAP.md`
3. `AGENTS.md`
4. Current GitHub issue assigned to you
5. Relevant docs/wiki links from the issue body
6. If working on persistence: read `godot/scripts/persist.gd` to understand the autoload pattern.

---

## What to read first (next agent)

1. `docs/VISION.md`
2. `docs/ROADMAP.md`
3. `AGENTS.md` (just-completed commit)
4. Current GitHub issue assigned to you
5. Relevant docs/wiki links from the issue body

---

## Pitfalls discovered (lesson bank)

*Section is empty until pitfalls are committed. Populating as we find them.*

[End of HANDOFF.md]
