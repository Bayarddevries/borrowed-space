---
title: Borrowed Space — Cartography & Travel System
status: draft
last_edited: 2026-06-23
tags:
  - cartography
  - travel
  - hex-coords
  - fuel
  - encounter-rolling
aliases:
  - CARTOGRAPHY
  - Cartography
phase: 3a
related:
  - "[[ROADMAP]]"
  - "[[VISION]]"
  - "[[WORLD_BIBLE]]"
  - "[[TRAITS]]"
  - "[[NPCS]]"
  - "[[PERSISTENCE]]"
---

# Cartography & Travel System v1 — *Borrowed Space*

The **travel system** sits between `step_4_meet_crew` and `step_5_6_overworld_and_station` of the run sequence. It is the *engine* of where you go between stations. Combat (Phase 3b) hangs off it. Missions (3c) hang off it. Encounters (3d) roll against it.

This spec was locked in preparation for Phase 3a.1. It defines rules; the implementation lives in `godot/scripts/travel.gd`, `ship.gd`, `cartography.gd`, with data in `narrative/data/cartography.json`.

---

## 1. Coordinate model — axial hex grid

Belt is charted as a **2D axial hex grid**, radius 25. Hex coordinates are `(q, r)`; hex distance is computed via Red Blob Games' canonical axial-distance formula:

```
axial_distance(a, b):
    dq = a.q - b.q
    dr = a.r - b.r
    ds = -dq - dr
    return (|dq| + |dr| + |ds|) / 2
```

Adjacency = axial distance == 1. Tactical-range (e.g., encounter rolls see neighbors) = axial distance ≤ 2.

### Why axial, not cube
- Two coords (q, r) are typed and serialized cleanly
- Distance math is closed-form, O(1)
- Familiar to anyone who's read Red Blob Games (canonical hex devop reference)

### Hex kinds (per-cell classification, computed)
| Kind | Description | Hazard modifier |
|---|---|---|
| `out_of_play` | hex out of radius | n/a |
| `deep_belt` | empty space | 1.0 |
| `lane` | well-trafficked transit corridor (faction-controlled) | 0.7 |
| `station_hex` | a hex with a station landing pad | 1.0 |
| `derelict_hex` | wreck / abandoned / hazard | 1.5 |
| `anomaly_hex` | discovery-triggering feature | 1.3 |

Hazard modifier scales fuel cost — derelict lanes burn more fuel.

---

## 2. Map data — cartography.json

A single JSON file defining every station in the belt. **Zero lore** is in it — just structure:

```json
{
  "_meta": { "schema_version": 1, ... },
  "stations": [
    {
      "id": "[STATION-A PLACEHOLDER]",
      "q": 0,
      "r": 0,
      "faction_id": "NAC",
      "kinds": ["station_hex", "lane"]
    },
    ...
  ]
}
```

Each station has:
- `id` — unique placeholder string
- `q`, `r` — axial coord (integer)
- `faction_id` — which faction this station's autoload answer is for (one of NAC/ED/RRA/AC/SAA; matches Genship IDs)
- `kinds` — array including `station_hex`; may also include `lane`, `derelict_hex`, etc.

The belt's playable surface = **all hexes within radius 25 of (0,0)** minus `out_of_play`.

### Station count target
8–12 stations seeded. Phase 3a-1 ships 10 (target=**medium** for run traversal time).

### Lore at stations
- Station *names* live in a separate `narrative/data/stations.json` file (Phase 3a.2 brings this in)
- Station *flavor text* lives in Ink files (Phase 3c era)
- Station *description* (paragraph) is `world_bible.md`-level; not in JSON

---

## 3. Ship state

A per-run state object held by `<root>/Ship` (or as a class instance inside `AI`). State fields:

| Field | Type | Notes |
|---|---|---|
| `captain_name` | string | from captain record |
| `genship_id` | string | from captain record |
| `current_q` | int | axial coord |
| `current_r` | int | axial coord |
| `fuel` | int | starts at 100; capped; consumed on transit |
| `hull` | int | starts at 100; decreased by combat (3b) and certain encounters |
| `supplies` | int | starts at 100; consumed by time-passage and crew cost |
| `time_elapsed` | int | measured in transit-ticks; mission boards will gate on this |

Time passes in discrete ticks = one transit = 1 tick. Within a tick, fuel is consumed and an encounter roll happens.

### Fuel-cost rule
```
transit_cost(from, to):
    base = axial_distance(from, to)           # integer ≥ 1
    hex_kind = cartography.hex_kind_at(to)     # string
    modifier = hazard_modifier(kind)
    return round(base * modifier)
```

- 1 hex = 1 fuel (default)
- 1 + 1 derelict hex (modifier 1.5) = 2 fuel
- Lanes cheap — `lane` kind = 0.7 modifier

### Stranding rule
- If `ship.fuel < cost` for any desired transit → cannot move (player must refuel)
- Out of fuel mid-transit is **not** a death — it's a stranded state; encounter rolls still happen

---

## 4. Transit mechanic

`Travel.transit(ship, to_q, to_r) → TransitResult`. Pseudocode:

```
function transit(ship, to_q, to_r):
    if axial_distance(ship.pos, (to_q, to_r)) > ship.fuel:
        return { ok: false, reason: "out_of_fuel" }
    
    cost = transit_cost(ship.pos, (to_q, to_r))
    new_fuel = ship.fuel - cost
    arrival_kind = cartography.hex_kind_at(to_q, to_r)
    
    # Ship advances (only on successful move).
    ship.fuel = new_fuel
    ship.current_q = to_q
    ship.current_r = to_r
    ship.time_elapsed += 1
    
    # Roll encounter if applicable.
    encounter = null
    if roll_encounter(ship, arrival_kind):
        encounter = encounter_pool.roll(ship, arrival_kind)
    
    return {
        ok: true,
        arrived_at: (to_q, to_r),
        arrival_kind: arrival_kind,
        fuel_after: new_fuel,
        cost: cost,
        tick: ship.time_elapsed,
        encounter_rolled: encounter
    }
```

`roll_encounter` is a weighted coin-flip, weights driven by hex kind + adjacency to faction-controlled stations. **Phase 3d replaces the placeholder** with the real encounter pool; Phase 3a-1 ships a stub `nil`-or-trivial text encounter.

---

## 5. Per-run vs persisted state

| Persists across runs | Resets per run |
|---|---|
| — (none) | `current_q`, `current_r`, `fuel`, `hull`, `supplies`, `time_elapsed` |

Travel state is per-run. Stations are world-stable (in `cartography.json`). Player cannot *carry* a position across runs — that's the design intent: each captain navigates fresh.

> ⚠️ Future phase: a "via-the-AI" continuity might let late-game unlocked charts shorten early runs. For Phase 3a-1, this is **out of scope**.

---

## 6. Integration with existing systems

### With `Persist` (phase 2d)
- After each transit, `travel.gd` patches `Persist.state["run_state"][captain_n]["ship"]` with the new ship state snapshot
- On end-of-run, the snapshot rolls into the captain record

### With `LedgerWriter` (phase 2g)
- Discovery rolls (anomaly hexes) push a discovery ID into `ledger.captains[captain_n].discoveries` immediately
- Casualty / bond-shift stays in Phase 3b

### With `AI.gd` (phase 2g)
- Step 5+6 calls `travel.transit(ship, ...)` instead of the manifest's `overworld_choose_1` beat
- `run-start-manifest.json` is updated: the overworld beat yields a hex coordinate; the AI's chooser picks a destination hex

---

## 7. Open questions

These are questions to answer with data, not yet:

1. **Refuel mechanic.** Does arriving at a station give fuel? Some stations yes, some no? This binds to faction modeling.
2. **Time alongside fuel.** Some roguelikes (FTL) decouple fuel from time; some couple. Where does this game fall?
3. **Long-haul vs short-haul stations.** Do stations have "ranges" beyond which they cannot trade / refuel?
4. **Lanes.** We assume lanes exist (`kinds` containing `"lane"`). How visible is that to the player? Tooltips? Revealed late via captain discoveries?

These are queued for Phase 3d–3f. For Phase 3a-1 they have placeholder answers:
- Refuel: stations always give +25 fuel on arrival (placeholder)
- Time: 1 transit = 1 tick; tick passed to mission-board queries
- Long-haul: out of scope, dropped placeholders
- Lanes: held in `cartography.json` `kinds`; player UI in Phase 4

---

## 8. Test plan (phase 3a-1 acceptance)

These tests prove what this spec describes:

| Test | Asserts |
|---|---|
| `test_cartography_loads` | 8–12 stations; all coords in radius; kinds well-formed |
| `test_hex_distance_constants` | axial_distance((0,0),(3,0))==3; ((-5,2),(0,0))==5; adjacent hexes have distance 1 |
| `test_fuel_cost_basic` | 1-hex lane = 1 fuel; 1-hex empty = 1 fuel; 1-hex derelict = 2 fuel; deep-belt 5-hex = 5 fuel |
| `test_transit_consumes_fuel_and_advances_time` | ship.fuel drops = cost; ship.time_elapsed += 1; sets current_* hex |
| `test_transit_blocks_when_out_of_fuel` | fuel=0, transit returns ok=false; reason "out_of_fuel" |
| `test_playable_run_includes_travel` | step 5+6 calls Travel.transit; Persist.run_state reflects ship position |
| `test_visible_run_demo` | demo prints hex coords and fuel after travel (existing demo extended) |

If `test_playable_run_includes_travel` regresses, all known-good behavior is broken — that's the canary test.

---

[End of CARTOGRAPHY.md draft v1 — Phase 3a readiness doc.]
