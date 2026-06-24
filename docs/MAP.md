---
title: Borrowed Space — Map Design
status: locked
last_edited: 2026-06-23
tags:
  - map
  - travel
  - cartography
  - design
aliases:
  - MAP
  - Space Map
phase: 3a
locked_at: 2026-06-23
locked_by: Bayard + Hermes (consensus)
related:
  - "[[ROADMAP]]"
  - "[[VISION]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[PERSISTENCE]]"
  - "[[TRAITS]]"
  - "[[NPCS]]"
  - "[[WORLD_BIBLE]]"
---

# MAP.md — Space Map Design (locked)

The map is **how the captain experiences space**. Its design is a contract:
the gameplay loop drives the map, *not the other way around*.

This doc locks four answers that were open as of the Phase 2 alignment commit.
Until this doc is revised, those answers are the source of truth.

---

## 1. Topology — the belt

A galactic belt: **two concentric rings** wrapping around a galactic arc.
The belt **wraps** — going one direction for long enough brings you back.
There is no "edge of the map." A captain can always make one more move.

| Layer | Radius | Vibe | Stations |
|---|---|---|---|
| **Inner ring (civilized)** | 25 | Trust-controlled core | ≥13 named stations, one per faction (7 Trust corps + 5 genships + ME) |
| **Outer ring (frontier)** | 40+ | Derelicts, coral-skip anomalies, abandoned genships | Sparse, irregular |
| **Open belt (between)** | between rings | Empty space; transit; minor hazards | None — pure procedural events |

### Station typing

Stations are typed. Each type has a distinct encounter beat shape:

| Type | Beat flavor | Example deltas |
|---|---|---|
| `refueling-outpost` | trade, credit, fuel | `fuel +25`, suspicion 0 |
| `salvage-derelict` | salvage, anomalies, derelict ships | discovery, bond ±1, suspicion ±1 |
| `coral-transit` | deep-space routes, predecessor fates, siphons | discovery, handler job, suspicion +2 |
| `frontier-station` | info brokering, atmosphere, varied | fuel / bond / standing mix |
| `abandoned-genship` | late-game, large stakes | high discovery, high suspicion |

(Station type is a property of the node, not of the captain. Types may vary per cycle.)

---

## 2. Time — per-move clock

Travel has a **single, simple clock**: each move = 1 day.

Each move is one and exactly one of:

1. **Travel** between adjacent nodes — 1 day, costs 1 fuel unit.
2. **Stop at a node** — 1 day, free, encounter fires.
3. **Major event** — variable days, e.g., a multi-turn rescue might burn 2-3 days.

Per-move side effects (ticked together, always):

- Clock +1 day
- Fuel -1 (if traveling)
- Suspicion tick (captain-specific value; +1 base, +2 in coral zones, +0 in friendly refuels)
- Bond aging: long-lived bonds gain +1 every ~10 days (legacy drift)

### Pressure model

Why a clock at all: roguelike pressure. Without a clock, the captain can hide forever and avoid the dismantling arc's escalation. With a clock, **decisions have weight** — every move risks raising suspicion, costing fuel, or revealing more.

### When the clock pauses

- During a multi-turn save beat (the 2-3 day rescue), the clock is **visible** but not "stopped" — fuel cost still ticks, suspicion still ticks.
- During ledger-close (end-of-run summary), the clock freezes for narrative effect.
- Never *paused* — that breaks player intuition. Always *ticking*.

---

## 3. Cartography — ghosts-of-past-captains

**The map is a layered artifact: current run state + past run traces.**

A new captain sees:

- The belt (Topology §1) — fully drawn, but **untyped nodes** (no station name visible)
- Distances and node positions
- A few names of "well-known" stations always visible per lore
- Saved crews from prior captains visible as faint pin clusters — *manifests*, not avatars
- Past-captain manifest-ledges half-illegible — like faded typewriter on parchment

### How ghost traces propagate

| Source | Trace type | Visibility on next run |
|---|---|---|
| Captain **died** with discovery `Heimdall derelict` | Pin mark, 1 line, faded | New captain sees faded pin *without* name |
| Captain **ledger-closed** with discovery `Heimdall derelict` | Pin mark, full name, legible | New captain sees legible pin with name + 1-line description |
| Captain **arrested / mutinied / deserted** | Trace file lost | Nothing carries |
| Captain's **bond** with an NPC ended well | NPC's name faded at last known node | New captain can find NPC if station is reached |
| Crew member **survived across runs** | Crew manifest — full name | New captain faces *legacy-test* with same crew archetype |

### Why this works for the story

The captain is never alone. The next captain inherits a map that is *unnarrated but inhabited* — past captains and crews whose traces they read. This is the Wildermyth resonance: **legacy without ownership**.

The mechanic also unlocks **across-captain stories** — the *Heimdall derelict* is one of many pin clusters. Each pin is a hook for a future player-readable mystery.

### Implementation cost

Cartography ghosts are **purely data + text**, no models.
- Pin mark = a hex position in the belt grid, drawn with the same icon for all
- Faded text = `fonts/faded_handwriting.otf` (cheap to license or hand-draw)
- Trace ledger = 1 manifest file per legacy captain, read by `Persist.load_legacy_traces()`

---

## 4. Open-belt encounters

When the captain travels between stations, **the open belt can fire an encounter.**

### Encounter categories

Four families. All built from one manifest schema:

| Category | Sample beats |
|---|---|
| **Distress call** | "the *Iphigenia*'s distress beacon has been broadcasting 14 days." Help / ignore / pick-over-the-wreckage. |
| **Passing stranger** | "hauler *Praxis C*. Their captain waves." Hail / tail / pretend-no. |
| **Ship failure** | "thermal-bleed in port nacelle." Triage / full-stop / ride-it-out. |
| **Crew fight** | "two crew, factions arguing over a high-g turn." Intervene / adjudicate / de-escalate. |

### Shape: one-shot beats, multi-turn saves

**Most open-belt beats are one-shot.**

- A distress call: hailer fires, 2-3 choices, beats resolves.
- A passing stranger: hail / tail / ignore, beats resolves.
- A ship failure: triage / stop / ride-out, beats resolves with a delta.

**A rare subset are multi-turn saves.** A save beat differs:

- Beat 1: encounter fires
- Choice: help (costly) / ignore (cheap)
- Beat 2 (if helped): "the *Iphigenia* reaches you; you have room for one crew-member"
- Choice: take / take-and-promise-to-return / take-and-cut-them-loose
- Beat 3 (later run): if same captain meets same NPC, legacy line fires

This produces the Wildermyth shape: *a small rescue becomes a recurring contact.*
It's **hub-and-spoke** — most beats are spokes, ~15% are hubs.

### Why dialog-heavy

90% of beat content lives in **Ink dialog**. Coded deltas are minimal:
`bond_score +1`, `crew_xp[N] += 1`, `suspicion +1`, `fuel -1`.

Dialog varies by captain type: an *ex-helm captain* gets different lines than an *ex-mutiny captain*.

---

## 5. View — sector view (zoom target)

Three layers of camera detail, ranging simple-to-rich:

| Layer | Purpose | Visible content |
|---|---|---|
| **Galaxy view** | orient-on-start | belt + ring positions only, low detail |
| **Sector view** | **default gameplay view** | 6-8 nodes around captain; names/types/edges; pin marks visible |
| **Approach view** | arrival moment | single node filling viewport; name appears; encounter triggers |

Default gameplay lives in **sector view**. Galaxy view is for first-launch and ledger-close cutscenes. Approach view is the beat-intro cinematic (≤3 seconds).

### Why sector, not full-belt

- Players focus on **immediate decisions**, not omniscient planning
- Past-captain pin marks render at sector scale, not as a global overlay
- Matches Wildermyth's regional map (within a region, not the world)
- 2.5D art pipeline produces regional tiles, not full-map renders — feasible cost

### Implementation shape

- Galaxy view = `godot/scenes/galaxy_view.tscn` (a single godot scene, 2D with belt circle drawn)
- Sector view = `godot/scenes/sector_view.tscn` (twin. view. with hex/cell grid)
- Approach view = `godot/scenes/approach_view.tscn` (a postcard-style zoom-in)

Mapping between views is `MapState.focus_node` — which node has the camera.

---

## 6. What this doc explicitly does NOT cover

These are open questions blocked on other docs / sessions. **Do not** design these as part of MAP.md:

- **Combat grid layout.** Combat is in its own doc (`COMBAT.md`, not yet written — Phase 3e).
- **Trust-corp content.** Trust corps are in `WORLD_BIBLE.md` and `BIAS_GUARDRAILS.md`; their behavior on the map is gameplay-loop territory.
- **Manifest schema details.** Manifests live in `narrative/beats/_META.md` (run-start-manifest) — see header of `run-start-manifest.json`.
- **Pin / font asset lists.** Assets live in `godot/assets/`; tracked via the asset issue list.
- **Multiplayer.** Out of scope for this design.

---

## 7. Where this doc fits in the larger plan

| Layer | Doc | Locked? |
|---|---|---|
| Vision | `docs/VISION.md` | yes (Phase 1) |
| World | `docs/WORLD_BIBLE.md` | yes (Phase 1) |
| **Map** | `docs/MAP.md` | **yes — this doc, locked tonight** |
| Gameplay loop | `docs/GAMEPLAY_LOOP.md` | yes (Phase 2 alignment) |
| Persistence | `docs/PERSISTENCE.md` | yes (Phase 2 alignment, v2 schema) |
| Traits | `docs/TRAITS.md` | yes (Phase 2 alignment) |
| Bias guardrails | `docs/BIAS_GUARDRAILS.md` | yes (Phase 2 alignment) |
| Combat | `docs/COMBAT.md` | not yet — Phase 3e |
| Art | `docs/ART_DIRECTION.md` | not yet — Phase 3f |
| Code/spec | `phase/3a.1-travel-system` branch | spec locked, code next session |

`ROADMAP.md` links here under Phase 3a. **When this doc is revised, ROADMAP and HANDOFF must be revised in lockstep — see AGENTS.md handoff loop.**

---

## Open questions (to resolve in a future session)

These are **known unknowns**. They don't block Map design and so are not in this doc's scope:

- How does map-drift interact with the dismantling arc (countdown for He-3 dismantling by Act)?
- Do past-captain manifests expire? (E.g., 3 runs without re-finding a pin = pin decays.)
- Does the captain see their own previous-run pin on a *new* run? (metagame question)
- Are there zones of the outer ring with hidden stations (only discoverable via specific NPCs)?
- What about NPC-driven station re-naming — should factions rename a station? (in-world lore)

These get checked by re-reading this doc after each Phase 3 sub-session and adding bullets here as they're locked.

---

[Locked 2026-06-23. Consensus reached with cross-agent content team in parallel session. Any change to §1 topology, §3 cartography, or §4 encounter shape requires a re-lock + roadmap update.]
