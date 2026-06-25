# Phase 3e — cqb_ai.gd + aliens.json

## What you are building
Two artifacts for Phase 3e (combat). Specs locked at `docs/COMBAT.md`
in the **borrowed-space** repo (path: `~/projects/borrowed-space`):

1. `godot/scripts/cqb_ai.gd` — enemy AI runtime.
2. `narrative/data/aliens.json` — 4 enemy archetype stat blocks.

Issue: #17 (Phase 3e — cqb_ai.gd + aliens.json, label `phase-3e,combat`).
Repo: https://github.com/Bayarddevries/borrowed-space (private).

## Read in this order before doing anything
1. `docs/VISION.md` — product frame.
2. `docs/ROADMAP.md` — phase context.
3. `HANDOFF.md` — current state.
4. `docs/COMBAT.md` — **the lock**. 6×6 grid, 2 AP, cover, fold.
   Sections §5 is yours. Sections §6 (casualty pipeline) and
   §10 (scene flow) **you will be called by** — read but DO NOT edit.
5. `godot/scripts/cqb_grid.gd` — the API you call into. Stable
   surface: `actors` (Dictionary keyed by id), `actor_at(x,y)`,
   `actor_pos(id)` returns Vector2i, `is_alive(id)`, `ap_remaining(id)`,
   `tile_at(x,y)`. Read this file first; do NOT modify it.
6. `docs/AGENTS.md` — workflow contract.
7. `docs/BIAS_GUARDRAILS.md` — bias-check before commit.

## Done = (one sentence)

`test_cqb_ai.gd` shows 4 cases (pathfind reduces distance, LOS-aware
targeting, dead-enemy skipped, all 4 alien archetypes load and validate);
aliens.json loads via NarrativeData and stats match the weapon table in
cqb_grid.gd.

## API you must implement

`cqb_ai.gd` (extends Node, `class_name CqbAI`):

```
static func decide_action(enemy_id: String, grid: CqbGrid, fold_mod: int = 0) -> CqbAction
```

`CqbAction` is a Dictionary literal:

```
{
  "kind": "attack" | "move" | "wait",
  "actor": enemy_id,
  "target_id": String,         # for attack; "" otherwise
  "step_to": Vector2i          # for move; (0,0) otherwise
}
```

Use `static`, not `self`. Reason: the AI is called from
`ai.gd.step_X_meet_aliens` and from the eventual `#21 integration` issue.

## Bias-watch

Do **not** strip roles/voices/passions from an alien. Aliens are people
with motives in the same world as the captain's crew. The T4 SomaGenesis
trap (BIAS_GUARDRAILS.md) is the one to dodge most — genetic-program /
clipped-sentence othering is the cheap move. Cross-reference TRAITS.md.

## Acceptance

- 4 cases in `godot/test/test_cqb_ai.gd` all-pass.
- 4 archetypes in aliens.json, all weapon_ids match weapon-table.
- Compile with `godot --headless --path godot --import` (no errors).
- Bias-check paragraph appended to CHANGELOG.md Phase-3e entry.
- Hand-off note appended to HANDOFF.md Stage update.
- Commit on a fresh branch (`phase/3e-cqb-ai`) with footer:
  ```
  Closes #17
  Phase: 3e
  ```
- Open a PR via `gh pr create`. Don't merge directly to main.

## What you must NOT do

- Don't introduce behaviors (guard/coward). Phase 4 has those.
- Don't change `cqb_grid.gd`. If you find a bug, log to ISSUES.md.
- Don't bypass Persist for ledger writes — all writes go through it.
- Don't add a 3rd-axis library on top of the simple pathfind. Single-function
  aggro pathfind. That's the whole v0.
- Don't add bike-shed: no UI, no animations, no audio.

## Pitfalls (from the same repo's HANDOFF.md)

- `class_name` registration: Godot 4 caches class names in
  `global_script_class_cache.cfg`. `--headless --import` refreshes it
  after you set `extends Node` + `class_name Foo`.
- `extends GutTest` scripts not matching `test_*` are silently
  filtered by `-gdir=res://test`.
- Headless test invocation:
  `godot --headless --path godot -s res://addons/gut/gut_cmdln.gd
   -gdir=res://test -gexit` (the `-s` form requires `extends
  SceneTree`, not `extends GutTest`).
- In Godot 4.6, **variant-inferred warnings are errors**. Declare
  `var g: CqbGrid = ...` not `var g := ...` if you're holding a
  ref to a custom class.
- Narrative data lives at `narrative/data/` **outside** `godot/`.
  Use `godot/scripts/narrative_data.gd` load paths, which resolves
  via `ProjectSettings.globalize_path("res://")`.

## Stop conditions (log to ISSUES.md and stop)

- Godot CLI missing.
- `git status` shows someone's uncommitted work: stop and ask.
- `docs/COMBAT.md` not found or `status: locked` is missing.
- aliens.json validates weapon ids against weapon-table with zero matches.
