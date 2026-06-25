---
title: Borrowed Space — Combat System
status: locked
last_edited: 2026-06-24
locks: code|sessions
aliases:
  - COMBAT
  - Combat
phase: 3e
related:
  - "[[GAMEPLAY_LOOP]]"
  - "[[MAP]]"
  - "[[PERSISTENCE]]"
  - "[[TRAITS]]"
  - "[[BIAS_GUARDRAILS]]"
  - "[[COMBAT_PLAN_LOCK]]"
---

# Combat System — DESIGN LOCKED

Combat in Borrowed Space is **CQB-first, space combat-deferred**. The whole roguelike persistence hinge — "*I remember Marcell*" — sits in close-quarters engagements, not in capital-ship broadsides. So Phase 3e builds the CQB layer; Phase 3f builds space combat.

---

## At-a-glance (locked values)

| Layer | Value |
|---|---|
| Grid | **6×6 default**, 5×5 cramped, 7×7 boss — set per-encounter via JSON |
| Action economy | **2 AP per crew per turn**; standard move or attack = 1 AP |
| Cover | Half = 25% damage reduction; full = 50%; flanked = ignored; no destructible cover v0 |
| HP | 8-12 per crew (rolled at generation) |
| Weapons | light weapon = 1d6 damage; heavy weapon = 2d4 damage |
| Enemy AI | aggro-pathfind-attack-LOS, single function, JSON-driven stats per archetype |
| Death pipeline | at HP=0: pause → Ink tribute (voice-cite from `voice_fragments`) → ledger entry → resume |
| Fold (T-trait) | when suspicion > 3: crew attacks −1, enemy attacks vs crew +1 (two-way malus). Per-trait fold, not global. Clamp suspicion at 6. |
| UI | ASCII grid first (1-2 hr prototype); paper-cutout after Phase 3f direction page locks |

---

## 1. Grid runtime

`CqbGrid.gd`:

- `grid: Array[Array]` — 6×6 default, declared at `CQB.new(grid_size := 6)`.
- `tiles[x][y] := {type: "floor"|"half_cover"|"full_cover", actor: null, height: 0|1}`.
- `place_actor(id, x, y)` validates tile is `floor` or `cover` (cover tile with `actor` is invalid).
- `move(actor_id, dx, dy)` consumes 1 AP, validates adjacency in 8-neighbor, updates tile.
- `line_of_sight(a, b)` — Bresenham or hex analog; full cover blocks, half cover doesn't.
- `flanked?(actor_id)` — actor's tile has enemies on 2+ opposite edges → cover ignored this attack.
- `attack(attacker_id, target_id)` — consumes 1 AP, rolls weapon, applies cover + flanking + fold modifiers, mutates HP.

The grid is **axial-friendly** if we keep using `hex.gd` for `axial_distance()` — keeps distance math consistent across travel and combat.

## 2. Action economy

```
2 AP / turn per crew.
1 AP  = standard move (1 tile)
1 AP  = standard attack
free  = cover-grant (taking cover = free), reload (free, only when out of ammo, free anyway v0)
```

No dash / no overwatch v0. Ship simple.

Order of resolution each turn:

1. **Player phase:** all crew take their 2 AP each. Order by `tdy` rank? Or by player-given order? **Locked decision**: player-given order (drag-to-reorder UI later; for ASCII prototype, implicit: by list order).
2. **Enemy phase:** all enemies take their 2 AP each. Deterministic order = list order.
3. **Cleanup:** `npc_status == dead` → fire tribute; remove from grid.

## 3. Cover semantics

| Cover type | Damage reduction |
|---|---|
| None | 0% |
| Half | **25%** (rounded down; min damage 1) |
| Full | **50%** (rounded down; min damage 1) |
| Flanked | ignored — full damage |

`flanked?` rule: count enemies on the 4 side-adjacent tiles; if 2+ enemies are on **opposite** edges, fail cover and apply full damage.

`height`: tile with `height: 1` grants +1 attack die (advantage on damage roll). Stacks with cover.

Destructible cover: **deferred.** No doors, no exploding walls v0.

## 4. Equipment (locked but ships lightweight)

`crew[].weapon` is one of:

- `light_pistol` → 1d6, range 3 tiles
- `cutting_laser` → 1d6, range 2 tiles, ignores half-cover
- `heavy_rifle` → 2d4, range 5 tiles
- `industrial_cutter` → 2d4, melee (range 1)

+1 attack-die when target is flanked. No modular attachments v0. Each crew has *one* weapon assigned at gen-time from a `weapon_pool` for their archetype.

## 5. Enemy AI (single function, JSON-driven)

```gdscript
func ai_action(enemy: CqbActor, grid: CqbGrid, fold := 0) -> CqbAction:
    var target = closest_crew_in_line_of_sight(enemy, grid)
    if target == null:
        # no LOS — move toward closest crew regardless (last-known-pos)
        return CqbAction.move(enemy, step_toward(enemy, grid.closest_friendly()))
    return CqbAction.attack(enemy, target, fold)
```

Three behaviors are *config-driven* via JSON:

- `aggro_threshold` — min HP% before retreating
- `retreat_to_tile` — optional tile id to retreat toward
- `bodyguard_target` — never attack if `bodyguard_target` is alive

For v0, all enemies are `aggro` with stat variety. Behaviors (guard/coward) arrive in Phase 4 if the loop calls for it.

**Stats JSON:**

```json
{
  "archetype_id": "alien_worker",
  "hp_max": 6,
  "weapon": {"id": "claw", "damage": "1d6", "range": 1},
  "aggro_score": 1.0,
  "flavor_cite": "claw swipes"
}
```

## 6. Casualty pipeline (the roguelike heart)

`CasualtyPipeline.gd`:

```
on crew HP == 0:
  pause combat
  tribute_voice_cite = pick_random(crew.voice_fragments)
  tribute_paragraph = "It wasn't %s. It was the cover." % [tribute_voice_cite]
  ledger.write({
    "died_at_run": run_id,
    "died_in_battle": battle_id,
    "archetype_id": crew.archetype_id,
    "variant_id": crew.variant_id,
    "name": crew.name,
    "bond_score_at_death": crew.bond_score,
    "held_trust_at_death": crew.held_trust,
    "tribute_paragraph": tribute_paragraph,
    "battle_hex_tile": crew.tile_id
  })
  persist.patch("ledger.captains[%d].crew[%d].status" % [n, i], "casualty")
  resume combat (with enemy-turn skipped — battle ends on next "won" check)
```

**Why this is the heart:** the Book of Borrowed Captains renders these tributes as little inline paragraphs. They make next-run ghosts feel like *people*.

`voice_fragments` are picked at gen-time from a 60-entry corpus in `narrative/data/voice_fragments.json`. The picked set is small (2-3 fragments) — but they accumulate across runs (the `voice_fragments` pool *grows* across runs, mirroring the legacy-trace mechanic).

## 7. Cover-test dialog layer

`CoverTest.gd`:

```
func roll(captain, crew_best_stat):
  var roll = rng.randi_range(0, 19) + captain.h_tier_peak + crew_best_stat
  var thresholds = {
    "pass-clean":   >= 18,
    "pass-rough":   >= 14,
    "fail-soft":    >= 9,
    "fail-hard":     < 9
  }
  return {
    "tier": tier_from_thresholds(roll),
    "raw_roll": roll,
    "modifiers_applied": [...]
  }
```

Tier → runtime routing:

| Tier | Result |
|---|---|
| pass-clean | Ink `station_pass_through_clean` beat; no combat |
| pass-rough | Ink `station_pass_through_rough` beat; suspicion +1; no combat |
| fail-soft | Ink `station_cqb_enter` beat; full CQB starts |
| fail-hard | captain-led detention arc. Ink `detention_arc` beat. No combat this run. |

Cover-test replaces any existing "negotiation roll" — it's the one pre-combat gating mechanic.

## 8. Fold mechanic (suspicion > 3)

Already documented in `TRAITS.md`. Combat integration:

- At `CQB.start`, read `captain.suspicion`. If > 3: fold all T-traits (mark ✕ in `t_slots`).
- **Mod-1 mechanic**: folded traits give `-1` to all crew attacks, and `+1` to all enemy attack rolls against the crew.
- 2-way cost makes suspicion tangible without runaway loops.
- Clamp suspicion at 6 (suspicion 6 → all T-traits folded, no more marginal escalation).
- Per-trait fold: each one rolls independently. A single ✕ in `t_slots` gives the mod for *that* trait's check, not all checks.

## 9. UI direction

**v0 (this phase):** ASCII prototype. `cqb_view.tscn` shows 6×6 grid with `█` for crew, `×` for enemies, `▒` for half-cover, `█` for full-cover, `_` for floor. HP shown as a number to the right of each token. Player clicks tile to select, clicks again to move/attack.

**Visual layer (Phase 3f+):** swap tokens for paper-cutout sprites; keep same grid math; add flint-lock sound on hit; `voice_fragments` show in a side panel during tribute pause.

Visual layer is **NOT in this phase.** It blocks on a DirectionPage pass (Phase 3f).

## 10. Scene flow (locked)

```
ai.step_X_meet_aliens(ship, current_station):
  var crew_picked = pick_crew_for_alien_contact(ship.active_crew, alien_archetype_modifier)
  var cover = CoverTest.roll(captain, best_stat_of(crew_picked))
  match cover.tier:
    "pass-clean":
      InkRunner.run("beats/station_pass_through_clean", {station: current_station, captain: captain.short_form})
    "pass-rough":
      InkRunner.run("beats/station_pass_through_rough", {station: current_station, suspicion_delta: +1})
      Persist.patch("ledger.captains[%d].suspicion" % run_id, +1)
    "fail-soft":
      var result = CQB.run(crew: crew_picked, aliens: alien_archetype, grid_size: encounter.grid_size, fold: fold_mod(captain))
      CasualtyPipeline.process(result, captain, run_id)
      InkRunner.run("beats/station_cqb_end_%s" % result.outcome, {
        outcome: result.outcome,
        casualty_count: len(result.casualties),
        cqb_turns: result.turn_count,
        ledger_citations: extract_casualty_names(result)
      })
    "fail-hard":
      InkRunner.run("beats/station_detention_arc", {station: current_station, suspicion_delta: +2})
      Persist.patch("ledger.captains[%d].suspicion" % run_id, +2)
```

This slot replaces any prior `ai.gd` "encounter handler" stub.

---

## Linked issues (Phase 3e)

- Issue #14 — `CqbGrid.gd` runtime (math + AP + state mutation)
- Issue #15 — `CoverTest.gd` (gate-check, returns `tier`)
- Issue #16 — `CasualtyPipeline.gd` (ledger writes + tribute formatting)
- Issue #17 — `cqb_ai.gd` (JSON-driven behaviors)
- Issue #18 — Four Ink beats
- Issue #19 — `test_cqb.gd` (8-10 GUT tests)
- Issue #20 — Visual layer (deferred; blocked on Phase 3f DirectionPage)

---

## Plain English

Combat is **CQB**. 6×6 grid. Each crew has 2 AP. Half-cover blocks 25% damage, full-cover blocks 50%, flanking beats cover. Enemies path-find to you and attack. When a crew member's HP hits zero they get an Ink tribute (a 2-line paragraph from their collected `voice_fragments`) and a ledger entry — that's how the roguelike persistence *feels* personal. T-traits fold when suspicion > 3 (captain's crews miss their shots, enemies hit harder). Space battles and pretty visuals are deferred.

This file now supersedes `COMBAT_PLAN_LOCK.md`. That doc remains as the audit trail of how we got here.
