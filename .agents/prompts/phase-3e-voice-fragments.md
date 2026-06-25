# Phase 3e.4 — voice_fragments.json (narrative content)

## Your job
Author `narrative/data/voice_fragments.json` — the tribute corpus and
captain's journal fragments consumed by the Phase 3e casualty pipeline.

This is **content only**. You do NOT write code. You do NOT touch
`godot/scripts/`.

## Repo
borrowed-space (private). Absolute path: `~/projects/borrowed-space`

## Read before you write
1. `docs/VISION.md` — product frame (read only)
2. `docs/ROADMAP.md` — phase layout (read only)
3. `HANDOFF.md` — current state (read only)
4. `docs/BIAS_GUARDRAILS.md` — bias-check MUST PASS before any write
5. `narrative/data/aliens.json` — existing data file; schema reference
6. `narrative/data/*.json` — any other existing data file; match style
7. `narrative/beats/cqb-ink-beats.json` — the 8-beat Schema A manifest
   that calls `{tribute_cite}`; read how the variable is used
8. `godot/scripts/casualty_pipeline.gd` — if it exists, read it to
   understand what fields the pipeline expects; if it does NOT exist
   yet, stop and ask (the mechanical layer hasn't shipped)

## What you are building

`narrative/data/voice_fragments.json` — a single file with two keys:

```json
{
  "die_in_throes": [
    "STRING",
    "..."
  ],
  "captain_journal": [
    "STRING",
    "..."
  ]
}
```

### die_in_throes — 50 entries, 3–12 words each

What it is: the last words that fire when a crew member's HP hits 0 in CQB.
Two sub-flavors, mixed at random:

- **Last words from the dead** (approx. half): "Tell my sister — never mind,
  she wouldn't believe it anyway." / "It wasn't me. It was the cover."
- **AI clinical read** (approx. half): "Target neutralized in one shot.
  No time for treatment." / "Hull breach at airlock 2. Immediate loss."

Rules:
- Mix the two flavors. No more than 5 of either flavor in a row.
- No ethnic-coded or nationality-coded references in the prose.
- No named-place strings that reference real geographies or Earth
  political entities.
- Each entry is a standalone String. No variables, no templating,
  no Ink-style markup. Pure prose.
- Do NOT repeat phrasing patterns. Each entry is distinct in image
  and rhythm.

### captain_journal — 50 entries, 1–2 sentences each

What it is: a captain's diary entry written in the days after a casualty.
It is addressed to the dead crew member by name (the pipeline injects the
name dynamically). It is observational, specific, held-tight. Never glowing.

Examples of tone (these are illustrations, do NOT copy them):
  ✓ "Marcell kept the wrench in his left pocket even after we stopped
      using it for the airlock crank."
  ✓ "I keep hearing his laugh in the mess. It's getting harder to tell
      which of us made it back."
  ✗ "Marcell was the bravest soul I ever knew and we will never forget him." (too glowing)
  ✗ "His sacrifice was not in vain." (purple, off-tone)

Rules:
- Each entry reads like a person who just watched someone die and
  hasn't decided yet what the death means.
- References to the dead should use secondary details (a tool, a
  habit, a specific shared moment) rather than abstract tribute.
- Post-collapse voice: drier, harder. No purple prose.
- No ethnic-coded naming in the entries themselves (the name will be
  injected at runtime).
- Entries are NOT re-rolled per run. Once written into the ledger they
  stay. Write them as if they are artifacts.

## What you must NOT do

- Do NOT edit `godot/scripts/cqb_grid.gd`, `cqb_ai.gd`,
  `casualty_pipeline.gd`, `captains_journal.gd` — runtime, off-limits
- Do NOT edit `docs/COMBAT.md`, `docs/TRAITS.md`, `docs/PERSISTENCE.md`,
  `docs/BIAS_GUARDRAILS.md` — LOCKED design docs
- Do NOT write new GitHub issues or close issues without explicit
  instruction
- Do NOT rename or move files without a Phase 3c+ issue number
- Do NOT add keys that don't match the schema shape above

## Schema conventions (NON-NEGOTIABLE)
Mirror the schema of existing files in `narrative/data/`. The top-level
structure is a single JSON object. Arrays of Strings only — no nested
objects, no extra keys beyond `die_in_throes` and `captain_journal`.

## Done = (one sentence)
`narrative/data/voice_fragments.json` contains 100 strings (50 + 50);
loads via `NarrativeData.voice_fragments()` without parse errors;
bias-check paragraph appended to CHANGELOG.md; HANDOFF.md updated.

## Acceptance
- `godot/scripts/narrative_data.gd` exposes a `voice_fragments()` static
  loader (if it doesn't already exist; if it does exist, don't touch it).
- JSON parses cleanly.
- 50 strings under `die_in_throes`, 50 strings under `captain_journal`.
- Each string fits the word-count and tone rules above.
- Bias-check paragraph appended to the Phase 3e block in CHANGELOG.md.
- HANDOFF.md "In-progress" section notes the file staged and ready for
  `casualty_pipeline.gd` consumption.
- Commit on branch `phase/3e-voice-fragments` with footer:
  ```
  Closes #<issue_number_assigned_to_you>
  Phase: 3e
  ```
- Open a PR via `gh pr create`. Do NOT merge directly to main.

## Pitfalls (from the same repo's AGENTS.md)

- Godot 4 class_name registration: `godot --headless --path godot
  --import` refreshes `global_script_class_cache.cfg` after edits.
- `extends GutTest` scripts not matching `test_*` are silently filtered
  by GUT's `-gdir=res://test`.
- Headless test invocation:
  `godot --headless --path godot -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
- In Godot 4.6, variant-inference warnings are errors. Use `var x: int = 0`
  not `var x := 0` when the type isn't obvious.
- Narrative data lives OUTSIDE `godot/` at `narrative/data/`. The path
  resolver in `narrative_data.gd` walks UP from `godot/` to the repo root.
  Test loading with:
  `var data = NarrativeData.voice_fragments(); print(data.keys())`

## Stop conditions (log to ISSUES.md and stop)
- Godot CLI missing.
- `git status` shows uncommitted unrelated work in the repo: stop and ask.
- Cannot find `docs/BIAS_GUARDRAILS.md` or `narrative/data/*.json`.
- The schema of existing data files conflicts with the schema specified
  above (stop and ask rather than guess).
```
