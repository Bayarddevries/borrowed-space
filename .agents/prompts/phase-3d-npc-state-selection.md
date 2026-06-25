# Phase 3d — NPC state-selection rules (Issue #11)

## Your job
Ship the NPC state-selection module that governs which NPCs appear
each run, weighted scoring, memory compression, and the Trustee
visibility chain.

Spec is LOCKED. Read docs/NPC_STATE_SELECTION.md before writing.
Do NOT redesign.

## Repo
borrowed-space (private). Absolute path: ~/projects/borrowed-space

## Read before you write
1. docs/VISION.md — read only
2. docs/ROADMAP.md — read only
3. HANDOFF.md — current state
4. docs/NPC_STATE_SELECTION.md — §Selection flow, §Memory system,
   §Cross-run incidence, §Trustee special rules, §Random Mode
5. docs/NPCS.md — NPC archetype definitions + field contract
6. godot/scripts/narrative_data.gd — how JSON loaders work outside godot/
7. godot/scripts/persist.gd — Persist singleton, patch() API only
8. docs/BIAS_GUARDRAILS.md — bias-check before commit

## What you are building

`godot/scripts/npc_state.gd` with class_name NpcState and:

```
static func select_npcs(ship_state: Dictionary, run_number: int,
                        random_mode: bool = false) -> Array[Dictionary]
```

Returns the 3 NPCs selected for this run, each shaped:
```
{
  "archetype_id": String,
  "variant_id": String,
  "weighted_score": float,
  "draw_tier": "primary" | "secondary" | "tertiary",
  "memory_tier": "recent" | "archived" | "ancient",
  "trustee_visibility": "voice_on_screen" | "silhouette" | "fully_visible" | "final_project",
  "memory_log": Array  # list of impact-tagged entries from prior runs
}
```

### Selection flow (locked, do NOT redesign)
1. Archetype pick — load npc-archetypes.json via NarrativeData
2. Filter — drop variants unavailable this run (act-gate, trust constraints)
3. Weighted score (unless random_mode):
   - 0.30 * affinity
   - 0.25 * trait_match
   - 0.15 * trust_alignment
   - 0.30 * memory_resonance
4. Top-3 draw with tier split — primary 60%, secondary 25%, tertiary 15%
5. Inject state — append encounter event to npc[v].memory_log at end of run

### Memory compression
- Runs 1–5    → recent   (full memory entries preserved)
- Runs 6–20   → archived (summarized to {run_range, dominant_impact})
- Runs 21+    → ancient  (mythologized to {last_encounter, mythos_seed})

### Impact weighting
- Critical → 5×
- Major    → 3×
- Minor    → 1×

### Trustee visibility chain
- Acts 1–2  → "voice_on_screen"    (audio/haptic only)
- Acts 3–4  → "silhouette"         (paper-cutout shadow, no detail)
- Acts 5–6  → "fully_visible"      (full paper art)
- Act 7      → "final_project"      (projection beam on genship)
  (adjust acts to match your act count schema — keep the four states)

### Random Mode toggle
- When random_mode=true, skip weighted score and draw uniformly from
  all available variants. Memory compression + Trustee visibility still
  apply to returned records.

### Cross-run incidence
- NPCs caused-by-events propagate their encounter events into
  npc_state.npcs[v].memory_log even when the NPC was not physically
  present on-ship during that event. The pipeline for this is the
  casualty_pipeline / captains_journal path — read those files and
  integrate, do not bypass them.

## What you must NOT do

- Do NOT edit cqb_grid.gd, cqb_ai.gd, casualty_pipeline.gd,
  captains_journal.gd — those are THE runtime
- Do NOT redesign the weighted scoring formula — it is locked
- Do NOT add a 4th draw tier — exactly 3
- Do NOT write NPC voice fragment text — that is the content
  agent's responsibility (separate prompt)
- Do NOT bypass Persist — use Persist.patch(ledger_path, ...)
  for npc_state writes

## Acceptance

- npc_state.gd loads, compiles, no GDScript 4.6 typing warnings
- test_npc_state.gd — 8 cases minimum:
  1. select_npcs returns exactly 3 entries
  2. Weighted score > random score for same npc in weighted mode
  3. Random mode produces uniform distribution over 1000 rolls
  4. Recent tier (run 5) preserves full memory entries
  5. Archived tier (run 15) produces summarized entries
  6. Ancient tier (run 30) produces mythologized entries
  7. Trustee visibility maps act number to correct state
  8. Cross-run incidence: event_without_npc present updates memory_log
- 8/8 pass
- Bias-check paragraph appended to CHANGELOG.md
- HANDOFF.md updated
- Commit on branch phase/3d-npc-state-selection with footer:
  Closes #11
  Phase: 3d

## Pitfalls

- Godot 4.6 strict variant typing on every typed var — no :=
  inference on custom class references
- Memory_log entries are Array[Dictionary], not a flat string
  — schema: {run_number, impact, summary, caused_by}
- The Trustee chain is enum-like but stored as plain String in
  save files — match Persist schema, don't invent enum objects
- Narrative data path: use NarrativeData.npc_archetypes() which you
  may need to add (one static func, 3 lines)
- Persist.patch merges by key; do NOT overwrite the npc_state block
  wholesale or you will lose cross-run data

## Stop conditions (log to ISSUES.md and stop)

- Godot CLI missing
- Uncommitted unrelated work in repo
- docs/NPC_STATE_SELECTION.md not found
- Persist singleton API mismatch that cannot be patched via
  patch()
