# Borrowed Space — Phase 3e.4 AI integration prompt

## Your job
Wire `ai.gd` so the end-to-end CQB flow actually runs during `step_X_meet_aliens`:
CoverTest → CQB.run → CasualtyPipeline → Ink beat.
You do NOT write narrative content. You do NOT touch game design. You do NOT edit docs/.

## Repo
borrowed-space (private). Path: ~/projects/borrowed-space

## Stop conditions
- Godot CLI not available: stop; don't claim test pass
- git status shows pre-existing uncommitted work: stop; ask
- BIAS_GUARDRAILS.md reference not found: stop; ask

## Read before you write
1. docs/VISION.md — what we're making and why (read only)
2. docs/ROADMAP.md — phase layout (read only; don't edit)
3. HANDOFF.md — current state (read only)
4. docs/BIAS_GUARDRAILS.md — bias-check reference (read only)
5. .agents/prompts/phase-3e-cqb-ai.md — prior integration prompt
6. .agents/prompts/phase-3e-ink-beats.md — beat manifest contract
7. godot/scripts/cqb_grid.gd — CQB runtime API
8. godot/scripts/cqb_ai.gd — CQB AI (already class_name CqbAI)
9. godot/scripts/narrative_data.gd — narrative loader

## What you can write
- godot/scripts/ai.gd — ONLY `step_X_meet_aliens` plus any private helper
  functions it calls. Follow the existing AI integration pattern.
- godot/scripts/casualty_pipeline.gd — IF it does not exist, stub with API
  signatures + clear TODO comments. Must print to console.
- godot/scripts/captains_journal.gd — IF it does not exist, stub with API
  signatures + clear TODO comments. Must print to console.
- godot/scripts/narrative_data.gd — ONLY if a new beat manifest key needs to
  be exposed in the loader. Add a single static func. Don't refactor.
- godot/test/test_ai_integration.gd — add the 4 required GUT cases

## What you must NOT do
- Do NOT edit cqb_grid.gd, cqb_ai.gd (these are the runtime)
- Do NOT redesign the flow above — this is locked at docs/COMBAT.md §10
- Do NOT add behaviors (guard/coward) — Phase 4
- Do NOT bypass Persist for ledger writes
- Do NOT add a 3rd AI library — single aggropathfind is the spec
- Do NOT write new Ink files — the beats already exist
- Do NOT edit docs/

## Stubs (if module not yet implemented)
If casualty_pipeline.gd or captains_journal.gd do NOT exist in the repo yet:
1. STUB them with the API signatures below (empty bodies that print).
2. Wire ai.gd to call the stubs so the end-to-end flow compiles.
3. Leave a clear TODO comment in the stub: "IMPLEMENT: [description]".
4. Do NOT leave the stub silent — it must print to console so the
   agent who implements it sees the calls coming.

### casualty_pipeline.gd API
```gdscript
class_name CasualtyPipeline
## Phase 3e casualty pipeline.
## Takes a list of actor IDs killed during CQB and applies
## crew-bond / suspicion deltas / tribute text.
##
## IMPLEMENT: apply internal logic.

static func process_casualties(casualties: Array[String]) -> Dictionary:
    print("[CasualtyPipeline] process_casualties called: %s" % casualties)
    return {"bond_delta": 0, "suspicion_delta": 0, "tribute_cite": ""}
```

### captains_journal.gd API
```gdscript
class_name CaptainsJournal
## Phase 3e journal / tribute autofill.
## Called after CasualtyPipeline hands off tribute_cite.
##
## IMPLEMENT: append to per-run journal array inside Persist.

static func record_tribute(tribute_cite: String) -> void:
    print("[CaptainsJournal] record_tribute called: %s" % tribute_cite)
```

## ai.gd flow to implement
Replace the existing stub path in `step_X_meet_aliens` with the real chain:

```gdscript
func step_X_meet_aliens(delta: Dictionary) -> Dictionary:
    # 1. Run CoverTest via CqbGrid helper (already on crew + enemy grid).
    var cover_out: Dictionary = CqbGrid.run_cover_test(crew_ids, alien_ids)
    if cover_out.get("passed", false):
        # Clean or rough pass — route straight to the appropriate ink beat.
        var beat_id: String = "cqb_cover_pass_clean"
        if cover_out.get("suspicion", 0) > 0:
            beat_id = "cqb_cover_pass_rough"
        return BeatRunner.run_beat(beat_id)

    # 2. Cover test failed — run CQB.
    var cqb_result: Dictionary = CqbGrid.run_cqb(crew_ids, alien_ids)
    var outcome: String = cqb_result.get("outcome", "lost")
    # outcome is one of: "won", "lost", "fled", "casualty"

    # 3. Process casualties if any.
    var casualties: Array[String] = cqb_result.get("casualties", [])
    if not casualties.is_empty():
        var cas: Dictionary = CasualtyPipeline.process_casualties(casualties)
        # Merge deltas into state for BeatRunner / ledger.
        _state.merge(cas)
        CaptainsJournal.record_tribute(cas.get("tribute_cite", ""))

    # 4. Route to the corresponding CQB outcome beat.
    var beat_id: String = "cqb_end_" + outcome
    return BeatRunner.run_beat(beat_id)
```

Notes:
- `step_X_meet_aliens` returns the BeatRunner `{text, choices, speaker}` dict
  that the ai.gd consumer already expects.
- Keep the existing function signature and return shape so the orchestrator
  step chain is not disrupted.
- Do NOT add new top-level state fields outside deltas; use the existing
  `apply_to_state(record)` path.

## test_ai_integration.gd — 4 required cases
1. CoverTest passes → no CQB, continue flow
2. CoverTest fails → CQB.run executes
3. CasualtyPipeline called with correct casualties array
4. Ink beat choice matches outcome (won/lost/fled)

## Acceptance
- step_X_meet_aliens in ai.gd now drives the full CQB flow
  (CoverTest → CQB.run → CasualtyPipeline → Ink beat)
- Compiles: godot --headless --path godot --import (no errors)
- test_ai_integration.gd — 4 cases minimum:
  1. CoverTest passes → no CQB, continue flow
  2. CoverTest fails → CQB.run executes
  3. CasualtyPipeline called with correct casualties array
  4. Ink beat choice matches outcome (won/lost/fled)
- 4/4 pass
- Bias-check paragraph appended to CHANGELOG.md
- HANDOFF.md updated
- Commit on branch phase/3e-ai-integration with footer:
  Closes #21
  Phase: 3e
- Open PR via gh pr create. Do NOT merge to main.

## Pitfalls
- Godot 4 caches class_name in global_script_class_cache.cfg. Run
  --import after adding class_name to any new file.
- Variant-inference warnings are ERRORS in GDScript 4.6. Use explicit
  types: var g: CqbGrid = CqbGrid.new(6) not var g := CqbGrid.new(6)
- Headless GUT: godot --headless --path godot -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
- Narrative data is OUTSIDE godot/ at narrative/data/. The loader in
  narrative_data.gd resolves via ProjectSettings.globalize_path("res://") + walk up.
- Persist singleton is the ONLY write path. Never FileAccess.open for ledger.
