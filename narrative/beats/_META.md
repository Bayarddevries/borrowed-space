---
title: Borrowed Space — Narrative Beat Manifest Schemas
status: locked
last_edited: 2026-06-24
tags:
  - narrative
  - schema
  - beats
  - manifest
aliases:
  - BEAT-SCHEMAS
  - BeatManifest
phase: 3a
related:
  - "[[PERSISTENCE]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[CARTOGRAPHY]]"
---

# Narrative Beat Manifest Schemas v1 — *Borrowed Space*

**Purpose:** Document the two manifest shapes used by the narrative layer, when to use each, and the delta vocabulary all beats share. This prevents future agents from inventing divergent schemas.

---

## Schema A — Station / Linear Beats

**Used by:** `run-start-manifest.json`, future linear story beats.

These beats follow the Ink runtime shape that `BeatRunner` reads directly. Flat, minimal, designed for the existing `choose(0)` cursor-advance pattern.

```json
{
  "_meta": { "schema": "manifest-v1", "version": "0.2-draft" },
  "start": "beat_id",
  "beats": {
    "beat_id": {
      "speaker": "narrator | captain | ai | crew",
      "text": "string with optional {state_key} interpolation",
      "choices": [
        {
          "label": "display text (≤12 words)",
          "to": "next_beat_id",
          "delta": { "fuel_delta": 5 }
        }
      ]
    }
  }
}
```

**Key properties:**
- `speaker` — who's talking. `narrator` for scene text, `ai` for ship AI, `crew` for crew member dialogue, `captain` for player internal voice.
- `text` — single string. Supports `{key}` interpolation from per-run state dictionary.
- `choices` — array. Each has `label` (player-facing), `to` (next beat ID), optional `delta` (state patch).
- `start` — initial beat ID the runner navigates to on first `run_beat()`.

**Navigation:** `run_beat(beat_id)` moves cursor. `choose(idx)` applies delta + advances. End beats have empty `choices`.

**When to use:** Linear story sequences, run-start beats, end-of-run summaries, prologues — anything that follows a fixed path with branching choices.

---

## Schema B — Self-Describing Beats (Open-Belt / Pool)

**Used by:** `empty-space-manifest.json`, `legacy-trace-prototype.json`, future pool-driven beats.

These beats carry their own metadata (category, ID, schema tag) and are selected by a pool system rather than navigated linearly.

```json
{
  "_meta": {
    "title": "Manifest Name",
    "trigger": "open_belt | legacy_pin_discovered | ...",
    "description": "When this manifest fires.",
    "schema": "manifest-v1"
  },
  "beats": {
    "beat_id": {
      "_id": "beat_id",
      "_type": "beat",
      "_schema": "manifest-v1",
      "category": "distress | stranger | failure | crew_fight | legacy_trace",
      "trigger": "optional override of _meta.trigger",
      "prose": "1-2 sentences. Present tense, second person.",
      "choices": [
        {
          "text": "player-facing (≤12 words)",
          "next_beat": "beat_id_or_run_end_summary",
          "delta": {
            "fuel_delta": -5,
            "suspicion_delta": 1,
            "bond_score": 1,
            "crew_xp": { "crew_name": 1 },
            "discoveries": ["entry_id"],
            "legacy_trace_claimed": true
          }
        }
      ]
    }
  }
}
```

**Key differences from Schema A:**
- `_id`, `_type`, `_schema` per beat — enables pool lookup and filtering.
- `category` — pool system uses this for weighting (e.g., distress calls more common in deep belt).
- `prose` instead of `text` — naming avoids confusion with Ink's `text` field.
- `next_beat` instead of `to` — explicit target field for pool consumers.
- `trigger` at manifest level — tells the travel system when this manifest is eligible.

**When to use:** Random encounters, pool-driven events, multi-category beats — anything the travel system selects at runtime based on state.

---

## Delta Vocabulary (shared across both schemas)

All beats produce deltas from this set. **Do not add new keys without review.**

| Key | Type | Semantics |
|---|---|---|
| `fuel_delta` | int | Positive = gain, negative = cost |
| `suspicion_delta` | int | Change to captain's hidden suspicion meter |
| `bond_score` | int | Change to captain-crew trust (legacy-bond) |
| `crew_xp` | dict[str, int] | Named crew member → XP awarded |
| `discoveries` | list[str] | Discovery IDs that flow into ledger |
| `legacy_trace_claimed` | bool | For legacy-trace beats only |
| `credit_delta` | int | Change to captain's credit balance |
| `blessing_variant` | str | Type of blessing gained (legacy-trace honor path) |

**Persistence mapping:** These deltas are applied via `Persist.patch()` and flow into `ledger.captains[captain_n]` at end-of-run. See `PERSISTENCE.md` §Layer 4 for the captain record shape.

---

## Schema selection guide

| Situation | Schema |
|---|---|
| Fixed sequence (run-start, prologue, end-of-run) | A |
| Random encounter selected by pool | B |
| Beat with category weighting | B |
| Linear story with Ink `speaker` tags | A |
| Beat needs pool metadata (category, trigger) | B |

---

## Migration notes

When `inkjs` replaces `BeatRunner` (Phase 2c), Schema A beats will be compiled to `.ink` source → compiled `ink.json`. Schema B beats will remain JSON (they're pool-driven, not Ink-native). Both schemas' deltas are consumed by the same `apply_to_state()` path in the AI/BeatRunner layer.

[End of _META.md — locked 2026-06-24]
