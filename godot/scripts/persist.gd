extends Node
## Persist — singleton persistence layer.
##
## Phase 2d of ROADMAP.md. Schema derived from docs/PERSISTENCE.md §1.
##
## API:
##   - save() — writes the current state to data/persist.json atomically.
##   - load(slot := "default") -> bool — reads from data/persist.json.
##   - reset() — wipes state to defaults.
##   - get_state() -> Dictionary — current in-memory state.
##   - patch(updates: Dictionary) — merges updates into state.
##   - flag_lock() / unflag_lock() — flag-based mutex (Godot lacks native mutex).
##
## Schema (matches docs/PERSISTENCE.md):
##   campaign_state:
##     he3_dismantling_progress: float (0-100)
##     discovered_acts: Array[String]
##     bunker_mapped_flags: Dictionary
##     mid_industrial_arcs_unlocked: Array[String]
##     alt_fuel_replacements: Array[String]
##   belt_state:
##     stations_destroyed: Array[String]
##     stations_defended: Array[String]
##     stations_ownership: Dictionary
##     resource_claims: Dictionary
##     fuel_depots: Dictionary
##   npc_state:
##     npcs: Dictionary
##   ledger:
##     captains: Dictionary
##     crew: Dictionary
##   trustee_arc:
##     unlocked_bits: Array[String]
##
## Per-run state is appended as a new captain section in `ledger.captains`.

const SAVE_PATH := "user://persist.json"
const SAVE_VERSION := 1

var state: Dictionary = _default_state()
var _locked := false


func _ready() -> void:
	# Auto-load on init. If file missing or corrupt, reset() is called.
	if not load_state():
		push_warning("[Persist] no save file at %s; starting fresh." % SAVE_PATH)


func _default_state() -> Dictionary:
	return {
		"campaign_state": {
			"he3_dismantling_progress": 0.0,
			"discovered_acts": [],
			"bunker_mapped_flags": {},
			"mid_industrial_arcs_unlocked": [],
			"alt_fuel_replacements": [],
		},
		"belt_state": {
			"stations_destroyed": [],
			"stations_defended": [],
			"stations_ownership": {},
			"resource_claims": {},
			"fuel_depots": {},
		},
		"npc_state": {
			"npcs": {},
		},
		"ledger": {
			"captains": {},
			"crew": {},
		},
		"trustee_arc": {
			"unlocked_bits": [],
		},
		"_meta": {
			"version": SAVE_VERSION,
			"created_at": Time.get_unix_time_from_system(),
			"updated_at": Time.get_unix_time_from_system(),
		},
	}


func save() -> bool:
	if _locked:
		push_warning("[Persist] save() blocked; lock held.")
		return false
	flag_lock()
	state["_meta"]["updated_at"] = Time.get_unix_time_from_system()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("[Persist] could not open %s for writing." % SAVE_PATH)
		unflag_lock()
		return false
	# Atomic write: write to a temp file then rename.
	var tmp := SAVE_PATH + ".tmp"
	var tmp_f := FileAccess.open(tmp, FileAccess.WRITE)
	if tmp_f == null:
		push_error("[Persist] could not open %s for temp write." % tmp)
		f.close()
		unflag_lock()
		return false
	tmp_f.store_string(JSON.stringify(state, "\t"))
	tmp_f.close()
	f.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(SAVE_PATH))
	unflag_lock()
	return true


func load_state(slot: String = "default") -> bool:
	if _locked:
		push_warning("[Persist] load_state() blocked; lock held.")
		return false
	flag_lock()
	# Phase 2: only one slot, named "default".
	if slot != "default":
		unflag_lock()
		push_warning("[Persist] unknown slot %s; only 'default' supported in phase 2d." % slot)
		return false
	if not FileAccess.file_exists(SAVE_PATH):
		unflag_lock()
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		unflag_lock()
		push_error("[Persist] file_exists but open failed: %s" % SAVE_PATH)
		return false
	var text := f.get_as_text()
	f.close()
	unflag_lock()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[Persist] parse failed; data was not a dictionary.")
		reset()
		return false
	if not parsed.has("_meta") or not parsed["_meta"].has("version"):
		push_warning("[Persist] no version metadata; resetting.")
		reset()
		return false
	if parsed["_meta"]["version"] != SAVE_VERSION:
		push_warning("[Persist] version mismatch (have %d, need %d); resetting." % [
			parsed["_meta"]["version"], SAVE_VERSION
		])
		reset()
		return false
	state = parsed
	return true


func reset() -> void:
	state = _default_state()


func get_state() -> Dictionary:
	# Return a *copy* so callers cannot mutate internal state.
	return state.duplicate(true)


func patch(updates: Dictionary) -> bool:
	# Merge keys into state. Recurse into nested dictionaries.
	if _locked:
		push_warning("[Persist] patch() blocked; lock held.")
		return false
	flag_lock()
	_deep_merge(state, updates)
	unflag_lock()
	return true


func flag_lock() -> void:
	_locked = true


func unflag_lock() -> void:
	_locked = false


func _deep_merge(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		var src_val = source[key]
		if target.has(key) and typeof(target[key]) == TYPE_DICTIONARY and typeof(src_val) == TYPE_DICTIONARY:
			_deep_merge(target[key], src_val)
		else:
			target[key] = src_val


# ── NPC persistence helpers ──────────────────────────────────────

## Get persisted state for a specific NPC. Returns dict with defaults.
func get_npc_state(npc_id: String) -> Dictionary:
	var npcs: Dictionary = state.get("npc_state", {}).get("npcs", {})
	if npcs.has(npc_id):
		return npcs[npc_id].duplicate()
	# Return defaults
	return {
		"met": false,
		"relationship": 0,
		"last_run": 0,
		"dialogue_flags": {},
		"total_encounters": 0,
	}


## Mark an NPC as met and optionally update relationship.
func meet_npc(npc_id: String, relationship_delta: int = 0) -> void:
	var npc: Dictionary = get_npc_state(npc_id)
	npc["met"] = true
	npc["relationship"] = npc.get("relationship", 0) + relationship_delta
	npc["total_encounters"] = npc.get("total_encounters", 0) + 1
	npc["last_run"] = state.get("run_counts", {}).get("started", 0)
	_set_npc(npc_id, npc)


## Set a dialogue flag for an NPC (e.g. "heard_about_conspiracy": true)
func set_npc_flag(npc_id: String, flag_key: String, value) -> void:
	var npc: Dictionary = get_npc_state(npc_id)
	npc["dialogue_flags"][flag_key] = value
	_set_npc(npc_id, npc)


## Get a dialogue flag for an NPC. Returns null if not set.
func get_npc_flag(npc_id: String, flag_key: String):
	var npc: Dictionary = get_npc_state(npc_id)
	if npc.get("dialogue_flags", {}).has(flag_key):
		return npc["dialogue_flags"][flag_key]
	return null


## Has the player ever met this NPC?
func has_met_npc(npc_id: String) -> bool:
	return get_npc_state(npc_id).get("met", false)


## Get relationship score for an NPC (default 0).
func get_npc_relationship(npc_id: String) -> int:
	return get_npc_state(npc_id).get("relationship", 0)


func _set_npc(npc_id: String, npc_data: Dictionary) -> void:
	if not state.has("npc_state"):
		state["npc_state"] = {"npcs": {}}
	if not state["npc_state"].has("npcs"):
		state["npc_state"]["npcs"] = {}
	state["npc_state"]["npcs"][npc_id] = npc_data
