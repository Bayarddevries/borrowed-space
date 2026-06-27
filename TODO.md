---
title: Borrowed Space — TODO Board
status: locked
last_edited: 2026-06-26
tags:
  - workflow
  - todo
  - phase
aliases:
  - TODO
phase: 3g
related:
  - "[[ROADMAP]]"
  - "[[ISSUES]]"
---

# TODO.md

Active work, in-progress, queued. Updated at the end of every session.

---

## In-progress

- [ ] **Phase 4 — Paper art pass.** Planning doc at `docs/PHASE_4_PLANNING.md`. Pipeline approach pending decision.
- [ ] **Narrative prose display.** Encounter prose + player choice UI not yet wired into demo. (See HANDOFF known issues.)

## Phase 3 done (all sub-phases shipped)

- [x] Phase 3a — travel system (hex, cartography, ship, transit, content)
- [x] Phase 3c — mission board
- [x] Phase 3d — encounter pool (30-entry expansion)
- [x] Phase 3e — CQB combat (grid, AI, Ink beats, casualty pipeline)
- [x] Phase 3f — genship origins (data expansion + runtime wiring)
- [x] **Phase 3g — Voice corpus split.** `voice_fragments.json` split into `die_in_throes.json` (52 entries) + `captains_journal.json` (52 entries). `NarrativeData.die_in_throes()` and `NarrativeData.captains_journal_frags()` loaders added. `casualty_pipeline.gd` consumes split die_in_throes. **91/90+1 GUT pass, 576 asserts.**

## Done (Phase 3 shipped)

- [x] Phase 3a.0 — content batch (16 empty-space beats + 1 legacy-trace prototype)
- [x] Phase 3a.1 — travel system (hex.gd, cartography.gd, ship.gd, travel.gd, 9 GUT tests)
- [x] Phase 3a.2 — stations content (10 named stations + arrival beats)
- [x] Phase 3c — Mission board (mission_board.gd + 8 GUT tests)
- [x] Phase 3d — Encounter pool (encounter_pool.gd + 30-entry expansion)
- [x] Phase 3e.1 — CqbGrid runtime (cqb_grid.gd + 15 GUT tests)
- [x] Phase 3e.2 — CqbAI + aliens.json (cqb_ai.gd + 4 GUT tests)
- [x] Phase 3e.3 — Ink beats for cover-test + CQB outcomes (8 GUT tests)
- [x] Phase 3e.4 — CasualtyPipeline + CaptainsJournal (50 GUT tests)
- [x] Phase 3f — Genship-origin data expansion (6 origins) + runtime wiring
- [x] **#21 — ai.gd CQB integration wiring.** CoverTest → CqbEngagement → CasualtyPipeline → Ink beat chained through travel encounter flow. New: cqb_engagement.gd (orchestrator), cover_test.gd (threshold roll). 8 new GUT tests. **77/78 pass (0 failures).**

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
