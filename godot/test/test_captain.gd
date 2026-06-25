extends GutTest
## test_captain.gd — Phase 3f runtime wiring tests.
## Verifies that genship-origin data flows through the runtime pipeline.

const ORIGIN_KEYS := [
	"genship_id", "genship_label", "first_ship_class",
	"h_tier_default", "starting_suspicion", "starting_genship_standing",
	"corp_relationships", "tag_pool", "unique_content", "narrative_flavor",
]
const GENShip_IDS := ["NAC", "ED", "RRA", "AC", "SAA", "ME"]


func before_each() -> void:
	NarrativeData.clear_cache()
	Persist.reset()


## --- Test 1: get_origin returns full block for valid IDs ---
func test_get_origin_returns_full_block() -> void:
	for gid: String in GENShip_IDS:
		var origin: Dictionary = Captain.get_origin(gid)
		assert_false(origin.is_empty(), "get_origin(%s) should return non-empty" % gid)
		for key: String in ORIGIN_KEYS:
			assert_true(origin.has(key), "get_origin(%s) should have key %s" % [gid, key])


## --- Test 2: get_origin returns empty for unknown genship ---
func test_get_unknown_origin_returns_empty() -> void:
	var origin: Dictionary = Captain.get_origin("UNKNOWN")
	assert_true(origin.is_empty(), "get_origin(\"UNKNOWN\") should return {}")


## --- Test 3: new_run sets origin key ---
func test_new_run_sets_origin_key() -> void:
	var captain: Dictionary = Captain.new_run("NAC", "NAC-charter")
	assert_false(captain.is_empty(), "new_run(\"NAC\", \"NAC-charter\") should succeed")
	var origin: Dictionary = captain.get("origin", {})
	assert_false(origin.is_empty(), "captain should have \"origin\" key")
	assert_eq(origin.get("genship_id", ""), "NAC", "origin.genship_id should be NAC")
	assert_true(origin.has("corp_relationships"), "origin should have corp_relationships")
	assert_true(origin.has("narrative_flavor"), "origin should have narrative_flavor")
	assert_true(origin.has("unique_content"), "origin should have unique_content")


## --- Test 4: origin block has correct corp values for NAC ---
func test_origin_corp_values_match_spec() -> void:
	var origin: Dictionary = Captain.get_origin("NAC")
	var corp: Dictionary = origin.get("corp_relationships", {})
	assert_eq(int(corp.get("trust_T5", 0)), 2, "NAC trust_T5 should be +2")
	assert_eq(int(corp.get("trust_T7", 0)), -1, "NAC trust_T7 should be -1")
	assert_eq(int(corp.get("trust_T1", 0)), 0, "NAC trust_T1 should be 0")


## --- Test 5: origin narrative_flavor has expected shape ---
func test_origin_narrative_flavor_shape() -> void:
	for gid: String in GENShip_IDS:
		var origin: Dictionary = Captain.get_origin(gid)
		var flavor: Dictionary = origin.get("narrative_flavor", {})
		assert_true(flavor.has("ai_tone"), "%s should have ai_tone" % gid)
		assert_true(flavor.has("cover_test_modifier"), "%s should have cover_test_modifier" % gid)
		assert_true(flavor.has("reaction_tokens"), "%s should have reaction_tokens" % gid)
		# JSON-parses to float in GDScript; accept both int and float for numeric fields.
		assert_true(typeof(flavor["cover_test_modifier"]) == TYPE_INT or typeof(flavor["cover_test_modifier"]) == TYPE_FLOAT,
			"%s cover_test_modifier should be numeric" % gid)
		assert_eq(typeof(flavor["reaction_tokens"]), TYPE_ARRAY,
			"%s reaction_tokens should be array" % gid)
