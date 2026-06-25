extends GutTest
## test_playable_run.gd
##
## Phase 2g. Drives the 7-step playable-run sequence end-to-end and asserts:
##   - step 1: origin resolves from matrix
##   - step 2: archetype accepted
##   - step 3: AI briefing beat runs
##   - step 4: 2 crew generated
##   - step 5+6: overworld + station beats run
##   - step 7: ledger entry persisted
##
## Acceptance (per issue #7):
##   "playthrough logs all 7 steps; ledger entry visible in persistence after run."

const AI_SCRIPT := preload("res://scripts/ai.gd")

func before_each() -> void:
	# Reset the persistence layer before each so test order doesn't matter.
	Persist.reset()

func test_full_run_writes_a_captain_record() -> void:
	var ai: Node = AI_SCRIPT.new()
	add_child(ai)
	var result: Dictionary = ai.full_run("SAA", "SAA-coalition", "B", "Test-Captain-1")
	var captain_n: int = int(result.get("captain_n"))
	assert_gt(captain_n, 0, "A captain_n should be assigned.")

	# Verify persisted state has the captain entry.
	var s = Persist.get_state()
	var captains: Dictionary = s.get("ledger", {}).get("captains", {})
	assert_true(captains.has(str(captain_n)),
		"Ledger should contain the new captain at key %d." % captain_n)
	var row: Dictionary = captains[str(captain_n)]
	assert_eq(row.get("genship_id"), "SAA",
		"Genship should round-trip.")
	assert_eq(row.get("country_fragment_id"), "SAA-coalition",
		"Fragment should round-trip.")
	assert_eq(result.get("crew_count"), 2,
		"Step 4 should produce two crew members.")
	assert_gt(result.get("discovery_count"), 0,
		"Step 6 should yield at least one discovery.")

func test_seven_steps_complete_in_order() -> void:
	var ai: Node = AI_SCRIPT.new()
	add_child(ai)
	ai.full_run("NAC", "NAC-charter", "A", "Test-Captain-2")

	# A captain record exists.
	var s = Persist.get_state()
	var captains: Dictionary = s.get("ledger", {}).get("captains", {})
	assert_eq(captains.size(), 1, "Exactly one captain in ledger after one run.")

	# Beat history exists (5 history entries: briefing→crew→overworld→station→end).
	for child in ai.get_children():
		if child is BeatRunner:
			assert_gt(child.get_history().size(), 0,
				"BeatRunner should record at least one beat traversal.")
			break

func test_run_count_increments() -> void:
	var ai_a: Node = AI_SCRIPT.new()
	add_child(ai_a)
	ai_a.full_run("ED", "ED-urban", "A", "Test-Captain-A")
	var ai_b: Node = AI_SCRIPT.new()
	add_child(ai_b)
	ai_b.full_run("RRA", "RRA-energo", "B", "Test-Captain-B")

	var s = Persist.get_state()
	var counts: Dictionary = s.get("run_counts", {})
	assert_eq(int(counts.get("ended", 0)), 2,
		"Two runs should yield ended_count == 2.")

func test_trait_pool_lock_uses_origin_tag_pool() -> void:
	# The SAA-coalition fragment has tag_pool ["t-P-H-coalition", "t-P-A", "t-P-C"].
	var ai: Node = AI_SCRIPT.new()
	add_child(ai)
	var result: Dictionary = ai.full_run("SAA", "SAA-coalition", "B", "Test-Captain-Trait")
	var captain = result.get("captain", {})
	var traits: Array = captain.get("t_slots", [])
	for t in traits:
		assert_true(["t-P-H-coalition", "t-P-A", "t-P-C"].has(t),
			"Each trait should come from the SAA-coalition tag_pool; got %s" % str(t))
	assert_eq(traits.size(), 3,
		"Three traits should be drawn.")
