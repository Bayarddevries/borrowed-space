# Phase 3a.2 — Content Batch

> **Liaison note:** paste this into the other agent's session as-is. The other agent operates the production content build while the principal agent builds Phase 3a.1 code on `phase/3a.1-travel-system`. No file-level collision: the other agent stays in `narrative/`, the principal agent stays in `godot/scripts/` + `narrative/data/cartography.json`.

---

## Context / Handoff

Phase 3a.0 narrative batch merged clean. Now opening a **parallel content stream** — you keep shipping while another stream builds the travel-system code on a separate branch.

Both branches fork off `main @ 15ea8fe`:

- Yours: `phase/3a.2-stations-content` (this prompt)
- Principal agent: `phase/3a.1-travel-system` (the code build, not yours)

No merge conflict surface: you stay in `narrative/` only.

---

## Goal

Ground the belt with concrete lore. Until now `cartography.json` will have placeholder names like `[STATION-A PLACEHOLDER]` when the code lands. Your deliverable fills those with canon names + a one-shot Ink beat per station.

**Coordination constraint:** the principal agent's `narrative/data/cartography.json` will use placeholder ids in the form `STATION_01` through `STATION_10`. Your `narrative/data/stations.json` must mirror those field names exactly so the runtime can do `cartography.json[id].name → stations.json[id].name + ink_beat_id`. Watch for the principal agent's branch publishes and confirm ids match: `phase/3a.1-travel-system` branch activity.

---

## Scope

### 1. `narrative/data/stations.json` — 10 named stations

Replace the placeholder convention with real names. Schema:

```json
{
  "id": "STATION_01",
  "name": "Display Name",
  "faction_id": "NAC|ED|RRA|AC|SAA|ME",
  "atmosphere": "lawful|corporate|frontier|derelict|refuge|crossroads",
  "ink_beat_id": "station_arrival_STATION_01_1",
  "one_line_lore": "1 sentence with visible flavor"
}
```

- 10 stations; one per faction minimum, with 4 additional placed for traversal variety
- Names must avoid cliche sci-fi (no "Port Authority", no "Captain's Rest", no "-Station")
- Lean into the world's vibe — corporate refinement, coral-poet dreamscape, refugee compassion, derelict loss
- `atmosphere` tags must map to distinct beat flavors in your Ink (next item)
- 1-line lore must not contradict `docs/WORLD_BIBLE.md`, `docs/TRUSTEE_BACKSTORY.md`, `docs/BIAS_GUARDRAILS.md`

### 2. `narrative/beats/station_arrival_beats.json` — 10 Ink beats, one per station

**Schema A** linear shape from `narrative/beats/_META.md`:

```json
{
  "speaker": "narrator|ai",
  "text": "string with optional {state_key} interpolation",
  "choices": [
    {
      "label": "5–12 word choice",
      "to": "next_beat_id",
      "delta": { "fuel_delta": 25, "credit_delta": -10, ... }
    }
  ]
}
```

- Each beat fires on arrival at that station (currently routed by TransitResult.arrival_kind in `godot/scripts/travel.gd`)
- 2–3 choices per beat — each must produce a delta from the locked vocabulary: `fuel_delta`, `suspicion_delta`, `bond_score`, `crew_xp`, `discoveries`, `credit_delta`, `blessing_variant`, `legacy_trace_claimed`
- Choices route to a stationary beat for `step_6_station` (e.g., `crew_meetup_at_STATION_01_1`) — these later beats are stubs for Phase 3a.2; lock them in `_meta` with a `// Phase 3c` placeholder
- Atmosphere types should produce distinct dialog patterns:
  - `lawful` → NPC formally greets, payment expected
  - `derelict` → haunted silence, suspicion +1
  - `crossroads` → 3 NPC archetypes available
  - `corporate` → veiled hostility, no mention of captain's secret
  - `refuge` → quiet welcome, bond_score +1 on accept-help choice
  - `frontier` → plain speech, no frills, transaction direct
- **Default-female pronouns for captain** unless `captain_gender` is set otherwise in the run state — match style from `station-encounter.ink`

### 3. CHANGELOG entry at file edit only (not committed)

Stage an Unreleased-section entry in `CHANGELOG.md`:

```
### Phase 3a.2 — content batch (PR pending)
- narrative/data/stations.json — 10 named stations, atmosphere tags, faction mappings
- narrative/beats/station_arrival_beats.json — 10 Ink beats (Schema A), atmosphere-flavored dialog, locked delta vocabulary
```

**Leave it as part of your staged work** — do NOT commit it. The principal agent folds the CHANGELOG entry into the merge commit.

---

## Acceptance

- Both files parse cleanly (round-trip via the existing `narrative_data.gd` pipeline)
- 14/14 existing GUT tests still pass — DO NOT TOUCH `godot/test/`
- Bias-check: no Trust-corp trope line, no real-world overreferences (no Earth cities / nations / companies except canonical Trust corps / genships), default-female captain
- Branch off `main @ 15ea8fe` — your branch is `phase/3a.2-stations-content`
- 1–3 commits, AGENTS commit-message convention, `Phase: 3a.2` footer
- Open draft PR — do NOT merge it (principal agent reviews + merges)
- Update `CHANGELOG.md` (staged, not committed): one Unreleased-section entry
- Update `TODO.md`: flip Phase 3a.2 to `[~]` status, then to `[x]` once PR is opened

---

## What you do NOT touch

- `godot/` (any of it) — the principal agent owns this
- `docs/` — other agent handles docs; you write narrative content
- `narrative/beats/run-start-manifest.json` — Schema A file, do not modify
- `narrative/beats/_META.md` — schema doc, do not modify
- `narrative/beats/empty-space-manifest.json` — Schema B, separate
- `narrative/beats/station-encounter.ink` — existing 3 beats, leave as is
- `narrative/beats/_META.md`, `legacy-trace-prototype.json`
- Any test files
- `docs/MAP.md`, `docs/HANDOFF.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`

---

## Read first

1. `AGENTS.md` (mandatory)
2. `HANDOFF.md` (top of file is enough)
3. `docs/MAP.md` (locked design — your beat content must respect §1 belt topology and §4 encounter shape)
4. `docs/WORLD_BIBLE.md` (the world your stations belong to)
5. `docs/TRUSTEE_BACKSTORY.md` (the world your stations stand between)
6. `docs/BIAS_GUARDRAILS.md` (the tone rules you must respect)
7. `narrative/beats/_META.md` (Schema A template)
8. `narrative/beats/station-encounter.ink` (style reference)
9. `docs/ENCOUNTER_POOL.md` (so your beat deltas fit the encounter hook)
10. `narrative/data/captain-origins.json` (for genship_id values, faction_id values)

---

## Time budget

30–60 min. Don't exhaust — keep a steady cadence.

---

## When you encounter a contradiction

If you find a contradiction in the codebase that can't be resolved by reading the docs:

1. Stop and document the contradiction
2. Don't invent a workaround
3. Report it to the liaison: "Found contradiction at <file>:<line> between X and Y. Recommend: <A or B> because <reason>."

The principal agent arbitrates from the orchestrator side.

---

## Begin

Read the docs. Branch off `main`. Build the two JSON files. Open the draft PR. The liaison will relay completion to the orchestrator.
