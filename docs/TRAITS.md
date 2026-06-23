---
title: Borrowed Space — Trait System
status: review
last_edited: 2026-06-22
tags:
  - trait
  - cover-test
  - fold
  - mechanics
aliases:
  - TRAITS
  - Trait System
phase: 1
related:
  - "[[WORLD_BIBLE]]"
  - "[[VISION]]"
  - "[[NPCS]]"
  - "[[PERSISTENCE]]"
  - "[[BIAS_GUARDRAILS]]"
  - "[[ROADMAP]]"
---

# Trait System v1 — *Borrowed Space*

---

## Trait architecture

### Pool size

- **3 personality trait slots** (T1, T2, T3)
- **1 captain's blessing slot** (B)
- **1 He-3 literacy slot** (H)
- **1 latent reveal slot** (L) — used only by archetype C

5 slots total.

| Slot | Description |
|---|---|
| T1, T2, T3 | Personality traits. Captain generation; chosen or randomized. |
| B | The Trustee's blessing. A direct endorsement from the AI carrying the Trustee's charge. The trustee can withdraw it. |
| H | He-3 literacy. How much the captain knows about the energy-cartel system. Affects which industrial arcs unlock. |
| L | Latent-reveal-tied trait (Archetype C only). Only manifests mid-run. |

### Slot semantics

The major change from the v0 imposter-trait concept is: B and H are *not* traits the captain has *naturally.* They are granted. They *can be withdrawn.*

---

## Trait components

Every trait has three mechanical components:

### 1. PASSIVE — what the trait routinely does

When the player has the trait, it's part of their day-to-day.

### 2. ENCOUNTER INFLUENCE — what the trait does during a story beat

When the trait matches a beat's trait-check, it rolls. When it doesn't, it stays invisible.

### 3. FOLD — the stress failure mode

B folds when the captain has unaddressed suspicion against them OR when the AI withdraws endorsement. B is *not* a permanent asset, it's a *delegated* asset.
H does not fold; H can be *eroded* by disinformation beams (mid-run adversary beats).
T-trait folds under accumulated stress.

---

## Cover-test mechanic v1

In v0 the cover-test was "the captain's lie corresponds to how the elite speak." That worked when the captain was class-passing.

In v1 the captain is **on Trust-vehicle step.** The cover-test is "the captain's lie corresponds to how the AI briefed them." The cover is the AI-given brief. When the cover breaks, exposure happens — and exposure is dynamic based on bond scores.

```pseudo
roll = LOWEST_TRAIT - suspicion_meter + (B_active ? 1 : 0) + (H_literacy_band_offset ? 1 : 0)
result = roll vs threshold
```

Result schema unchanged: pass clean / pass rough / fail soft / fail hard. (See v0 doc.)

Cover-test fails are *not* game-over — they enter the late-run arc.

---

## Trait pool

### Personality traits (T-slot)

| ID | Mechanical Name | Description |
|---|---|---|
| T-P-A | [place-pattern-reader] | Notices the parts of an argument that are deliberately hidden. |
| T-P-B | [outsider-credible] | Reads well to factions outside your own. Reads suspicious to your own. |
| T-P-C | [kin-of-the-near-failure] | Keeps going when cooperation cost increases. |
| T-P-D | [faster-than-the-question] | Interrupts inquiries with abandonment trivia. |
| T-P-E | [re-stater] | Concedes irrelevant things to keep the relevant. |
| T-P-F | [over-worker] | Tiredness reads as service-accomplished. |
| T-P-G | [second-thought-fanatic] | Always has an exit. Sometimes the exit is the only plan. |
| T-P-H | [discrete-on-purpose] | Refuses airtime given to others. |
| T-P-I | [quiet-mountain] | Doesn't betray, doesn't reveal. |
| T-P-J | [linguistic-tense] | Sentence comes out textured, no-no. |
| T-P-K | [numeric-as-truce] | Numbers grease relationships. |
| T-P-L | [work-that-looks-hard] | The captain's manual effort reads fluent. |

12 elaborated trait fragments. Draw 3 per run.

### Latent trait (L-slot)

| ID | Mechanical Name | Description |
|---|---|---|
| T-L-A | [is-no-one] | Captain will discover they have *no surviving family.* |
| T-L-B | [is-someone-else] | Captain's archived history points to *another person wholly.* |
| T-L-C | [is-also-someone-else] | Captain is *one identity among several* they've forgotten. |

### Blessing trait (B-slot)

The Trustee's blessing.

The Trustee, through the AI, grants each captain a *blessing.* Mechanically:

- The blessing **unlocks one Trust-special clearance** at run-start.
- The blessing **permits one mid-run cross-station conversation** that would otherwise be blocked.
- The blessing **denotes-endorsement** in dispatches. Belt-side observers treat the captain as a sanctioned figure.

The blessing **can be withdrawn by the AI.** Withdrawal is triggered by:

- AI later decides the captain *violated the trustee experiment.*
- AI detects the captain deliberately leaks trustee material.
- AI detects the captain betrays the Trustee's project.

When withdrawn, the AI *announces* the withdrawal to the captain. Sustained gameplay post-withdrawal is possible but harder.

### He-3 literacy (H-slot)

Tiers of industrial-cartel knowledge:

| Tier | Description | Unlocks |
|---|---|---|
| H-1 | Surface-level only. Captain knows fuel exists, mines exist. | Standard encounters. |
| H-2 | Mid-tier. Captain knows the cartel structure, who's who, where the value flows. | Industrial-arc bridges, mid-tier dispatches. |
| H-3 | Deep-tier. Captain knows the sabotage program, the founding-families' early roles, the bunker-options on Mars. | Late-arc unlocks, critical dispatches, mid-run miracle-encounters. |
| H-4 | Covert. Captain knows an *alternative cartography* of the He-3 system. (Smoking gun.) | The Trustee's *final* project option. Endgame-grade. |

H-tier is set per-run. It is mostly inherited from the captain's genship-of-origin and the AI's briefing. Cross-run, the AI *remembers* the H-tier maxima achieved and can front-load a new captain with prior captain's H-tier teachings.

---

## Fold mechanic in detail

T-traits fold when:

- Suspicion meter > 3.
- Crew betrayal-event triggered.
- Late-run revelation triggered.
- The player fails the cover-test twice in a row.

Folded T-traits become their opposites for encounter purposes. Trait IDs become *negative.* The UI marks them with ✕.

B-withdrawal is its own flow. See above.

H-erosion happens via disinformation beats. Disinfo beats can occur when the captain encounters *adversary-faction* who feeds them incomplete maps. Erosion can lower H-tier by 1 within a run; can't raise.

---

## Trait-to-arc mapping (Ink hooks)

```ink
~ captain_trait_T1 = "T-P-A"
~ captain_trait_T2 = "T-P-E"
~ captain_trait_T3 = "T-P-L"
~ captain_trait_B = "active"
~ captain_trait_H = "H-2"
~ captain_trait_L = "" (empty unless archetype-C)

// state
~ suspicion_meter = 0
~ crew_bond_avg = 0
~ fold_count = 0
~ run_discoveries = []
```

These Ink variables are the trait system's runtime state. The companion runtime values (H-tier progression, B-withdrawal flags, etc.) live as additional Ink variables.

[End of TRAITS.md draft v1.]
