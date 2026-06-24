---
title: Borrowed Space — Encounter Pool
status: draft
last_edited: 2026-06-24
tags:
  - encounter
  - random-event
  - travel
  - event-pool
  - belt
aliases:
  - Encounter Pool
  - Random Events
  - Travel Events
phase: 2
related:
  - "[[VISION]]"
  - "[[ROADMAP]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[MISSION_BOARD]]"
  - "[[HE3_INDUSTRY]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Encounter Pool v0.1 — *Borrowed Space*

**Purpose:** Define the random events that occur during travel and at stations — the emergent layer that makes the belt feel alive and unpredictable.

---

## Design philosophy

Encounters are **not filler**. They are the primary way the player discovers lore, faces unexpected choices, and experiences the consequences of their reputation. A good encounter is a micro-story: setup, choice, consequence. It should take 2–5 minutes and leave the player feeling like something *happened*.

Encounters are **not random for randomness' sake**. They're weighted by the game state — suspicion, H-tier, faction standing, dismantling progress, and current location. The pool adapts. A captain with high suspicion sees more patrols. A captain with high H-tier sees more corporate intrigue. A captain who just unlocked Act 2 sees more sabotage-related events.

---

## When encounters occur

### Travel encounters

Travel between nodes on the space map triggers encounter rolls. The base chance of an encounter during travel is **40%**. Each travel segment rolls once.

**Weighting modifiers:**

| Condition | Encounter chance |
|---|---|
| Base | 40% |
| High suspicion (5+) | +30% |
| Hostile faction territory | +20% |
| Neutral faction territory | +0% |
| Friendly faction territory (standing +3) | -20% |
| Low fuel (below 20%) | +10% (distress signals, scavengers) |
| High H-tier (H-3, H-4) | +15% (corporate intelligence targets you) |
| Recent combat (within last travel segment) | -10% (clearance sweep) |

**Result:** Encounter chance ranges from 10% to 95%. The player always has a chance of a clean trip, but the belt gets more dangerous as their reputation grows.

### Station encounters

When the captain arrives at a station, an encounter roll determines what's happening *before* the player enters the station hub. Base chance: **25%**.

Station encounters are different from travel encounters — they're about the station's current state, not the journey.

**Station encounter triggers:**

| Condition | Encounter type |
|---|---|
| Station under siege | Combat encounter (defend or flee) |
| Station tense | Social encounter (angry crowd, checkpoint) |
| Station controlled by hostile faction | Cover-test with higher threshold |
| Station controlled by friendly faction | Social encounter (old contact, welcome) |
| Station recently captured by faction | Exploration encounter (looting, prisoners) |

If no station encounter triggers, the captain enters normally and proceeds to the station hub.

---

## Encounter categories

Encounters fall into **5 categories**, each with multiple variants.

### 1. Patrol encounters

A faction patrol stops the captain. The patrol's behavior depends on the captain's standing with the controlling faction and suspicion meter.

**Variants:**

| Variant | What happens | Typical outcome |
|---|---|---|
| **Routine check** | Patrol asks for invoice code. Cover-test. | Pass: move on. Fail: detention, bribe, or combat. |
| **Wanted captain** | Patrol recognizes the captain from a prior incident. | Combat or flee. No cover-test. |
| **Undercover contact** | Patrol is secretly a Trustee asset. | Offers information or mission. Free passage. |
| **Corrupt patrol** | Patrol demands a bribe. | Pay: move on. Refuse: combat or report. |
| **Friendly escort** | Allied faction patrol offers escort to next station. | Safe passage, small standing gain. |

**Weighting:** Routine checks are common at low suspicion. Wanted captain appears when suspicion is high. Undercover contact is rare and requires Act 1+ unlocked.

### 2. Distress signals

A ship or station is in trouble. The captain can respond or ignore.

**Variants:**

| Variant | What happens | Typical outcome |
|---|---|---|
| **Damaged ship** | A freighter is adrift. Crew needs help. | Rescue: credits + standing with ship's faction. Loot: credits, suspicion +1. Ignore: nothing. |
| **Distress beacon** | Automated signal from a derelict. | Exploration: salvage opportunity. May be a trap. |
| **Pirate attack** | A ship is being raided by pirates. | Fight pirates: combat, credits + standing. Ignore: nothing. Join pirates: combat, standing with law factions drops. |
| **Mutiny in progress** | A ship's crew is rebelling against their captain. | Support mutiny: free the crew, standing with corps drops, dismantling progress. Support captain: credits + corp standing. Ignore: nothing. |
| **Medical emergency** | A ship's crew member needs medical aid. | Deliver to station: credits + standing. Use own medic: crew bond shift. Ignore: nothing. |

**Weighting:** Damaged ships are common. Pirate attacks are uncommon. Mutiny is rare and only appears after Act 1.

### 3. Discovery encounters

The captain finds something unexpected — a location, an object, a signal, a person.

**Variants:**

| Variant | What happens | Typical outcome |
|---|---|---|
| **Derelict ship** | An abandoned ship drifts in space. | Exploration: salvage, lore, danger (survivors, traps, hostile scavengers). |
| **Hidden station** | An uncharted station. | Exploration: new contacts, black market, Trustee cache. Dismantling progress possible. |
| **Anomalous signal** | A strange transmission. | Exploration: leads to lore, a mission, or a trap. |
| **Survivor in escape pod** | A person in a pod. | Rescue: crew addition, lore, standing. May be a trap. |
| **Pre-launch artifact** | An object from before the collapse. | Lore: evidence of sabotage program. Act 2 unlock possible. |
| **Hidden deposit** | A resource deposit not on official maps. | Dismantling Act 3 progress. Mapping it secretly requires trait check. |

**Weighting:** Derelicts are common. Hidden stations are uncommon. Pre-launch artifacts are rare and only appear after Act 1. Hidden deposits are rare and only appear after Act 2.

### 4. Crew encounters

Something happens involving the captain's crew. These are personal, character-driven events.

**Variants:**

| Variant | What happens | Typical outcome |
|---|---|---|
| **Personal quest** | A crew member approaches with a personal problem. | Dialog: bond shift, mission offer, or item. |
| **Crew conflict** | Two crew members are fighting. | Dialog: mediate, side with one, or ignore. Bond shifts. |
| **Crew injury** | A crew member is injured in an accident. | Choice: use medical supplies, divert to station, or push on. Bond shift. |
| **Crew revelation** | A crew member reveals something about their past. | Lore: may connect to a faction, the Trust, or the dismantling arc. |
| **Crew recruitment** | A potential crew member wants to join. | Choice: accept (new crew, bond starts at 0) or refuse. |
| **Mutiny brewing** | A crew member is unhappy and considering leaving or betraying. | Dialog: address concerns (bond shift), ignore (mutiny risk), or dismiss them. |

**Weighting:** Personal quests and crew conflicts are common. Crew revelations are uncommon. Mutiny brewing is rare and only appears when bond is low or suspicion is very high.

### 5. Faction encounters

A faction makes contact — not a patrol, but a specific NPC or organization with an agenda.

**Variants:**

| Variant | What happens | Typical outcome |
|---|---|---|
| **Recruitment pitch** | A belt faction (B1, B2, B3) offers membership. | Access to faction missions, standing, unique content. May conflict with Trust standing. |
| **Blackmail** | A faction has information about the captain's secret. | Choice: comply (mission, standing loss), resist (combat, suspicion), or negotiate (partial compliance). |
| **Information trade** | An NPC offers to sell information. | Credits for lore, dismantling progress, or mission leads. |
| **Sabotage request** | A faction asks the captain to sabotage a Trust operation. | Dismantling progress, high suspicion risk, standing with Trust drops. |
| **Alliance offer** | A faction proposes a formal alliance. | Standing locked at +3+, access to restricted content. Harder to work with rival factions. |
| **Trust defector** | An oligarch son (not the Trustee) makes contact. | Lore: Trustee identity fragment, mission offer, or trap. |

**Weighting:** Recruitment pitches are common early. Blackmail is uncommon. Sabotage requests are rare and only appear after Act 1. Alliance offers are rare and require Act 2+. Trust defector encounters are very rare and tied to the Trustee reveal arc.

---

## Encounter resolution

Every encounter resolves in one of three ways:

1. **Dialog** — the player talks through it. Cover-test, persuasion, or information exchange.
2. **Combat** — the player fights. Turn-based (space = simplified, CQB = Wildermyth-style).
3. **Flee** — the player escapes. May lose credits, cargo, or standing. No combat.

The player always has a choice of how to resolve (except for ambush variants where the enemy attacks first).

---

## Encounter intensity by game state

The pool adapts. Here's how the encounter mix changes as the run progresses:

| Game state | Encounter mix |
|---|---|
| **Early run, low suspicion** | Mostly distress signals, routine patrols, crew encounters. Safe, exploratory. |
| **Mid run, moderate suspicion** | More patrols, discovery encounters, faction encounters. Tension rising. |
| **Late run, high suspicion** | Wanted captain events, combat encounters, sabotage requests, mutiny brewing. Dangerous. |
| **Post-Act 1** | Pre-launch artifacts, Trust defector encounters, Trustee missions appear. |
| **Post-Act 2** | Hidden deposits, sabotage requests, corporate intelligence encounters. |
| **Post-Act 3** | Faction conflicts intensify, alliance offers, high-stakes operations. |
| **Post-Act 4** | Endgame encounters — Trustee's final project, regime panic, high-risk high-reward. |

---

## What this doc does NOT cover (deferred)

- **Specific encounter writing** — the actual text and branching for individual encounters. Phase 2g content work.
- **Encounter rewards table** — exact credit/standing values. Phase 3 balance.
- **Encounter difficulty scaling** — how combat encounters scale with captain progress. Phase 3 design.
- **Encounter UI** — how encounters present on screen. Phase 3 design.

---

[End of ENCOUNTER POOL v0.1 draft.]
