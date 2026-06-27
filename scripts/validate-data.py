#!/usr/bin/env python3
"""
borrowed-space data validation script.
Run from repo root:  python3 scripts/validate-data.py
Exits 0 on pass, 1 on failure.

Checks every JSON file for structural correctness and cross-file consistency.
"""

import json, sys, os
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
errors = []
warnings = []

def err(msg):
    errors.append(msg)
    print(f"  ❌ {msg}")

def warn(msg):
    warnings.append(msg)
    print(f"  ⚠️  {msg}")

def ok(msg):
    print(f"  ✅ {msg}")

def check(cond, msg):
    if cond:
        ok(msg)
    else:
        err(msg)

# ── Helpers ───────────────────────────────────────────────────────

ALLOWED_CATEGORIES = {"Patrol", "Distress", "Discovery", "Crew", "Faction"}
ALLOWED_ARRIVAL_KINDS = {"lane", "deep_belt", "derelict_hex", "anomaly_hex", "station_hex"}
ALLOWED_RESOLUTIONS = {"dialog", "combat"}
ALLOWED_GIVER_SOURCES = {"corps", "genship", "private", "trustee"}
ALL_CORP_IDS = {"T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8"}
ALL_GENSHIP_IDS = {"NAC", "ED", "RRA", "SAA", "AC", "ME"}
ALL_BELT_IDS = {"B1", "B2", "B3"}

INVENTORY_FILES = [
    ("captain-origins.json", "narrative/data"),
    ("npc-archetypes.json", "narrative/data"),
    ("ledger.json", "narrative/data"),
    ("belt_factions.json", "narrative/data"),
    ("trust_families.json", "narrative/data"),
    ("stations.json", "narrative/data"),
    ("cartography.json", "narrative/data"),
    ("encounter-pool.json", "narrative/data"),
    ("aliens.json", "narrative/data"),
    ("die_in_throes.json", "narrative/data"),
    ("captains_journal.json", "narrative/data"),
    ("encounter-pool-beats.json", "narrative/beats"),
    ("cqb-ink-beats.json", "narrative/beats"),
    ("station_arrival_beats.json", "narrative/beats"),
]

# ── 1. File existence + parseability ──────────────────────────────

print("\n=== 1. All JSON files parse ===")
all_data = {}
for fname, subdir in INVENTORY_FILES:
    path = REPO / subdir / fname
    check(path.exists(), f"{fname} exists")
    if path.exists():
        try:
            all_data[fname] = json.loads(path.read_text(encoding="utf-8"))
            ok(f"{fname} parses ({path.stat().st_size} bytes)")
        except json.JSONDecodeError as e:
            err(f"{fname} parse error: {e}")

# ── 2. encounter-pool.json structural checks ──────────────────────

print("\n=== 2. encounter-pool.json ===")
pool = all_data.get("encounter-pool.json", {})
if pool:
    entries = pool.get("entries", [])
    check(len(entries) >= 30, f"entry count >= 30 (got {len(entries)})")
    seen_ids = set()
    for i, e in enumerate(entries):
        eid = e.get("id", f"entry_{i}")
        # Required fields
        for field in ["id", "category", "weight", "arrival_kinds", "beat_id", "flavor_hook", "intensity", "resolution"]:
            if field not in e:
                err(f"{eid}: missing '{field}'")
        # Category validity
        if e.get("category") not in ALLOWED_CATEGORIES:
            err(f"{eid}: invalid category '{e.get('category')}'")
        # Arrival kinds
        for ak in e.get("arrival_kinds", []):
            if ak not in ALLOWED_ARRIVAL_KINDS:
                err(f"{eid}: invalid arrival_kind '{ak}'")
        # Weight sanity
        w = e.get("weight", 0)
        if w <= 0 or w > 10:
            warn(f"{eid}: unusual weight {w}")
        # Duplicate id
        if eid in seen_ids:
            err(f"{eid}: duplicate id")
        seen_ids.add(eid)
        # Resolution
        if e.get("resolution") not in ALLOWED_RESOLUTIONS:
            err(f"{eid}: invalid resolution '{e.get('resolution')}'")
        # Giver source
        gs = e.get("giver_source", "")
        if gs and gs not in ALLOWED_GIVER_SOURCES:
            err(f"{eid}: invalid giver_source '{gs}'")
        # Faction validity
        gf = e.get("giver_faction", "")
        if gf and gf not in ALL_CORP_IDS and gf not in ALL_GENSHIP_IDS and gf not in ALL_BELT_IDS:
            warn(f"{eid}: unknown giver_faction '{gf}' (may be a new one)")
    ok("structural checks complete")

# ── 3. encounter-pool-beats.json structural checks ────────────────

print("\n=== 3. encounter-pool-beats.json ===")
beats = all_data.get("encounter-pool-beats.json", {})
if beats:
    beat_dict = beats.get("beats", {})
    check(len(beat_dict) >= 25, f"beat count >= 25 (got {len(beat_dict)})")
    for bid, beat in beat_dict.items():
        check("prose" in beat, f"{bid}: has prose")
        check("choices" in beat, f"{bid}: has choices")
        for c in beat.get("choices", []):
            check("text" in c, f"{bid} choice: has text")
            check("delta" in c, f"{bid} choice: has delta")
    check(len(beat_dict) >= len(pool.get("entries", [])),
          "beats >= pool entries")

# ── 4. Cross-file: pool beat_ids exist in beats file ──────────────

print("\n=== 4. Pool → beat cross-reference ===")
if pool and beats:
    beat_keys = set(beats.get("beats", {}).keys())
    pool_bids = {e.get("beat_id") for e in pool.get("entries", []) if e.get("beat_id")}
    missing = pool_bids - beat_keys
    orphans = beat_keys - pool_bids
    check(len(missing) == 0, f"0 pool entries missing beat (found {len(missing)})")
    for m in sorted(missing):
        err(f"  beat_id '{m}' not found in beats file")
    check(len(orphans) == 0, f"0 orphan beats (found {len(orphans)})")
    for o in sorted(orphans):
        warn(f"  beat '{o}' has no pool entry (may be intentional)")

# ── 5. cqb-ink-beats.json ─────────────────────────────────────────

print("\n=== 5. cqb-ink-beats.json ===")
cqb = all_data.get("cqb-ink-beats.json", {})
if cqb:
    cqb_beats = cqb.get("beats", {})
    check(len(cqb_beats) >= 6, f"beat count >= 6 (got {len(cqb_beats)})")
    required_outcomes = {"cqb_cover_pass_clean", "cqb_cover_pass_rough",
                         "cqb_end_won", "cqb_end_lost", "cqb_end_fled", "cqb_end_casualty"}
    for rid in required_outcomes:
        check(rid in cqb_beats, f"required beat '{rid}' exists")
    for bid, beat in cqb_beats.items():
        check("text" in beat, f"{bid}: has text")
        check("speaker" in beat, f"{bid}: has speaker")
        check("choices" in beat, f"{bid}: has choices")
        for c in beat.get("choices", []):
            check("label" in c, f"{bid} choice: has label")
            check("to" in c, f"{bid} choice: has 'to' target")

# ── 6. station_arrival_beats.json ────────────────────────────────

print("\n=== 6. station_arrival_beats.json ===")
arrival = all_data.get("station_arrival_beats.json", {})
if arrival:
    arr_beats = arrival.get("beats", {})
    check(len(arr_beats) >= 15, f"beat count >= 15 (got {len(arr_beats)})")
    for bid, beat in arr_beats.items():
        check("text" in beat, f"{bid}: has text")
        check("speaker" in beat, f"{bid}: has speaker")
        check("choices" in beat, f"{bid}: has choices")
        for c in beat.get("choices", []):
            check("label" in c, f"{bid} choice: has label")
            check("to" in c, f"{bid} choice: has 'to' target")

# ── 7. station beat → station ID coverage ─────────────────────────

print("\n=== 7. Station beat coverage ===")
stations_file = all_data.get("stations.json", {})
if stations_file and arrival:
    station_ids = [s.get("id", "") for s in stations_file.get("stations", [])]
    arr_keys = list(arrival.get("beats", {}).keys())
    for sid in station_ids:
        num_part = sid.replace("STATION_", "")
        matches = [k for k in arr_keys if k.upper().endswith("_" + num_part)]
        check(len(matches) >= 1, f"{sid}: has >= 1 arrival beat (found {len(matches)})")
        if len(matches) < 3:
            warn(f"{sid}: only {len(matches)} visit variants (expected 3 for full coverage)")

# ── 8. stations.json structural ──────────────────────────────────

print("\n=== 8. stations.json ===")
if stations_file:
    stations = stations_file.get("stations", [])
    check(len(stations) >= 8, f"station count >= 8 (got {len(stations)})")
    for s in stations:
        for field in ["id", "name", "faction_id", "atmosphere", "ink_beat_id"]:
            check(field in s, f"{s.get('id', '?')}: has '{field}'")
    # Cross-check with cartography: every station in stations.json should have a
    # matching entry in cartography.json (with q/r coordinates)
    carto_data = all_data.get("cartography.json", {})
    if carto_data:
        carto_ids = {cs.get("id") for cs in carto_data.get("stations", [])}
        station_ids = {s.get("id") for s in stations}
        missing_carto = station_ids - carto_ids
        extra_carto = carto_ids - station_ids
        check(len(missing_carto) == 0, f"0 stations missing from cartography (found {len(missing_carto)})")
        check(len(extra_carto) == 0, f"0 cartography entries without station (found {len(extra_carto)})")

# ── 9. captain-origins.json ─────────────────────────────────────

print("\n=== 9. captain-origins.json ===")
origins = all_data.get("captain-origins.json", {})
if origins:
    o_list = origins.get("origins", [])
    check(len(o_list) >= 5, f"origin count >= 5 (got {len(o_list)})")
    gids = set()
    for o in o_list:
        gid = o.get("genship_id", "")
        check(gid in ALL_GENSHIP_IDS, f"{gid}: valid genship_id")
        check("genship_label" in o, f"{gid}: has label")
        check("country_fragments" in o, f"{gid}: has fragments")
        check("tag_pool" in o, f"{gid}: has tag_pool")
        gids.add(gid)
    check(len(gids) >= 5, f"unique genship IDs >= 5")

# ── 10. aliens.json ─────────────────────────────────────────────

print("\n=== 10. aliens.json ===")
aliens = all_data.get("aliens.json", {})
if aliens:
    archs = aliens.get("archetypes", [])
    check(len(archs) >= 3, f"alien archetypes >= 3 (got {len(archs)})")
    for a in archs:
        check("id" in a, f"alien: has id")
        check("weapon_id" in a, f"{a.get('id')}: has weapon_id")
        check("hp_max" in a, f"{a.get('id')}: has hp_max")

# ── 11. Voice fragments ─────────────────────────────────────────

print("\n=== 11. Voice corpus ===")
dit = all_data.get("die_in_throes.json", {})
cj = all_data.get("captains_journal.json", {})
if dit:
    dit_pool = dit.get("die_in_throes", [])
    check(len(dit_pool) >= 50, f"die_in_throes >= 50 (got {len(dit_pool)})")
if cj:
    cj_pool = cj.get("captain_journal", [])
    check(len(cj_pool) >= 50, f"captain_journal >= 50 (got {len(cj_pool)})")

# ── 12. Cartography hex validation ─────────────────────────────────

print("\n=== 12. cartography.json ===")
carto = all_data.get("cartography.json", {})
if carto:
    stations = carto.get("stations", [])
    check(len(stations) >= 8, f"station count >= 8 (got {len(stations)})")
    for s in stations:
        check("id" in s, f"station {s.get('id', '?')}: has id")
        check("q" in s and "r" in s, f"{s.get('id')}: has q/r coordinates")
        check("faction_id" in s, f"{s.get('id')}: has faction_id")
        check("kinds" in s, f"{s.get('id')}: has kinds")

# ── Summary ────────────────────────────────────────────────────────

print(f"\n{'='*50}")
print(f"Validation complete")
print(f"  Errors:   {len(errors)}")
print(f"  Warnings: {len(warnings)}")
if errors:
    print(f"\n  ❌ {len(errors)} error(s) — fix before commit:")
    for e in errors:
        print(f"    - {e}")
if warnings:
    print(f"\n  ⚠️  {len(warnings)} warning(s) — review:")
    for w in warnings:
        print(f"    - {w}")
if not errors:
    print(f"\n  ✅ All data files valid.")
sys.exit(1 if errors else 0)
