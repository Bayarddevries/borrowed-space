---
title: Borrowed Space — Encounter Pool System
status: draft
last_edited: 2026-06-24
tags:
  - encounter
  - pool
  - travel
  - system
aliases:
  - ENCOUNTER_POOL
  - EncounterPool
phase: 3a
related:
  - "[[CARTOGRAPHY]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[MAP]]"
  - "[[_META]]"
---

# Encounter Pool System v0.1 — *Borrowed Space*

**Purpose:** Define the interface contract for the encounter pool — the system that selects which beat fires when the captain transits an open-belt hex. This is a spec-only doc; implementation lives in `godot/scripts/encounter_pool.gd` (Phase 3a.2).

---

## Trigger model

The encounter pool is queried after every successful transit. The travel system calls:

```
EncounterPool.roll(ship: Dictionary, arrival_kind: String) → EncounterResult
```

**Trigger conditions:**
- `TransitResult.ok == true` (ship arrived somewhere)
- `arrival_kind` is one of: `deep_belt`, `lane`, `derelict_hex`, `anomaly_hex`
- Station hexes (`station_hex`) do NOT trigger the encounter pool — they route to station-arrival beats directly.

**No-trigger cases:**
- `arrival_kind == "station_hex"` — station beats handle this
- `ship.fuel == 0` (stranded) — stranded state has its own beat pool (future)
- First 3 ticks of a new run — grace period, no encounters (prevents early frustration)

---

## EncounterResult shape

```gdscript
Dictionary {
    rolled: bool,              # false = no encounter this transit
    beat_id: String,           # which beat to run (e.g., "distress_call_1")
    manifest_id: String,       # which manifest to look up ("empty-space-manifest")
    beat_category: String,     # "distress" | "stranger" | "failure" | "crew_fight"
    weight: float,             # debug: what weight produced this roll
}
```

When `rolled == false`, the transit produces no narrative beat (silent travel).

---

## Weighting rules

Encounter selection is weighted by **hex kind** and **ship state**:

### Base weights by arrival_kind

| arrival_kind | Any encounter? | Notes |
|---|---|---|
| `deep_belt` | 60% chance | Default open space |
| `lane` | 40% chance | Well-trafficked = fewer surprises |
| `derelict_hex` | 80% chance | High activity zone |
| `anomaly_hex` | 100% chance | Always something here |

### Category distribution (conditional on encounter rolling)

| Category | Weight | Scales with |
|---|---|---|
| `distress` | 30% | +10% if `ship.fuel < 30` |
| `stranger` | 25% | +10% if `arrival_kind == "lane"` |
| `failure` | 25% | +10% if `ship.hull < 50` |
| `crew_fight` | 20% | +10% if `bond_score < 0` |

Weights are normalized to 100% after scaling. The pool system rolls a weighted random among active categories, then picks a random beat from that category in the manifest.

---

## Manifest integration

The pool reads beats from manifests of Schema B (`_META.md`). Specifically:

1. Load all manifests with `trigger: "open_belt"` from `narrative/beats/`.
2. Index beats by `category`.
3. On `roll()`, filter eligible beats by category weight, pick one randomly.
4. Return `EncounterResult` with `beat_id` + `manifest_id`.

The AI/BeatRunner then navigates to `beat_id` in `manifest_id` and runs it.

---

## Multi-turn saves (rare subset)

~15% of beats are flagged as "hub" beats (see MAP.md §4). These have a `next_beat` that chains to a follow-up beat within the same category. The pool tracks hub chains in `Persist.state["encounter_hub_state"][captain_n]` so a rescue that started in one transit can resolve in the next.

Hub state resets at end-of-run. See `PERSISTENCE.md` for the hub state shape.

---

## Out of scope (deferred)

- **Stranded encounters** (fuel == 0) — Phase 3d
- **Combat-triggered encounters** — Phase 3b (after combat module lands)
- **Mission-board encounters** — Phase 3c
- **Legacy-trace discovery flow** — handled by `legacy_trace_system.gd` (Phase 3a), not the encounter pool

---

## Test plan (Phase 3a.2 acceptance)

| Test | Asserts |
|---|---|
| `test_pool_rolls_on_deep_belt` | 60% hit rate over 1000 rolls |
| `test_pool_no_roll_on_station` | station_hex → rolled=false |
| `test_pool_weights_scale_with_state` | low fuel → distress weight increases |
| `test_pool_returns_valid_beat_id` | result.beat_id exists in manifest |
| `test_pool_grace_period` | first 3 ticks → rolled=false |

[End of ENCOUNTER_POOL.md v0.1 — spec for Phase 3a.2 implementation]
