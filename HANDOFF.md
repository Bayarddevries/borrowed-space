---
title: Borrowed Space — Handoff State
status: review
last_edited: 2026-06-23
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

- **Phase:** 2e (narrative-data shape) — committed; 2f next (test harness)
- **Last commit:** see git log
- **Repo:** https://github.com/Bayarddevries/borrowed-space (private)
- **Working tree:** clean as of last verification
- **Headline achievement:** github.com/Bayarddevries/borrowed-space is live with phase 1 docs + phase 2 plan. Phase 2a–2e committed.

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
- ✅ **Phase 2e Narrative-data shape**: 3 JSON files in `narrative/data/`: `captain-origins.json` (5 genships × 2 fragments), `npc-archetypes.json` (5 archetypes, 21 variants total), `ledger.json` (initial-empty schema mirroring PERSISTENCE.md §layer 4). Loadable via `godot/scripts/narrative_data.gd`. Smoke-tested via `godot/test/smoke_test_narrative_data.gd`. Trait IDs validated against TRAITS.md T-pool. Genship IDs cross-referenced across files.


## In-progress

- ⏳ Phase 2f: Test harness (formal GUT setup; smoke tests exist already).
- ⏳ Phase 2g: Sample playable run (Phase 2's ONLY product).

---

## Known issues

- ⚠️ Some docs use placeholder names like `[G1-NorthAmerica PLACEHOLDER]`. **Rename pass** at end of phase 1 has not been run yet. Defer to a separate issue.
- ⚠️ Phase 1 has not been "read" by the player-of-record yet. Bias-check on the project's tone has not been formally done. **Read pass** to land before phase 3+.
- ⚠️ Godot CLI smoke runs print warnings the first time (no save file yet). The persist load_state handles this gracefully.
- ⚠️ `load()` was renamed to `load_state()` in persist.gd to avoid conflict with the built-in `ResourceLoader.load()`. Module 1 (State machine) consumers must use the renamed API.
- ⚠️ **narrative/ lives outside the Godot project root** (per AGENTS.md convention). `godot/scripts/narrative_data.gd` resolves paths via `globalize_path("res://")` and walks up to repo root. In production builds, Phase 2c bundler (Path-A Vite) routes JSON into res:// — until that lands, narrative data is accessible only to dev-mode test-runners and the wrapped Ink runner. Scene-bundled game runtime should not call NarrativeData directly.

---

## What to read first (next agent)

1. `docs/VISION.md`
2. `docs/ROADMAP.md`
3. `AGENTS.md` (just-completed commit)
4. Current GitHub issue assigned to you
5. Relevant docs/wiki links from the issue body
6. If working on narrative data: read `godot/scripts/narrative_data.gd` and `narrative/data/` schema docs.
7. If working on persistence: read `godot/scripts/persist.gd` to understand the autoload pattern.

---

## Pitfalls discovered (lesson bank)

- **GDScript class_name stays registered in ProjectSettings even after file deletion** — Godot 4 caches class names in `project_metadata.cfg`. Renaming or moving class_name scripts requires editing that cache or `--headless --import` to refresh.
- **Narrative data lives outside the Godot project root** by AGENTS.md convention. Use `ProjectSettings.globalize_path("res://")` and walk up to the repo root to access it; standard `res://` URIs can't reach it. Production builds need a bundler step (Phase 2c Path-A).
- **`load()` in GDScript conflicts with `ResourceLoader.load()`** — name carefully when writing persist or similar loaders. We renamed to `load_state()` in `persist.gd` after a parse error.

---

[End of HANDOFF.md]
