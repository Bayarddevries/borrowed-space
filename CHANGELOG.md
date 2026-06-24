---
title: Borrowed Space — Changelog
status: review
last_edited: 2026-06-24
status: locked
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

## [Unreleased] — Phase 3a content

### Phase 3a.0 — content batch (commit 8f4cc55)
- narrative/beats/empty-space-manifest.json — 16 beats × 4 categories (distress / stranger / failure / crew-fight). Deltas feed LedgerWriter (fuel, suspicion, bond, crew_xp, discoveries).
- narrative/beats/legacy-trace-prototype.json — 1 beat demonstrating the past-captain ghost-pin mechanic. Includes a data_spec block that documents the contract for the future legacy_trace_system.gd.
- Both rounds-trip through the manifest parser cleanly. 14/14 GUT tests still pass.

### Phase 3a.1 — design doc
- docs/MAP.md (NEW, locked) — belt topology, per-move clock, ghosts-of-past-captains cartography, hub-and-spoke open-belt encounters, sector view. Cross-linked from ROADMAP.md Phase 3a.
- HANDOFF.md updated with phase 3 sub-phase tracker.

### Phase 3a journey docs (commit ed73c6a)
- narrative/beats/_META.md — Schema A (linear/BeatRunner) vs Schema B (pool/self-describing) beat schemas. Delta vocabulary locked: fuel_delta, suspicion_delta, bond_score, crew_xp, discoveries, credit_delta, blessing_variant, legacy_trace_claimed.
- docs/ENCOUNTER_POOL.md — interface contract for EncounterPool.roll(ship, arrival_kind) → EncounterResult. Weighting rules by hex kind + ship state. 5-test plan.
- docs/COMBAT.md — placeholder stub. Lists known facts + open questions + design prerequisites (Phase 3b — explicitly not designed yet).
- TODO.md + ISSUES.md synced with current GitHub state.

### Phase 3a cleanup (commit f455c32)
- Three broken `[[CARTOGRAPHY]]` wikilinks replaced with `[[MAP]]` in _META.md, ENCOUNTER_POOL.md, TODO.md (docs/CARTOGRAPHY.md never existed).

### Phase 2 — gameplay-loop doc alignment (commit pending)
- docs/TRAITS.md — blessing mechanic clarified: use-once-and-spend (player choice) **plus** AI-can-withdraw on betrayal; b_status enum documented
- docs/PERSISTENCE.md — v2 schema: 5 act boolean fields (discovered_act_1..5) replacing flat `discovered_acts` array; new `faction_standing` block with 6 genships + 7 Trust corps; documented captain outcome enum (death-combat / death-other / ship-destroyed / arrested / mutiny-deposed / mutiny-abandoned / voluntary-retreat / ledger-closed)
- docs/BIAS_GUARDRAILS.md — new §Watch list per Trust Corp (T1–T7) with anti-trope rows for each corporate front; explicit reminder that T4 SomaGenesis intersects genetic-program trope field
- 4 new issues opened: #9 mission board, #10 encounter pool, #11 NPC state-selection, #12 genship-origin mechanical wiring
- Per Bayard clarifications during cross-agent doc handoff
- No code, no tests touched; doc-only commit

### Phase 2 final — Sample playable run (commit prior)
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
