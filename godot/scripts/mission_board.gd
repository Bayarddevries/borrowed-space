class_name MissionBoard
extends RefCounted

## MissionBoard — mission offer generator for Issue #9.
## generate(ship_state, ledger, run_number) -> Array[Dictionary]
## Returns 3-5 mission offers shaped per docs/MISSION_BOARD.md.

static func generate(ship_state: Dictionary, ledger: Dictionary,
                     run_number: int) -> Array:
	var standings: Dictionary = _init_standings(ledger)
	var seeds: Array = _seed_weights(ship_state, standings)

	var offers: Array = []
	var count: int = _offer_count()
	var attempts: int = 0
	# Guarantee continuation offer if ledger has in-progress missions.
	var guaranteed_continuation: Variant = _guarantee_continuation(ledger)
	if guaranteed_continuation != null:
		offers.append(guaranteed_continuation)
	while offers.size() < count and attempts < 64:
		var src: Dictionary = _roll_source(seeds)
		var offer: Dictionary = _craft(src, ship_state, ledger,
		                               run_number, offers)
		if offer == null:
			attempts += 1
			continue
		offers.append(offer)

	# Apply decay directly to ledger's faction_standing (in-place side-effect).
	_apply_decay(ledger, standings, run_number)
	return offers

## ── internals ──────────────────────────────────────────────────────────

static func _init_standings(ledger: Dictionary) -> Dictionary:
	var base: Dictionary = ledger.get("faction_standing", {})
	if typeof(base) != TYPE_DICTIONARY:
		base = {}
	return base

static func _seed_weights(ship_state: Dictionary, standings: Dictionary) -> Array:
	var out: Array = [
		_series("corps", 0.40, standings, "trust"),
		_series("genship", 0.30, standings, "genship"),
		_series("private", 0.20, standings, null),
		_series("trustee", 0.10, standings, null),
	]
	# Normalize so total == 1.0.
	var total: float = 0.0
	for s in out:
		total += float(s.get("weight", 0.0))
	if total <= 0.0:
		return out
	var inv: float = 1.0 / total
	for s in out:
		s["weight"] = float(s.get("weight", 0.0)) * inv
	return out

static func _series(id: String, base: float, standings: Dictionary,
                    flag_prefix: Variant = null) -> Dictionary:
	var w: float = base
	if flag_prefix != null:
		var blocked: int = 0
		for k in standings.keys():
			if str(k).begins_with(flag_prefix):
				var v: int = int(standings[k])
				if v < -3:
					blocked += 1
		if blocked >= 1:
			w = 0.0
	return {"id": id, "weight": w}

static func _roll_source(seeds: Array) -> Dictionary:
	var rng: float = randf()
	var acc: float = 0.0
	for s in seeds:
		acc += float(s.get("weight", 0.0))
		if rng <= acc or acc >= 1.0:
			return s
	return seeds[0]

static func _offer_count() -> int:
	return 3 + randi() % 3  # 3, 4, or 5

static func _craft(src: Dictionary, ship_state: Dictionary,
                   ledger: Dictionary, run_number: int,
                   existing: Array) -> Dictionary:
	var source: String = str(src.id)
	var offer: Dictionary = {}
	if source == "trustee":
		offer = _trustee_mission(ledger, run_number, existing)
	else:
		offer = _offer_from_registry(source, ship_state, ledger, existing)
	if offer == null:
		return {}
	# Ensure required keys exist.
	if not offer.has("id"):
		offer["id"] = "mission_%s_%d" % [source, randi()]
	if not offer.has("source"):
		offer["source"] = source
	if not offer.has("risk"):
		offer["risk"] = _risk_for(offer)
	if not offer.has("act_gate"):
		offer["act_gate"] = ""
	# Normalize act_gate: never leave as null in output.
	if offer["act_gate"] == null:
		offer["act_gate"] = ""
	# Ensure continuation_of key exists.
	if not offer.has("continuation_of"):
		offer["continuation_of"] = null
	return offer

static func _risk_for(offer: Dictionary) -> String:
	var tier: String = str(offer.get("tier", "Gig"))
	match tier:
		"Operation":
			return "high"
		"Contract":
			return "medium"
		_:
			return "low"

## Registry-backed offers (Phase 3c content stubs).
static var _registry := {
	"corps": [
		{
			"tier": "Contract",
			"type": "freight",
			"giver": "Voidline Logistics",
			"objective": "Haul he-3 canisters to Kepler Station before deadline.",
			"complication_hint": "One canister is marked; unit seal broken en route.",
			"rewards": {"credits": 280, "standing_delta": {"trust_T2": 2}},
			"act_gate": "act_1",
			"dismantling_hook": "voidline_he3_route"
		},
		{
			"tier": "Operation",
			"type": "data",
			"giver": "Actuary Capital",
			"objective": "Intercept ledger packet carrying conscript payroll schema.",
			"complication_hint": "Packet is mirrored across three mids; only one is real.",
			"rewards": {"credits": 180, "standing_delta": {"trust_T5": 1}},
			"act_gate": "act_1",
			"dismantling_hook": "actuary_payroll_intercept"
		},
		{
			"tier": "Gig",
			"type": "mining",
			"giver": "Helios Extraction",
			"objective": "Vent regolith stockpile at Mars dust site Alpha-7.",
			"complication_hint": "Competitor crews are also on-site tonight.",
			"rewards": {"credits": 180, "standing_delta": {"trust_T1": 2}},
			"act_gate": "act_1",
			"dismantling_hook": "helios_mars_vent"
		},
		{
			"tier": "Contract",
			"type": "diplomacy",
			"giver": "SomaGenesis",
			"objective": "Review medical clearance for contested docking bay.",
			"complication_hint": "Settlement kin are hiding a non-cleared civilian.",
			"rewards": {"credits": 120, "standing_delta": {"trust_T4": 2}},
			"act_gate": "",
			"dismantling_hook": "soma_docking_review"
		},
		{
			"tier": "Operation",
			"type": "combat",
			"giver": "Forge & Frame",
			"objective": "Escort hull plate shipment through derelict corridor.",
			"complication_hint": "Corridor bulkhead cycle misfire forces alternate route.",
			"rewards": {"credits": 320, "standing_delta": {"trust_T6": 2}},
			"act_gate": "",
			"dismantling_hook": "forge_hull_escort"
		},
	],
	"genship": [
		{
			"tier": "Gig",
			"type": "freight",
			"giver": "NAC",
			"objective": "Deliver bridge circuit kit to forward outpost.",
			"complication_hint": "Kit is over-spec; local technician wants to keep it.",
			"rewards": {"credits": 120, "standing_delta": {"genship_NAC": 2}},
			"act_gate": "",
			"dismantling_hook": "nac_bridge_delivery"
		},
		{
			"tier": "Contract",
			"type": "combat",
			"giver": "RRA",
			"objective": "Secure fuel line against raider harassment.",
			"complication_hint": "Raider leader knows captain's genship past.",
			"rewards": {"credits": 260, "standing_delta": {"genship_RRA": 2}},
			"act_gate": "act_1",
			"dismantling_hook": "rra_fuel_defense"
		},
		{
			"tier": "Gig",
			"type": "exploration",
			"giver": "SAA",
			"objective": "Chart new canopy growth zone at edge of Recife block.",
			"complication_hint": "Growth zone carries unusual low-frequency resonance.",
			"rewards": {"credits": 140, "standing_delta": {"genship_SAA": 1}},
			"act_gate": "",
			"dismantling_hook": "saa_canopy_survey"
		},
		{
			"tier": "Contract",
			"type": "diplomacy",
			"giver": "ED",
			"objective": "Arbitrate docking-rights dispute between two station blocks.",
			"complication_hint": "One bloc has doctored transit logs.",
			"rewards": {"credits": 200, "standing_delta": {"genship_ED": 1}},
			"act_gate": "",
			"dismantling_hook": "ed_docking_arbitration"
		},
	],
	"private": [
		{
			"tier": "Gig",
			"type": "freight",
			"giver": "private",
			"objective": "Courier sealed package to secondary belt station.",
			"complication_hint": "Package contents are sensitive; questioning clears duty only.",
			"rewards": {"credits": 140, "standing_delta": {}},
			"act_gate": "",
			"dismantling_hook": "private_courier_run"
		},
		{
			"tier": "Gig",
			"type": "exploration",
			"giver": "private",
			"objective": "Survey derelict comms dish for reusable solar array.",
			"complication_hint": "Dish is partially inhabited by independent crew.",
			"rewards": {"credits": 160, "standing_delta": {}},
			"act_gate": "",
			"dismantling_hook": "private_derelict_survey"
		},
	],
	"trustee": [
		{
			"tier": "Operation",
			"type": "data",
			"giver": "Trustee",
			"objective": "Retrieve Trustee sealed folder from Station 09 safe-deposit.",
			"complication_hint": "Folder is cached by third party with competing claims.",
			"rewards": {"credits": 340, "standing_delta": {}},
			"act_gate": "act_1",
			"dismantling_hook": "trustee_folder_retrieval"
		},
	],
}

static func _offer_from_registry(source_id: String, ship_state: Dictionary,
                                  ledger: Dictionary, existing: Array) -> Dictionary:
	var pool: Array = _registry.get(source_id, [])
	if pool.size() == 0:
		return {}
	# Multi-stage continuation hook: if a matching in-progress mission
	# exists in the ledger, prefer a continuation offer.
	var in_progress_id: String = _find_in_progress(ledger, source_id)
	var pick: Dictionary = _pick(pool)
	if in_progress_id != "" and pick != null:
		# Try to find a pool entry that continues the in-progress mission.
		for candidate in pool:
			if str(candidate.get("dismantling_hook", "")) == in_progress_id:
				pick = candidate
				pick["continuation_of"] = in_progress_id
				break
		if not pick.has("continuation_of"):
			pick["continuation_of"] = in_progress_id
	elif pick == null:
		return {}
	# Assign stable id.
	pick["id"] = "mission_%s_%s_%d" % [source_id, pick.get("dismantling_hook", "x"), randi()]
	return pick

static func _find_in_progress(ledger: Dictionary, source_id: String) -> String:
	var missions: Array = []
	var run_state = ledger.get("run_state", {})
	if typeof(run_state) == TYPE_DICTIONARY:
		missions = run_state.get("missions", [])
	if typeof(missions) != TYPE_ARRAY:
		return ""
	for m in missions:
		if typeof(m) != TYPE_DICTIONARY:
			continue
		if str(m.get("status", "")) == "in_progress":
			# Match by source prefix or by dismantling_hook.
			var mid: String = str(m.get("id", ""))
			if mid.begins_with("mission_" + source_id) or \
			   str(m.get("source", "")) == source_id:
				return mid
	return ""

## Produce a guaranteed continuation offer for the first in-progress mission
## found in the ledger. Ensures multi-stage threads always advance.
static func _guarantee_continuation(ledger: Dictionary) -> Variant:
	var missions: Array = []
	var run_state = ledger.get("run_state", {})
	if typeof(run_state) == TYPE_DICTIONARY:
		missions = run_state.get("missions", [])
	if typeof(missions) != TYPE_ARRAY:
		return null
	for m in missions:
		if typeof(m) != TYPE_DICTIONARY:
			continue
		if str(m.get("status", "")) != "in_progress":
			continue
		var mid: String = str(m.get("id", ""))
		var source: String = str(m.get("source", ""))
		# Derive source from mission id if source field missing.
		if source == "" and mid.begins_with("mission_"):
			source = mid.substr(8)  # strip "mission_"
			# e.g. "mission_corps_cargo_stage1" -> try "corps"
			for src_key in _registry.keys():
				if source.begins_with(src_key):
					source = src_key
					break
		# Build a continuation offer for this source.
		var offer: Variant = _offer_from_registry(source, {}, ledger, [])
		if offer == null or (typeof(offer) == TYPE_DICTIONARY and offer.size() == 0):
			return null
		offer["continuation_of"] = mid
		offer["id"] = mid + "_continuation"
		offer["source"] = source
		return offer
	return null

static func _pick(pool: Array) -> Dictionary:
	if pool.size() == 1:
		return pool[0]
	return pool[randi() % pool.size()]

static func _trustee_mission(ledger: Dictionary, run_number: int,
                             existing: Array) -> Dictionary:
	var pool: Array = _registry.get("trustee", [])
	if pool.size() == 0:
		return {}
	var pick: Dictionary = _pick(pool)
	pick["id"] = "mission_trustee_%s_%d" % [pick.get("dismantling_hook", "x"), randi()]
	return pick

## ── cross-run decay ───────────────────────────────────────────────────

static func _apply_decay(ledger: Dictionary, standings: Dictionary, run_number: int) -> void:
	# Decay mutates ledger["faction_standing"] in-place (test reads it back).
	var fs: Dictionary = ledger.get("faction_standing", {})
	if typeof(fs) != TYPE_DICTIONARY:
		fs = {}
		ledger["faction_standing"] = fs
	for k in standings.keys():
		var v: int = int(standings[k])
		var new_val: int = v
		if v > 3:
			new_val = v + 1
		elif v == 0:
			# Neutral drifts slightly negative (use-it-or-lose-it engagement).
			new_val = -1
		else:
			var delta: int = int(round(float(v) * -0.05))
			if delta != 0:
				new_val = v + delta
		fs[k] = new_val
	# Also persist to disk.
	var patch: Dictionary = {"faction_standing": {}}
	for k in fs.keys():
		patch["faction_standing"][k] = fs[k]
	Persist.patch(patch)

## ── helpers ───────────────────────────────────────────────────────────

static func _pick_tier() -> String:
	var r: float = randf()
	if r < 0.55:
		return "Gig"
	if r < 0.85:
		return "Contract"
	return "Operation"
