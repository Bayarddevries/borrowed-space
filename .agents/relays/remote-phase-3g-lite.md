# � Remote Agent Brief — Phase 3g Lite (Voice Corpus)

> **Audience:** Remote content agent on Bayard's home PC.
>
> **Repo:** https://github.com/Bayarddevries/borrowed-space (private)
>
> **Path:** `~/projects/borrowed-space`
>
> **Coordinator (this session):** relay only — you have GitHub access and Godot CLI, work independently. Land work in a branch and report back.

---

## What you are building

A combined JSON file at `narrative/data/voice_fragments.json` with two internal keys. The runtime's `NarrativeData.voice_fragments()` loader reads this file and feeds casualty tributes (`die_in_throes`) + captain journals (`captain_journal`).

**Scope:** 15 + 15 = 30 entries (was 50+50; trimmed for day-1).

## ⚠️ Important facts before you start

1. **The file does NOT yet exist on disk.** Phase 3e.4 claimed 50+50 entries were "staged" — that was wrong. Coordinator verified disk state on 2026-06-26. You're creating it from scratch.
2. **The loaders expect a combined file structure** with two internal keys: `die_in_throes` (Array) and `captain_journal` (Array). Do NOT split into two separate `.json` files. Splitting requires runtime changes owned by Local.
3. **You create the file.** No PR needed if you and Local are both pushing to `main`;

## Read in this order (mandatory)

1. `docs/BIAS_GUARDRAILS.md` — **must-read first**
2. `docs/ROADMAP.md` — current state (~5 min skim, Phase 3 tracker)
3. `godot/scripts/casualty_pipeline.gd` lines 26-31 — see how `die_in_throes` is consumed
4. `godot/scripts/captains_journal.gd` — see how `captain_journal` is consumed (string-prefix based: `captain_journal_017`)
5. `docs/VISION.md` (tone reference)

## Done = (one sentence)

`narrative/data/voice_fragments.json` exists, contains 15 `die_in_throes` + 15 `captain_journal` entries with the schema below, all bias-checked, and `NarrativeData.voice_fragments()` returns it cleanly.

## Combined-file schema

```json
{
  "die_in_throes": [
    {
      "id": "dit_<n_or_snake_case>",
      "text": "<1-2 sentences, gritty, personal>",
      "tags": ["optional", "tags"]
    }
  ],
  "captain_journal": [
    {
      "id": "cj_<n_or_snake_case>",
      "text": "<1-3 sentences, journal voice>",
      "tags": ["optional", "tags"]
    }
  ]
}
```

## Distribution (smaller than original)

### die_in_throes (15 entries)
- **12 generic** — fit any death: grief, dark humor, regret, defiance, exhaustion
- **3 SomaGenesis T4 cross-cite** — one-liner hints at medical debt without naming religion/nationality (e.g. "T4's clause 7 ledger" framing)

### captain_journal (15 entries)
- **8 generic** — weariness, doubt, small triumphs, ship maintenance, crew morale
- **4 journey** — belt loneliness, fuel anxiety, hex-cartography fatigue
- **3 loss** — casualty aftermath, guilt, crew-bond weight

## Tone rules (locked)

- **Wildermuth-style:** personal, grounded, **avoid melodrama**. No "heroic sacrifice" clichés.
- **Not uniform mood:** mix of grief, anger, dark humor, exhaustion — captains feel human.
- **No specific crew names.** Use "my crew", "the eng tech", "my second" — neutral.
- **3 sentences max per entry.** Fragments, not prose.
- **First person for journal. Second or third person acceptable for die_in_throes** (speaker is dying — voice range allowed).

## Pitfalls

- **Do NOT write more than 3 sentences.** Fragments.
- **Do NOT reference specific named crew, stations, or genships** by their canonical names — keep generic.
- **Do NOT invent faction/family IDs.** Genship refs (NAC/RRA/SAA/ED/ME/Coalition) are fine since they're already in `narrative/data/`.
- **Bias-check EVERY entry.** Group stereotypes → rewrite. Gendered role assumptions → rewrite.
- **Each entry needs unique `id`** — use `dit_01`..`dit_15` and `cj_01`..`cj_15` numbering.

## Stop conditions

- `docs/BIAS_GUARDRAILS.md` unreadable
- `voice_fragments.json` schema does not match the two-key combined structure
- `NarrativeData.voice_fragments()` returns null after your changes (Local will verify)

## Output deliverable

1. `narrative/data/voice_fragments.json` (created)
2. Bias-check log (1 line per entry: "pass" or "rewrote: <reason>")
3. Report to coordinator:
   - Entry counts (15 + 15)
   - Sample 3 entries from each corpus
   - Any pattern you noticed in your bias pass
   - Sample IDs and confirmation of unique naming

## Verification (you can run this yourself before reporting)

```bash
godot --headless --path godot --import
godot --headless --path godot -s res://addons/gut/gut_cmdln.gd -gtest=res://test/test_casualty_pipeline.gd -gexit
```

Should still pass. If test breaks, your schema is wrong.

## Expected commit message

```
lore(narrative): seed voice_fragments.json — 15 die_in_throes + 15 captain_journal (Phase 3g lite)

Phase: 3g
```

## Report back format

After committing, send coordinator a 5-line status card:

```
3g: done
  • file: narrative/data/voice_fragments.json
  • counts: 15 dit + 15 cj, all bias-checked
  • tests: 64/64 GUT pass (or report which failed)
  • sample ID: dit_001 = "<first line>"
  • caveats: <none | blocker>
```

If you block, send:
```
3g: blocker
  • step: <where you are>
  • reason: <what's stuck>
  • ask: <what you need from coordinator>
```
