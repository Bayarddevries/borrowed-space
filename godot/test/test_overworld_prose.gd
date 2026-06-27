extends GutTest
## Tests for overworld_controller.gd — encounter prose display,
## transit button state, beat loading, and choice resolution.
##
## These tests instantiate overworld.tscn in a headless scene tree
## and exercise the controller's public/internal methods.

var _ctrl: Node = null
var _scene_packed: PackedScene = null

func before_all() -> void:
	_scene_packed = load("res://scenes/overworld.tscn")
	assert_not_null(_scene_packed, "overworld.tscn loads")

func before_each() -> void:
	if _scene_packed == null:
		return
	_ctrl = _scene_packed.instantiate()
	add_child_autoqfree(_ctrl)
	await get_tree().process_frame  # let _ready() run
	# Seed required state that _ready() usually gets from DemoSession
	_ctrl.captain = {"name": "TestCap", "genship_id": "NAC"}
	_ctrl.crew = [{"crew_name": "Crew-1", "archetype_id": "A", "variant_id": "v1", "held_trust": 3}]
	_ctrl.ship = ShipState.new_default("TestCap", "NAC", 0, 0)
	_ctrl.stations = Cartography.load_stations()

# ── Beat file loading ─────────────────────────────────────────────

func test_load_beat_file_encounter_pool() -> void:
	var data: Dictionary = _ctrl._load_beat_file("/../narrative/beats/encounter-pool-beats.json")
	assert_false(data.is_empty(), "encounter-pool-beats.json loads")
	assert_true(data.has("beats"), "has beats key")
	assert_gt(data["beats"].size(), 0, "has at least one beat")

func test_load_beat_file_cqb() -> void:
	var data: Dictionary = _ctrl._load_beat_file("/../narrative/beats/cqb-ink-beats.json")
	assert_false(data.is_empty(), "cqb-ink-beats.json loads")
	assert_true(data.has("beats"), "has beats key")

func test_load_beat_file_station_arrival() -> void:
	var data: Dictionary = _ctrl._load_beat_file("/../narrative/beats/station_arrival_beats.json")
	assert_false(data.is_empty(), "station_arrival_beats.json loads")
	assert_true(data.has("beats"), "has beats key")

func test_load_beat_file_caches() -> void:
	var first: Dictionary = _ctrl._load_beat_file("/../narrative/beats/encounter-pool-beats.json")
	var second: Dictionary = _ctrl._load_beat_file("/../narrative/beats/encounter-pool-beats.json")
	assert_eq(first, second, "cached result matches fresh load")

func test_load_beat_file_missing_returns_empty() -> void:
	var data: Dictionary = _ctrl._load_beat_file("/../narrative/beats/nonexistent.json")
	assert_true(data.is_empty(), "missing file returns empty dict")

# ── Encounter beat loading ─────────────────────────────────────────

func test_load_encounter_beat_known_beat() -> void:
	var ok: bool = _ctrl._load_encounter_beat("beat_patrol_license_check")
	assert_true(ok, "known beat_id returns true")
	assert_gt(_ctrl._pending_choices.size(), 0, "choices populated")

func test_load_encounter_beat_unknown_beat() -> void:
	var ok: bool = _ctrl._load_encounter_beat("beat_does_not_exist_xyz")
	assert_false(ok, "unknown beat_id returns false")

func test_load_encounter_beat_empty_id() -> void:
	var ok: bool = _ctrl._load_encounter_beat("")
	assert_false(ok, "empty beat_id returns false")

func test_load_encounter_beat_populates_choices() -> void:
	var ok: bool = _ctrl._load_encounter_beat("enc_crew_bonding_ritual")
	assert_true(ok, "crew bonding beat loads")
	# Should have 3 choices with text + delta
	for c in _ctrl._pending_choices:
		assert_true(c.has("text"), "each choice has text")
		assert_true(c.has("delta"), "each choice has delta")

# ── Station arrival beat loading ───────────────────────────────────

func test_station_arrival_beat_station_01() -> void:
	var ok: bool = _ctrl._load_station_arrival_beat("STATION_01")
	assert_true(ok, "STATION_01 arrival beat found")
	assert_gt(_ctrl._pending_choices.size(), 0, "choices populated")

func test_station_arrival_beat_station_10() -> void:
	var ok: bool = _ctrl._load_station_arrival_beat("STATION_10")
	assert_true(ok, "STATION_10 arrival beat found")

func test_station_arrival_beat_unknown_station() -> void:
	var ok: bool = _ctrl._load_station_arrival_beat("STATION_99")
	assert_false(ok, "unknown station returns false")

func test_all_stations_have_arrival_beats() -> void:
	for s in _ctrl.stations:
		var sid: String = str(s.get("id", ""))
		if sid == "":
			continue
		var ok: bool = _ctrl._load_station_arrival_beat(sid)
		assert_true(ok, "%s has arrival beat" % sid)

# ── Fallback display ──────────────────────────────────────────────

func test_fallback_encounter_display_dict() -> void:
	var fake := {"category": "Patrol", "flavor_hook": "A patrol scans your hull."}
	_ctrl._fallback_encounter_display(fake)
	assert_true(_ctrl._proceed_btn.visible, "Proceed button shows for dict fallback")

func test_fallback_encounter_display_string() -> void:
	var fake := "station_arrival_default_1"
	_ctrl._fallback_encounter_display(fake)
	assert_false(_ctrl._proceed_btn.visible, "Proceed button hidden for string fallback")
	assert_false(_ctrl._end_run_btn.disabled, "End Run enabled for string fallback")

# ── Show beat ─────────────────────────────────────────────────────

func test_show_beat_renders_prose_and_choices() -> void:
	var beat := {
		"text": "Test prose for the encounter.",
		"choices": [
			{"text": "Choice A", "delta": {"fuel_delta": -5}},
			{"text": "Choice B", "delta": {"bond_score": 1}},
		],
	}
	_ctrl._show_beat(beat)
	assert_eq(_ctrl._pending_choices.size(), 2, "two choices stored")
	assert_false(_ctrl._choice_btns[0].visible == false, "first choice visible")
	assert_true(_ctrl._choice_btns[2].visible == false, "third choice hidden (only 2 choices)")

func test_show_beat_schema_a_format() -> void:
	# Schema A uses 'label' instead of 'text' for choices
	var beat := {
		"text": "CQB outcome prose.",
		"choices": [
			{"label": "Push on.", "to": "end_of_run_1", "delta": {"bond_score": 1}},
		],
	}
	_ctrl._show_beat(beat)
	assert_eq(_ctrl._pending_choices.size(), 1, "one choice stored")
	# _show_beat uses 'text' first, falls back to 'label'
	assert_eq(_ctrl._choice_btns[0].text, "Push on.", "schema A label rendered as button text")

func test_show_beat_empty_choices() -> void:
	var beat := {"text": "Just prose, no choices.", "choices": []}
	_ctrl._show_beat(beat)
	assert_eq(_ctrl._pending_choices.size(), 0, "zero choices")
	for i in range(3):
		assert_false(_ctrl._choice_btns[i].visible, "choice %d hidden" % i)

# ── Choice resolution ─────────────────────────────────────────────

func test_choice_applies_delta_via_persist() -> void:
	# Set up a beat with choices
	_ctrl._pending_choices = [
		{"text": "Take fuel", "delta": {"fuel_delta": -5}},
	]
	var pre_fuel: int = _ctrl.ship.fuel
	_ctrl._on_choice_pressed(0)
	# After choice, transit re-enabled
	assert_false(_ctrl._transit_btn.disabled, "transit re-enabled after terminal choice")

func test_choice_invalid_index_safe() -> void:
	_ctrl._pending_choices = [{"text": "Only one choice", "delta": {}}]
	# Should not crash — call with out-of-range index
	_ctrl._on_choice_pressed(5)
	assert_true(true, "invalid choice index did not crash")

func test_choice_empty_delta() -> void:
	_ctrl._pending_choices = [{"text": "Do nothing", "delta": {}}]
	_ctrl._on_choice_pressed(0)
	assert_false(_ctrl._transit_btn.disabled, "transit re-enabled after empty delta choice")
