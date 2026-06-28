# narrative_data.gd
#
# Loader for narrative/data/*.json.
#
# Scope (Phase 2e): prove the three data files parse and the schema shape
# is reachable from GDScript. NOT an Ink runner — that's Phase 2c (deferred).
# When Ink wrapper lands, it consumes the same shapes exposed here.
#
# Files live at <repo-root>/narrative/data/, OUTSIDE the Godot project root
# (per AGENTS.md convention — narrative is the source-of-truth for the
# story layer, separate from the engine). NarrativeData resolves the
# dev-mode location from ProjectSettings.globalize_path("res://") and
# walks up one level to the repo root.
#
# In production builds, Phase 2c bundler routes JSON through the Vite
# pipeline into res:// — see docs/INK_INTEGRATION.md §Path-A. Until then,
# narrative data is accessible to test-runs and to the wrapped Ink runner,
# but not to scene-bundled runtime code that needs res:// access.
#
# Zero lore is read or printed.
extends Node
class_name NarrativeData

const RELATIVE_PATHS := {
	"origins":          "/../narrative/data/captain-origins.json",
	"npcs":             "/../narrative/data/npc-archetypes.json",
	"ledger":           "/../narrative/data/ledger.json",
	"cartography":      "/../narrative/data/cartography.json",
	"aliens":           "/../narrative/data/aliens.json",
	"encounter_pool":   "/../narrative/data/encounter-pool.json",
	"die_in_throes":    "/../narrative/data/die_in_throes.json",
	"captains_journal": "/../narrative/data/captains_journal.json",
}

# Bundle path prefix: res://assets/data/ — populated by scripts/bundle-narrative.sh
const BUNDLE_PREFIX := "res://assets/data/"

# Cache so we don't re-parse every call.
static var _cache := {}

## Resolve a data file path. Tries the production bundled path first
## (res://assets/data/<filename>.json), falls back to dev-mode repo-root path.
static func _resolve_path(key: String) -> String:
	var bundled: String = BUNDLE_PREFIX + key + ".json"
	if FileAccess.file_exists(bundled):
		return bundled
	# Dev-mode fallback: map filename to RELATIVE_PATHS entry
	var rel_key := _dev_key_for(key)
	var godot_root := ProjectSettings.globalize_path("res://")
	var rel: String = RELATIVE_PATHS[rel_key]
	return godot_root + rel.lstrip("/")

## Map a filename (e.g. "captain-origins") to its RELATIVE_PATHS key ("origins").
static func _dev_key_for(key: String) -> String:
	var mapping := {
		"captain-origins": "origins",
		"npc-archetypes": "npcs",
		"ledger": "ledger",
		"cartography": "cartography",
		"aliens": "aliens",
		"die_in_throes": "die_in_throes",
		"captains_journal": "captains_journal",
		"encounter-pool": "encounter_pool",
	}
	return mapping.get(key, key)

static func _read_json(key: String) -> Variant:
	if _cache.has(key):
		return _cache[key]
	var path: String = _resolve_path(key)
	if not FileAccess.file_exists(path):
		push_error("NarrativeData: file not found at %s" % path)
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("NarrativeData: open failed for %s" % path)
		return null
	var raw := f.get_as_text()
	f.close()
	var data = JSON.parse_string(raw)
	if data == null:
		push_error("NarrativeData: failed to parse %s" % path)
		return null
	_cache[key] = data
	return data

static func origins() -> Variant:
	return _read_json("captain-origins")

static func npc_archetypes() -> Variant:
	return _read_json("npc-archetypes")

static func ledger_template() -> Variant:
	return _read_json("ledger")

static func aliens() -> Variant:
	return _read_json("aliens")

static func die_in_throes() -> Variant:
	return _read_json("die_in_throes")

static func captains_journal_frags() -> Variant:
	return _read_json("captains_journal")

static func encounter_pool() -> Variant:
	return _read_json("encounter-pool")

# Returns a list of {id, label, ship_class, fragments_count} per genship.
static func list_genships() -> Array:
	var data = origins()
	if data == null:
		return []
	var out: Array = []
	for o in data["origins"]:
		out.append({
			"id": o["genship_id"],
			"label": o["genship_label"],
			"ship_class": o["first_ship_class"],
			"fragments_count": o["country_fragments"].size(),
		})
	return out

# Returns variant count per archetype slot.
static func npc_variant_counts() -> Dictionary:
	var data = npc_archetypes()
	if data == null:
		return {}
	var out: Dictionary = {}
	for a in data["archetypes"]:
		out[a["archetype_id"]] = a["variants"].size()
	return out

# Invalidate cache (e.g., after a save that mutated inherited data).
static func clear_cache() -> void:
	_cache.clear()

# Smoke-test kicker (callable from GUT or scene-bundled tests).
# Returns true if all three files parse and basic shape checks pass.
static func smoke_test() -> bool:
	var ok := true
	var o = origins()
	var n = npc_archetypes()
	var l = ledger_template()
	if o == null or not o.has("origins") or (o["origins"] as Array).size() == 0:
		ok = false
	if n == null or not n.has("archetypes") or (n["archetypes"] as Array).size() == 0:
		ok = false
	if l == null or not l.has("save_slot") or not l.has("captains"):
		ok = false
	return ok
