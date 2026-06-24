---
title: Borrowed Space — Gameplay Loop
status: draft
last_edited: 2026-06-24
tags:
  - gameplay
  - loop
  - spine
  - encounter
  - session
aliases:
  - Gameplay Loop
  - Loop
  - Spine
phase: 2
related:
  - "[[VISION]]"
  - "[[ROADMAP]]"
  - "[[TRAITS]]"
  - "[[NPCS]]"
  - "[[PERSISTENCE]]"
  - "[[HE3_INDUSTRY]]"
  - "[[GAMEPLAY_LOOP]]"
---

# Gameplay Loop v0.2 — *Borrowed Space*

**Purpose:** Define the moment-to-moment flow of a single run. This is the spine that connects all systems. Every trait, encounter, and module must place itself somewhere in this flow.

**Design pillars:**
- Dialog-heavy. The game unfolds primarily through player choice in conversation.
- Turn-based combat. Space combat is simplified (quick resolution). CQB is Wildermyth-style grid combat (positional, cover tiles, small squad, high stakes).
- Emergent encounters. Random events and encounters — not a fixed mission structure — are the driving force.
- Cosmetic awards. Between-run rewards are collectable and cosmetic only, not mechanical.
- Crew interaction is dialog-first. Combat only triggers when someone attacks.

---

## Run shape (target: 30–45 minutes)

A run is divided into **4 phases**. The sequence is fixed, but the player controls pace and how much content they engage with.

```
Phase 1: Awakening       (2–3 min)
Phase 2: Crew meetup     (3–5 min)
Phase 3: Belt run        (20–30 min) ← the bulk
Phase 4: End-of-run      (3–5 min)
```

There is no guaranteed "crisis" phase. Runs end when they end — by player choice, death, arrest, mutiny, or ship destruction.

---

## Phase 1: Awakening

**Location:** Captain's quarters. Alone.

**What happens:**
1. Captain awakens. AI speaks. Brief, urgent — not an educational briefing.
2. AI assigns captain number ("You are Captain [N].").
3. AI tells the captain: "Your crew is waiting outside. They don't know who you are. When you leave this room, you'll be what you choose to be to them."
4. AI grants the blessing (B-slot) — a Trust-clearance code, one-time-use mid-run.
5. No He-3 literacy briefing here. The captain learns about the He-3 system through encounters during the run.

**Player actions:**
- Read / advance text. No choices — this is atmosphere and setup.
- The player cannot skip, but it's short.

**Systems active:**
- `Persist` records: captain number, origin, archetype, H-tier, blessing state.
- `Ledger` records: new captain entry.

**Exit condition:** AI says "Your crew is waiting." Captain exits quarters.

---

## Phase 2: Crew meetup

**Location:** Outside the captain's quarters. Two crew members are waiting.

**What happens:**
1. The two procedurally-generated crew are present. AI introduces them by name, role, archetype.
2. The captain makes a **dialog choice** about how to handle the moment. Options include:
   - **Defiant:** "I don't belong here. I'm not who the Trust thinks I am. You can take me in or take me down."
   - **Apologetic:** "I'm new. I don't know what I'm doing either. We figure this out together."
   - **Authoritative:** "I'm your captain. That's all you need to know. Follow my lead."
   - **Silent:** Say nothing. Let them speak first.
3. Crew reactions vary based on their archetypes, the captain's origin, and the captain's traits.
4. Bond scores are established. **Bond starts at zero or negative** — the crew does not trust the captain by default. Trust is earned through the run.

**Player actions:**
- Dialog choice at crew meetup.
- Follow-up dialog options as the crew reacts.
- The conversation continues until a natural break. The player can extend or cut it short.

**Systems active:**
- `Crew system` — draws 2 crew from archetype pool + personality fragments.
- `Trait system` — captain's T1/T2/T3 traits influence available dialog options and crew reactions.
- `Bond mechanic` — initial bond scores set. Negative bond is possible and dangerous.
- `Cover-test` — the crew meetup functions as an implicit cover-test. The captain's dialog choice is the test. How the crew reacts reveals whether the captain "passes" or raises suspicion.

**Exit condition:** Crew conversation reaches a natural resting point. AI says: "The ship is yours. Where to?"

---

## Phase 3: Belt run

**Location:** Ship → space map → travel → stations/encounters → return.

This is the core loop. The player controls the pace. There is no fixed sequence of stations — the player chooses how long to stay out, what to pursue, when to return.

### 3a. Ship → Space map

The player is on their ship. They can access:
- **Mission board** — available jobs posted by factions (mining, combat, exploration, delivery). Missions are generated procedurally and refresh periodically.
- **Space map** — node graph of the belt showing stations, faction-controlled zones, and points of interest. Some nodes are locked (require H-tier, blessing, or prior discovery).
- **Crew manifest** — view crew status, bond scores, traits, personal quests.

**Player actions:**
- Browse mission board. Accept or decline missions.
- Select a destination on the space map.
- Talk to crew members on the ship (dialog events, personal quests, bond moments).
- Manage ship (fuel, repairs, refit).

### 3b. Travel

Travel between nodes is not instant. During travel, **random events** can occur:

| Event type | What happens |
|---|---|
| **Distress signal** | Another ship requests help. Respond or ignore. |
| **Patrol encounter** | Faction patrol stops the captain. Cover-test or combat. |
| **Derelict** | Find a wrecked ship. Salvage for supplies, lore, or danger. |
| **Merchant** | Passing trader offers goods for credits. |
| **Anomaly** | Unexplorable phenomenon. Scan for lore or avoid. |
| **Crew event** | A crew member approaches the captain with a personal matter. |

**Player actions:**
- React to events as they arise. Dialog choices, tactical decisions (fight/flee), or ignore.
- Events are generated by the encounter pool, influenced by the captain's suspicion meter, faction relationships, and H-tier.

**Systems active:**
- `Encounter pool` — generates events based on current state.
- `Suspicion meter` — higher suspicion = more hostile patrol events.
- `Faction relationships` — affects which factions appear and how they behave.

### 3c. Station arrival

The captain arrives at a station. The station has a **faction controller**, a **station type**, and a **current state** (normal, tense, hostile, ruined).

**What happens:**
1. Arrival text. AI narrates the approach. Tone varies by faction and state.
2. **Cover-test** to enter without escalation. The captain's dialog choice at the gate determines the test.
3. Cover-test result:
   - **Pass clean** → enter freely.
   - **Pass rough** → enter, suspicion +1, NPC remembers.
   - **Fail soft** → detained briefly, lose resource, released.
   - **Fail hard** → escalated encounter. Combat or flee.

**Player actions:**
- Cover-test is rolled; player sees the result and responds through dialog.
- On pass: choose where to go inside the station.
- On fail: play the escalated branch.

### 3d. Station encounters

Inside the station, the captain can pursue multiple encounter slots before leaving. Each station offers 1–3 encounters.

**Encounter types:**

| Type | What happens | Primary system |
|---|---|---|
| **Social** | Dialog with NPC. Bond shifts, information gained, missions offered. | Dialog, Bond, Trait |
| **Discovery** | Find a cache, ledger, dispatch, or overheard conversation. May unlock a discovery act. | Narrative, Ledger, Dismantling |
| **Mission** | Complete an accepted mission (combat, mining, delivery, exploration). Earn credits and faction standing. | Mission, Combat, Credits |
| **Crew event** | Something happens to a crew member. Personal quest advances. Bond shifts. | Crew, Bond, Dialog |
| **Combat** | Tactical engagement. Triggered by faction hostility, mission objectives, or suspicion overflow. | Combat, Crew, Narrative |

**Player actions:**
- Choose which encounters to pursue.
- Dialog choices in social/combat encounters.
- Resolve combat (turn-based: space = simplified, CQB = Wildermyth-style grid).
- Decide when to leave the station.

### 3e. Leaving station

When the captain departs:
1. Suspicion cools by 1 (cool-down).
2. Bond mechanic updates based on encounter outcomes.
3. Discoveries and mission outcomes are recorded in the ledger.
4. AI narrates departure. May reference prior captains.
5. Return to 3a (ship → space map).

**Loop:** The player continues exploring, pursuing missions, and engaging encounters until the run ends.

---

## Phase 4: End-of-run

**Trigger conditions** (any one ends the run):
- **Death in combat** — captain or entire crew lost in CQB or space combat.
- **Ship destroyed** — ship HP reaches zero in space combat.
- **Arrested** — captured by faction authorities. Imprisoned or executed.
- **Mutiny** — crew bond drops to zero or below. Crew deposes or abandons the captain.
- **Voluntary retreat** — captain chooses to stand down and end the run.

**What happens:**
1. AI delivers end-of-run narration. References specific events of this run.
2. **Journey summary** — a narrative recap of the captain's journey, including:
   - How the run began (crew meetup choice).
   - Key encounters and decisions.
   - How the run ended (death, arrest, mutiny, retreat).
   - **How this run changed the belt** — which stations shifted, which factions lost ground, which discovery acts advanced, which NPCs remember this captain.
3. **Awards** — cosmetic collectables unlocked this run:
   - Ship cosmetic (paint, decal, nameplate).
   - Captain portrait variation.
   - Crew memento (an item the next captain finds in the ship).
4. **Ledger update** — the captain's entry is finalized. Future captains may encounter their name.
5. **Belt status update** — the player sees the world change.

**Player actions:**
- Read the journey summary.
- See how their run impacted the belt.
- Browse cosmetic awards.
- Review ledger.
- Choose: **Start next run** or **Browse ledger**.

**Systems active:**
- `Persist` — saves run outcome.
- `Ledger` — displays cross-run state.
- `Dismantling arc` — updates progress.
- `Belt geography` — updates station states.

---

## Cross-run loop (meta)

Between runs, the player sees:

1. **Belt status screen** — visual map showing station states, faction control, dismantling progress.
2. **Ledger** — list of past captains, their origins, outcomes, crew casualties.
3. **Trustee fragments** — any new identity bits unlocked this run.
4. **Next captain preview** — "Captain [N+1] will be from [genship]."

The player then starts run N+1. The awakening plays again with the new captain. The belt has changed based on what the previous captain did.

---

## Combat systems

### Space combat (simplified)

- Turn-based but streamlined: 2–3 tactical decisions per engagement.
- Not the focus of the game. Resolve quickly, return to story.
- Outcomes: damage to ship, cargo loss, escape, or victory.
- Triggered by patrol encounters, hostile faction ships, or mission objectives.

### CQB (Wildermyth-style)

- Turn-based grid combat.
- Small squad (2–3 crew vs. enemies).
- Cover tiles, height, positioning matter.
- Per-action: move + one attack/ability.
- **High stakes** — crew members can be injured or killed in CQB.
- Triggered by station encounters, missions, or when a crew member or NPC attacks the captain.

---

## Suspicion economy (clarified)

| Action | Suspicion change |
|---|---|
| Arrive at station (base) | 0 |
| Cover-test pass clean | 0 |
| Cover-test pass rough | +1 |
| Cover-test fail soft | +2 |
| Cover-test fail hard | +4 |
| Stay at station too long (3+ encounters without leaving) | +1 per extra encounter |
| Leave station (cool-down) | -1 |
| Crew event (argument, betrayal reveal) | +1 to +3 |
| Discovery act triggered | +0 to +2 |
| Combat (hostile faction) | +1 if won, +0 if fled |
| Blessing withdrawn | +3 |

**Suspicion cap:** 10 (at 5+, hostile encounters become frequent; at 8+, the Trust actively hunts).

**Fold triggers:**
- T-traits fold when suspicion > 3. Folded traits become opposites (negative IDs, marked ✕).
- Fold is permanent for the run, resets next run.
- B-withdrawal is separate — triggered by narrative events (captain betrays the experiment), not by suspicion.

---

## Session flow (real-world time)

```
[Player opens game]
  → Belt status screen (last run's summary + world state)
  → "Start Run [N]" button
  → Phase 1: Awakening (2–3 min)
  → Phase 2: Crew meetup (3–5 min)
  → Phase 3: Belt run (20–30 min) ← player controls pace
  → Phase 4: End-of-run (3–5 min)
  → Back to Belt status screen
  → "Start Run [N+1]" or "Review Ledger"
```

Total: 30–45 minutes per run. 30+ runs for full Trustee reveal = ~15–20 hours of play for the complete arc.

---

## What this doc does NOT cover (deferred)

- **Mission board structure** — how missions generate, what factions offer, reward types. Needs its own doc.
- **Encounter pool generation** — what determines which random events appear and how they're weighted. Needs its own doc.
- **Cosmetic award catalog** — list of collectables. Phase 3+ content.
- **CQB combat specifics** — grid size, action economy, crew abilities. Phase 3 design.
- **Space combat resolution** — the 2–3 tactical decisions. Phase 3 design.
- **Ship management depth** — fuel economy, repair, refit. Needs its own doc.
- **UI layout** — this doc describes flow, not interface.

---

[End of GAMEPLAY LOOP v0.2 draft.]
