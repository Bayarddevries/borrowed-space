---
title: Borrowed Space — NPC State-Selection Rules
status: draft
last_edited: 2026-06-24
tags:
  - npc
  - state
  - selection
  - memory
  - variant
  - weighted
  - persistence
aliases:
  - NPC State-Selection
  - NPC Selection
  - NPC Memory
phase: 2
related:
  - "[[NPCS]]"
  - "[[VISION]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[PERSISTENCE]]"
  - "[[ENCOUNTER_POOL]]"
---

# NPC State-Selection Rules v0.1 — *Borrowed Space*

**Purpose:** Define how the AI selects which NPC variant the player meets, how NPCs accumulate state across runs, and how that state manifests in gameplay.

---

## Scope

State-selection applies to **recurring NPCs** only:
- **NPC1 — Sherpa** (early anchor, 6 variants)
- **NPC2 — Engineer** (mid anchor, 6 variants)
- **NPC3 — Gatekeeper** (late anchor, 6 variants)
- **NPC-T — The Trustee** (special rules; see below)
- **NPC-AI — Ship-AI** (the AI itself accumulates state but has no variants)

**One-off mission contacts** (corp handlers, station administrators, etc.) are generated fresh each run. They do not accumulate state.

---

## Selection flow

When the game needs to spawn a recurring NPC, the AI runs this sequence:

### Step 1: Determine archetype

Based on context (mission type, station type, act progress, narrative need), the AI picks which archetype is appropriate:
- Early run: NPC1 (Sherpa) and NPC2 (Engineer) are most likely
- Mid run: NPC2 (Engineer) dominates
- Late run: NPC3 (Gatekeeper) appears
- Special: NPC-T (Trustee) only on specific triggers

### Step 2: Filter available variants

From the archetype's variant pool, the AI filters out variants the player *cannot* meet:
- Variants whose `genship_affinity` does not include the captain's genship AND the captain's standing with the variant's dominant faction is below -3 (hostile)
- Variants who are dead (killed in a prior run and not recyclable — NPC death rules TBD)

### Step 3: Score remaining variants

The AI scores each remaining variant against the current captain:

| Factor | Weight | How it's calculated |
|---|---|---|
| **Genship affinity** | 30% | 1.0 if captain's genship in variant's `genship_affinity`; 0.0 if not |
| **Trait match** | 25% | % of variant's `passive_traits` that match captain's T1/T2/T3 traits |
| **Trust seed alignment** | 15% | Higher if variant's `trust_seed` is compatible with captain's archetype (e.g., Coalition Heir pairs with variants whose trust_seed suggests they trust underdogs) |
| **Memory resonance** | 30% | If the NPC has prior memory entries involving this captain's genship, archetype, or recent actions, weight toward variants that would reference those memories |

**Score formula:**
```
score = (0.30 * affinity) + (0.25 * trait_match) + (0.15 * trust_alignment) + (0.30 * memory_resonance)
```

### Step 4: Draw variant

**Default mode:** Weighted random among top-3 scored variants. The highest-score variant has ~60% chance, second ~25%, third ~15%. This preserves some unpredictability while favoring the most narratively resonant match.

**Player toggle — Random Mode:** If the player enables "Random NPC Encounters" in settings, all filtered variants are drawn with equal probability.

### Step 5: Inject state

The selected variant loads its current state:
- `memory_log` — all prior encounters with this NPC (across all captains)
- `bond_momentum` — weighted average of past bond outcomes
- `known_about_player` — what this NPC knows about the current captain specifically
- `personal_state` — current life-status (operational, injured, afraid, angry, hopeful, etc.)

The AI uses this state to flavor dialog, offer missions, and determine the NPC's opening demeanor.

---

## Memory system

### What gets recorded

Every encounter with a recurring NPC generates a memory entry:

```json
{
  "run": 7,
  "captain_number": 47,
  "captain_archetype": "coalition_heir",
  "captain_genship": "SAA",
  "encounter_type": "social",
  "station": "kepler-3",
  "summary": "Captain 47 helped negotiate a labor dispute. The Captain chose the workers' side.",
  "impact": "major",
  "bond_shift": +1,
  "faction_effects": { "T1": -1, "SAA": +2 },
  "timestamp": "run-7-station-kepler3"
}
```

### Impact weighting

Not all memories are equal:

| Impact level | Weight | Examples |
|---|---|---|
| **Critical** | 5x | Captain died at this station, faction betrayal, liberation of laborers, major revelation |
| **Major** | 3x | Significant bond shift, combat outcome, discovery act unlocked |
| **Minor** | 1x | Brief conversation, passing through, small transaction |

### Memory persistence

NPCs have **long memory**. There is no cap on entries. However, for gameplay clarity, the AI summarizes older memories into compressed form:

- **Recent entries (last 5 runs):** Full detail. The NPC references specific events.
- **Archived entries (runs 6–20):** Summarized. The NPC references patterns ("Several captains from the Coalition have passed through lately").
- **Ancient entries (runs 20+):** Forgotten or mythologized. The NPC may reference legends ("They say a captain once... but I'm not sure if that's true").

The AI uses these summaries to generate the NPC's opening dialog when the player meets them.

### Cross-run incidence

NPCs are affected by events the captain causes **even when the NPC is not present**:
- If the captain destroys Station X and NPC1-3 was stationed there, their `personal_state` shifts to "displaced" or "injured" and their `memory_log` records the event.
- If the captain triggers a faction shift (e.g., T1 loses control of a region), NPCs affiliated with T1 reflect this in their state.

This creates continuity between runs. The world moves around the NPCs even when the player isn't watching.

---

## The AI as director

The ship-AI (NPC-AI) controls NPC state-selection. It runs the selection flow at the moment an NPC needs to appear:
- When the player enters a station where an NPC is present
- When the player accepts a mission that requires an NPC contact
- When a crew event triggers an NPC interaction
- When a random encounter spawns an NPC

The AI also:
- Updates NPC state after every encounter
- Compresses older memories into summaries
- Generates the opening dialog line based on the NPC's current state

---

## NPC-T (The Trustee) special rules

The Trustee does not use variant selection. There is only one Trustee. However, the Trustee's *visibility* and *communication style* change based on dismantling progress:

| Act state | Trustee behavior |
|---|---|
| Acts 0–1 | The Trustee is a voice on screens. Never seen. Speaks in short, cryptic statements. |
| Acts 2–3 | The Trustee appears as a silhouette. Shares information more directly. May offer missions. |
| Acts 4 | The Trustee is fully visible. Speaks openly. The player understands who they are. |
| Act 5 | The Trustee communicates directly, urgently. The final project is queued. |

The Trustee's state is global, not per-variant. All captains see the same Trustee state.

---

## Player visibility

The player always knows they are meeting the **same NPC** across runs (the same Sherpa, the same Engineer). The NPC's name, role, and archetype are consistent. What changes is:
- Their **demeanor** (warm, suspicious, afraid, angry — reflects `personal_state`)
- Their **opening line** (references recent memory or current situation)
- Their **available missions** (influenced by faction standing and memory)
- Their **willingness to help** (influenced by `bond_momentum`)

The player never sees the selection algorithm. They experience its results.

---

## Random Mode

A player-accessible toggle in settings: **"Random NPC Encounters"** (default: off).

When on:
- All filtered variants draw with equal probability
- The selection algorithm still filters unavailable variants (dead NPCs, hostile factions)
- Memory and state still function normally — the only change is *which* variant appears

This is for players who want surprise and unpredictability over narrative resonance. The game remains playable because the memory system adapts to whichever variant appears.

---

## What this doc does NOT cover (deferred)

- **NPC death rules** — can recurring NPCs die? If so, how is that handled in state-selection? Phase 3 design encounter rules.
- **NPC voice fragment resolution** — how voice_fragments map to actual dialog lines. Phase 2g Inktegration.
- **Trait compatibility table** — which trait_ids pair well with which trust_seeds. Phase 2g detail work.

---

[End of NPC STATE-SELECTION RULES v0.1 draft.]
