# 🌌 Remote Agent Brief — Encounter Pool Beats (Schema B)

> **Audience:** Remote content agent.
>
> **Repo:** `~/projects/borrowed-space`
>
> **Coordinator:** Back-channel via progress reports.

---

## What you are building

A **Schema B beat manifest** that gives narrative text to the 30 encounter pool entries already in `narrative/data/encounter-pool.json`.

Each entry in the pool has a `beat_id` string — those IDs need corresponding beat content (prose + choices + deltas) so the travel system has narrative text to show when an encounter fires.

**File you'll create:** `narrative/beats/encounter-pool-beats.json`

**Scope:** 30 Schema B beats, one per encounter pool entry.

## Read in this order (mandatory)

1. `narrative/beats/_META.md` — Schema B format spec (pay attention to `prose`, `choices`, `delta`)
2. `narrative/data/encounter-pool.json` — the 30 entries with `beat_id`, `flavor_hook`, `category`, `tags`
3. `docs/BIAS_GUARDRAILS.md` — mandatory before writing
4. `narrative/beats/empty-space-manifest.json` — existing Schema B beats as reference (e.g. `distress_call_1`)
5. `docs/VISION.md` — tone reference

## Done = (one sentence)

`narrative/beats/encounter-pool-beats.json` exists with 30 Schema B beats matching the 30 `beat_id` values in `encounter-pool.json`, all bias-checked.

## File structure

Use the existing Schema B dict-based format (not array):

```json
{
  "_meta": {
    "title": "Encounter Pool Narrative Beats",
    "trigger": "encounter_pool",
    "description": "Narrative beats for weighted encounter pool selection. One beat per pool entry.",
    "schema": "manifest-v1",
    "version": "0.1"
  },
  "beats": {
    "beat_patrol_license_check": {
      "_id": "beat_patrol_license_check",
      "_type": "beat",
      "_schema": "manifest-v1",
      "category": "Patrol",
      "prose": "<1-3 sentences. Present tense, second person.>",
      "choices": [
        {
          "text": "<player-facing text, ≤12 words>",
          "next_beat": "run_end_summary",
          "delta": {
            "fuel_delta": <int>,
            "suspicion_delta": <int>,
            "bond_score": <int>,
            "discoveries": ["<string>"]
          }
        }
      ]
    }
  }
}
```

The `flavor_hook` field in `encounter-pool.json` is your textual seed — expand it into full prose. Use it as the starting situation, then write 1-3 choices that escalate, resolve, or transform it.

Each beat gets **2-3 choices**. Choices flow to `"run_end_summary"` (the encounter ends and returns to travel). If a beat has a natural outcome variant, you can chain a second beat ID (e.g., `beat_patrol_license_check_cooperate`) but keep chains short — one follow-up max.

## Beat ID mapping

| Encounter pool ID | beat_id | Category |
|---|---|---|
| `enc_patrol_license_check_01` | `beat_patrol_license_check` | Patrol |
| `enc_patrol_unregistered_cargo_02` | `enc_patrol_unregistered_cargo` | Patrol |
| `enc_patrol_ghost_ping_chase_03` | `enc_patrol_ghost_ping_chase` | Patrol |
| `enc_patrol_convoy_escort_request_04` | `enc_patrol_convoy_escort_request` | Patrol |
| `enc_patrol_station_perimeter_sweep_05` | `enc_patrol_station_perimeter_sweep` | Patrol |
| `enc_patrol_anomaly_border_check_06` | `enc_patrol_anomaly_border_check` | Patrol |
| `enc_distress_beacon_failure_01` | `enc_distress_beacon_failure` | Distress |
| `enc_distress_hull_breach_02` | `enc_distress_hull_breach` | Distress |
| `enc_distress_medical_emergency_03` | `enc_distress_medical_emergency` | Distress |
| `enc_distress_raider_siege_04` | `enc_distress_raider_siege` | Distress |
| `enc_distress_fuel_line_freeze_05` | `enc_distress_fuel_line_freeze` | Distress |
| `enc_distress_station_scrubber_failure_06` | `enc_distress_station_scrubber_failure` | Distress |
| `enc_discovery_derelict_vessel_01` | `enc_discovery_derelict_vessel` | Discovery |
| `enc_discovery_abandoned_station_02` | `enc_discovery_abandoned_station` | Discovery |
| `enc_discovery_anomalous_signal_03` | `enc_discovery_anomalous_signal` | Discovery |
| `enc_discovery_fatigue_failure_evidence_04` | `enc_discovery_fatigue_failure_evidence` | Discovery |
| `enc_discovery_contested_finds_05` | `enc_discovery_contested_finds` | Discovery |
| `enc_discovery_water_vein_mapping_06` | `enc_discovery_water_vein_mapping` | Discovery |
| `enc_crew_interpersonal_conflict_01` | `enc_crew_interpersonal_conflict` | Crew |
| `enc_crew_mutiny_rumor_02` | `enc_crew_mutiny_rumor` | Crew |
| `enc_crew_bonding_ritual_03` | `enc_crew_bonding_ritual` | Crew |
| `enc_crew_skill_gap_training_04` | `enc_crew_skill_gap_training` | Crew |
| `enc_crew_resource_tension_05` | `enc_crew_resource_tension` | Crew |
| `enc_crew_loss_tributary_06` | `enc_crew_loss_tributary` | Crew |
| `enc_faction_ac_union_contract_01` | `enc_faction_ac_union_contract` | Faction |
| `enc_faction_nac_payroll_audit_02` | `enc_faction_nac_payroll_audit` | Faction |
| `enc_faction_b2_clearance_broker_03` | `enc_faction_b2_clearance_broker` | Faction |
| `enc_faction_me_engineering_access_04` | `enc_faction_me_engineering_access` | Faction |
| `enc_faction_t4_genetic_leak_05` | `enc_faction_t4_genetic_leak` | Faction |
| `enc_faction_saa_overlooked_intel_06` | `enc_faction_saa_overlooked_intel` | Faction |

## Tone rules (locked, same as 3g)

- **Wildermuth-style:** personal, grounded, **avoid melodrama**. The belt is indifferent.
- **2-3 choices minimum.** Give the player meaningful trade-offs (resources vs ethics vs survival vs reputation).
- **Zero "good choice / bad choice" framing.** Every choice has a cost and a benefit. Player makes trade-offs.
- **No named crew members.** Use archetypes: "nav officer", "eng tech", "the medic", "the conscript".
- **Choices are actions, not sentiments.** "Cut the line and proceed" not "Consider cutting the line."
- **Bias-check EVERY beat** against BIAS_GUARDRAILS.md. No ethnic, religious, or cultural shorthand.

## Delta vocabulary (repeat from _META.md)

Allowed keys only:

| Key | Type | Use |
|---|---|---|
| `fuel_delta` | int | Negative = cost, positive = gain |
| `suspicion_delta` | int | Change to suspicion meter |
| `bond_score` | int | Trust with crew |
| `crew_xp` | dict | e.g. `{ "eng_tech": 1 }` |
| `discoveries` | list[str] | Discovery IDs for ledger |
| `credit_delta` | int | Credits gained or lost |
| `blessing_variant` | str | Blessing type reward |
| `legacy_trace_claimed` | bool | Only for legacy trace beats |

Do NOT add keys outside this set.

## Stop conditions

- `narrative/beats/_META.md` not readable
- `docs/BIAS_GUARDRAILS.md` not readable
- Schema B format doesn't match dict-based `beats { }` pattern

## Output deliverable

1. `narrative/beats/encounter-pool-beats.json` — 30 beats
2. Bias-check log
3. Report to coordinator with:
   - Beats written count (30)
   - Sample 3 beats in full
   - Any patterns found in bias pass

## Estimated effort

~2-3h for 30 beats with full prose + choices. If time is tight, write the first 3 categories (Patrol + Distress + Discovery = 18 beats) first — they have the highest encounter weight. Crew and Faction are lower weight and can be deferred.

## Expected commit message

```
narrative(encounter): add 30 Schema B beats for encounter pool (Phase 3g.2)

Phase: 3g
```

## Report format

```
enc-beats: <done|blocker>
  • File: narrative/beats/encounter-pool-beats.json
  • Count: <N> written (of 30)
  • Bias: all passed / <N> rewrites
  • Next: <waiting | available for more>
```
