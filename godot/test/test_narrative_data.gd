extends GutTest
## test_narrative_data.gd
## First canonical GUT test.
## Phase 2f — verify the smoke-test runner is end-to-end live.

func test_narrative_data_smoke() -> void:
	# smoke_test() returns true iff all three JSON files parse and key-shape checks pass.
	assert_true(NarrativeData.smoke_test(),
		"NarrativeData.smoke_test() should return true")

func test_list_genships_returns_six() -> void:
	var gs: Array = NarrativeData.list_genships()
	assert_eq(gs.size(), 6,
		"Six genships expected — NAC, ED, RRA, AC, SAA, ME")

func test_each_genship_has_country_fragments() -> void:
	var gs: Array = NarrativeData.list_genships()
	for g in gs:
		assert_true(g.fragments_count > 0,
			"%s should have at least one country fragment" % g.id)

func test_npc_variant_counts_in_range() -> void:
	# Spec: NPC1, NPC2, NPC3 = 6-8 variants each.
	# Constants NPC-T, NPC-AI are minimal (deferred variants OK).
	var counts: Dictionary = NarrativeData.npc_variant_counts()
	for arch_id in ["NPC1", "NPC2", "NPC3"]:
		var n: int = counts.get(arch_id, 0)
		assert_true(n >= 6 and n <= 8,
			"%s should have 6-8 variants; got %d" % [arch_id, n])
