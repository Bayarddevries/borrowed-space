class_name EncounterPool
extends RefCounted

## Weighted encounter selector for belt/transit.
## Reads `narrative/data/encounter-pool.json` via NarrativeData.
## Returns a result dict or null when no encounter rolls.

static func roll(ship_state: Dictionary, arrival_kind: String, stations: Array) -> Variant:
	var data: Variant = NarrativeData.encounter_pool()
	if data == null:
		push_error("[EncounterPool] encounter-pool.json missing or unparseable")
		return null

	var entries: Array = data.get("entries", [])
	if entries.is_empty():
		return null

	# 1) Base hit chance
	var base_chance: float = 0.0
	match arrival_kind:
		"deep_belt":
			base_chance = 0.40
		"lane":
			base_chance = 0.40
		"derelict_hex":
			base_chance = 0.80
		"anomaly_hex":
			base_chance = 1.0
		"station_hex":
			base_chance = 0.25
		_:
			base_chance = 0.40

	var roll_val: float = randf()
	if roll_val > base_chance:
		return null

	# 2) Station state multiplier (only matters for station_hex)
	var station_mult: float = 1.0
	if arrival_kind == "station_hex":
		var state_label: String = str(ship_state.get("station_state", "normal")).to_lower()
		match state_label:
			"normal":
				station_mult = 1.0
			"tense":
				station_mult = 1.3
			"hostile":
				station_mult = 0.6
			"ruined":
				station_mult = 0.4
			_:
				station_mult = 1.0

	# 3) Ship-state modifiers (suspicion, low fuel, etc.)
	var suspicion: int = int(ship_state.get("suspicion", 0))
	var fuel: int = int(ship_state.get("fuel", 100))
	var recent_combat: bool = bool(ship_state.get("recent_combat", false))

	var suspicion_mod: float = float(suspicion) * 0.02
	var fuel_mod: float = 0.0
	if fuel < 20:
		fuel_mod = -0.10
	var recent_combat_mod: float = 0.05 if recent_combat else 0.0

	var final_chance: float = base_chance * station_mult + suspicion_mod + fuel_mod + recent_combat_mod
	if final_chance < 0.0:
		final_chance = 0.0
	if final_chance > 1.0:
		final_chance = 1.0
	if randf() > final_chance:
		return null

	# 4) Weighted selection among eligible entries
	var eligible: Array = []
	for entry in entries:
		if not _is_eligible(entry, ship_state):
			continue
		eligible.append(entry)

	if eligible.is_empty():
		return null

	var total_weight: float = 0.0
	for e in eligible:
		total_weight += float(e.get("weight", 1.0))

	var roll_weight: float = randf() * total_weight
	var acc: float = 0.0
	var picked: Dictionary = eligible[0]
	for e in eligible:
		acc += float(e.get("weight", 1.0))
		if roll_weight <= acc:
			picked = e
			break

	return {
		"category": str(picked.get("category", "")),
		"variant_id": str(picked.get("id", "")),
		"flavor_hook": str(picked.get("flavor_hook", "A belt encounter unfolds.")),
		"beat_id": str(picked.get("beat_id", "")),
		"intensity": str(picked.get("intensity", "mid")),
		"resolution_hint": str(picked.get("resolution", "dialog")),
	}

static func _is_eligible(entry: Dictionary, ship_state: Dictionary) -> bool:
	var act_gate: String = str(entry.get("act_gate", ""))
	if act_gate == "" or act_gate == "null":
		return true

	var current_act: String = str(ship_state.get("act", ""))
	if current_act == "":
		return true

	return current_act == act_gate
