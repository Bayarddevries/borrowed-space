---
title: Borrowed Space — Combat System
status: placeholder
last_edited: 2026-06-24
tags:
  - combat
  - cqb
  - space-combat
  - cover-test
  - system
aliases:
  - COMBAT
  - Combat
phase: 3b
related:
  - "[[GAMEPLAY_LOOP]]"
  - "[[MAP]]"
  - "[[PERSISTENCE]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Combat System — PLACEHOLDER

This document is a placeholder. Combat design has not been locked.

---

## What we know (from GAMEPLAY_LOOP.md §Combat systems)

- **Space combat:** simplified, 2–3 tactical decisions per engagement. Not the focus. Resolve quickly, return to story.
- **CQB (Close Quarters Battle):** Wildermyth-style grid combat. Small squad (2–3 crew vs. enemies). Cover tiles, height, positioning. High stakes — crew can be injured or killed.
- **Cover-test:** A dialog-driven mechanic that determines whether the captain passes through a station gate without escalation. Fail arcs lead to combat or detention.
- **Fold mechanic:** When suspicion > 3, T-traits fold into opposites (negative IDs, marked ✕). Permanent for the run.

## What needs to be designed

- [ ] Space combat resolution: what are the 2–3 decisions? How is damage applied to ship?
- [ ] CQB grid size and action economy. MAP.md defers this.
- [ ] Cover-test thresholds: what roll/stat determines pass/rough/fail-soft/fail-hard?
- [ ] How combat outcomes write to the ledger (casualties, discoveries, bond shifts).
- [ ] How the narrative layer calls into combat (the `combat_trigger.ink` hook).
- [ ] Crew injury/death persistence across runs.

## Design session prerequisites

Before this doc can be locked, the following must be complete:
1. Phase 3a.1 — travel system (provides `TransitResult` → combat trigger hook)
2. Phase 3a.2 — encounter pool (combat is one possible encounter outcome)
3. Cover-test mechanic spec (lives in GAMEPLAY_LOOP.md §3c, needs expansion)

## Open questions

- Turn-based or real-time-with-pause for space combat? (GAMEPLAY_LOOP says turn-based simplified, but this may change based on feel.)
- Does CQB use the same grid as ship travel (hex) or a separate tile grid?
- How many crew members can participate in CQB? (GAMEPLAY_LOOP says 2–3 — is this the full crew or a squad subset?)
- What triggers combat vs. cover-test? Is it faction-based, suspicion-based, or mission-based?

---

[End of COMBAT.md placeholder — Phase 3b design pending]
