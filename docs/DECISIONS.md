---
title: Borrowed Space — Decisions Log
status: locked
last_edited: 2026-06-24
tags:
  - decisions
  - log
  - phase-1
  - phase-2
  - phase-3a
aliases:
  - DECISIONS
  - DecisionLog
phase: 3a
related:
  - "[[ROADMAP]]"
  - "[[AGENTS]]"
  - "[[VISION]]"
---

# Decisions Log — *Borrowed Space*

Retroactive documentation of key structural decisions. Updated at the end of each phase.

---

## D1. Text-first build order (Phase 2)

**Decided:** 2026-06-22
**Locked by:** Bayard + Hermes consensus

Code does not touch combat until the narrative layer is proven in a playable run. Rationale: combat that can't tell story is wasted engineering. Story-first *proves the storytelling* before thousands of lines of combat/art code exist.

## D2. Manifest schema split: A (linear) vs B (pool) (Phase 2 → 3a)

**Decided:** 2026-06-24
**Locked by:** Hermes (narrative agent)

Linear beats (run-start, prologue) use a flat schema with `speaker/text/choices`. Pool beats (open-belt encounters, random events) use a self-describing schema with `_id/_type/_schema/category`. Rationale: pool beats need metadata (category, trigger) for weighted selection; linear beats don't. Documented in `narrative/beats/_META.md`.

## D3. Delta vocabulary lock (Phase 3a)

**Decided:** 2026-06-24
**Locked by:** Hermes (narrative agent)

All narrative beats produce deltas from a fixed set: `fuel_delta`, `suspicion_delta`, `bond_score`, `crew_xp`, `discoveries`, `credit_delta`, `blessing_variant`, `legacy_trace_claimed`. Adding a new key requires agent review. Rationale: prevents every beat from inventing incompatible state fields that break the persistence layer.

## D4. Station count: 10 (Phase 2)

**Decided:** 2026-06-22
**Locked by:** Bayard

The belt has 10 stations (later adjusted to 13 in CARTOGRAPHY.md, but 10 was the Phase 2 target). One station per faction minimum. Enough for varied run traversal without bloating early development.

## D5. Multiplex agent workflow with file-level isolation (Phase 2)

**Decided:** 2026-06-23
**Locked by:** AGENTS.md

Two agents work in parallel on non-overlapping files. Narrative beats live in `narrative/beats/`; travel system code lives in `godot/scripts/`. Agent contracts (AGENTS.md handoff loop) enforce reading state before writing. Rationale: prevents git merge conflicts and enables concurrent narrative/code development.

## D6. Narrative data: zero lore in JSON files (Phase 2)

**Decided:** 2026-06-22
**Locked by:** AGENTS.md

`narrative/data/*.json` files contain only structure and identifiers — no prose, no lore text. All narrative text lives in `.ink` files. Rationale: separates world-building content from mechanical data. Translators/writers can work on `.ink` without touching game logic.

## D7. Suspicion as hidden stat + fold mechanic (Phase 2 alignment)

**Decided:** 2026-06-23
**Locked by:** GAMEPLAY_LOOP.md §Suspicion economy

Suspicion is a hidden 0–10 stat. At >3, T-traits fold into negative opposites. At 5+, hostile encounters multiply. At 8+, the Trust actively hunts. Rationale: the captain's class-passing imposter status needs a mechanical pressure valve that doesn't instantly kill them.

## D8. Legacy-trace mechanic: ghost pins on map (Phase 3a)

**Decided:** 2026-06-23
**Locked by:** MAP.md §3

When a captain dies without ledger-close, their last hex gets a faint pin. New captains who discover the pin can honor the clearance code (gain blessing) or leave it (suspicion +1, pin persists). Rationale: creates "legacy without ownership" — past captains narrate through traces, not avatars.

## D9. inkgd deferred — BeatRunner remains (Phase 3a)

**Decided:** 2026-06-24
**Locked by:** Hermes + Bayard

The `inkgd` addon (pure GDScript Ink runtime) has Godot 4.6 incompatibilities (`tool`→`@tool`, `Directory`→`DirAccess`). Migration cost ~2 hours. Decision: keep BeatRunner + JSON manifests as the runtime for now. Defer inkgd migration to when Ink wrapper (Phase 2c) is officially scoped. The manifest approach is tested and working.

## D10. Bias-check is per-write, not batch (Phase 1 → ongoing)

**Decided:** 2026-06-22
**Locked by:** BIAS_GUARDRAILS.md + AGENTS.md

Every narrative beat is checked against BIAS_GUARDRAILS.md before commit, not in a batch pass. Rationale: bias drifts in small increments; catching it at write-time is cheaper than auditing later. Known watch items: Trust corps (tone-only, no evil-corp tropes), real-world regions (one reference per region max), gender defaults (captain = she/her unless stated).

---

[End of DECISIONS.md — 10 entries. Updated 2026-06-24.]
