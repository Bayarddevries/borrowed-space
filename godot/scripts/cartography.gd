class_name Cartography
extends RefCounted

# Cartography — the belt map data.
#
# Loads narrative/data/cartography.json (zero lore, ids + coords only).
# Each station has a unique id (STATION_01..10), an axial-hex coord,
# a faction, and a list of hex kinds (always including "station_hex").
#
# Hex kinds (computed from station kinds + belt geometry):
#   out_of_play   — outside radius 25, never enters runtime
#   deep_belt     — empty space (default for in-belt, non-station)
#   lane          — well-trafficked transit corridor (faction-controlled)
#   station_hex   — a hex with a station landing pad
#   derelict_hex  — wreck / abandoned / hazard
#   anomaly_hex   — discovery-triggering feature
#
# Hazard modifiers (per OLD CARTOGRAPHY.md §1):
#   deep_belt    1.0
#   lane         0.7
#   station_hex  1.0
#   derelict_hex 1.5
#   anomaly_hex  1.3
#
# Phase 3a.0 narrative beat content (empty-space encounters,
# legacy-trace prototype) sits on top of this — the encounter_pool
# rolls against arrival_kind returned here.

const _DATA_KEY := "cartography"

const HEX_KINDS := {
	"out_of_play":   { "hazard_modifier": 1.0 },
	"deep_belt":     { "hazard_modifier": 1.0 },
	"lane":          { "hazard_modifier": 0.7 },
	"station_hex":   { "hazard_modifier": 1.0 },
	"derelict_hex":  { "hazard_modifier": 1.5 },
	"anomaly_hex":   { "hazard_modifier": 1.3 },
}

## Hex kind at an arbitrary (q, r) coord.
## Stations claim their own coord; other in-belt hexes are "deep_belt"
## unless a lane spans them (lanes not yet modeled in Phase 3a.1 — held
## as a placeholder per CARTOGRAPHY.md §7 open-questions).
static func hex_kind_at(q: int, r: int, stations: Array) -> String:
	if Hex.distance(Vector2i(0, 0), Vector2i(q, r)) > Hex.BELT_RADIUS:
		return "out_of_play"
	for s in stations:
		if int(s.get("q", -99999)) == q and int(s.get("r", -99999)) == r:
			var kinds: Array = s.get("kinds", ["station_hex"])
			if kinds.size() == 0:
				return "station_hex"
			# Return the primary "structural" kind for the hex:
			# station > derelict > anomaly > lane > deep_belt
			for k in ["station_hex", "derelict_hex", "anomaly_hex", "lane"]:
				if kinds.has(k):
					return k
			return kinds[0]
	return "deep_belt"

## Hazard modifier at a hex kind.
static func hazard_modifier(kind: String) -> float:
	if HEX_KINDS.has(kind):
		return float(HEX_KINDS[kind].get("hazard_modifier", 1.0))
	return 1.0

## Look up a station by id; returns Dictionary or null.
static func find_station(stations: Array, id: String) -> Variant:
	for s in stations:
		if s.get("id", "") == id:
			return s
	return null

## Validate the cartography.json data set meets acceptance criteria from
## CARTOGRAPHY.md §8.1:
##   - 8–12 stations
##   - all coords within Hex.BELT_RADIUS of origin
##   - kinds array well-formed (always contains "station_hex")
##   - faction_id present
static func validate(stations: Array) -> Dictionary:
	var issues: Array = []
	if stations.size() < 8 or stations.size() > 12:
		issues.append("station_count_out_of_range_%d_%d" % [8, 12])
	var seen_ids := {}
	for s in stations:
		var id := str(s.get("id", ""))
		if id == "":
			issues.append("missing_id")
			continue
		if seen_ids.has(id):
			issues.append("duplicate_id_%s" % id)
		seen_ids[id] = true
		var q := int(s.get("q", -99999))
		var r := int(s.get("r", -99999))
		if Hex.distance(Vector2i(0, 0), Vector2i(q, r)) > Hex.BELT_RADIUS:
			issues.append("out_of_belt_%s_at_(%d,%d)" % [id, q, r])
		var kinds: Array = s.get("kinds", [])
		if not kinds.has("station_hex"):
			issues.append("missing_station_hex_kind_%s" % id)
		if str(s.get("faction_id", "")) == "":
			issues.append("missing_faction_id_%s" % id)
	return { "ok": issues.is_empty(), "issues": issues }

## Load stations from narrative/data/cartography.json via NarrativeData.
## Returns Array of station dicts; mirrors the shape in .json.
static func load_stations() -> Array:
	var paths = NarrativeData.RELATIVE_PATHS
	if not paths.has(_DATA_KEY):
		# Late-bind if not yet registered; defensive default.
		paths[_DATA_KEY] = "/../narrative/data/cartography.json"
	var path: String = NarrativeData._resolve_dev_path(_DATA_KEY)
	if not FileAccess.file_exists(path):
		push_error("Cartography: file not found at %s" % path)
		return []
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Cartography: cannot open %s" % path)
		return []
	var raw := f.get_as_text()
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Cartography: top-level not an object at %s" % path)
		return []
	var v = parsed.get("stations", [])
	if typeof(v) != TYPE_ARRAY:
		push_error("Cartography: 'stations' not array at %s" % path)
		return []
	return v
