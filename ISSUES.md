---
title: Borrowed Space — Issues Mirror
status: locked
last_edited: 2026-06-26
tags:
  - workflow
  - issues
  - github
aliases:
  - ISSUES
phase: 3g
related:
  - "[[ROADMAP]]"
  - "[[TODO]]"
---

# ISSUES.md

Mirror of GitHub Issues. **GitHub Issues are the authoritative source** — this file is a snapshot.

For current state, run:
```
gh issue list --state open
gh issue list --state closed
```

---

## Open issues

| GitHub # | Title | Labels | Phase | Status |
|---|---|---|---|---|
| #8 | Phase 3a.1 — Space travel system | phase-3, docs | 3a.1 | **DONE** (merged, 23/23 GUT) |
| #9 | Phase 3c — Mission board module | phase-3 | 3c | **DONE** (merged, 64/64 GUT) |
| #10 | Phase 3d — Encounter pool module | phase-3 | 3d | **DONE** (merged, 30 entries) |
| #11 | Phase 3e — Genship-origin mechanicals | phase-3 | 3e | **DONE** (mislabeled; was NPC state-selection) |
| #12 | Phase 3f — NPC state-selection | phase-3 | 3f | **DONE** (mislabeled; was genship-origin) |

Note: GitHub issue labels #11/#12 were swapped at creation time. Actual work completed per HANDOFF.

## Next untracked work

| Work | Prompt/Spec | Status |
|---|---|---|
| Phase 3g — Voice corpus (die_in_throes + captain_journal) | `.agents/prompts/phase-3g-voice-corpus.md` | READY |
| #21 — ai.gd CQB integration wiring | TBD | Blocked on 3g |
| #20 — CQB visual layer | TBD | Deferred (blocked on DirectionPage) |

## Closed issues

| GitHub # | Title | Labels | Phase |
|---|---|---|---|
| #1 | 2a. Repo conventions (AGENTS, HANDOFF, CHANGELOG, TODO, ISSUES) | phase-2 | 2a |
| #2 | 2b. Godot 4 project layout | phase-2 | 2b |
| #3 | 2c. Ink wrapper for Godot | phase-2 | 2c |
| #4 | 2d. Persistence layer | phase-2 | 2d |
| #5 | 2e. Narrative-data shape | phase-2, docs | 2e |
| #6 | 2f. Test harness with GUT | phase-2 | 2f |
| #7 | 2g. Sample playable run (Phase 2's ONLY deliverable) | phase-2 | 2g |
| #15 | Phase 3e.1 — CqbGrid runtime | phase-3e, combat | 3e.1 |
| #16 | Phase 3e.4 — CasualtyPipeline | phase-3e, combat | 3e.4 |
| #17 | Phase 3e.2 — CqbAI + aliens.json | phase-3e, combat | 3e.2 |
| #18 | Phase 3e.3 — Ink beats for CQB | phase-3e, narrative | 3e.3 |
| #19 | Phase 3e.1 — test_cqb.gd suite | phase-3e, test | 3e.1 |

---

[End of ISSUES.md]
