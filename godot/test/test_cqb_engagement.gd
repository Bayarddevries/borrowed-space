extends GutTest
## test_cqb_engagement.gd — Phase 3e/21 end-to-end CQB flow.
##
## Verifies that the CQB combat chain fires correctly:
##   1. CoverTest.roll() returns correct tiers
##   2. CqbEngagement.run() produces combat outcomes
##   3. CasualtyPipeline processes casualties against ledger
##   4. ai.gd routes encounters through the combat flow
##
## Does NOT test the Ink beat routing (that's BeatRunner's domain).

const NUM_ITERS := 50

func before_each() -> void:
	randomize()
	# Reset persistence so test order doesn't matter.
	Persist.reset()

# ──────────────────────────────────────────────────────────────────
# §1 — CoverTest threshold boundaries
# ──────────────────────────────────────────────────────────────────

func test_cover_clean_threshold() -> void:
	# With h_tier=4 and crew_bond=5, bonus = 9. d20=18 → total=27 ≥ 18 → clean
	var captain: Dictionary = {"h_tier_peak": 4, "name": "Test"}
	# Force the random seed so d20 is deterministic. We can't seed per-call,
	# but we can run enough iterations to verify the threshold exists.
	var had_clean := false
	for _i in range(NUM_ITERS):
		var result: Dictionary = CoverTest.roll(captain, [5])
		if result.tier == "pass-clean":
			had_clean = true
			# Every clean pass should have total ≥ 18
			assert_true(int(result.total) >= 18,
				"pass-clean needs total >= 18 (got %d)" % result.total)
			assert_false(result.modifiers_applied.is_empty(),
				"modifiers should be applied")
			break
	assert_true(had_clean,
		"h_tier=4 + crew=5 should produce at least one clean pass in %d rolls" % NUM_ITERS)

func test_cover_fail_hard_possible() -> void:
	# With h_tier=0 and crew_bond=0, bonus = 0. d20 ranges 1-20 so
	# fail-hard (total < 9) is possible.
	var captain: Dictionary = {"h_tier_peak": 1, "name": "Test"}
	var had_fail := false
	for _i in range(NUM_ITERS):
		var result: Dictionary = CoverTest.roll(captain, [0])
		if result.tier == "fail-hard":
			had_fail = true
			assert_true(int(result.total) < 9,
				"fail-hard needs total < 9 (got %d)" % result.total)
			break
	assert_true(had_fail,
		"h_tier=1 + crew=0 should produce some fail-hard in %d rolls" % NUM_ITERS)

# ──────────────────────────────────────────────────────────────────
# §2 — CqbEngagement runs and produces deterministic outcomes
# ──────────────────────────────────────────────────────────────────

func test_engagement_crew_vs_one_alien() -> void:
	var crew_data: Array = [
		{"id": "crew_a", "hp_max": 10, "weapon_id": "heavy_rifle"},
	]
	var alien_data: Array = [
		{"id": "alien_x", "hp_max": 6, "weapon_id": "claw"},
	]
	var result: Dictionary = CqbEngagement.run(crew_data, alien_data)
	assert_true(result.has("outcome"), "result must have outcome")
	assert_true(result.has("turn_count"), "result must have turn_count")
	assert_true(result.has("casualties"), "result must have casualties")
	assert_gt(result.get("turn_count", 0), 0, "should complete in >=1 turn")
	assert_true(
		result.outcome in ["won", "lost", "fled", "casualty"],
		"outcome must be valid: %s" % result.outcome
	)

func test_engagement_multiple_aliens() -> void:
	var crew_data: Array = [
		{"id": "crew_a", "hp_max": 10, "weapon_id": "heavy_rifle"},
		{"id": "crew_b", "hp_max": 10, "weapon_id": "cutting_laser"},
	]
	var alien_data: Array = [
		{"id": "alien_1", "hp_max": 6, "weapon_id": "claw"},
		{"id": "alien_2", "hp_max": 6, "weapon_id": "claw"},
		{"id": "alien_3", "hp_max": 6, "weapon_id": "claw"},
	]
	var result: Dictionary = CqbEngagement.run(crew_data, alien_data)
	assert_true(result.outcome in ["won", "lost", "fled", "casualty"],
		"outcome must be valid: %s" % result.outcome)

func test_engagement_tracks_casualties() -> void:
	var crew_data: Array = [
		{"id": "crew_frail", "hp_max": 1, "weapon_id": "light_pistol"},
		{"id": "crew_tough", "hp_max": 10, "weapon_id": "heavy_rifle"},
	]
	var alien_data: Array = [
		{"id": "alien_attacker", "hp_max": 6, "weapon_id": "claw"},
	]
	var result: Dictionary = CqbEngagement.run(crew_data, alien_data)
	var cas: Array = result.get("casualties", [])
	if not cas.is_empty():
		assert_eq(cas[0].get("actor_id", ""), "crew_frail",
			"frail crew should be in casualty list")

# ──────────────────────────────────────────────────────────────────
# §3 — CasualtyPipeline processes crew deaths against ledger
# ──────────────────────────────────────────────────────────────────

func test_casualty_pipeline_processes_dict() -> void:
	Persist.reset()
	# Pre-write a captain + crew into the ledger so the pipeline finds them.
	Persist.patch({
		"ledger": {
			"captains": {
				"1": {
					"captain_n": 1,
					"genship_id": "NAC",
					"crew": {
						"test_crew_01": {
							"name": "Thea",
							"archetype_id": "NPC1",
							"bond_score": 2,
						}
					}
				}
			}
		}
	})
	var casualties: Array = [
		{"actor_id": "test_crew_01", "faction": "crew"},
	]
	var result: Dictionary = CasualtyPipeline.process_casualties(casualties)
	assert_true(result.has("tributes"), "pipeline result should have tributes key")
	assert_true(result.has("casualties"), "pipeline result should have casualties")
	assert_eq(result.casualties.size(), 1, "should process 1 casualty")
	assert_eq(result.casualties[0].actor_id, "test_crew_01",
		"actor id preserved through pipeline")

# ──────────────────────────────────────────────────────────────────
# §4 — step_X_meet_aliens routing structure
# ──────────────────────────────────────────────────────────────────

func test_step_X_routes_via_cover_test() -> void:
	# Create an AI instance and run the setup steps so captain + crew exist.
	var AI_SCRIPT: GDScript = load("res://scripts/ai.gd")
	var ai: Node = AI_SCRIPT.new()
	add_child(ai)
	ai.step_1_pick_origin("NAC", "NAC-charter")
	ai.step_2_pick_archetype("A")
	ai.step_3_ai_briefing("Test-Captain-CQB")
	ai.step_4_meet_crew()

	# step_X_meet_aliens expects a ShipState. Create a default one.
	var ship: ShipState = ShipState.new_default("Test-Captain-CQB", "NAC", 0, 0)
	var result: Dictionary = ai.step_X_meet_aliens(ship)
	assert_true(result.has("combat_fired"), "result must have combat_fired field")
	assert_true(result.has("outcome"), "result must have outcome field")
	assert_true(result.outcome in ["no_crew", "cover_pass", "won", "lost", "fled", "casualty", "beat_missing"],
		"outcome must be valid: %s" % result.outcome)

	# If combat fired, verify beat_result has text.
	if result.get("combat_fired", false):
		var beat: Dictionary = result.get("beat_result", {})
		assert_true(beat.get("text", "") != "", "CQB beat should have text")

# ──────────────────────────────────────────────────────────────────
# §5 — CQB engagement ASCII debug output (for test observation)
# ──────────────────────────────────────────────────────────────────

func test_debug_view_via_existing_cqb_grid() -> void:
	# Verify the existing CqbGrid debug print still works alongside the
	# new engagement orchestrator.
	var grid: CqbGrid = CqbGrid.new(6)
	grid.place_actor("crew_a", 0, 0, "crew", 10, "light_pistol")
	grid.place_actor("alien_1", 5, 5, "alien", 6, "claw")
	var view: String = grid.cqb_debug_print()
	assert_true(view.length() > 50, "debug view should have content (got %d chars)" % view.length())
	assert_true(view.contains("crew_a"), "debug view should mention crew_a")
	assert_true(view.contains("alien_1"), "debug view should mention alien_1")
