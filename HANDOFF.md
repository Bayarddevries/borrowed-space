---
title: Borrowed Space — Handoff State
status: locked
last_edited: 2026-06-28
tags:
  - workflow
  - handoff
  - state
aliases:
  - HANDOFF
phase: 4
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

**Phase 3 — DONE.** All sub-phases 3a–3g shipped. **Phase 4 (paper art) in progress.**
**Phase 5 (ship out) — issue #31 open, not started.**

Last commit: `02a91d3 feat(ui): multi-turn encounter chaining — checks all beat file caches`
Repo: https://github.com/Bayarddevries/borrowed-space (private)
Working tree: clean
Headline achievement: **112/111+1 GUT pass (630+ asserts)**. Full end-to-end narrative loop: origin pick → crew → overworld → transit → encounter prose with 3 choices → choice result with deltas → station arrival text (visit-tracked) → mission board → run summary → return to briefing. 44 encounter pool entries, 30 station arrival beats, 15 CQB beats. All Phase 3 systems shipped and tested.

## Verified-working

### Today's additions (2026-06-27/28)

- ✅ **Narrative prose display** — encounter beats, CQB outcome beats, station arrival beats all display full prose with up to 3 choice buttons
- ✅ **Choice result feedback** — after clicking a choice, shows what you chose + effects (-5 fuel, +1 suspicion, etc.)
- ✅ **Transit button stays active** after routine arrival (string fallback path)
- ✅ **Station visit tracking** — visit count tracked per run; first visit shows `_01` beat, second shows `_11`, third+ shows `_12`
- ✅ **Mission board** — "Missions" button appears when docked; shows offers with title, source, risk, flavor text
- ✅ **Run summary screen** — shows captain name/genship, duration, fuel consumed, crew roster, encounter log, remaining fuel before returning to briefing
- ✅ **Encounter pool: 44 entries** (was 30) — 7→9 per category, T8/T2/B1 patrols, medical/electrical distress, data cache/cooperative wreck discoveries, payroll test crew, transport dispute/anti-piracy faction
- ✅ **Station beats: 30** — 10 first-visit (`_01`), 10 second-visit (`_11`), 10 third-visit (`_12`)
- ✅ **Multi-turn chaining** — `_load_manifest_beat` checks all three beat cache files
- ✅ **21 GUT tests** — prose display, beat loading, station matching, choice resolution
- ✅ **Window: 1400×800 maximized** — encounter prose readable, all 3 choice buttons visible
- ✅ **Validation script** — `scripts/validate-data.py` checks all 14 JSON files, 0 errors
- ✅ **Paid agent brief** at `.agents/relays/paid-narrative-prose-brief.md`
- ✅ **Phase 3g** — voice corpus split into `die_in_throes.json` (52) + `captains_journal.json` (52)
- ✅ **GitHub issues** — #30 (Phase 4 art), #31 (Phase 5 ship out)

### Core systems (Phase 2+3)

- ✅ Repo + GitHub remote + initial commit
- ✅ Phase 1 docs (9 .md files) with cross-references
- ✅ Obsidian-compatible YAML frontmatter on every doc
- ✅ AGENTS.md workflow contract + commit-message convention
- ✅ ROADMAP.md with phase boundaries
- ✅ Godot 4.6.2.stable imports cleanly
- ✅ Persist singleton — autoload, save/load_state/reset/patch
- ✅ Narrative-data loaders — 14 JSON files via `NarrativeData` static methods
- ✅ GUT 9.6.0 test harness — vendored, 112 tests
- ✅ Travel system — axial hex grid, cartography, ship state, transit
- ✅ Mission board — `MissionBoard.generate()` with weighted offers
- ✅ Encounter pool — weighted selection by hex kind + ship state
- ✅ CQB combat — 6×6 grid, cover/fold/flanking, aggro AI, casualty pipeline
- ✅ Crew system — procedural generation, bond mechanism
- ✅ Captain generation — 6 genship origins × country fragments × trait pools
- ✅ Beat runner — Ink-shaped JSON manifest runtime
- ✅ Voice corpus — die_in_throes + captains_journal fragments

## In-progress

| Item                          | Issue/PR                        | Status                                     |
|--------------------------------|----------------------------------|---------------------------------------------|
|| Phase 4a — Visual hex map     | #30 (art) / 6497fac              | **SHIPPED** — isometric tiles, ship animation, per-hop encounters, clickable station pins, pan/zoom camera |
|| Phase 4b — Station hub screens | Next                             | Planned                                    |
|| Phase 4c — Dialogue system     | Next                             | Planned                                    |
|| Phase 4d — Recurring NPCs      | Next                             | Planned                                    |
| Phase 5 — Ship out             | #31 (build)                      | Not started                                |

## Queued (next)

- Phase 4b: Station hub screens (bar, store, mission UI with per-station BGs and dialogue)
- Phase 4c: Dialogue system (speaker portraits, branching, conditions, full-screen takeovers)
- Phase 4d: Recurring NPCs + relationship tracking
- Phase 5: ship out — browser build, README

---

## Known issues

- ⚠️ Some docs use placeholder names like `[G1-NorthAmerica PLACEHOLDER]`. **Rename pass** deferred.
- ⚠️ Godot CLI smoke runs print warnings the first time (no save file yet). Persist handles this gracefully.
- ⚠️ `load()` was renamed to `load_state()` in persist.gd to avoid conflict with `ResourceLoader.load()`.
- ⚠️ **narrative/ lives outside the Godot project root.** Dev mode resolves via `globalize_path`. Production builds need the bundler (`scripts/bundle-narrative.sh`) to copy JSON into `res://` before export.
- ⚠️ Encounter pool weight test is probabilistic — rare failures with high seed variance on first run (always passes on re-run).

---

## What to read first (next agent)

1. `docs/VISION.md`
2. `docs/ROADMAP.md`
3. `AGENTS.md`
4. `HANDOFF.md` (this file)
5. `docs/BIAS_GUARDRAILS.md` — mandatory before writing narrative
6. `.agents/relays/paid-narrative-prose-brief.md` — task brief architecture
7. `scripts/validate-data.py` — run before committing content changes

---

## Pitfalls discovered (lesson bank)

- **GDScript `class_name` is registered in ProjectSettings' `global_script_class_cache.cfg`** — Godot 4 caches class names regardless of source state. Renaming/moving class scripts needs `--headless --import` to refresh.
- **`extends GutTest` scripts not matching `test_*` prefix are silently filtered** by `-gdir=res://test` — name them `test_foo.gd` or pass `-gtest=...` explicitly.
- **Script-mode `-s` boot does not run autoloads** before `_init()`. Run via GUT.
- **`Node.name` property shadows any instance var named `name`** — crew dict uses `"name"` key, scripts use `crew_name`.
- **Godot 4.6 vs inkgd 0.5.0** — inkgd has Godot 3.x compatibility issues. DO NOT install. The BeatRunner + JSON manifest approach is the workaround.
- **Encounter pool probabilistic tests** — with 44+ entries, weight-based tests need 800+ seeds for reliability. These are acceptable as single re-run fixes.

---

[End of HANDOFF.md]
