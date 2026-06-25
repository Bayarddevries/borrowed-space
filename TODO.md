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

- [~] **Narrative beat content.** Shipped: station encounters (14 beats), empty-space encounters (16 beats), legacy-trace prototype (1 beat). Draft PR #13 waiting for merge. More beats will be needed as Phase 3 modules wire in.
- [ ] **Phase 3e — CQB runtime + tests.** `cqb_grid.gd` and `test_cqb.gd` shipped on `phase/3e-cqb-grid`. 15/15 GUT tests pass. Issues #15, #19 closed. Remaining open issues: #16 CasualtyPipeline, #17 cqb_ai + aliens.json, #18 Ink beats, #20 visual layer (deferred), #21 ai.gd integration.

## Queued (Phase 3 sub-deliverables)

- [~] **Phase 3e.1 — cqb_grid.** CqbGrid runtime + 15/15 GUT tests on `phase/3e-cqb-grid`.
- [~] **Phase 3a.2 — Encounter pool system.** Spec ready. Implementation pending merge of Phase 3e cqb_grid.
- [ ] **3b. — Combat module.** Cover-test in run + CQB grid + space combat. Plan locked in COMBAT.md.
- [ ] **3c. — Mission board module.** Implementation spec written; development pending.
- [ ] **3d. — NPC state-selection.** Spec at `docs/NPC_STATE_SELECTION.md`.
- [ ] **3f. — Genship-origin mechanicals.** Implementation spec not yet written.

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
