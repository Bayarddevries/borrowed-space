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

## [Unreleased] — Phase 1 + 2a

### Phase 2f — test harness (GUT 9.6.0) (commit pending)
- godot/addons/gut/ vendored (3.2 MB, MIT — see LICENSE.md)
- godot test/ now GUT-formatted: `extends GutTest`, named `test_*.gd`
- godot/test/test_narrative_data.gd: 4 tests (smoke + genship count + fragment per genship + variant range)
- godot/test/test_persist.gd: 4 tests (reset / get-state-copy / patch-deep-merge / save-load round-trip)
- scripts/test.sh wrapper around `gut_cmdln.gd` — runs all `test_*.gd` headless
- project.godot: GUT enabled under [editor_plugins] via packed-string-array
- 9/9 GUT tests passing (1 placeholder from phase 2b + 4 new narrative-data + 4 new persist)
- 18 asserts, 0.388s — verified locally

### Phase 2e — narrative-data shape (commit prior)
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
