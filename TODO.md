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

- [~] **Phase 3g — Voice corpus.** Prompt ready at `.agents/prompts/phase-3g-voice-corpus.md`. Build target: `narrative/data/die_in_throes.json` (50 entries) + `narrative/data/captains_journal.json` (50 entries). Schema + bias-check rules in prompt. No code changes required — content only.

## Queued (Phase 3 sub-deliverables)

- [ ] **Phase 3g — Voice corpus (die_in_throes + captain_journal, 50 each).** Prompt: `.agents/prompts/phase-3g-voice-corpus.md`.
- [ ] **#21 — ai.gd CQB integration wiring.** Wire CQB combat outcomes into the ai.gd orchestrator flow. Depends on 3g landing first (needs voice fragments for combat beats).
- [ ] **#20 — CQB visual layer.** Deferred, blocked on Phase 3f DirectionPage. Do not start.

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
