---
title: Borrowed Space — Changelog
status: review
last_edited: 2026-06-22
tags:
  - workflow
  - changelog
  - history
aliases:
  - CHANGELOG
phase: 2
related:
  - "[[ROADMAP]]"
  - "[[AGENTS]]"
---

# CHANGELOG.md

This file lists notable commits for human-reviewed history. Detailed diffs are in git history.

Format follows [Keep a Changelog](https://keepachangelog.com/) but adapted for solo-dev / agent workflows. Compatible with the commit-message convention in `AGENTS.md`.

---

## [Unreleased] — Phase 1 + 2

### Phase 2 final — Sample playable run (commit pending)
- godot/scripts/captain.gd — captain record builder: reads origin matrix, locks 3 T-pool traits from country-fragment.tag_pool
- godot/scripts/crew.gd — procedurally generates crew from npc-archetypes variant pool
- godot/scripts/ai.gd — orchestrator for the 7-step run sequence
- godot/scripts/beat_runner.gd — Ink-shaped runtime reading beats from JSON manifest (drop-in for inkjs when bundle lands)
- godot/scripts/ledger_writer.gd — translates per-run state into Persist rows keyed by captain_n
- godot/scripts/tool/dice.gd — `class_name Dice` with roll/weighted_choice/lowest_of
- narrative/beats/run-start-manifest.json — 5-beat story (briefing → crew → overworld → station → ledger close)
- godot/test/test_playable_run.gd — 4 tests: full-run reproducibility, ledger-row written, beat history recorded, trait-pool lock uses origin tag_pool
- 13/13 GUT tests pass; 31 asserts; 0.386s verified locally
- No combat, no cover-test fail arcs, no art beyond placeholder paper-blocks (issue #7 spec)

### Phase 2f — test harness (GUT 9.6.0) (commit prior)
- 3 JSON files in narrative/data/: captain-origins.json (5 genships × 2 fragments), npc-archetypes.json (5 archetypes, 21 variants), ledger.json (mirrors PERSISTENCE.md §layer 4)
- godot/scripts/narrative_data.gd — GDScript loader stub for the three files; resolves paths via globalize_path since narrative/ is outside the Godot project root
- godot/test/smoke_test_narrative_data.gd — SceneTree-based smoke test (5/5 genships, 21 variants distributed); superseded by test_narrative_data.gd but kept for one-off ad-hoc runs
- All trait IDs in tag_pool match TRAITS.md T-pool; genship_affinity cross-references valid
- Zero lore; identifiers + structural flags only

### Phase 2d — persistence singleton (commit pending prior)
- godot/scripts/persist.gd — autoload singleton with save/load_state/reset/patch
- renamed `load()` → `load_state()` to avoid conflict with `ResourceLoader.load()`
- save uses JSON round-trip on user://persist.json
- godot/test/smoke_test_persist.gd — verified pass

### Phase 2c — Godot project layout (commits prior)
- project.godot scaffold
- godot/scripts/persist.gd.uid and others
- godot/scenes/* placeholders: run_start, overworld, station, combat/

### Phase 2a — scaffold conventions (commit `e525942`)
- ROADMAP.md drafted
- Cross-links to BIAS_GUARDRAILS and ROADMAP in every world-building doc
- GitHub Labels: `phase-2`, `phase-3`, `phase-4`, `phase-5`

### Phase 2a — agent workflow convention (commit `pending`)
- AGENTS.md drafted
- Pre-session reading list: VISION + ROADMAP + HANDOFF → issue → relevant docs
- Commit-message convention: Metis Trail V2 base + `Closes #N` and `Phase: X` footers

### Phase 1 — world bible v1 (commit `f0426c9`)
- 9 docs drafted: VISION, WORLD_BIBLE, BELT_CANON_LADDER, TRAITS, NPCS, PERSISTENCE, TRUSTEE_BACKSTORY, HE3_INDUSTRY, BIAS_GUARDRAILS, _CONVENTIONS
- Two sample Ink beats: prologue.ink, run-start.ink
- Initial git push to private GitHub repo
- Naming: PLACEHOLDERS until rename pass

---

## How to use this file

**Add a dated entry** for each phase. Example pattern:

```
### Phase 2b — Godot 4 project layout (commit <hash>)
- project.godot scaffold laid
- scenes/run_start.tscn, overworld.tscn, station.tscn placeholders
- assets/sprites/, assets/data/ structure solve

Closes #2
Phase: 2b
```

[End of CHANGELOG.md]
