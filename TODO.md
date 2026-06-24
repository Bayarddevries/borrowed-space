---
title: Borrowed Space — TODO Board
status: review
last_edited: 2026-06-24
tags:
  - workflow
  - todo
  - phase
aliases:
  - TODO
phase: 3a
related:
  - "[[ROADMAP]]"
  - "[[ISSUES]]"
---

# TODO.md

Active work, in-progress, queued. Updated at the end of every session.

---

## In-progress

- [~] **Phase 3a.1 — Space travel system.** Spec locked at `docs/MAP.md` (cartography, topology, encounters, view). Code on branch `phase/3a.1-travel-system`. Integration test (`test_playable_run_includes_travel`) will land with that code.
- [~] **Narrative beat content.** Shipped: station encounters (14 beats), empty-space encounters (16 beats), legacy-trace prototype (1 beat). Draft PR #13 waiting for merge. More beats will be needed as Phase 3 modules wire in.

## Queued (Phase 3 sub-deliverables)

Phase 3 is combat module. Spec-first — no code until plans are locked.

- [ ] **3a.2 — Encounter pool system.** Interface spec needed. Depends on travel system (3a.1) for `TransitResult` hook. Beats exist; the pool that *selects* them does not.
- [ ] **3b. — Combat module.** Cover-test in run + CQB grid + space combat. Plan not locked. COMBAT.md placeholder exists.
- [ ] **3c. — Mission board module.** Implementation spec not yet written.
- [ ] **3d. — NPC state-selection.** Implementation spec not yet written.
- [ ] **3e. — Genship-origin mechanicals.** Implementation spec not yet written.

## Deferred / non-blocking

- [ ] **Rename pass.** Replace placeholder names with final names. Separate issue.
- [ ] **Read pass.** Player-of-record reads every doc for tone + bias. Separate issue.
- [ ] **Bias-check pass.** Cross-read all lore against BIAS_GUARDRAILS.md. Ongoing per-commit, no separate pass needed.

## Status legend

- [ ] = pending
- [~] = in-progress
- [x] = done
- [!] = blocked (resolve before / in next session)

[End of TODO.md]
