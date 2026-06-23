extends GutTest
## test_persist.gd
## Verifies the Persist singleton's save/load/reset round-trip.
## Tests run against the live <root>/Persist autoload.

func before_each() -> void:
	Persist.reset()

func test_reset_clears_state() -> void:
	Persist.patch({"campaign_state": {"he3_dismantling_progress": 42.0}})
	Persist.reset()
	assert_eq(Persist.get_state()["campaign_state"]["he3_dismantling_progress"], 0.0,
		"reset() should zero he3_dismantling_progress")

func test_get_state_returns_a_copy() -> void:
	Persist.patch({"campaign_state": {"he3_dismantling_progress": 10.0}})
	var s := Persist.get_state()
	s["campaign_state"]["he3_dismantling_progress"] = 99.0  # mutate the copy
	assert_eq(Persist.get_state()["campaign_state"]["he3_dismantling_progress"], 10.0,
		"get_state() must return a defensive copy")

func test_patch_deep_merges_nested() -> void:
	Persist.patch({"campaign_state": {"discovered_acts": ["a"]}})
	Persist.patch({"campaign_state": {"alt_fuel_replacements": ["b"]}})
	var s := Persist.get_state()
	assert_eq(s["campaign_state"]["discovered_acts"], ["a"],
		"first patch's acts preserved")
	assert_eq(s["campaign_state"]["alt_fuel_replacements"], ["b"],
		"second patch's alts preserved")

func test_save_then_load_round_trips() -> void:
	Persist.patch({"campaign_state": {"he3_dismantling_progress": 73.5}})
	assert_true(Persist.save(), "save() should succeed")
	# Mutate in-memory state to verify load_state actually re-reads.
	Persist.patch({"campaign_state": {"he3_dismantling_progress": 0.0}})
	assert_true(Persist.load_state(), "load_state() should succeed")
	assert_eq(Persist.get_state()["campaign_state"]["he3_dismantling_progress"], 73.5,
		"dismantling progress must round-trip")
