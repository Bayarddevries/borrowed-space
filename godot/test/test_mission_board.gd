extends GutTest
class_name TestMissionBoard

## Phase 3c acceptance suite for Issue #9.
## Godot 4.6-safe syntax only: no lambdas, no f-strings, no := inference.

const MISSION_BOARD := preload("res://scripts/mission_board.gd")

func _ship() -> Dictionary:
	return {
		"name": "Test-Hound",
		"genship_id": "NAC",
		"frag_id": "NAC-charter",
	}

func _ledger(overrides: Dictionary) -> Dictionary:
	var base: Dictionary = {
		"faction_standing": {},
		"run_state": {"missions": []},
	}
	for key in overrides.keys():
		base[key] = overrides[key]
	return base

func _generate(overrides: Dictionary, run_number: int) -> Array:
	return MISSION_BOARD.generate(_ship(), _ledger(overrides), run_number)

## Case 1: default generate returns 3-5 offers.
func test_generate_returns_3_to_5_offers() -> void:
	for n in range(1, 6):
		var offers: Array = _generate({}, n)
		assert_true(offers.size() >= 3, "offers >=3 for run " + str(n))
		assert_true(offers.size() <= 5, "offers <=5 for run " + str(n))

## Case 2: source distribution closer to spec split.
func test_source_distribution_within_tolerance() -> void:
	var counts: Dictionary = {"corps": 0, "genship": 0, "private": 0, "trustee": 0}
	var total_count: int = 0
	for i in range(200):
		var run: Array = _generate({}, i + 1)
		for offer in run:
			var src: String = str(offer.get("source", ""))
			if counts.has(src):
				counts[src] = counts[src] + 1
				total_count += 1
	assert_true(total_count > 0, "should produce offers")
	var weights: Dictionary = {"corps": 0.40, "genship": 0.30, "private": 0.20, "trustee": 0.10}
	for src in counts.keys():
		var obs: float = float(counts[src]) / float(total_count)
		var expected: float = float(weights[src])
		var msg: String = "source " + src + " observed " + str(obs) + " expected " + str(expected)
		assert_true(abs(obs - expected) <= 0.15, msg)

## Case 3: low trust standing suppresses corps offers.
func test_low_standing_suppresses_corp_offers() -> void:
	var counts: Dictionary = {"corps": 0, "genship": 0, "private": 0, "trustee": 0}
	for i in range(80):
		var overrides: Dictionary = {"faction_standing": {"trust_T1": -4}}
		var run: Array = _generate(overrides, i + 1)
		for offer in run:
			var src: String = str(offer.get("source", ""))
			if counts.has(src):
				counts[src] = counts[src] + 1
	assert_true(counts["corps"] <= 25, "corps offers should drop with low standing")

## Case 4: continuation_of set when prior in-progress mission exists.
func test_continuation_of_set_when_in_progress() -> void:
	var missions: Array = [{"id": "mission_corps_cargo_stage1", "status": "in_progress"}]
	var overrides: Dictionary = {"run_state": {"missions": missions}}
	var offers: Array = _generate(overrides, 2)
	assert_true(offers.size() > 0, "generate must return offers")
	var found: bool = false
	for offer in offers:
		if str(offer.get("continuation_of", "")) == "mission_corps_cargo_stage1":
			found = true
			break
	assert_true(found, "continuation_of should reference staged mission id")

## Case 5: act_gate filtered.
func test_act_gate_filters_out_of_act_missions() -> void:
	var offers: Array = _generate({}, 1)
	for offer in offers:
		var gate: String = str(offer.get("act_gate", ""))
		assert_true(gate == "" or gate == null or gate == "act_1", "bad act_gate: " + gate)

## Case 6: standings decay for neutral corps.
func test_neutral_standings_decay() -> void:
	var overrides: Dictionary = {"faction_standing": {"trust_T1": 0, "genship_NAC": 0}}
	var before: Dictionary = _ledger(overrides)
	var after: Array = _generate(overrides, 3)
	var standing_t1: int = int(overrides["faction_standing"]["trust_T1"])
	assert_true(standing_t1 < 0, "neutral corp should decay negative; got " + str(standing_t1))

## Case 7: high trust standings increase per run.
func test_high_trust_standings_grow() -> void:
	var overrides: Dictionary = {"faction_standing": {"trust_T1": 4}}
	_generate(overrides, 2)
	var after: int = int(overrides["faction_standing"]["trust_T1"])
	assert_true(after > 4, "high trust standings should grow; got " + str(after))

## Case 8: offer shape matches mission_board schema keys.
func test_offer_shape_has_required_keys() -> void:
	var offers: Array = _generate({}, 1)
	assert_true(offers.size() >= 1, "needs offer for shape check")
	var first: Dictionary = offers[0]
	var required: Array = ["id", "source", "giver", "tier", "type", "objective", "rewards", "risk"]
	for key in required:
		assert_true(first.has(key), "offer missing key: " + key)
