# Phase 3c — Mission board + faction missions (Issue #9)

## Your job
Ship the mission-board data engine: mission generation, standing
tracking, dismantling hooks, cross-run continuation.

Spec is LOCKED. Read docs/MISSION_BOARD.md before writing.
Do NOT redesign.

## Repo
borrowed-space (private). Absolute path: ~/projects/borrowed-space

## Read before you write
1. docs/VISION.md — read only
2. docs/ROADMAP.md — read only
3. HANDOFF.md — current state
4. docs/MISSION_BOARD.md — full spec, all sections
5. docs/WORLD_BIBLE.md — Trust families, genship names, belt factions
6. godot/scripts/narrative_data.gd — how JSON loaders work
7. godot/scripts/persist.gd — Persist singleton, patch() API only
8. docs/BIAS_GUARDRAILS.md — bias-check before commit

## What you are building

`godot/scripts/mission_board.gd` with class_name MissionBoard and:

```
static func generate(ship_state: Dictionary, ledger: Dictionary,
                     run_number: int) -> Array[Dictionary]
```

Returns 3–5 mission offers for the current run, each shaped:
```
{
  "id": String,                # mission_<source>_<seed>
  "source": String,            # "trust_XX", "genship_XX", "private", "trustee"
  "giver": String,             # corps name or genship id
  "tier": "Gig" | "Contract" | "Operation",
  "type": "mining"|"combat"|"exploration"|"data"|"diplomacy"|"freight",
  "giver_npc_id": String,      # from npc-archetypes.json if applicable
  "objective": String,         # briefing text (Ink beat ID placeholder allowed)
  "complication_hint": String, # one-line hint; detail is content-side
  "rewards": {
    "credits": int,
    "standing_delta": {"trust_XX": int},   # positive or negative
    "item": String
  },
  "dismantling_hook": String,  # how this mission advances the arc
  "risk": String,              # per docs/MISSION_BOARD.md §Risk
  "act_gate": "act_X" | null,
  "continuation_of": String | null   # prior mission id if multi-stage
}
```

### Generation rules (locked)
1. Roll per source using source weight:
   - corps:  40%
   - genship: 30%
   - private: 20%
   - trustee: 10%
2. Filter sources unavailable this act via act_gate
3. Apply standing modifier: if standing < -3, corp source weight × 0.2
   (effectively blacklists that corp for low-standing captains)
4. Tier split: 55% Gig / 30% Contract / 15% Operation
5. For multi-stage ops, set `continuation_of` when ledger contains
   an in-progress matching mission id; otherwise leave null

### Standing tracker
- Standings stored in `ledger["faction_standing"]` as:
  `{"trust_T1": int, "genship_NAC": int, ...}` range [-5, +5]
- Initialize from world-bible defaults if block missing

### Cross-run decay
- Decay 5% per run for all standing values
- Trust corps withstanding > +3 rebuild at +1/run instead

## What you must NOT do

- Do NOT write mission prose or Ink beats — that is a content issue
- Do NOT redesign the 4-source weight split or tier split
- Do NOT add a 5th mission source
- Do NOT bypass Persist — use Persist.patch(ledger_path, ...)
  for standing writes
- Do NOT import `npc-archetypes.json` fields beyond what
  NarrativeData.npc_archetypes() already exposes

## Acceptance

- mission_board.gd loads, compiles, no GDScript 4.6 typing warnings
- test_mission_board.gd — 8 cases minimum:
  1. generate returns 3–5 missions for a default ship_state
  2. Source distribution over 1000 rolls matches +-5% of target split
  3. Low standing with a corp reduces that corp's mission offers
  4. Multi-stage: continuation_of set when ledger has in-progress mission
  5. act_gate filters out-of-act missions
  6. Decay: standings reduce by ~5% per run for neutral corps
  7. Trust standing > +3 rebuilds at +1/run instead of decaying
  8. Bias-check paragraph appended to CHANGELOG.md
- 8/8 pass
- HANDOFF.md updated
- Commit on branch phase/3c-mission-board with footer:
  Closes #9
  Phase: 3c

## Pitfalls

- Godot 4.6 strict variant typing — no := inference on custom class refs
- Ledger schema: faction_standing is a flat dict, not nested under
  a mission object — keep Persist.patch patches to that key only
- Source weights are percentages; implement as float weights summing
  to 1.0, not integers
- continuation_of must match the id returned by a prior generate()
  call — those ids must be stable across runs (use source + run prefix)
- Missions are data objects, not Ink files — no external beat calls here

## Stop conditions (log to ISSUES.md and stop)

- Godot CLI missing
- Uncommitted unrelated work in repo
- docs/MISSION_BOARD.md not found or unreadable
- npc-archetypes.json not present in narrative/data/
- Persist singleton API mismatch that cannot be patched via patch()
