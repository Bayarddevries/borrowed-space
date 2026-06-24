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

- **Phase:** 2 → 2 final, sample playable run SHIPPED. Phase 3 (combat) next.
- **Last commit:** see git log
- **Repo:** https://github.com/Bayarddevries/borrowed-space (private)
- **Working tree:** clean as of last verification
- **Headline achievement:** github.com/Bayarddevries/borrowed-space ships **Phase 2 — one playable text-first run**. 13/13 GUT tests pass.

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
- ✅ **Phase 2d Persistence singleton (`godot/scripts/persist.gd`) works** — registered as autoload `Persist`. Round-trip verified via test/test_persist.gd.
- ✅ **Phase 2e Narrative-data shape**: 3 JSON files in `narrative/data/`. Loadable, smoke-tested.
- ✅ **Phase 2f Test harness (GUT 9.6.0)**: GUT addon vendored at `godot/addons/gut/`. Tests live in `godot/test/` with `test_*.gd` prefix. `scripts/test.sh` shell wrapper around `gut_cmdln.gd`. **13/13 tests pass** (1 placeholder + 4 narrative-data + 4 persist + 4 playable-run).
- ✅ **Phase 2 final — Sample playable run**:
  - 7-step sequence per issue #7 (origin pick → archetype → briefing → crew → overworld → station encounter → ledger close).
  - BeatRunner shim at `godot/scripts/beat_runner.gd` mimics Ink's surface (text + choices + delta); same API as `ink_runner.gd` will expose when inkjs lands.
  - Captain class reads origin matrix, locks 3 traits from origin's tag_pool.
  - Crew class procedurally generates NPCs from archetype variants.
  - LedgerWriter writes captain rows into `ledger.captains[captain_n]` keyed by captain number for idempotency.
  - Manifest at `narrative/beats/run-start-manifest.json` — 5 beats end-to-end, with optional `{state_key}` interpolation.
  - Programmatic playthrough proven via `godot/test/test_playable_run.gd` (4 tests).
  - **No combat, no cover-test fail arcs, no art beyond placeholder paper-blocks** — exactly as issue #7 specified.

## In-progress

- 🔵 Phase 3: Combat module. Plan not locked yet. Ship grid (8×8?) + CQB (5×5?) + fold mechanic + ledger writes from combat. **Plan-first session pending.**

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

- **GDScript `class_name` is registered in ProjectSettings' `global_script_class_cache.cfg`** — Godot 4 caches class names regardless of source state. Renaming/moving class scripts needs `--headless --import` to refresh. Stale cache throws `'Identifier not found'` even when the file is correct.
- **`extends GutTest` scripts not matching `test_*` prefix are silently filtered** by `-gdir=res://test` — name them `test_foo.gd` or `-gtest=...` them explicitly.
- **Script-mode `-s` boot (-s script.gd) does not run autoloads** before `_init()`; scripts that depend on `<root>/Persist` or class_name access fail with "Identifier not found". Run via GUT (which wires autoloads correctly), or `root.add_child(node)` followed by `await process_frame`.
- **`run_beat("beat_id")` is the cursor-advance primitive** — first call moves cursor to that beat, subsequent calls re-read it. `choose(idx)` is read + apply_delta + advance. Knowing this beats visualising the cursor.
- **narrative/ lives outside the Godot project root** by AGENTS.md convention. Use `ProjectSettings.globalize_path("res://")` to walk up to the repo root. Production builds need bundler (Phase 2c Path-A).
- **`load()` in GDScript conflicts with `ResourceLoader.load()`** — name carefully. `persist.gd` uses `load_state()` to disambiguate.
- **`Node.name` property shadows any instance var named `name`** — even via Dictionary it's confusing. Crew dict key is `"name"`; instance var on the class is `crew_name` to avoid the conflict.
- **`Crew.generate` static call requires `Crew` class_name to be loaded** from project cache; failing that, ScriptCache shows `'Non-existent function generate'`-style errors. (Not a single-tool GUT can't fix — plugin needs project_metadata.cfg sync.)

---

[End of HANDOFF.md]
