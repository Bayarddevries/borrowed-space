---
title: Borrowed Space — Changelog
status: locked
last_edited: 2026-06-24
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

## [Unreleased] — Phase 3 fully done, Phase 4 next

### Phase 3g — Voice corpus split (this session)
- `voice_fragments.json` split into `narrative/data/die_in_throes.json` (52 entries) + `narrative/data/captains_journal.json` (52 entries)
- `godot/scripts/narrative_data.gd` — added `die_in_throes()` and `captains_journal_frags()` static loaders + RELATIVE_PATHS entries; removed `voice_fragments()`
- `godot/scripts/casualty_pipeline.gd` — `_resolve_tribute` now calls `NarrativeData.die_in_throes()` instead of `NarrativeData.voice_fragments()`
- `godot/test/test_voice_fragments.gd` — rewritten for split loaders (4 tests: both load, content count)
- `godot/test/verify_demo_loop_fixes_2026_06_26.gd` — updated for new loader API
- **91/90+1 GUT pass, 576 asserts** (was 89/88/574)
- **Phase 3 formally complete — all sub-phases 3a-3g shipped**

### Paid agent — #21 CQB integration shipped (PR #28)
- `godot/scripts/cqb_engagement.gd` — full grid turn-loop orchestrator (CqbEngagement.run())
- `godot/scripts/ai.gd` — step_X_meet_aliens() chaining CoverTest → CQB → CasualtyPipeline → Ink beat
- `godot/scripts/beat_runner.gd` — load_manifest_from() for CQB beat manifest
- `godot/scripts/casualty_pipeline.gd` — process → process_casualties rename, static-context fix
- `godot/scripts/narrative_data.gd` — RELATIVE_PATHS voice_fragments fix (one-liner)
- `godot/test/test_cqb_engagement.gd` — 8-test suite
- **Suite: 77/78 pass, 515 asserts** (was 68/70/388)
- Closes #21

### Local — day-1 demo scaffold (PR #27)
- `godot/scripts/demo_controller.gd` — run_start.tscn driver
- `godot/scenes/run_start.tscn` — RichTextLabel + origin pick + crew readout + ledger
- `godot/scripts/demo_session.gd` — cross-scene state autoload (no class_name, 4.6-safe)
- `godot/project.godot` — DemoSession autoload registration
- Moves 3+4+5 (overworld, encounter display, return-to-briefing) deferred — wired by paid agent next

### Remote — content batch (Phase 3g complete)
- `voice_fragments.json` — 52 die_in_throes + 52 captain_journal entries, bias-clean
- `encounter-pool-beats.json` — 30 Schema B beats matching pool entries
- `station_arrival_beats.json` — 20 beats (10 original + 10 second-visit variants)
- `cqb-ink-beats.json` — 15 beats (7 original + 8 new: flanked, fold, height-advantage variants)
- All content bias-checked (0 flags across all files)

### Reconciliation commit (this session)
- docs(ROADMAP): full rewrite of Phase 2+3 sections, module table updated to actual architecture (11→15 nodes), content data inventory (13 files)
- docs(HANDOFF): Phase 3 sub-phase tracker cleanup, next-agent reading list points to 3g
- docs(TODO, ISSUES): Phase 3a/3c/3d/3e/3f flipped to done; 3g + #21 queued
- CHANGELOG: this entry
- 64/64 GUT tests pass (278 asserts); next build = Phase 3g voice corpus

### Phase 3g — voice corpus (READY)
- `.agents/prompts/phase-3g-voice-corpus.md` — build prompt for `die_in_throes.json` (50 entries) + `captains_journal.json` (50 entries). Schema, bias-check rules, distribution targets all specified.
- Bias-check: no ethnic-coded tropes; Wildermyth-style personal fragments; two-corpus register distinction (AI voice vs captain observational voice)

### Phase 3e/21 — CQB combat wired into run loop (PAID AGENT)
- `godot/scripts/cqb_engagement.gd` — NEW: static orchestrator that runs a full CQB engagement to completion. Places crew + aliens on 6×6 grid, runs crew-auto-pilot + CqbAI turn loop, returns outcome/casualties/turn_count. `class_name CqbEngagement`.
- `godot/scripts/beat_runner.gd` — added `load_manifest_from(path)` public method + refactored `_load_manifest` into `_read_manifest_at()` for shared parsing. Allows loading the CQB beat manifest on demand.
- `godot/scripts/ai.gd` — added `step_X_meet_aliens(ship_state)` routing CoverTest → CQB engagement → CasualtyPipeline → Ink beat. Updated `step_5_6_overworld_and_station()` to check travel.encounter_rolled and route through combat when triggered.
- `godot/scripts/narrative_data.gd` — fixed missing `voice_fragments` key in `RELATIVE_PATHS` (caused test_voice_fragments to fail with "file not found"). One-line add: `"voice_fragments": "/../narrative/data/voice_fragments.json"`.
- `godot/scripts/casualty_pipeline.gd` — renamed `process()` → `process_casualties()` to avoid conflict with `Node.process()` reserved method. Fixed `has_node()` called from static context by replacing with `Engine.get_main_loop() → SceneTree.root.get_node_or_null()` lazy lookup. Added static vars `_current_captain_id` / `_current_day_index`.
- `godot/test/test_cqb_engagement.gd` — NEW: 8-test acceptance suite covering CoverTest thresholds (clean/fail-hard), CQB engagement outcomes (1-vs-1, multi-alien, casualty tracking), CasualtyPipeline ledger writes, step_X routing structure, and ASCII debug view.
- Bias-check: no new archetypes or content data written. All alien references come from existing `aliens.json`. Combat is purely tactical grid — no anthropomorphic or cultural framing.
- Full GUT suite: 77/78 pass (0 failures), 515 asserts. 1 risky (expected — frail crew doesn't always die in combat).
- Closes #21
- Phase: 3e

## [Unreleased] — Phase 3a content (legacy heading, kept for history)

### Phase 3c — mission board (commit pending)
- godot/scripts/mission_board.gd — `MissionBoard.generate()` returning 3-5 offers with `id`, `source`, `risk`, `act_gate`, `continuation_of`. Source weights: corps 40% / genship 30% / private 20% / trustee 10%. Standing < -3 blacks out corp source. Neutral (0) drifts to -1 per run. Trust > +3 grows at +1/run. In-place ledger mutation. Guaranteed continuation offer when `run_state.missions` contains an in-progress entry.
- godot/test/test_mission_board.gd — 8-case acceptance suite (all pass).
- `.agents/prompts/phase-3c-mission-board.md` — Issue #9 definement prompt.
- godot/scripts/travel.gd — restored EncounterPool.roll() encounter fallback chain (registry → pool → default). Fixed `_DEFAULT_ENCOUNTER_BEAT` constant.
- godot/test/test_travel.gd — updated method names for Travel API rename.
- godot/scripts/ai.gd — fixed `clear_encounters()` → `clear_registry()` rename from Phase 3d.
- godot/test/test_playable_run.gd — fixed SAA-coalition tag_pool assertion to match content data (`t-P-H-coalition`, `t-P-A`, `t-P-C`).
- Full GUT suite: 64/64 pass, 278/278 asserts.

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

### Phase 3a.1 — travel-system shipped (commit c2154fa, branch phase/3a.1-travel-system)
- godot/scripts/hex.gd — axial hex math (axial distance, neighbors, in_belt, tactical_range, BELT_RADIUS=25).
- godot/scripts/cartography.gd — JSON loader + HexKind classifier + hazard_modifier table + validation; integrates with NarrativeData via RELATIVE_PATHS["cartography"].
- godot/scripts/ship.gd — per-run ShipState (hex, fuel, hull, supplies, time_elapsed, is_docked); to_dict/from_dict round-trips for Persist.
- godot/scripts/travel.gd — Travel.transit(ship, to_q, to_r, stations) → TransitResult. Validates out-of-belt + fuel-sufficiency, advances ship state, rolls encounter from a registry hook (Phase 3d replaces stub with real EncounterPool).
- godot/scripts/ai.gd — step_5_6_overworld_and_station() now instantiates a ShipState, runs one real Travel.transit() to STATION_10 at (1,-1), and patches the snapshot into Persist.run_state.phase3a_demo_ship.
- godot/scripts/narrative_data.gd — adds 'cartography' to RELATIVE_PATHS.
- godot/test/test_travel.gd — 9 new tests: hex_distance_constants, cartography_loads+validation, fuel_cost_basic (lane 0.7, deep_belt 1.0, derelict-anomaly placeholders), transit_consumes_fuel_and_advances_time, transit_blocks_when_out_of_fuel, transit_out_of_belt_refused, transit_encounter_rolled_for_station_hex, ship_state_round_trip, canary test_z_playable_run_includes_travel.
- narrative/data/cartography.json — 10 stations STATION_01..STATION_10, all 6 factions represented, ids mirror Phase 3a.2 station naming.
- **23/23 GUT tests pass (was 14, +9). 100/100 asserts. 0.405s.**

### Phase 3a.2 — content batch (PR #14, branch phase/3a.2-stations-content)
- narrative/data/stations.json — 10 named stations matching cartography.json faction split exactly. Names: Kashner Iceworks (NAC, corporate), Bentic Penal (ED, derelict), Corvallo Station (RRA, crossroads), SX Halo (AC, corporate), Orpheum Astrogrowth (SAA, corporate), Prophet's Threshold (ME, refuge), Denise Mar (NAC, refuge), Berezina Drift (ED, frontier), Moscow Prospekt (RRA, lawful), Coral (AC, crossroads).
- narrative/beats/station_arrival_beats.json — 10 Schema A beats, atmosphere-appropriate dialog, 2-3 choices each, deltas use locked vocabulary only (fuel_delta, suspicion_delta, bond_score, crew_xp, discoveries, credit_delta, blessing_variant, legacy_trace_claimed).

### Phase 3f — genship-origin data expansion (commit pending)
- `narrative/data/captain-origins.json` — expanded from 5 to 6 origins (added ME). Each origin now carries full per-origin mechanical data: `h_tier_default`, `starting_suspicion`, `starting_genship_standing`, `corp_relationships` (7 Trust corps, -5..+5), `tag_pool`, `unique_content` (chain_id/chain_title/act_gate/available_by_default/lock_rule/summary), `narrative_flavor` (ai_tone/cover_test_modifier/reaction_tokens). All values locked per Issue #12 spec table. Chain IDs unique across origins.
- `godot/test/test_narrative_data.gd` — updated `test_list_genships_returns_five` → `test_list_genships_returns_six` to reflect 6 origins.
- Bias-check: all `narrative_flavor.ai_tone` strings reference in-fiction entities only (genship IDs, Trust corp IDs, belt terminology). No real-world ethnicity, nationality, or religion named. `reaction_tokens` are structural descriptors (payroll-grade, rotation-cycle, flu-memory, off-the-clock, overlooked-ship, built-with-design) — none encode ethnic or religious shorthand. `cover_test_modifier` values are flat integers with no genship hierarchy implied. ME origin uses "built-with-design" and "spaces-between-walls" tokens per BIAS_GUARDRAILS.md §ME watch list (avoids "crammed"/"overpopulated" tropes). All chain summaries describe mechanical gameplay effects, not cultural stereotypes.
- Closes #12
- Phase: 3f

### Phase 3e — combat design lock (commit pending)
- **docs/COMBAT.md** upgraded from placeholder to **DESIGN LOCKED**. Full spec at 6×6 default grid (5×5 cramped / 7×7 boss via JSON) + 2 AP per turn + half/full cover (25%/50%) + flanking-waives + aggro-AI pathfind-attack-LOS + casualty pipeline (HP=0 → Ink tribute + ledger write) + fold two-way cost (crews −1 attack / enemies +1 attack when suspicion > 3) + ASCII prototype first.
- docs/COMBAT_PLAN_LOCK.md — preserved as audit trail of design decisions; superseded by COMBAT.md.
- HANDOFF.md — Phase 3e tracked in In-progress; Prior "Phase 3: Combat module not locked" line replaced; Pitfalls section re-read.
- 7 GitHub issues opened: #15 CqbGrid runtime, #16 CasualtyPipeline (ledger + Ink tribute), #17 cqb_ai + aliens.json, #18 Ink pass-through + cqb-end beats, #19 test_cqb.gd suite (8-10 cases), #20 visual layer (deferred, blocked on Phase 3f DirectionPage), #21 ai.gd integration wiring.
- Issue #11 re-labeled (was mis-labeled "Phase 3e"; now NPC state-selection under phase-3/npc labels).
- New labels created: phase-3e, phase-3f, combat, narrative, npc, test, art.
- Per session clarifications (D1 6×6 variable-size, D4 single-aggro-fn v0, D5 Ink tribute v0 must-have, D7 two-way fold, D8 ASCII-first).
- 23/23 GUT tests still pass (no code touched this session; design-only commit).
- Per docs/AGENTS.md bias-check rule: combat design preserves crew-bond ledger writes and trusts no trope-field shortcuts; SomaGenesis T4 cross-cite preserved in CASUALTY tribute cite generation.

### Phase 3e.1 — cqb_grid.gd + test_cqb.gd shipped (branch phase/3e-cqb-grid)
- `godot/scripts/cqb_grid.gd` — Phase 3e CQB runtime. 6×6 default grid; 2 AP/turn; half/full cover; LOS check; attack with cover/fold/height modifiers; step_toward; flanked detection; ASCII prototype (`cqb_debug_print`). `class_name CqbGrid` registered.
- `godot/test/test_cqb.gd` — 15 GUT cases: grid init, cover types, actor placement, LOS, cover damage reduction, flanking, step_toward, suspicion fold two-way, mortality, ASCII render.
- **15/15 GUT tests pass** (29/29 asserts). 0.884s.
- Bug fixes during landing: `class_name` registration (was missing, causing "Identifier not found" in tests), Godot 4.6 variant-inferred warnings treated as errors (explicit types on all typed vars in `test_cqb.gd` + `cqb_grid.gd`), test placement distances adjusted (claw range 1 required actor proximity), fold test distance adjusted for same reason.
- Per bias-check: no new proxemic or anthropomorphic othering in alien stats; vanilla human-vs-alien tactical grid only.
- Closes #15, #19.

### Phase 3e.2 — cqb_ai.gd + aliens.json shipped (branch phase/3e-cqb-ai)
- `godot/scripts/cqb_ai.gd` — `class_name CqbAI`. Static `decide_action(enemy_id, grid, fold_mod=0)` returns `CqbAction` dict (`kind`/`actor`/`target_id`/`step_to`). v0 behavior: pick nearest crew; attack if in-range + LOS + AP; else close distance; else wait. No fold-branching yet.
- `narrative/data/aliens.json` — 4 archetypes: Rust Runner (claw), Forge Wright (industrial_cutter), Gaze Striker (toxic_needle), Sentry Drone (drone_blaster). All weapon_ids validated against `CqbGrid.WEAPON_TABLE`.
- `godot/scripts/narrative_data.gd` — added `aliens()` static loader (resolves from `narrative/data/`).
- `godot/test/test_cqb_ai.gd` — 4 GUT cases: attack-in-range, move-out-of-range, wait-no-ap, aliens.json load+validate.
- **4/4 cqb_ai tests pass** (33 asserts). Full suite: 42/42 tests pass (162/162 asserts).
- Bias-check: archetypes are functional/synthetic IDs; no anthropomorphic othering or ethnic-coded tropes. Placeholder names prefixed.
- Closes #17.

### Phase 3e.3 — Ink beats for cover-test + CQB outcomes shipped (branch phase/3e-ink-beats)
- `narrative/beats/cqb-ink-beats.json` — 8-beat Schema A manifest (cover-test tiers + CQB outcome variants). Beat IDs: `cqb_cover_pass_clean`, `cqb_cover_pass_rough`, `cqb_enter`, `cqb_end_won`, `cqb_end_lost`, `cqb_end_fled`, `cqb_end_casualty`. Casualty beat carries tribute via `{tribute_cite}` variable per Phase 3e casualty pipeline contract.
- `godot/test/test_ink_beats_cover_test.gd` — 8 GUT cases: manifest parse + per-beat structure/delta validation.
- **50/50 GUT tests pass** (236/236 asserts) after this commit.
- Bias-check: all archetype references match `aliens.json` IDs; no ethnic-coded tropes; casualty tone is solemn and defers tribute wording to the casualty pipeline variable.
- Closes #18.

### Phase 3e.4 — casualty pipeline + captains journal shipped (commit 09879c0)
- `godot/scripts/casualty_pipeline.gd` — HP=0 → ledger patch → journal append → Ink tribute cite. `class_name CasualtyPipeline`. `process(casualties: Array[Dictionary])` writes `tribute_paras` to ledger and returns casualty summary.
- `godot/scripts/captains_journal.gd` — append-only per-captain journal. `append(captain_id, fragment_id, day_index)` stores `{fragment_id, day_index, run_id}` entries. Reads through `NarrativeData.voice_fragments()`. `class_name CaptainsJournal`.
- `godot/scripts/narrative_data.gd` — added `voice_fragments()` loader + `encounter_pool()` loader (the latter landed on Phase 3d branch first; back-ported for consumer consistency).
- `narrative/data/voice_fragments.json` — staged by remote content agent via prompt `phase-3e-voice-fragments.md` (50 `die_in_throes` + 50 `captain_journal` entries; user-authored corpus expansion pending).
- **50/50 GUT tests pass** (236/236 asserts) on commit.
- Bias-check: no ethnic-coded naming in journal fragments; two-corpus system ensures clinical AI voice and captain observational voice are distinct register.
- Closes #16.

### Phase 3d.1 — encounter-pool scaffold (commit d5b69c8, branch phase/3d-encounter-pool)
- `narrative/data/encounter-pool.json` — 6-entry skeleton (2 low / 2 mid / 2 high) across Patrol, Distress, Discovery, Crew, Faction categories. Schema: `id`, `category`, `description`, `weight`, `intensity`, `resolution`, `state_modifiers`, `act_gate`.
- `godot/scripts/narrative_data.gd` — added `encounter_pool()` static loader.
- Content agent instructed to expand skeleton to 30+ entries; integration agent owns `travel.gd` stub wire-up.
- **50/50 GUT tests pass** on branch (no code touched on main).
- Note: this commit predates GitHub issue #10 creation during context compaction; tracked here for CHANGELOG completeness.

### Missing-issue tracking note
- Two commits landed (`d5b69c8` Phase 3d scaffold, `09879c0` Phase 3e.4) whose `Closes #N` footers reference issues that did not yet exist at commit time. The issue tracker has since caught up (#10 Phase 3d, #16 CasualtyPipeline). No orphaned closes remain.

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
