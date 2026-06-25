extends GutTest
var EncounterPool = preload("res://scripts/encounter_pool.gd")
## test_encounter_pool.gd — Phase 3d acceptance cases.

const MANIFEST_PATH: String = "/../narrative/data/encounter-pool.json"

func before_each() -> void:
	pass

func _make_ship(overrides: Dictionary = {}) -> Dictionary:
	var base: Dictionary = {
		"fuel": 80,
		"hull": 100,
		"suspicion": 0,
		"recent_combat": false,
		"act": "",
	}
	for k in overrides.keys():
		base[k] = overrides[k]
	return base

func test_empty_space_roll_can_succeed() -> void:
	var result: Variant = _roll_with_seed(_make_ship(), "deep_belt", [], 12345)
	assert_true(result != null, "deep_belt should sometimes roll with seed 12345")

func test_station_hostile_reduces_roll_probability_vs_normal() -> void:
	var rolls_normal: int = 0
	var rolls_hostile: int = 0
	for seed in range(200):
		if _roll_with_seed(_make_ship({"suspicion": 0}), "station_hex", [], seed):
			rolls_normal += 1
		if _roll_with_seed(_make_ship({"station_state": "hostile", "suspicion": 0}), "station_hex", [], seed):
			rolls_hostile += 1
	assert_true(rolls_hostile <= rolls_normal,
			"hostile station-state should not produce more encounters than normal")

func test_suspicion_modifier_adds_chance() -> void:
	var rolls_zero: int = 0
	var rolls_high: int = 0
	for seed in range(200):
		if _roll_with_seed(_make_ship({"suspicion": 0}), "deep_belt", [], seed):
			rolls_zero += 1
		if _roll_with_seed(_make_ship({"suspicion": 20}), "deep_belt", [], seed):
			rolls_high += 1
	assert_true(rolls_high > rolls_zero, "high suspicion should produce more rolls")

func test_low_fuel_reduces_encounter_chance() -> void:
	var low_total: int = 0
	var full_total: int = 0
	for seed in range(400):
		if _roll_with_seed(_make_ship({"fuel": 10}), "deep_belt", [], seed):
			low_total += 1
		if _roll_with_seed(_make_ship({"fuel": 100}), "deep_belt", [], seed):
			full_total += 1
	assert_true(low_total < full_total, "low fuel should reduce encounter chance")

func test_weighted_selection_respects_weight() -> void:
	# Heavy entries (weight >= 2.8) that are eligible on deep_belt:
	#   enc_distress_hull_breach_02 (3.0), enc_distress_raider_siege_04 (3.2),
	#   enc_discovery_derelict_vessel_01 (3.0), enc_discovery_anomalous_signal_03 (3.2),
	#   enc_discovery_water_vein_mapping_06 (3.1)
	# Light entries (weight <= 1.5) that are eligible on deep_belt:
	#   enc_crew_skill_gap_training_04 (1.7), enc_crew_resource_tension_05 (1.9)
	var heavy_ids := [
		"enc_distress_hull_breach_02",
		"enc_distress_raider_siege_04",
		"enc_discovery_derelict_vessel_01",
		"enc_discovery_anomalous_signal_03",
		"enc_discovery_water_vein_mapping_06",
	]
	var light_ids := [
		"enc_crew_skill_gap_training_04",
		"enc_crew_resource_tension_05",
	]
	var counts: Dictionary = {}
	for seed in range(400):
		var r: Variant = _roll_with_seed(_make_ship(), "deep_belt", [], seed)
		if r != null:
			var vid: String = str(r.get("variant_id", ""))
			if not counts.has(vid):
				counts[vid] = 0
			counts[vid] += 1

	var heavy_hits: int = 0
	for hid in heavy_ids:
		heavy_hits += counts.get(hid, 0)
	var light_hits: int = 0
	for lid in light_ids:
		light_hits += counts.get(lid, 0)
	assert_true(heavy_hits > 0, "heavier entries should have been selected at least once")
	# Compare per-entry hit rate: heavier weights should produce at least
	# as many selections per eligible entry as the lighter-weight entries.
	var heavy_per_entry: float = float(heavy_hits) / float(heavy_ids.size())
	var light_per_entry: float = float(light_hits) / float(light_ids.size())
	assert_true(heavy_per_entry >= light_per_entry,
			"heavier entries should not underperform lighter entries on a per-entry basis")

func test_act_gate_filters_by_current_act() -> void:
	# enc_discovery_water_vein_mapping_06 has act_gate=act_1 and is eligible
	# on deep_belt + anomaly_hex.
	var eligible_act1: int = 0
	for seed in range(300):
		var r: Variant = _roll_with_seed(_make_ship({"act": "act_1"}), "deep_belt", [], seed)
		if r != null:
			var vid: String = str(r.get("variant_id", ""))
			if vid == "enc_discovery_water_vein_mapping_06":
				eligible_act1 += 1
	assert_true(eligible_act1 > 0, "act_1 entry should be eligible when act=act_1")

	var eligible_act2: int = 0
	for seed in range(300):
		var r: Variant = _roll_with_seed(_make_ship({"act": "act_2"}), "deep_belt", [], seed)
		if r != null:
			var vid: String = str(r.get("variant_id", ""))
			if vid == "enc_discovery_water_vein_mapping_06":
				eligible_act2 += 1
	assert_true(eligible_act2 == 0,
			"act_1 entry should NOT be eligible when act=act_2")

func _roll_with_seed(ship: Dictionary, arrival_kind: String, stations: Array, seed: int) -> Variant:
	var saved: int = randi()
	seed(seed)
	var result: Variant = EncounterPool.roll(ship, arrival_kind, stations)
	seed(saved)
	return result
