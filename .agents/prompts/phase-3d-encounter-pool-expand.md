# Phase 3d — Encounter Pool Content Expansion

## What you are building
Expand `narrative/data/encounter-pool.json` from its current 6-entry skeleton to 30+ entries. This is **content only** — no code, no `docs/` edits, no `godot/scripts/` touches.

## Repo
borrowed-space (private). Absolute path: ~/projects/borrowed-space

## Read in this order
1. `narrative/data/encounter-pool.json` — current entries (the schema contract)
2. `godot/scripts/encounter_pool.gd` — the runtime that consumes this data (read-only)
3. `docs/BIAS_GUARDRAILS.md` — bias-check before every write
4. `narrative/data/stations.json` — existing station names/locations for cross-references
5. `narrative/data/cartography.json` — belt geography (lanes, deep belt, derelicts, anomalies)
6. `narrative/data/captain-origins.json` — faction IDs (NAC, RRA, SAA, ED, etc.) for faction-tagged encounters
7. `narrative/data/trust_families.json` — Trust family IDs (T1–T8) for encounter hooks
8. `narrative/data/belt_factions.json` — belt faction IDs (B1/B2/B3) and their conflicts
9. `narrative/data/npc-archetypes.json` — NPC types for encounter cast

## Done = (one sentence)
`narrative/data/encounter-pool.json` has 30+ entries covering all 5 categories with faction-specific variants, all bias-checked, and the runtime loader (`NarrativeData.encounter_pool()`) still parses it cleanly.

## Schema contract
Each entry in the `"entries"` array must have:
```json
{
  "id": "enc_<category>_<variant>_<n>",
  "category": "Patrol" | "Distress" | "Discovery" | "Crew" | "Faction",
  "weight": 1.0-10.0,
  "arrival_kinds": ["lane" | "deep_belt" | "derelict_hex" | "anomaly_hex" | "station_hex"],
  "giver_source": "corps" | "genship" | "private" | "trustee",
  "beat_id": "beat_<snake_case_id>",
  "flavor_hook": "<one-line captain-facing description>",
  "tags": ["optional", "faction_tags", "for", "cover_test"]
}
```

## Content targets
- **Patrol (6 entries):** routine sweeps, license inspections, unregistered cargo flags, ghost-ping chases. Cross-reference trust families T1/T4/T6 for giver sources.
- **Distress (6 entries):** beacon failures, hull breaches, crew medical emergencies, raider sieges. Bias-check: no "helpless victim" tropes — distressed parties have agency.
- **Discovery (6 entries):** derelict ships, abandoned stations, anomalous signals, uncharted wrecks. Cross-reference belt factions B1/B3 for contested finds.
- **Crew (6 entries):** interpersonal conflicts, mutiny rumors, bonding moments, crew-loss events. Bias-check: avoid stereotype-driven personality conflicts.
- **Faction (6+ entries):** NAC/RRA/SAA/ED-specific missions, Trust family rivalries, belt faction border tensions. Cross-reference `belt_factions.json` for current conflicts.

## Distribution
- Weight sum should make Patrol + Distress + Discovery common (~2.5-3.0 each), Crew less common (~1.5-2.0), Faction rare (~1.0-1.5).
- Every `arrival_kind` must appear at least 3 times across all entries.
- Every faction from `captain-origins.json` must appear in at least 2 entries (as giver or in tags).

## Pitfalls
- **Do NOT invent new faction IDs.** Use only IDs present in the existing JSON files.
- **Do NOT write Ink text.** `flavor_hook` is a one-line description, not prose.
- **Do NOT add `beat_runner` calls or script references.** This is data only.
- **Bias-check every entry** against `docs/BIAS_GUARDRAILS.md`. If an entry defaults to a stereotype (e.g., "tribal" cultures, "exotic" women, "inscrutable" aliens), rewrite it.

## Stop conditions
- `encounter-pool.json` not found or unparseable
- `docs/BIAS_GUARDRAILS.md` not readable
- Runtime `NarrativeData.encounter_pool()` returns null after your changes (schema mismatch)

## Output
1. Write the expanded `encounter-pool.json`
2. Run `godot --headless --path godot --import` to verify Godot parses the JSON cleanly
3. Report: entry count, category breakdown, arrival_kind coverage, faction coverage
