# Phase 3e — Ink beats for cover-test pass-through + CQB outcomes

## What you are building
Narrative beats that fire from `ai.gd.step_X_meet_aliens(captain, current_station)`
when one of four cover-test tiers resolves. Issue: **#18** in the borrowed-space
repo (label `phase-3e,narrative`). Repo at `~/projects/borrowed-space`.

The beats are adjacent to combat but contain no code — your output is beat
content in the existing JSON-manifest format the BeatRunner already loads.

## Read in this order

1. `docs/VISION.md` — product frame.
2. `docs/ROADMAP.md` — phase context.
3. `HANDOFF.md` — current state.
4. `docs/COMBAT.md` — **the lock**. §7 (cover-test) and §10 (scene flow) are
   yours for content. §6 (casualty pipeline) you will *be called by* — read
   but DO NOT edit.
5. `narrative/beats/_META.md` — Schema A vs B (+ delta vocabulary).
6. `narrative/beats/station_arrival_beats.json` — already-shipped beats of
   similar shape. Match this format.
7. `narrative/beats/run-start-manifest.json` — example BeatRunner manifest
   (5 beats, briefing → crew → overworld → station → ledger close).
8. `godot/scripts/beat_runner.gd` — the runtime. Read only.
9. `docs/AGENTS.md` — workflow contract.
10. `docs/BIAS_GUARDRAILS.md` — bias-check before commit.

## Done = (one sentence)

`beat_runner.gd` can load each of the 4 new beat-files by id without
errors, all cover-test tiers in §10 of COMBAT.md land at the right beat,
a `test_ink_beats_cover_test.gd` 4-case test confirms each tier routes
correctly.

## Beats to author

You will produce **4 beat files** at `narrative/beats/`. Pick a
naming style consistent with the existing `station_arrival_beats.json`
and `run-start-manifest.json` (suggest: `cqb_cover_pass_clean.ink.json`,
or whatever fits the existing convention).

### A. Cover-test **pass-clean** beat

- **ID suggestion:** `cqb_cover_pass_clean`
- **Fires when:** `CoverTest.tier == "pass-clean"`
- **Voice:** captain narrates slipping past the gate with no friction.
- **Variables the beat receives:** `{station: short_id, captain: short_form}`
- **Must include:** 1 choice that returns to the overworld beat.
- **Locked values in delta:** `fuel_delta` only (small positive; +1 safe).

### B. Cover-test **pass-rough** beat

- **ID suggestion:** `cqb_cover_pass_rough`
- **Fires when:** `CoverTest.tier == "pass-rough"`
- **Voice:** "they let you through, but they saw you." Tension.
- **Variables:** `{station: short_id, suspicion_delta: +1}`
- **Locked value delta:** must reference `suspicion_delta: +1` so the
  persist layer can patch it. Use language that *names* the suspicion.
- **Must include:** 1 choice.

### C. Cover-test **fail-soft → CQB enter** beat

- **ID suggestion:** `cqb_enter`
- **Fires when:** `CoverTest.tier == "fail-soft"` *and* `CQB.run` began.
- **Voice:** "the gate's defender catches your crew at the threshold."
  Tension shifted to action.
- **Variables:** `{station: short_id, alien_archetype, grid_size}`
- **Locked value deltas:** none yet — combat happens in the grid.
- **Must include:** 1 choice that triggers `CQB.run` (or, if the runtime
  handles that automatically outside the beat, just narrate the start).

### D. CQB **outcome** beats (4 variants)

- **ID suggestions:** `cqb_end_won`, `cqb_end_lost`, `cqb_end_fled`,
  `cqb_end_casualty` — pick the naming scheme that matches existing
  convention.
- **Fire when:** `CQB.result.outcome` matches the suffix.
- **Voice per variant:**
  - `won` — relief + breath after the fight. Crew injured but alive.
  - `lost` — pulled from combat by allies. Run aborted.
  - `fled` — "you got out, but you left a trace."
  - `casualty` — the tone-shift beat. **Solemn.** Reads a tribute
    paragraph from `voice_fragments` (set picked at crew gen-time).
    Variable: `{tribute_cite: String, voice_fragment_pick: String,
    casualty_name: String, casualty_archetype: String}`.
- **Variables common:** `{outcome, casualty_count, cqb_turns,
  ledger_citations: Array[String]}` — list of dead crew names.
- **Locked value deltas:** `bond_score` (small positive on won; tanked
  on lost/fled); `crew_xp` (positive only); `discoveries` (optional,
  is-array append; new key not overwrite).
- **Must include:** the casualty variant beat reads the tribute
  paragraph verbatim from the var — DO NOT template language for the
  tribute; let the variable carry it.

## Format (Schema A — JSON manifest)

Each beat file is one JSON manifest (Schema A). Use the existing
`station_arrival_beats.json` shape — `beats: [{id, narrative_id_or_text,
vars, choices: [{text, goto_or_apply_delta}]}]` style.

Concrete shape (you can copy from existing files):

```json
{
  "manifest_id": "phase-3e-cqb-cover-passes",
  "schema": "A",
  "beats": [
    {
      "id": "cqb_cover_pass_clean",
      "kind": "story",
      "vars_received": ["station", "captain"],
      "narrative": [
        "We threaded the gate at {station}. {captain.short_form} on the
         ship-board gave them the lighter-offset bill. They waved us in.",
        "Nobody on the crew spoke for twenty minutes after."
      ],
      "choices": [
        {
          "text": "Push on.",
          "outcome": "advance_overworld",
          "deltas": { "fuel_delta": +1 }
        }
      ]
    },
    { ... }
  ]
}
```

(You do NOT need to copy this verbatim — the schema is described in
`narrative/beats/_META.md`. Read that. Read the existing beats. Match
the convention they use.)

## Bias-watch

Bias points already flagged in `docs/BIAS_GUARDRAILS.md`:
- `T4 SomaGenesis` — don't pull alien-archetype lines into
  clipped-other-speak. If the alien has a name (Gaze Striker, etc.),
  its dialog should have the same irregularity and variety as a
  crew-archetype.
- Vault identifiers / faction names — keep existing faction ids
  (`NAC`, `ED`, `RRA`, `AC`, `SAA`, `ME`). Don't invent new factions
  in beat text.
- Don't morality-cast alien archetypes. They can be scary, ruthless,
  or alien-distance, but they should be *people* with motivations.

## Acceptance

- 4 beat files at `narrative/beats/`.
- 4 cases in `godot/test/test_ink_beats_cover_test.gd` covering each tier.
- All beat files parse and load via `beat_runner.gd`.
- 4+4=8 GUT cases total pass.
- 42 prior tests still pass → **50/50 GUT pass after this commit.**
- Bias-check paragraph appended to CHANGELOG.md Phase-3e entry.
- Hand-off note appended to HANDOFF.md.
- Commit on `phase/3e-ink-beats` branch with footer:
  ```
  Closes #18
  Phase: 3e
  ```
- Open a PR via `gh pr create`. Don't merge directly to main.

## What you must NOT do

- Don't edit `cqb_grid.gd` or `cqb_ai.gd` — those are downstream.
- Don't change `narrative/beats/_META.md` (locked spec doc).
- Don't author new factions or new alien archetypes — the
  `aliens.json` already has the 4 working names (Rust Runner, Forge
  Wright, Gaze Striker, Sentry Drone). Match those letters when
  pulling alien dialog.
- Don't write the casualty *tribute paragraph* language inside the
  beat — it must come through `tribute_cite` variable. The beat
  reads it; the casualty pipeline (Phase 3e.3) writes it.

## Pitfalls (from the same repo's HANDOFF.md)

- Godot 4 string interpolation: **use backtick template literals**
  for any beat text containing apostrophes ("it's", "you're",
  "didn't", etc.). Single-quoted strings break on apostrophes.
- `extends GutTest` scripts not matching `test_*` are silently
  filtered by `-gdir=res://test`.
- Headless test invocation (from the same repo's HANDOFF) is
  documented. Pattern holds.
- In Godot 4.6, **variant-inferred warnings are errors**. Declare
  `var x: Type = ...` not `var x := ...` for custom-class refs.
- BeatRunner reads JSON files at `narrative/beats/` which lives
  **outside** `godot/`. Use the loader already shipped in
  `godot/scripts/narrative_data.gd` (added `aliens()` in Phase 3e.2;
  you may need to add a similar `cover_test_beats()` if not present —
  mirror the `aliens()` shape).

## Stop conditions (log to ISSUES.md and stop)

- `docs/COMBAT.md` not found or `status: locked` is missing.
- `narrative/beats/_META.md` is missing or format-spec contradicts
  Schema A.
- Aliens in `narrative/data/aliens.json` are not at 4 archetypes (the
  Phase 3e.2 hand-off point may have changed the names — read what's
  there first).
- A beat file is required to reference a `voice_fragments` corpus that
  doesn't yet exist (Phase 3e.3 = CasualtyPipeline work; logged; stop
  with explicit dependency note).
