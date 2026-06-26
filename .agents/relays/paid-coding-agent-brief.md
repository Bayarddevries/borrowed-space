# Paid Agent — Borrowed Space Handoff Brief

## The project in 3 bullets

- **2.5D paper RPG roguelike** — captain impostor, coalition heritage, He-3 monopoly dismantling arc
- **Godot 4.6** + GDScript (explicit types required — variant-inference warnings are errors)
- **64/64 GUT tests pass** (68/70 expected after Local lands — 2 voice_fragments tests will be fixed by Local's PR)

## What lands when you start

By the time you read this, `phase/day-1-demo-loop` should be merged into `main`. It delivers:

| File | What it does |
|---|---|
| `run_start.tscn` + `demo_controller.gd` | Demo launch: Pick origin → see crew → click "Launch" |
| `overworld.tscn` + `overworld_controller.gd` | ASCII hex view, Travel.transit() button, ledger write |
| `demo_session.gd` | Scene-transition glue (NOT game state — Persist is the source of truth) |
| `narrative_data.gd` | RELATIVE_PATHS now includes `voice_fragments` (the one-line fix) |
| `docs/RUN_BOOK.md` | Click-by-click guide Bayard can follow |

**Result:** Bayard can open Godot, hit Play on run_start.tscn, click through an origin pick → crew meet → overworld → encounter → ledger close → return-to-briefing loop. First visible end-to-end run.

## Content that already exists (Remote agent work, don't redo)

| Content | File | Status |
|---|---|---|
| Voice corpus | `narrative/data/voice_fragments.json` | 52 die_in_throes + 52 captain_journal entries, bias-clean |
| Encounter pool beats | `narrative/beats/encounter-pool-beats.json` | 30 Schema B beats, one per pool entry |
| Station beats | `narrative/beats/station_arrival_beats.json` | 20 beats (10 original + 10 second-visit variants) |
| CQB Ink beats | `narrative/beats/cqb-ink-beats.json` | 7 combat outcome beats |
| Encounter pool | `narrative/data/encounter-pool.json` | 30 entries across 5 categories, weighted |

## Code modules shipped (don't rebuild)

| Module | File | Tests |
|---|---|---|
| CQB grid | `godot/scripts/cqb_grid.gd` | 15/15 |
| CQB AI | `godot/scripts/cqb_ai.gd` | 4/4 |
| Casualty pipeline | `godot/scripts/casualty_pipeline.gd` | Via cqb suite |
| Captain journal | `godot/scripts/captains_journal.gd` | Via cqb suite |
| Travel/hex | `godot/scripts/travel.gd`, `hex.gd`, `cartography.gd` | 9 tests |
| Ship state | `godot/scripts/ship.gd` | Via travel suite |
| Mission board | `godot/scripts/mission_board.gd` | 8 tests |
| Encounter pool | `godot/scripts/encounter_pool.gd`, `godot/scripts/narrative_data.gd` | Via travel suite |
| Beat runner | `godot/scripts/beat_runner.gd` | 14+ tests |
| Ledger writer | `godot/scripts/ledger_writer.gd`, `godot/scripts/persist.gd` | Via playable run suite |
| AI orchestrator | `godot/scripts/ai.gd` | Links everything together |
| Captain/Crew | `godot/scripts/captain.gd`, `godot/scripts/crew.gd` | Via playable run suite |

## Next work (your queue)

| Priority | Task | File surface | Impact |
|---|---|---|---|
| **1** | **#21 — ai.gd CQB wiring** — chain encounter pool → CQB grid → casualty pipeline → ledger into the orchestrator. The combat is built but never fires in a run. You need to wire `travel.gd`'s encounter return so it can route to CQB, then route CQB outcomes through the casualty pipeline. | `ai.gd`, `encounter_pool.gd`, `travel.gd`, `cqb_grid.gd`, `casualty_pipeline.gd` | High — makes combat real |
| **2** | **Combat encounter test** — write a GUT test that runs a complete CQB engagement end-to-end through the orchestrator, verifying tribute is written and ledger updates | New test file | High — proves #21 works |
| **3** | **Full suite regression** — after Local's PR merges, confirm all tests still pass. Fix any regression from the scene glue changes | Run `godot --headless -s res://addons/gut/gut_cmdln.gd -gexit` | Blocking gate |
| 4 | #20 — CQB visual layer (deferred) | Needs DirectionPage design | Lowest priority |

## Godot 4.6 pitfalls (from the project wall)

- **Variant-inference warnings are ERRORS** — use `var x: Type = ...` not `:=`
- **`class_name` registration** — after creating new class_name scripts, run `godot --headless --path godot --import` to refresh cache. Otherwise tests fail with "Identifier not found"
- **`extends GutTest` scripts** not matching `test_*` prefix are silently filtered — name them `test_foo.gd`
- **`load()` conflicts with `ResourceLoader.load()`** — the project renamed `load → load_state` in persist.gd. Follow that pattern
- **narrative/ lives outside the Godot project root** — use `_resolve_dev_path()` from `narrative_data.gd`, don't bypass it

## Docs to read first (if you haven't)

1. `docs/ROADMAP.md` — up-to-date, 15-node module table
2. `docs/COMBAT.md` — design-locked CQB system
3. `docs/BIAS_GUARDRAILS.md` — mandatory before writing any narrative content
4. `HANDOFF.md` — current state + known issues

## Boundaries

| Do | Don't |
|---|---|
| Wire existing modules together | Write new content (beats, lore, data) — that's Remote's lane |
| Add new test files | Touch `narrative/data/*.json` content |
| Fix bugs in existing scripts | Rewrite module interfaces — they're designed around the dependency graph |
| Extend `ai.gd` with combat flow | Change the loader pattern in `narrative_data.gd` |
| Run GUT after every commit | Touch BIAS_GUARDRAILS.md |
| Open PRs with `Closes #N` footers | Touch demo_session.gd — it's ephemeral scene glue |

## Workflow expectations

- Report status cards with the prefix `paid: <task> — <status>`
- Open PRs against `main` with `Closes #21` etc.
- Small commits, one concern per commit
- Bias-check your own work — the project has a zero-tolerance policy on tropes

## Communication

- Bayard relays between you and coordinator
- Coordinator watches for regressions, doc drift, and architecture boundary crossing
- Report blockers fast — don't spin on something the coordinator can answer in 2 min

---

[End of paid agent brief]
