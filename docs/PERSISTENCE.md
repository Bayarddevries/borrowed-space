---
title: Borrowed Space — Persistence Model
status: review
last_edited: 2026-06-22
tags:
  - persistence
  - npc-state
  - dismantling-arc
  - mechanics
aliases:
  - Persistence
phase: 1
related:
  - "[[VISION]]"
  - "[[WORLD_BIBLE]]"
  - "[[NPCS]]"
  - "[[TRUSTEE_BACKSTORY]]"
  - "[[HE3_INDUSTRY]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Persistence Model v1 — *Borrowed Space*

---

## Persistence categories

Cross-run state is separated into five layers. Each layer has explicit rules: *what persists; what resets; what shapeshift.*

### Layer 1: Persistent He-3 Industrial State (the meta-loop)

**What persists:** Discovery progress on every level of the He-3 dismantling.

| Sub-layer | What persists |
|---|---|
| Discovery acts | Whether each "discovery act" (5–10 of them) has been triggered. Once triggered, future captains can re-explore the *consequences* but not the *original discovery.* |
| Bunker-state | Whether alternative-fuel nexuses have been mapped. Once mapped, the bunker is in the player's permanent ledger. |
| Mission progress | Whether mid-tier industrial arcs have unlocked. Once unlocked, they are available cross-run. |
| Resource-replacements | Whether "alt-fuel" discoveries have been made and what they unlock. |

**What resets:** Nothing in this layer resets. The He-3 cartel's *partial dismantling* is permanent.

### Layer 2: Persistent Belt Geography (the WRLD-layer)

**What persists:**

- Stations destroyed, **stay destroyed**.
- Stations defended, **stay defended**.
- Stations that shift ownership, **stay** with new owners across runs.
- Mining claims inherited from prior runs.
- Fuel depots in non-destroyed state.

**What resets per run:**

- Per-station role assignments (who staffs which station).
- Per-station micro-events (small fires, domes breached).

### Layer 3: Persistent NPC State

**What persists:**

- NPC archetype definitions (NPC1 — Sherpa — has 6 variants, drawn from same pool).
- NPC memory: each NPC's *history record* — what captains met them, what each told them, etc.
- NPC bond-momentum: each NPC carries a *vector of past bonds* that biases future bonds. Whether they trust or distrust the player archetype.
- NPC inventory items and personal quests.
- NPC's relationship to the AI.

**What resets per run:**

- Per-run *bond scores* (the new captain starts fresh even with the same Sherpa. Their cumulative arc, however, biases the captain's experience.)
- Per-run NPC *current mood* (because NPCs don't simulate daily life).

### Layer 4: Persistent Captain-Specific State

**What persists:**

- Captain number assignment.
- Captain story-fate.
- Captain discoveries (added to the *Ledger*).
- Captain's He-3 contributions to dismantling arc.
- Captain's *archived* identity (for Archetype C).

**What resets:**

- Captain personality traits (drawn fresh per run).
- Per-run suspense-meter, per-run crew-bonds.

### Layer 5: Procedural-Reset Per-Run State

**What resets:**

- The captain's identity.
- The captain's exact current manifests.
- Per-run story branches.
- Per-run time-of-year.
- Per-run fuel-availability.

---

## The Ledger

A persisted record across runs, *kept by the AI.* The Ledger contains:

- **Crew-from-all-runs.** Names, archetypes, runs, outcomes.
- **Generators assigned.** Discoveries made. Casualties taken.
- **The Trustee's collected communications.** All recordings the AI has of The Trustee.
- **He-3 dismantling progress.** Which unlocks are triggered.
- **Captain-Cascades.** Pattern recognition the AI performs over many runs.

The Ledger is partially *visible to the player* during play (the AI refers to it) and partially *unknown.* Future arc reveals in the AI's voice are part of late-game design.

---

## Reactive-MO rules

The He-3 dismantling progress influences NPC behavior across runs in **slow-cascade** rules:

### Oligarch faction MO shifts (mode 1: low dismantling)

If dismantling is below 5%, the regime is *funded but distant.* The regime doesn't expect captains but doesn't track them.

- Encounter dispatches are neutral.
- Oligarch-side NPCs are routine.
- The Trustee's program is *covert.* It's unclear whether the network is persisting.

### Oligarch faction MO shifts (mode 2: 5-15% dismantling)

At ~5%, the oligarchy *notices* the program is a thing.

- Encounter dispatches begin to reference "fringe captains."
- Some merchants list the Trustee's program in private catalogues.
- Faction-heavies ask questions on-station.

### Oligarch faction MO shifts (mode 3: 15-30% dismantling)

The oligarchy *tracks* the program. Captains are *recognized.*

- Encounter dispatches refer to specific captains by name.
- Some stations are *denied* to player-captains.
- Internal patrol ships attempt inspection of special-class ships.

### Oligarch faction MO shifts (mode 4: 30-50% dismantling)

The regime is *concerned.* Captains are *targeted.*

- Specific captains are wanted.
- Mid-run encounters become dangerous in new ways.
- Some crew members are now visibly afraid.

### Oligarch faction MO shifts (mode 5: 50+% dismantling)

The regime is *panicking.*

- Internal oligarch families become hostile to each other.
- Some families break trust.
- The Trustee's program becomes *less covert,* not more.

These MO shifts affect *all* future runs. Once a threshold is crossed, the regime doesn't reset.

---

## NPC state vector (cross-run)

Each NPC has a *state vector* that is updated by every captain who meets them:

| Field | Description |
|---|---|
| archetype | NPC1 / NPC2 / NPC3 |
| variant_id | The NPC's specific instance |
| memory_log | List of "[Captain N said X, Y to me.]" entries |
| bond_momentum | Average past bond-score; biases future bonds |
| held_trust | How much they extend trust to player-captains in general |
| known_about_player | What they currently know about the player |
| personal_state | Life-status, critical events, sanity-state |

### Practical mechanic

When a new captain meets an NPC from prior runs, the AI sources them with discretion. The AI knows the NPC's arc-momentum, the player's progress, and selects the version of "the NPC" that *reflects* what's been happening. This is **state-priority** selection.

---

## The Trustee cross-run reveal arc state

### Information bits (re-stated from NPC.md)

Each run yields *one* bit of the Trustee's full identity:

| Run | New bit |
|---|---|
| Run 1 | "Selected by *the Trustee.*" (Identity unknown.) |
| Run 4 | "The Trustee is one of oligarch sons." |
| Run 7 | "The Trustee is one of 7 founding families." |
| Run 9 | "The Trustee's family is *TBD placeholder.*" |
| Run 12 | "The Trustee's father deployed the helium sabotage program." |
| Run 19 | "The Trustee is in direct opposition to one specific oligarch sibling." |
| Run 26 | "The Trustee's name is *TBD placeholder.*" |
| Run 30+ | "The Trustee's full life-story is recoverable." |

Once an information bit is unlocked, it remains unlocked. Some bits only unlock if certain *prior* bits are revealed.

---

## Run-insulation: per-run scope

Per-run elements that **must not** persist:

### Captain's identity
Per-run. Each captain is a *new person.*

### Per-run suspense-meter
Per-run. New captain, new emotional buildup.

### Per-run crew-bonds
Per-run. New captain, new bonds.

### Per-run narrative branches
Per-run. TheAI doesn't fully replay past branches in new ones.

These per-run elements are specifically *what makes each run feel alive* — *not* what holds the campaign together. The cross-run arc holds the campaign; the per-run arc *belongs to the captain.*

---

## Save-state shape (rough draft)

For simplicity, the run-state shape is:

```yaml
campaign_state:
  he3_dismantling_progress: 0-100
  discovered_acts: []
  bunker_mapped_flags: []
  mid_industrial_arcs_unlocked: []
  alt_fuel_replacements: []

belt_state:
  stations_destroyed: []
  stations_defended: []
  stations_ownership: {}
  resource_claims: {}
  fuel_depots: {}

npc_state:
  npcs:
    [npc_id]:
      archetype: "NPC1"
      variant_id: "TBD"
      memory_log: []
      bond_momentum: 0
      held_trust: 0
      known_about_player: []
      personal_state: "operational"

ledger:
  captains:
    [captain_number]:
      origin_genship
      origin_country
      archetype
      outcomes
      he3_contribution_pct
      archived_identity

  crew:
    [crew_name]:
      archetype_variant
      runs_participated
      status
      carried_state

trustee_arc:
  unlocked_bits: []
```

Per-run state is appended as a new captain section.

[End of PERSISTENCE.md draft v1.]
