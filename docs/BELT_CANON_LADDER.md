---
title: Borrowed Space — Belt-Canon Ladder
status: review
last_edited: 2026-06-22
tags:
  - belt
  - canon-ladder
  - lore
aliases:
  - Ladder
  - Belt Canon
phase: 1
related:
  - "[[WORLD_BIBLE]]"
  - "[[VISION]]"
  - "[[HE3_INDUSTRY]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Belt-Canon Ladder — *Borrowed Space*

## Canonicity bands (top → bottom)

### Band 0 — IMPLICIT WORLD

Always true in the campaign. Every scenario, every archetype, every run includes these without ever stating them.

- Earth is in ecological collapse. Survivors are split between those who escaped and those who didn't.
- There is an asteroid belt economy. It is the only post-launch economic engine.
- Conscripts labor for the wealthy. This is *the* power structure.
- Names reveal identity. *Where exactly are you from?* is the lie detector.

Players never need band 0 explained. It's felt.

### Band 1 — ALWAYS-TRUE LORE

The lore that every player-character knows because it's common knowledge in the belt.

- The 5 genships launched (4 large blocs + 1 coalition half-ship).
- The First Five run the stations.
- Coalition genship exists, smaller, frequently forgotten.
- The big four blocs have different signs of conscript treatment.
- Officers of [G3-Russia PLACEHOLDER] sign off conscript rosters with hand signals.

Players can use band 1 lore in conversation without dice rolls. Band 1 *names* are stable across runs.

### Band 2 — RUN-DEPENDENT ARCHETYPE KNOWLEDGE

Different captains know different things. Generated from archetype + trait.

#### [Archetype-A: FirstFive Ward]
- Knows F1-F5 invoice-code language. Can read station ledgers.
- Does NOT know conscript-camp survival tactics or trade-claim law.
- Has *tacit* knowledge of First Five station hierarchies.

#### [Archetype-B: Coalition Heir]
- Knows [G5-Coalition] survival-practices. Multilingual. Can read shipboard diagnostic logs.
- Has *cultural* knowledge of discrimination patterns in 4 blocs.
- Doesn't know the inner functioning of First Five governance.

#### [Archetype-C: Substitute Body]
- Knows fictional history planted for them, *as real memory*. They recall events that didn't happen to them.
- Doesn't know their own genealogy.
- Has archival access to factions they only simulate kinship with.

Trait pool determines *which specific arc fragments* of band 2 the captain knows. Trait-roll against precision.

### Band 3 — ENCOUNTER-DISCOVERED LORE

Knowledge unlocked through gameplay beats. Cannot be assumed; the game must surface it.

Examples (named for design — names TBD):
- "[B3-Lineage]'s Hand-Print" — unlocking this means meeting a [B3] operative and getting a code.
- "First Five station ledger" — finding a station cache unlocks it.
- "Officer's blab" — overhearing an officer's confession during a skirmish.

Band 3 unlocks are gated by trait checks during encounters. They unlock *Ink variables* that drive later story changes.

### Band 4 — CAMPAIGN-ARC WORLDBUILDING

Late-game reveals that re-shape earlier bands. These are *the twists*.

- **The Captain Was Planted.** [Archetype-C] canonical ending.
- **The Captain Was Once Genuinely Right.** A coalition captain's first captaincy year that they don't remember *being stolen from them.*
- **The Crew Already Knows.** Reveal arc, [NPC-3: Gatekeeper] sigil.
- **The First Five Are Five Factions, Not One.** Reveal arc — different blocs can betray each other.

Band 4 unlocks change the meaning of earlier bands. Storytelling iteration should not assume a clean ladder — band 4 redesigns band 1.

---

## How the ladder meets the trait system

Each character's trait pool can pull from band-2 fragments. Mid-run encounters *generate* band-3 fragments keyed to the trait pool. Band 4 is what the captain *doesn't yet know* — it's the unfairness that the storytelling layer can weaponize.

Implementation hook for Ink:

```ink
~ has_band2_artifact_X = false
~ has_band3_artifact_X = false
~ has_band4_artifact_X = false
```

These are *boolean Ink variables* keyed to the canonicity ladder.

[End of BELT_CANON_LADDER.md draft v0.]
