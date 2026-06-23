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
	"origins":  "/../narrative/data/captain-origins.json",
	"npcs":     "/../narrative/data/npc-archetypes.json",
	"ledger":   "/../narrative/data/ledger.json",
}

# Cache so we don't re-parse every call.
static var _cache := {}

static func _resolve_dev_path(key: String) -> String:
	var godot_root := ProjectSettings.globalize_path("res://")
	var rel: String = RELATIVE_PATHS[key]
	# godot/ ends with "/", so we want /<rel> with no extra slash.
	return godot_root + rel.lstrip("/")

static func _read_json(key: String, path: String) -> Variant:
	if _cache.has(key):
		return _cache[key]
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
	return _read_json("origins", _resolve_dev_path("origins"))

static func npc_archetypes() -> Variant:
	return _read_json("npcs", _resolve_dev_path("npcs"))

static func ledger_template() -> Variant:
	return _read_json("ledger", _resolve_dev_path("ledger"))

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
