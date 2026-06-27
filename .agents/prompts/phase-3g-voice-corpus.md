# Phase 3g — Voice Corpus (die_in_throes + captain_journal)

## What you are building
Two JSON content files with short captain-facing text fragments. These fire from `casualty_pipeline.gd` (death tributes) and `captains_journal.gd` (journal entries). **Content only** — no code, no `docs/` edits, no `godot/scripts/` touches.

## Repo
borrowed-space (private). Absolute path: ~/projects/borrowed-space

## Read in this order
1. `docs/BIAS_GUARDRAILS.md` — **mandatory** before every entry
2. `narrative/data/captain-origins.json` — captain voices, genships, fragments
3. `narrative/data/trust_families.json` — Trust family Trust IDs for "caused_by" fields
4. `narrative/data/belt_factions.json` — belt faction IDs for flavor
5. `narrative/data/stations.json` — station names for location hooks
6. `narrative/data/npc-archetypes.json` — NPC types for "caused_by" fields
7. `godot/scripts/casualty_pipeline.gd` — runtime that consumes `die_in_throes` (read-only)
8. `godot/scripts/captains_journal.gd` — runtime that consumes `captain_journal` (read-only)
9. `docs/VISION.md` — product frame and tone

## Done = (one sentence)
`narrative/data/die_in_throes.json` has 50 entries and `narrative/data/captains_journal.json` has 50 entries, all bias-checked, and both runtime loaders parse them cleanly.

## Schema contract

### die_in_throes.json
```json
{
  "entries": [
    {
      "id": "dit_<snake_case>_<n>",
      "text": "<1-2 sentences of last words, gritty, personal>",
      "tags": ["optional", "faction_tags", "for", "filtering"]
    }
  ]
}
```

### captain_journal.json
```json
{
  "entries": [
    {
      "id": "cj_<snake_case>_<n>",
      "text": "<1-3 sentences of journal voice, reflective or weary>",
      "tags": ["optional", "mood_or_situation_tags"]
    }
  ]
}
```

## Content targets

### die_in_throes (50 entries)
- **30 generic** — last words that fit any crew death. Grief, dark humor, regret, defiance, exhaustion.
- **10 Trust-family-specific** — references to T1/T2/T3/T4 values (duty, mercy, leverage, sacrifice). Generic enough to fit any captain whose crew served that family.
- **5 genship-specific** — NAC (bureaucratic stoicism), RRA (militaristic), SAA (communal), ED (pragmatic). 1-2 each.
- **5 belt-faction-specific** — B1/B2/B3 crew casualties, station-specific flavor.

**Tone rules:**
- Wildermyth-style: personal, grounded, avoid melodrama. No "heroic sacrifice" clichés.
- Not all are sad — some are angry, some darkly funny, some just tired.
- SomaGenesis T4 cross-cites preserved in ~5 entries (mention of genetic debt, radiation lottery, medical rationing).

### captain_journal (50 entries)
- **20 generic** — weariness, doubt, small triumphs, ship maintenance worries, crew morale.
- **10 journey** — loneliness of the belt, fuel anxiety, hex-cartography fatigue.
- **10 faction** — Trust family interactions, genship politics, belt faction encounters.
- **10 loss** — casualty aftermath, guilt, crew-bond ledger weight.

**Tone rules:**
- First-person, present or past tense.
- Short. Journal entries, not monologues.
- Voice should feel like a captain with secrets (per VISION.md — "captain imposter with coalition heritage").

## Distribution

Die_in_throes weight:
- generic: 30 entries
- trust-family: 10 entries (spread across T1-T8)
- genship: 5 entries
- belt-faction: 5 entries

Captain_journal weight:
- generic: 20 entries
- journey: 10 entries
- faction: 10 entries
- loss: 10 entries

## Pitfalls
- **Bias-check EVERY entry** against `docs/BIAS_GUARDRAILS.md`. No group stereotypes, no gendered assumptions about roles, no "primitive culture" framing, no poverty porn.
- **Do NOT write more than 3 sentences per entry.** These are fragments, not prose.
- **Do NOT reference specific named crew members.** Use generic "my crew", "the eng tech", "my second".
- **Do NOT add `Persist.patch` calls or script references.** This is data only.
- **Do NOT invent new faction/family IDs.** Use only IDs present in existing JSON files.
- **Each entry needs a unique `id`** — use `dit_01` / `cj_01` numbering or descriptive snake_case.

## Stop conditions
- `docs/BIAS_GUARDRAILS.md` not found or unreadable
- `godot/scripts/casualty_pipeline.gd` or `captains_journal.gd` not found
- Runtime `NarrativeData.die_in_throes()` or `NarrativeData.captain_journal()` returns null after your changes (schema mismatch)

## Output
1. Write `narrative/data/die_in_throes.json` (50 entries)
2. Write `narrative/data/captains_journal.json` (50 entries)
3. Run `godot --headless --path godot --import` to verify Godot parses cleanly
4. Report: entry count per category, sample entries (3 each), bias-check confirmation

## Links for report
- Repo: https://github.com/Bayarddevries/borrowed-space
- Branch: main
- Expected commit message: `lore(narrative): add voice corpus — die_in_throes + captain_journal (50 each, Phase 3g)`
