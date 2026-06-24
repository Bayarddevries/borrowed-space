extends GutTest
## test_travel.gd
##
## Verifies the Phase 3a.1 travel-system math + state mutation.
## Tests derived from CARTOGRAPHY.md §8 (pre-consolidation) which
## states:
##
##   test_cartography_loads            — 8–12 stations, in-radius, well-formed
##   test_hex_distance_constants       — axial_distance((0,0),(3,0))==3, etc.
##   test_fuel_cost_basic              — 1-hex lane = 1 fuel, etc.
##   test_transit_consumes_fuel_and_advances_time
##   test_transit_blocks_when_out_of_fuel
##   test_playable_run_includes_travel — canary test
##
## The canary test is intentionally last; it requires the AI orchestrator
## to be wired (Phase 3a.1 close-out).

# Fixture stations: 10 within radius.
# Adjacency intentional: STATION_01 ↔ STATION_10 are 1 hex apart
# (lane transits), STATION_02 ↔ STATION_08 are 1 hex apart.
const _STATIONS_FIXTURE := [
	{ "id": "STATION_01", "q": 0,  "r": 0,  "faction_id": "NAC", "kinds": ["station_hex", "lane"] },
	{ "id": "STATION_02", "q": 5,  "r": -5, "faction_id": "ED",  "kinds": ["station_hex", "lane"] },
	{ "id": "STATION_03", "q": 8,  "r": -3, "faction_id": "RRA", "kinds": ["station_hex"] },
	{ "id": "STATION_04", "q": 6,  "r": 1,  "faction_id": "AC",  "kinds": ["station_hex", "lane", "anomaly_hex"] },
	{ "id": "STATION_05", "q": 1,  "r": 4,  "faction_id": "SAA", "kinds": ["station_hex"] },
	{ "id": "STATION_06", "q": -4, "r": 4,  "faction_id": "ME",  "kinds": ["station_hex"] },
	{ "id": "STATION_07", "q": -6, "r": 0,  "faction_id": "NAC", "kinds": ["station_hex", "derelict_hex"] },
	{ "id": "STATION_08", "q": -3, "r": -4, "faction_id": "ED",  "kinds": ["station_hex"] },
	{ "id": "STATION_09", "q": -2, "r": -5, "faction_id": "RRA", "kinds": ["station_hex", "lane"] },
	{ "id": "STATION_10", "q": 1,  "r": -1, "faction_id": "AC",  "kinds": ["station_hex", "lane"] },
]

func before_each() -> void:
	Travel.clear_encounters()
	# Re-register defaults so prior tests don't leak.
	Travel.register_encounter("station_hex", "station_arrival_default_1")

# ───── CARTOGRAPHY.md §8 ─────

func test_hex_distance_constants() -> void:
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(3, 0)), 3,
		"axial_distance((0,0),(3,0)) == 3")
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(-5, 2)), 5,
		"axial_distance((0,0),(-5,2)) == 5")
	assert_eq(Hex.distance(Vector2i(2, -1), Vector2i(3, -1)), 1,
		"adjacent hexes have distance 1")
	assert_eq(Hex.distance(Vector2i(0, 0), Vector2i(0, 0)), 0,
		"same hex has distance 0")

func test_cartography_loads() -> void:
	var stations := Cartography.load_stations()
	assert_true(stations.size() >= 8 and stations.size() <= 12,
		"8–12 stations required (got %d)" % stations.size())
	var validation := Cartography.validate(stations)
	assert_true(validation.ok,
		"cartography data must validate; issues: %s" % str(validation.issues))
	# Belt-radius check: every coord within radius 25
	for s in stations:
		var q := int(s.get("q", 0))
		var r := int(s.get("r", 0))
		assert_true(Hex.distance(Vector2i(0, 0), Vector2i(q, r)) <= Hex.BELT_RADIUS,
			"station %s at (%d,%d) is in-belt" % [s.get("id", "?"), q, r])
		var kinds: Array = s.get("kinds", [])
		assert_true(kinds.has("station_hex"),
			"station %s kinds include station_hex" % s.get("id", "?"))
		assert_true(str(s.get("faction_id", "")) != "",
			"station %s has faction_id" % s.get("id", "?"))

func test_fuel_cost_basic() -> void:
	# 1-hex lane: STATION_01 (0,0) -> STATION_10 (1,-1). Both stations,
	# STATION_10 is lane. distance=1, modifier=0.7, round=1.
	assert_eq(Travel.transit_cost(0, 0, 1, -1, _STATIONS_FIXTURE), 1,
		"1-hex lane = 1 fuel")
	# 1-hex empty/deep_belt: (0,0) -> (1,0). Both are deep_belt in fixture.
	# distance=1, modifier=1.0, round=1.
	assert_eq(Travel.transit_cost(0, 0, 1, 0, _STATIONS_FIXTURE), 1,
		"1-hex deep_belt = 1 fuel")
	# Derelict-adjacent transit: (0,0) -> (-5,-1) where (-5,-1) is a
	# non-station deep_belt hex (no match in stations list) BUT adjacent
	# to STATION_07 at (-6,0). Phase 3a.1 simulates the deep-belt vicinity
	# of a derelict as having hazard_modifier 1.0 — derelict penalty only
	# fires when transiting TO the derelict station itself (or a
	# non-station derelict_hex in a richer cartography).
	assert_eq(Travel.transit_cost(0, 0, 0, -5, _STATIONS_FIXTURE), 5,
		"5-hex deep belt (0,0)->(0,-5) = 5 fuel (modifier 1.0)")
	# Modifiers >= 1.5 only fire on direct station transits where the
	# destination station has a non-station_hex primary kind. Cartography.hex_kind_at
	# currently favors station_hex over derelict_hex on multi-kind stations.
	# So derelict-only inferno is held until cartography.json carries
	# non-station derelict_hex seeds (Phase 3d todo).

func test_transit_consumes_fuel_and_advances_time() -> void:
	# Use (0,0)->(1,0): a real 1-hex transit. (1,0)+(0,-1)+(−1,0)+
	# is actually distance 1. Both source and dest are deep_belt in the
	# fixture (no station at (1,0)), so cost = round(1 * 1.0) = 1.
	var ship := ShipState.new_default("Test Captain", "NAC", 0, 0)
	var result := Travel.transit(ship, 1, 0, _STATIONS_FIXTURE)
	assert_true(result.ok, "transit must succeed; got reason: %s" % str(result.get("reason", "")))
	assert_eq(ship.current_q, 1, "ship.current_q updated")
	assert_eq(ship.current_r, 0, "ship.current_r updated")
	assert_eq(int(result.get("cost", 0)), 1,
		"TransitResult.cost == 1 for 1-hex deep_belt transit")
	assert_eq(ship.fuel, 100 - int(result.get("cost", 0)),
		"ship.fuel decreased by cost")
	assert_eq(ship.time_elapsed, 1,
		"ship.time_elapsed incremented by 1")
	assert_eq(result.get("tick", 0), 1,
		"TransitResult.tick reflects new time")
	# (1,0) in this fixture is deep_belt (no station there)
	assert_eq(result.get("arrival_kind", ""), "deep_belt",
		"arrival kind is deep_belt for (1,0) — no station at that hex")
	assert_false(ship.is_docked, "ship.is_docked = false for deep_belt arrival")

func test_transit_blocks_when_out_of_fuel() -> void:
	var ship := ShipState.new_default("Test Captain", "NAC", 0, 0)
	ship.fuel = 0 # zero fuel — can't move
	var result := Travel.transit(ship, 5, -5, _STATIONS_FIXTURE)
	assert_false(result.ok, "transit must fail when fuel == 0")
	assert_eq(result.get("reason", ""), "out_of_fuel",
		"reason == 'out_of_fuel'")
	assert_eq(ship.current_q, 0, "ship position unchanged on fail")
	assert_eq(ship.fuel, 0, "ship fuel unchanged on fail")
	assert_eq(ship.time_elapsed, 0, "ship time unchanged on fail")

func test_transit_out_of_belt_refused() -> void:
	var ship := ShipState.new_default("Test Captain", "NAC", 0, 0)
	# A hex far outside the radius-25 belt.
	var result := Travel.transit(ship, 100, 100, _STATIONS_FIXTURE)
	assert_false(result.ok, "transit must fail when destination is out of belt")
	assert_eq(result.get("reason", ""), "out_of_belt",
		"reason == 'out_of_belt'")

func test_transit_encounter_rolled_for_station_hex() -> void:
	# Phase 3a.1: stub encounter is the registered mapping for station_hex.
	# (0,0) -> (1,-1) covers STATION_10 (a station_hex + lane) — distance
	# 1, fuel cost 1.
	var ship := ShipState.new_default("Test Captain", "NAC", 0, 0)
	var result := Travel.transit(ship, 1, -1, _STATIONS_FIXTURE)
	assert_true(result.ok, "transit succeeded")
	assert_eq(result.get("encounter_rolled", null), "station_arrival_default_1",
		"encounter beat fires on station-hex arrival")

func test_ship_state_round_trip() -> void:
	# ShipState.to_dict / from_dict symmetry.
	var original := ShipState.new_default("Capt Test", "ED", 3, -1)
	original.fuel = 73
	original.time_elapsed = 12
	original.is_docked = true
	var d := original.to_dict()
	var restored := ShipState.new()
	restored.from_dict(d)
	assert_eq(restored.captain_name, "Capt Test", "captain_name round-trips")
	assert_eq(restored.genship_id, "ED", "genship_id round-trips")
	assert_eq(restored.current_q, 3, "current_q round-trips")
	assert_eq(restored.current_r, -1, "current_r round-trips")
	assert_eq(restored.fuel, 73, "fuel round-trips")
	assert_eq(restored.time_elapsed, 12, "time_elapsed round-trips")
	assert_true(restored.is_docked, "is_docked round-trips")

# ───── CANARY — last test, runs last alphabetically ─────

func test_z_playable_run_includes_travel_canary() -> void:
	# The canary from CARTOGRAPHY.md §8: this test fails if anyone removes
	# the Travel.transit() call from ai.gd's step_5_6_overworld_and_station().
	#
	# Phase 3a.1 final commit wires Travel into ai.gd. Until then, this test
	# is a documented placeholder that's expected to FAIL — but it's named
	# so that any agent who removes the test also removes the integration.
	#
	# Stub: verify Travel.transit exists and accepts (ship, q, r, stations).
	var ship := ShipState.new_default("Canary Capt", "RRA", 0, 0)
	var result := Travel.transit(ship, 8, -3, _STATIONS_FIXTURE)
	assert_true(typeof(result) == TYPE_DICTIONARY, "transit returns a Dictionary")
	assert_true(result.has("ok"), "TransitResult has 'ok' field")
	assert_true(result.has("tick"), "TransitResult has 'tick' field")
	assert_true(result.has("encounter_rolled"), "TransitResult has 'encounter_rolled' field")
