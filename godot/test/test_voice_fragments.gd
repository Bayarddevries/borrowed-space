extends GutTest

func test_die_in_throes_loads() -> void:
	var data = NarrativeData.die_in_throes()
	assert_not_null(data, "die_in_throes.json must load")
	assert_true(data is Dictionary, "die_in_throes must be a Dictionary")

	var pool: Array = data.get("die_in_throes", [])
	assert_gt(pool.size(), 0, "die_in_throes pool must not be empty")

	for e in pool:
		assert_true(typeof(e) == TYPE_STRING or typeof(e) == TYPE_DICTIONARY,
			"die_in_throes element must be string or dict, got: " + str(typeof(e)))

func test_captains_journal_loads() -> void:
	var data = NarrativeData.captains_journal_frags()
	assert_not_null(data, "captains_journal.json must load")
	assert_true(data is Dictionary, "captains_journal must be a Dictionary")

	var pool: Array = data.get("captain_journal", [])
	assert_gt(pool.size(), 0, "captain_journal pool must not be empty")

	for e in pool:
		assert_true(typeof(e) == TYPE_STRING or typeof(e) == TYPE_DICTIONARY,
			"captain_journal element must be string or dict, got: " + str(typeof(e)))

func test_die_in_throes_count() -> void:
	var data = NarrativeData.die_in_throes()
	var pool: Array = data.get("die_in_throes", [])
	assert_gt(pool.size(), 49, "die_in_throes should be 50+ entries (got " + str(pool.size()) + ")")

func test_captains_journal_count() -> void:
	var data = NarrativeData.captains_journal_frags()
	var pool: Array = data.get("captain_journal", [])
	assert_gt(pool.size(), 49, "captains_journal should be 50+ entries (got " + str(pool.size()) + ")")
