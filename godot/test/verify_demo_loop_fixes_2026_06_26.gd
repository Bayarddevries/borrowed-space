extends GutTest
## Ad-hoc verification for two code paths:
##
##   1. /root/DemoSession autoload registers and is reachable as a
##      Node carrying the expected fields.
##   2. NarrativeData.die_in_throes() resolves to a file on disk that parses.
##
## Run with:
##   godot --headless --path godot -s res://addons/gut/gut_cmdln.gd \
##         -gtest=res://test/verify_demo_loop_fixes_2026_06_26.gd \
##         -gexit

func test_demo_session_autoload_present() -> void:
	assert_true(has_node("/root/DemoSession"),
		"DemoSession autoload must register on project.godot entry")
	var ds: Node = get_node("/root/DemoSession")
	assert_not_null(ds, "DemoSession node should be non-null")
	assert_true(ds.has_method("reset"),
		"DemoSession.reset() must exist")
	assert_true(ds.captain is Dictionary, "captain must be Dictionary")
	assert_true(ds.crew is Array, "crew must be Array")
	assert_true(ds.transit_result is Dictionary, "transit_result must be Dictionary")
	assert_eq(bool(ds.ledger_written), false, "ledger_written must default false")
	assert_true(ds.run_states is Array, "run_states must be Array")
	ds.reset()
	assert_eq(ds.captain.size(), 0, "captain empty after reset()")
	assert_eq(ds.crew.size(), 0, "crew empty after reset()")

func test_die_in_throes_loads_or_null() -> void:
	var data = NarrativeData.die_in_throes()
	if data == null:
		assert_true(false, "die_in_throes() returned null - file missing or unreadable")
		return
	assert_true(data is Dictionary, "die_in_throes must parse to a Dictionary")
	if data.has("die_in_throes"):
		assert_true(data["die_in_throes"] is Array, "die_in_throes must be Array")
