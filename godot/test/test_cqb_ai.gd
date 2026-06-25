extends GutTest
## test_cqb_ai.gd — v0 alien AI decisions.
##
## Verifies the 4 acceptance cases required by issue #17.

const GRID_SIZE := 6

func before_each() -> void:
	randomize()

func test_decide_attack_when_in_range_and_los() -> void:
	var g: CqbGrid = CqbGrid.new(GRID_SIZE)
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 1, 0, "alien", 6, "claw")  # claw range 2, dist 1
	var result: Dictionary = CqbAI.decide_action("alien_a", g)
	assert_eq(result["kind"], "attack", "in range + LOS should attack")
	assert_eq(result["target_id"], "crew_a")
	assert_eq(result["actor"], "alien_a")
	assert_eq(result["step_to"], Vector2i.ZERO)

func test_decide_move_toward_target_when_out_of_range() -> void:
	var g: CqbGrid = CqbGrid.new(GRID_SIZE)
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")
	# industrial_cutter range 1; alien is at dist 3 -> out of range
	g.place_actor("alien_a", 3, 0, "alien", 6, "industrial_cutter")
	var result: Dictionary = CqbAI.decide_action("alien_a", g)
	assert_eq(result["kind"], "move", "out of range should close distance")
	assert_eq(result["actor"], "alien_a")
	# step_toward reduced distance by 1 along x
	assert_eq(result["step_to"], Vector2i(-1, 0),
			"step toward should move left (got %s)" % str(result["step_to"]))

func test_decide_wait_when_no_ap() -> void:
	var g: CqbGrid = CqbGrid.new(GRID_SIZE)
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 1, 0, "alien", 6, "claw")
	g.actors["alien_a"]["ap"] = 0
	var result: Dictionary = CqbAI.decide_action("alien_a", g)
	assert_eq(result["kind"], "wait", "no AP should wait")
	assert_eq(result["actor"], "alien_a")
	assert_eq(result["step_to"], Vector2i.ZERO)
	assert_eq(result["target_id"], "")

func test_aliens_json_loads_and_validates() -> void:
	var data = NarrativeData.aliens()
	assert_true(data != null, "aliens.json should load via NarrativeData")
	var list: Array = data["archetypes"]
	assert_eq(list.size(), 4, "expected 4 alien archetypes")
	var valid_weapons: Array = CqbGrid.WEAPON_TABLE.keys()
	for entry in list:
		assert_true(entry.has("id"), "archetype missing id")
		assert_true(entry.has("display_name"), "archetype missing display_name")
		assert_true(entry.has("hp_max"), "archetype missing hp_max")
		assert_true(entry.has("weapon_id"), "archetype missing weapon_id")
		var wid: String = str(entry["weapon_id"])
		assert_true(valid_weapons.has(wid),
				"weapon_id '%s' not in weapon table" % wid)
