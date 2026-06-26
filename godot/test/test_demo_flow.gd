extends GutTest
## test_demo_flow.gd — programmatic verification of the demo button chain.
##
## Exercises every function the demo buttons call, without requiring the
## scene tree (tests the logic directly through ai.gd + DemoSession).
##
## Run: godot --headless -s res://addons/gut/gut_cmdln.gd -gtest=res://test/test_demo_flow.gd -gexit

# ── Move 1: Pick Origin ─────────────────────────────────────────────
func test_origin_pick_populates_captain() -> void:
	var ai_s: GDScript = load("res://scripts/ai.gd")
	var ai = ai_s.new()
	add_child_autofree(ai)
	await wait_frames(2)

	var cap: Dictionary = ai.step_1_pick_origin("SAA", "SAA-coalition")
	assert_false(cap.is_empty(), "step_1 should return non-empty captain")
	assert_has(cap, "genship_id", "captain should have genship_id")
	assert_has(cap, "ship_class", "captain should have ship_class")
	assert_eq(cap.get("genship_id"), "SAA", "genship_id should match input")
	assert_gt(int(cap.get("h_tier_peak", 0)), 0, "h_tier_peak should be positive")

# ── Move 2: Meet Crew ──────────────────────────────────────────────
func test_crew_meet_returns_two() -> void:
	var ai_s: GDScript = load("res://scripts/ai.gd")
	var ai = ai_s.new()
	add_child_autofree(ai)
	await wait_frames(2)

	# Run steps 1-4 to match the demo button chain
	ai.step_1_pick_origin("SAA", "SAA-coalition")
	ai.step_2_pick_archetype("A")
	ai.step_3_ai_briefing("Test-Captain")
	var crew: Array = ai.step_4_meet_crew()

	assert_eq(crew.size(), 2, "step_4 should generate exactly 2 crew")
	for c in crew:
		assert_true(c is Dictionary, "each crew member should be a Dictionary")
		assert_has(c, "name", "crew member should have name")
		assert_has(c, "archetype_id", "crew member should have archetype_id")
		assert_has(c, "held_trust", "crew member should have held_trust")
		assert_gt(c.get("held_trust", -1), -100, "held_trust should be a sensible number")

# ── DemoSession: cross-scene state transfer ─────────────────────────
func test_demosession_stores_and_retrieves_state() -> void:
	# Verify DemoSession autoload is available
	assert_true(has_node("/root/DemoSession"), "DemoSession autoload should exist")
	var ds = get_node("/root/DemoSession")

	# Simulate what demo_controller does before Launch
	var ai_s: GDScript = load("res://scripts/ai.gd")
	var ai = ai_s.new()
	add_child_autofree(ai)
	await wait_frames(2)
	var cap: Dictionary = ai.step_1_pick_origin("ME", "ME-urban")
	ai.step_2_pick_archetype("B")
	ai.step_3_ai_briefing("Test-Captain")
	var crew: Array = ai.step_4_meet_crew()

	# This is what _on_launch_pressed does
	ds.captain = cap
	ds.crew = crew

	# Verify stored state is readable (simulates what overworld reads)
	assert_false(ds.captain.is_empty(), "DemoSession should store captain")
	assert_eq(ds.crew.size(), 2, "DemoSession should store 2 crew members")
	assert_eq(ds.captain.get("genship_id"), "ME", "stored genship should match")

# ── Launch path: scene exists and DemoSession populated ─────────────
func test_launch_path_is_valid() -> void:
	# Verify the overworld scene file exists on disk
	var scene_path: String = "res://scenes/overworld.tscn"
	assert_true(FileAccess.file_exists(scene_path), "overworld.tscn should exist at path")

	# Verify DemoSession has the ship property for overworld transit (property exists on class)
	var ds = get_node("/root/DemoSession")
	assert_not_null(ds, "DemoSession autoload should be accessible")
	# ship exists as a property — just accessing it should not error
	var ship_val = ds.ship
	assert_null(ship_val, "DemoSession.ship should be null before overworld sets it")

# ── Full chain: from origin to overworld-ready state ────────────────
func test_full_demo_chain_origin_to_launch() -> void:
	var ai_s: GDScript = load("res://scripts/ai.gd")
	var ai = ai_s.new()
	add_child_autofree(ai)
	await wait_frames(2)

	# Step 1 — Pick Origin
	var cap: Dictionary = ai.step_1_pick_origin("NAC", "NAC-charter")
	assert_false(cap.is_empty(), "origin chain should produce captain")

	# Step 2 — Pick Archetype
	ai.step_2_pick_archetype("A")
	# Should still have captain state
	assert_eq(ai.captain.get("archetype", "?"), "A", "archetype should be set")

	# Step 3 — AI Briefing
	var brief: Dictionary = ai.step_3_ai_briefing("Demo-Test")
	assert_has(brief, "text", "briefing should have text")
	assert_has(brief, "choices", "briefing should have choices")

	# Step 4 — Meet Crew
	var crew: Array = ai.step_4_meet_crew()
	assert_eq(crew.size(), 2, "should have 2 crew members after step 4")

	# Simulate Launch — stash in DemoSession
	var ds = get_node("/root/DemoSession")
	ds.captain = cap
	ds.crew = crew

	# Verify DemoSession is ready for overworld
	assert_false(ds.captain.is_empty(), "DemoSession should have captain for overworld")
	assert_eq(ds.crew.size(), 2, "DemoSession should have crew for overworld")

# ── Overworld reads DemoSession correctly ───────────────────────────
func test_demosession_to_overworld_state_transfer() -> void:
	# Simulate what demo_controller does on Launch
	var ds = get_node("/root/DemoSession")
	ds.captain = {"genship_id": "SAA", "ship_class": "Freighter", "h_tier_peak": 2}
	ds.crew = [
		{"name": "Test1", "archetype_id": "NPC1", "held_trust": 2},
		{"name": "Test2", "archetype_id": "NPC2", "held_trust": 3},
	]

	# Simulate what overworld_controller does in _ready()
	var captain: Dictionary = ds.captain.duplicate(true) if ds.captain else {}
	var crew: Array = ds.crew.duplicate(true) if ds.crew else []

	assert_false(captain.is_empty(), "overworld should receive non-empty captain from DemoSession")
	assert_false(crew.is_empty(), "overworld should receive non-empty crew from DemoSession")
	assert_eq(crew.size(), 2, "overworld should receive 2 crew")
	assert_eq(captain.get("genship_id"), "SAA", "overworld should see correct genship")
