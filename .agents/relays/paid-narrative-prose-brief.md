# Paid Agent — Narrative Prose Display Brief

## The project in 3 bullets

- **2.5D paper RPG roguelike** — captain impostor, coalition heritage, He-3 monopoly dismantling arc
- **Godot 4.6.2** + GDScript (explicit types required; variant-inference warnings are errors)
- **91/90+1 GUT pass, 578 asserts** — all 3a–3g shipped, Phase 3 done

## What lands when you start

Everything is merged to `main`. The demo loop runs end-to-end:
- `run_start.tscn` → pick origin (3 genships) → meet crew → Launch → `overworld.tscn`
- Transit to station → encounter fires (shows `flavor_hook` one-liner) → optional CQB → end run → ledger writes

**The critical gap:** Encounter prose and choices exist in beat files but the UI shows one-line `flavor_hook` text instead of the rich narrative writing with player choice buttons.

## Content that already exists (don't redo)

| Content | File | Status |
|---|---|---|
| Encounter pool beats (30 Schema B) | `narrative/beats/encounter-pool-beats.json` | Prose + choices ready, `next_beat` field (`"run_end_summary"` = terminal) |
| CQB Ink beats (8 Schema A) | `narrative/beats/cqb-ink-beats.json` | Cover-test pass/tiers + CQB outcomes. `{station}`, `{captain.short_form}` variable interpolation needed |
| Station arrival beats (20 Schema A) | `narrative/beats/station_arrival_beats.json` | 10 stations × 1 arrival each + 10 second-visit variants. Full prose + choices |
| Voice corpus split (Phase 3g) | `narrative/data/die_in_throes.json` + `captains_journal.json` | 52 entries each, dedicated loaders |

## Code modules shipped (don't rebuild)

| Module | File | Key function |
|---|---|---|
| Overworld controller | `godot/scripts/overworld_controller.gd` | Has `_load_encounter_beat()` + choice button wiring already. Shows prose, renders 3 choice buttons, applies deltas on choice |
| Encounter pool | `godot/scripts/encounter_pool.gd` | `roll()` returns dict with `beat_id` matching encounter-pool-beats.json |
| Beat runner | `godot/scripts/beat_runner.gd` | Manifest loader + `_interpolate()` for `{var}` replacement. Schema A linear manifests |
| AI orchestrator | `godot/scripts/ai.gd` | `step_X_meet_aliens()` runs CQB engagement, returns combat outcome + casualties |
| CQB engagement | `godot/scripts/cqb_engagement.gd` | Full grid turn-loop, returns `{combat_fired, outcome, casualties}` |

## Next work (queue)

| Priority | Task | File surface | Current state |
|---|---|---|---|
| **1** | **CQB Ink beats after combat** — When `_on_proceed_pressed()` fires CQB and gets a result, load matching beat from `cqb-ink-beats.json` and display prose + choice buttons instead of hardcoded outcome strings. Map combat outcomes to beat IDs: `pass-clean` → `cqb_cover_pass_clean`, `pass-rough` → `cqb_cover_pass_rough`, `won` → `cqb_end_won`, `lost` → `cqb_end_lost`, `fled` → `cqb_end_fled`, `casualty` → `cqb_end_casualty`. | `overworld_controller.gd` | Placeholder text |
| **2** | **Station arrival beats** — When transit completes with no encounter (`routine arrival`), load matching beat from `station_arrival_beats.json` using the station's `id` field (e.g. `STATION_01` → `station_arrival_KASHNER_01`). Show prose + choices. | `overworld_controller.gd` | Shows "Routine arrival" |
| **3** | **Variable interpolation** — CQB beats use `{station}`, `{captain.short_form}`, `{alien_archetype}` tokens. Implement string replacement before display. Ship state has the station name; captain dict has short_form; CQB result has alien_archetype. | `overworld_controller.gd` or new util | Tokens render as raw text |
| **4** | **Fallback chain** — If no beat file found / beat_id not found / prose empty: show existing `flavor_hook` text. Never crash, never show raw JSON. | `overworld_controller.gd` | Partially done (returns false → fallback) |

## Godot 4.6 pitfalls

- **Variant-inference warnings are ERRORS** — use `var x: Type = ...` not `:=`
- **`class_name` registration** — after new class_name scripts, run `godot --headless --path godot --import` to refresh cache
- **`extends GutTest` scripts** not matching `test_*` prefix are silently filtered
- **`load()` conflicts with `ResourceLoader.load()`** — project renamed to `load_state()` in persist.gd
- **narrative/ lives outside the Godot project root** — use `ProjectSettings.globalize_path("res://")` + `"../"` to reach it (the existing `_load_encounter_beat` pattern works)
- **`Node.name` property** shadows instance vars named `name` — crew dict uses `"name"` key, scripts use `crew_name`

## Docs to read first

1. `docs/VISION.md` — product frame
2. `docs/BIAS_GUARDRAILS.md` — mandatory before writing narrative
3. `HANDOFF.md` — current state + known issues
4. `docs/ROADMAP.md` — phase boundaries
5. `godot/scripts/overworld_controller.gd` — the file you'll edit most
6. `narrative/beats/cqb-ink-beats.json` — CQB beat schema
7. `narrative/beats/station_arrival_beats.json` — station beat schema
8. `narrative/beats/encounter-pool-beats.json` — encounter beat schema

## Boundaries

| Do | Don't |
|---|---|
| Edit `godot/scripts/overworld_controller.gd` | Write new content beats, lore, or JSON data |
| Add new test files for prose display | Touch `narrative/data/*.json` content files |
| Fix bugs in encounter wiring | Rewrite `EncounterPool.roll()`, `Travel.transit()`, or `beat_runner.gd` interfaces |
| Add variable interpolation helper | Touch `BIAS_GUARDRAILS.md` |
| Wire CQB beats into display flow | Change `ai.gd` orchestrator logic |
| Run `godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://test -gprefix=test_ -gexit` after every commit | Touch `narrative/beats/*.json` content |

## Workflow expectations

- Report with prefix: `prose: <task> — <status>`
- Commit small, one concern per commit
- Test after every commit: `godot --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://test -gprefix=test_ -gexit`
- Bias-check: every narrative beat already bias-checked; don't rewrite, just display
- Ship-partial if infrastructure-blocked — commit what exists, document deferral in body

## Communication

- Bayard is the creative director — relays between you and coordinator
- Coordinator watches for regressions, doc drift, architecture boundary crossing
- Blockers: report fast, don't spin

---

**Expected commit messages:**
```
feat(ui): show CQB Ink beats with prose + choice buttons after combat
feat(ui): show station arrival beats on routine station docking
fix(ui): interpolate {captain.short_form} and {alien_archetype} in beat text
```
