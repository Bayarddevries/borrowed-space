extends GutTest
## hermes_verify_demo_loop.gd — GUT-based verification of demo loop wiring.
##
## Tests scene structure and DemoSession state inside the GUT harness
## (which wires autoloads correctly — unlike godot -s standalone mode).

func before_each() -> void:
	DemoSession.reset()

func test_demo_session_carries_state() -> void:
	DemoSession.captain = {"name": "Test", "genship_id": "NAC"}
	DemoSession.crew = [{"name": "C1"}]
	assert_eq(DemoSession.captain.get("name"), "Test", "captain carries")
	assert_eq(DemoSession.crew.size(), 1, "crew carries")
	DemoSession.reset()
	assert_true(DemoSession.captain.is_empty(), "reset clears captain")
	assert_true(DemoSession.crew.is_empty(), "reset clears crew")

func test_overworld_scene_nodes() -> void:
	var scene_res: PackedScene = load("res://scenes/overworld.tscn")
	assert_not_null(scene_res, "overworld.tscn loads")
	var inst: Node = scene_res.instantiate()
	assert_not_null(inst, "overworld.tscn instantiates")
	assert_not_null(inst.get_node_or_null("HexLabel"), "HexLabel")
	assert_not_null(inst.get_node_or_null("EncounterLabel"), "EncounterLabel")
	assert_not_null(inst.get_node_or_null("StatusLabel"), "StatusLabel")
	assert_not_null(inst.get_node_or_null("StationDropdown"), "StationDropdown")
	assert_not_null(inst.get_node_or_null("TransitButton"), "TransitButton")
	assert_not_null(inst.get_node_or_null("ProceedButton"), "ProceedButton")
	assert_not_null(inst.get_node_or_null("EndRunButton"), "EndRunButton")
	inst.queue_free()

func test_run_start_scene_nodes() -> void:
	var rss: PackedScene = load("res://scenes/run_start.tscn")
	assert_not_null(rss, "run_start.tscn loads")
	var rsi: Node = rss.instantiate()
	assert_not_null(rsi, "run_start.tscn instantiates")
	assert_not_null(rsi.get_node_or_null("LaunchButton"), "LaunchButton")
	if rsi.get_node_or_null("LaunchButton") is Button:
		var lb: Button = rsi.get_node_or_null("LaunchButton") as Button
		assert_eq(lb.text, "Launch → Overworld", "LaunchButton text")
	assert_not_null(rsi.get_node_or_null("PickOriginButton"), "PickOriginButton")
	assert_not_null(rsi.get_node_or_null("MeetCrewButton"), "MeetCrewButton")
	assert_not_null(rsi.get_node_or_null("OriginDropdown"), "OriginDropdown")
	assert_not_null(rsi.get_node_or_null("BriefLabel"), "BriefLabel")
	assert_not_null(rsi.get_node_or_null("CrewLabel"), "CrewLabel")
	assert_not_null(rsi.get_node_or_null("LedgerSidebar"), "LedgerSidebar")
	rsi.queue_free()

func test_cartography_loads_10_stations() -> void:
	var stations: Array = Cartography.load_stations()
	assert_eq(stations.size(), 10, "cartography has 10 stations")
	assert_eq(stations[0].get("id", ""), "STATION_01", "first station is STATION_01")
