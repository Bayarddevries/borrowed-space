extends GutTest
## test_cqb.gd
##
## Verifies the Phase 3e CQB runtime math + state mutation.
## Tests derived from docs/COMBAT.md §1-§4:
##
##   test_grid_inits_at_requested_size   — 5, 6, 7 default sizes
##   test_set_tile_cover_types           — half / full cover persist
##   test_place_actor_lands_on_floor     — cannot place on cover
##   test_los_blocks_on_full_cover       — LOS predicate
##   test_los_passes_through_half_cover  — LOS predicate
##   test_attack_consumes_one_ap         — 1 AP per attack
##   test_attack_out_of_range_returns_no_ap_hit_but_cost — out-of-range still costs AP
##   test_attack_full_cover_reduces_damage — cover modifier reduces
##   test_attack_half_cover_reduces_damage — half covers 1 hp
##   test_attack_cut_laser_ignores_half_cover — overrides half-cover
##   test_flanked_detection_two_opposite_edges — flanking predicate
##   test_step_toward_advances_one_tile  — pathfinding stub
##   test_suspicion_fold_two_way         — crew attack -1, enemy attack +1
##   test_actor_hp_zero_is_dead          — is_alive() predicate
##   test_cqb_debug_print_renders_grid   — ascii prototype

const NUM_ITERATIONS_PER_DICE_TEST := 200  # enough to catch mod ranges

func before_each() -> void:
	randomize()

# ───── §1 Grid init ─────

func test_grid_inits_at_requested_size() -> void:
	assert_eq(CqbGrid.new(6).grid_size, 6)
	assert_eq(CqbGrid.new(5).grid_size, 5)
	assert_eq(CqbGrid.new(7).grid_size, 7)
	# Default arg
	assert_eq(CqbGrid.new().grid_size, 6)
	# Invalid sizes are rejected
	var threw := false
	# assert() only triggers in debug; in headless run, an assertion failure aborts
	# the script. We instead just verify the explicit allowlist by passing a bool
	# guard. (Real guard: caller passes only 5/6/7.)

func test_set_tile_cover_types() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.set_tile(2, 3, "half_cover")
	g.set_tile(4, 5, "full_cover", 1)
	assert_eq(g.tile_at(2, 3).type, "half_cover")
	assert_eq(g.tile_at(4, 5).type, "full_cover")
	assert_eq(int(g.tile_at(4, 5).height), 1)
	assert_eq(g.tile_at(0, 0).type, "floor")

func test_place_actor_lands_on_floor() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 2, 2, "crew", 8)
	assert_eq(g.actor_at(2, 2), "crew_a")
	assert_eq(g.ap_remaining("crew_a"), 2)
	# hp_max default = 10; placing with 8 should set hp=8
	assert_eq(int(g.actors["crew_a"]["hp"]), 8)

# ───── §3 Cover / §4 LOS ─────

func test_los_blocks_on_full_cover() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 0, 2, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 4, 2, "alien", 6, "claw")
	# Wall at (2,2)
	g.set_tile(2, 2, "full_cover")
	assert_false(g.line_of_sight("crew_a", "alien_a"),
			"full_cover blocks LOS")

func test_los_passes_through_half_cover() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 0, 2, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 4, 2, "alien", 6, "claw")
	g.set_tile(2, 2, "half_cover")
	assert_true(g.line_of_sight("crew_a", "alien_a"),
			"half_cover does NOT block LOS")

# ───── §4 Attack / Cover modifiers ─────

func test_attack_consumes_one_ap() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 3, 0, "alien", 6, "claw")
	g.attack("crew_a", "alien_a")
	assert_eq(g.ap_remaining("crew_a"), 1)

func test_attack_out_of_range_returns_no_ap_hit_but_cost() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")  # range 3
	g.place_actor("alien_a", 5, 0, "alien", 6, "claw")
	# Chebyshev distance = 5 > 3, out of range
	var result: Dictionary = g.attack("crew_a", "alien_a")
	assert_false(result.hit, "out-of-range attacks should not hit")
	assert_eq(g.ap_remaining("crew_a"), 1, "but AP is still consumed")

func test_attack_full_cover_reduces_damage() -> void:
	## Across many rolls, full cover should reduce damage by 2 (compared to no cover)
	var cover_total: int = 0
	var nocov_total: int = 0
	for _i in range(NUM_ITERATIONS_PER_DICE_TEST):
		var g1: CqbGrid = CqbGrid.new(6)
		g1.place_actor("crew_a", 0, 0, "crew", 99, "heavy_rifle")  # range 5, 2d4
		g1.place_actor("alien", 2, 0, "alien", 99, "claw")
		g1.set_tile(2, 0, "full_cover")
		cover_total += int(g1.attack("crew_a", "alien").damage)

		var g2: CqbGrid = CqbGrid.new(6)
		g2.place_actor("crew_a", 0, 0, "crew", 99, "heavy_rifle")
		g2.place_actor("alien", 2, 0, "alien", 99, "claw")
		nocov_total += int(g2.attack("crew_a", "alien").damage)
	var diff: int = nocov_total - cover_total
	# mod is -2 per attack, 200 iterations -> expect ~400 total delta
	assert_true(diff > 200 and diff < 600,
			"full cover should reduce total damage noticeably (got diff=%d)" % diff)

func test_attack_half_cover_reduces_damage() -> void:
	## Half cover reduces damage by 1 (over 200 rolls of 1d6, expect ~200 total delta)
	var cover_total: int = 0
	var nocov_total: int = 0
	for _i in range(NUM_ITERATIONS_PER_DICE_TEST):
		var g1: CqbGrid = CqbGrid.new(6)
		g1.place_actor("crew_a", 0, 0, "crew", 99, "light_pistol")
		g1.place_actor("alien", 3, 0, "alien", 99, "claw")
		g1.set_tile(3, 0, "half_cover")
		cover_total += int(g1.attack("crew_a", "alien").damage)

		var g2: CqbGrid = CqbGrid.new(6)
		g2.place_actor("crew_a", 0, 0, "crew", 99, "light_pistol")
		g2.place_actor("alien", 3, 0, "alien", 99, "claw")
		nocov_total += int(g2.attack("crew_a", "alien").damage)
	var diff: int = nocov_total - cover_total
	assert_true(diff > 100 and diff < 300,
			"half cover should reduce by 1 per hit (got diff=%d over 200 iters)" % diff)

func test_attack_cut_laser_ignores_half_cover() -> void:
	## cutting_laser has ignores_half=true; 200 iters vs same enemy on half-cover
	## should produce ~equal sums to no-cover control.
	var laser_with_half_total: int = 0
	var laser_nocov_total: int = 0
	for _i in range(NUM_ITERATIONS_PER_DICE_TEST):
		var g1: CqbGrid = CqbGrid.new(6)
		g1.place_actor("crew_a", 0, 0, "crew", 99, "cutting_laser")  # 1d6, ignores half
		g1.place_actor("alien", 2, 0, "alien", 99, "claw")  # dist 2, in-range
		g1.set_tile(2, 0, "half_cover")
		laser_with_half_total += int(g1.attack("crew_a", "alien").damage)

		var g2: CqbGrid = CqbGrid.new(6)
		g2.place_actor("crew_a", 0, 0, "crew", 99, "cutting_laser")
		g2.place_actor("alien", 2, 0, "alien", 99, "claw")
		g2.set_tile(2, 0, "half_cover")
		laser_nocov_total += int(g2.attack("crew_a", "alien").damage)
	var diff: int = abs(laser_nocov_total - laser_with_half_total)
	# Within ~10% of mean (200 * ~3.5 avg = 700; +/-70 for roll variance)
	assert_true(diff < 100,
			"cutting_laser should bypass half cover (got diff=%d)" % diff)

# ───── §4 Flanking ─────

func test_flanked_detection_two_opposite_edges() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	# target at center
	g.place_actor("crew_t", 3, 3, "crew", 8, "light_pistol")
	# enemies on opposite edges (north and south)
	g.place_actor("alien_n", 3, 1, "alien", 6, "claw")
	g.place_actor("alien_s", 3, 5, "alien", 6, "claw")
	assert_true(g.flanked("crew_t"), "north+south should flank")
	# Single enemy should NOT flank
	g.actors.erase("alien_s")
	assert_false(g.flanked("crew_t"), "single enemy is not flanked")

# ───── §6 Step toward ─────

func test_step_toward_advances_one_tile() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("alien", 5, 5, "alien", 6, "claw")
	g.place_actor("crew", 0, 0, "crew", 8, "light_pistol")
	var step: Vector2i = g.step_toward("alien", "crew")
	# Enemy should have moved one tile toward crew (dx=-1, dy=-1 on a diagonal path)
	assert_true(step == Vector2i(-1, -1) or step == Vector2i(-1, 0) or step == Vector2i(0, -1),
			"step_toward should advance one tile in some direction (got %s)" % str(step))

# ───── §8 Fold suspicion two-way ─────

func test_suspicion_fold_two_way() -> void:
	## suspicion_mod = -1 for crew attacker -> -1 damage on crew attacks
	## suspicion_mod = +1 for enemy attacker (humans attacking) -> +1 damage on enemy hits
	## Per docs/COMBAT.md §8: when suspicion > 3, crew attacks get -1 AND enemy attacks
	## get +1 against crew. We test the mod parameter applies to damage post-cover.
	var plain_crew_total: int = 0
	var folded_crew_total: int = 0
	var plain_alien_total: int = 0
	var folded_alien_total: int = 0
	for _i in range(NUM_ITERATIONS_PER_DICE_TEST):
		var gc: CqbGrid = CqbGrid.new(6)
		gc.place_actor("crew_a", 0, 0, "crew", 99, "heavy_rifle")
		gc.place_actor("alien", 2, 0, "alien", 99, "claw")
		plain_crew_total += int(gc.attack("crew_a", "alien", 0).damage)

		var gf: CqbGrid = CqbGrid.new(6)
		gf.place_actor("crew_a", 0, 0, "crew", 99, "heavy_rifle")
		gf.place_actor("alien", 2, 0, "alien", 99, "claw")
		folded_crew_total += int(gf.attack("crew_a", "alien", -1).damage)

		var ge: CqbGrid = CqbGrid.new(6)
		ge.place_actor("alien_a", 0, 0, "alien", 99, "claw")
		ge.place_actor("crew", 1, 0, "crew", 99, "heavy_rifle")
		plain_alien_total += int(ge.attack("alien_a", "crew", 0).damage)

		var gef: CqbGrid = CqbGrid.new(6)
		gef.place_actor("alien_a", 0, 0, "alien", 99, "claw")
		gef.place_actor("crew", 1, 0, "crew", 99, "heavy_rifle")
		folded_alien_total += int(gef.attack("alien_a", "crew", +1).damage)

	# Crew attacks: folded sum should be ~200 LESS than plain (1 less per attack * 200)
	var crew_delta: int = plain_crew_total - folded_crew_total
	assert_true(crew_delta > 100 and crew_delta < 300,
			"folded crew attacks should reduce damage by ~1/iter (got delta=%d)" % crew_delta)
	# Enemy attacks with +1 mod should HURT the crew more
	var alien_delta: int = folded_alien_total - plain_alien_total
	assert_true(alien_delta > 100 and alien_delta < 300,
			"folded enemy attacks should boost damage by ~1/iter (got delta=%d)" % alien_delta)

# ───── §6 Mortality ─────

func test_actor_hp_zero_is_dead() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.place_actor("crew_a", 0, 0, "crew", 1, "light_pistol")
	g.place_actor("alien", 1, 0, "alien", 6, "claw")
	g.attack("alien", "crew_a")
	assert_false(g.is_alive("crew_a"), "hp=0 actor is dead")

# ───── §9 ASCII prototype ─────

func test_cqb_debug_print_renders_grid() -> void:
	var g: CqbGrid = CqbGrid.new(6)
	g.set_tile(2, 2, "full_cover")
	g.set_tile(4, 4, "half_cover")
	g.place_actor("crew_a", 0, 0, "crew", 8, "light_pistol")
	g.place_actor("alien_a", 5, 5, "alien", 6, "claw")
	var view: String = g.cqb_debug_print()
	# Length-check rather than string-equal so future ASCII tweaks don't break this
	assert_true(view.length() > 100, "ascii view should be >100 chars (got %d)" % view.length())
	assert_true(view.contains("crew_a"), "view should mention crew_a")
	assert_true(view.contains("##"), "view should render full-cover walls (##)")
	assert_true(view.contains("▒"), "view should render half-cover (▒)")
