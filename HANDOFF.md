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

## Phase

**Phase 3e (combat) plan locked.** 6×6 default grid, 2 AP/turn, half/full cover (25%/50%), flanked-waives. Single aggro AI, JSON-driven stats. Casualty pipeline: HP=0 → Ink tribute + ledger entry. Fold mechanic two-way cost (crews −1 attack, enemies +1 attack). Ship ASCII prototype first. Specs at `docs/COMBAT.md`. Issues #15–19, #21 opened. #20 (visual layer) deferred to Phase 3f.

Last commit: `529463b docs(handoff): post-merge update for Phase 3a.1 + 3a.2`
Repo: https://github.com/Bayarddevries/borrowed-space (private)
Working tree: clean
Headline achievement: 23/23 GUT tests pass; Phase 3e plan locked + 7 issues opened; Phase 3a combat scaffolding parallel-tracked with Phase 3d-3f via separate sub-agents.

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
- ✅ **Phase 2d Persistence singleton** working — `<root>/Persist` autoload, save/load_state/reset/patch all green.
- ✅ **Phase 2e Narrative-data shape** — 3 JSON files in `narrative/data/`, smoke-tested.
- ✅ **Phase 2f Test harness (GUT 9.6.0)** — vendored, 14/14 tests pass.
- ✅ **Phase 2 final — Sample playable run** — 7-step sequence per issue #7; visible-demo via `godot/test/test_demo_visible_run.gd`; ship record written to `ledger.captains["1"]`.
- ✅ **Phase 2 alignment commit** (this session) — TRAITS / PERSISTENCE / BIAS_GUARDRAILS docs aligned with cross-agent gameplay-loop handoff (GAMEPLAY_LOOP.md / MISSION_BOARD.md / ENCOUNTER_POOL.md / NPC_STATE_SELECTION.md / GENSHIP_ORIGIN.md).
- ✅ **`docs/MAP.md` locked** — phase 3a.1 design: bipolar belt (inner 25 / outer 40+), per-move clock (1 day / 1 fuel / 1 suspicion), ghosts-of-past-captains cartography (manifest-ledges never avatars), hub-and-spoke open-belt encounters (mostly one-shot, ~15% multi-turn saves), sector view as default zoom target. Cross-linked from ROADMAP.md Phase 3a.
- ✅ **Phase 3a.0 content merged** (`8f4cc55`) — `empty-space-manifest.json` (16 beats across distress / stranger / failure / crew-fight) + `legacy-trace-prototype.json` (1 past-captain ghost-pin beat with `data_spec` block defining the future `legacy_trace_system.gd` contract). Both rounds-trip through the manifest parser; 14/14 GUT tests still pass.
- ✅ **Phase 3a journey docs locked** (`ed73c6a`, `f455c32`) — `narrative/beats/_META.md` (Schema A linear / Schema B pooled beats, delta vocabulary locked); `docs/ENCOUNTER_POOL.md` (interface contract for `EncounterPool.roll(ship, arrival_kind)`); `docs/COMBAT.md` placeholder stub preventing accidental combat references elsewhere. TODO.md + ISSUES.md synced. Stale `[[CARTOGRAPHY]]` wikilinks replaced with `[[MAP]]` (CARTOGRAPHY.md never existed).
- ✅ **Phase 3a.2 content shipped** — `phase/3a.2-stations-content` branch: `narrative/data/stations.json` (10 named stations: Kashner Iceworks, Bentic Penal, Corvallo Station, SX Halo, Orpheum Astrogrowth, Prophet's Threshold, Denise Mar, Berezina Drift, Moscow Prospekt, Coral — matching `cartography.json` faction split exactly); `narrative/beats/station_arrival_beats.json` (10 Schema A beats with atmosphere-based dialog).
- ✅ **Phase 3a.1 travel-system MERGED** (`1884277`) — axial-hex math helpers (`hex.gd`), JSON-driven cartography (`cartography.gd` + `narrative/data/cartography.json` with 10 stations STATION_01..STATION_10), per-run ship state (`ship.gd`), transit orchestrator (`travel.gd`), ai.gd integration in `step_5_6_overworld_and_station()`. **23/23 GUT tests pass** (was 14; +9 new). Real EncounterPool integration held for Phase 3d — Phase 3a.1 ships the registry seam it plugs into.

## In-progress

| Spotify Entry                  | Issue/PR                        | Status                                     |
|--------------------------------|----------------------------------|---------------------------------------------|
| Mission board                  | #9                               | Parse clean; awaiting Persist wiring decision |
| Phase 3f — CQB visual layer    | #20                              | Deferred                                   |
| Phase 3d — EncounterPool impl  | phase/3d-encounter-pool          | Merged to main (`cc19be2`), 56/56 pass    |
| NPC state-selection            | phase/3d-npc-state-selection     | 1fadf25, 8/8 pass, merged to main         |

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
│ **`Node.name` property shadows any instance var named `name`** — even via Dictionary it's confusing. Crew dict key is `"name"`; instance var on the class is `crew_name` to avoid the conflict.
│ **`Crew.generate` static call requires `Crew` class_name to be loaded** from project cache; failing that, ScriptCache shows `'Non-existent function generate'`-style errors. (Not a single-tool GUT can't fix — plugin needs project_metadata.cfg sync.)
│ **Godot 4.6 vs inkgd 0.5.0** — the inkgd addon (pure GDScript Ink runtime) has Godot 3.x compatibility issues (`tool` → `@tool`, `onready` → `@onready`, `Directory` → `DirAccess`, `ToolButton` → `Button`). Do NOT attempt to install inkgd until someone ports the editor plugin to Godot 4.6. The current BeatRunner + JSON manifest approach is the workaround. If you need native Ink, the migration cost is ~2 hours of GDScript compatibility fixes across 10 files.

---

[End of HANDOFF.md]
