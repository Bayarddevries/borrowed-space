extends GutTest
## test_ink_beats_cover_test.gd — Phase 3e cover-test + CQB outcome beat validation.
##
## Verifies that all 8 beats in cqb-ink-beats.json load and have the
## correct speaker, delta keys, and structure for BeatRunner consumption.

const MANIFEST_PATH: String = "/../narrative/beats/cqb-ink-beats.json"

func before_each() -> void:
	pass

func _load_manifest() -> Dictionary:
	var godot_root: String = ProjectSettings.globalize_path("res://")
	var path: String = godot_root + MANIFEST_PATH.lstrip("/")
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	var raw: String = f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(raw)
	if data == null:
		push_error("Failed to parse cqb-ink-beats.json at %s" % path)
	return data

func test_pass_clean_beat_exists_and_has_delta() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data != null, "manifest should parse")
	assert_true(data.has("beats"), "manifest must have beats dict")
	assert_true(data["beats"].has("cqb_cover_pass_clean"), "pass-clean beat must exist")
	var b: Dictionary = data["beats"]["cqb_cover_pass_clean"]
	assert_eq(b["speaker"], "narrator")
	assert_true(b.has("text"), "beat must have text")
	assert_true(b.has("choices"), "beat must have choices")
	assert_eq(b["choices"].size(), 1, "pass-clean should have 1 choice")
	var c: Dictionary = b["choices"][0]
	assert_eq(c["to"], "end_of_run_1")
	assert_eq(c["delta"]["fuel_delta"], 1)

func test_pass_rough_beat_exists_and_has_delta() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_cover_pass_rough"), "pass-rough beat must exist")
	var b: Dictionary = data["beats"]["cqb_cover_pass_rough"]
	assert_eq(b["speaker"], "narrator")
	assert_eq(b["choices"].size(), 1)
	assert_eq(b["choices"][0]["delta"]["suspicion_delta"], 1)

func test_cqb_enter_beat_exists() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_enter"), "cqb enter beat must exist")
	var b: Dictionary = data["beats"]["cqb_enter"]
	assert_eq(b["speaker"], "narrator")
	assert_eq(b["choices"].size(), 1)
	assert_eq(b["choices"][0]["to"], "end_of_run_1")

func test_cqb_end_won_beat_exists() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_end_won"), "won beat must exist")
	var b: Dictionary = data["beats"]["cqb_end_won"]
	assert_true(b.has("choices"))
	assert_eq(b["choices"].size(), 1)
	assert_eq(b["choices"][0]["delta"]["bond_score"], 1)

func test_cqb_end_lost_beat_exists() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_end_lost"), "lost beat must exist")
	var b: Dictionary = data["beats"]["cqb_end_lost"]
	assert_eq(b["choices"].size(), 1)
	assert_eq(b["choices"][0]["delta"]["bond_score"], -2)

func test_cqb_end_fled_beat_exists() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_end_fled"), "fled beat must exist")
	var b: Dictionary = data["beats"]["cqb_end_fled"]
	assert_eq(b["choices"].size(), 1)
	assert_eq(b["choices"][0]["delta"]["fuel_delta"], -5)

func test_cqb_end_casualty_uses_tribute_variable() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data["beats"].has("cqb_end_casualty"), "casualty beat must exist")
	var b: Dictionary = data["beats"]["cqb_end_casualty"]
	assert_eq(b["speaker"], "narrator")
	assert_true(b["text"].find("{tribute_cite}") != -1,
			"casualty beat must use tribute_cite variable, not templated text")
	assert_eq(b["choices"][0]["delta"]["bond_score"], -2)

func test_all_beats_have_valid_structure() -> void:
	var data: Dictionary = _load_manifest()
	assert_true(data != null and data.has("beats"), "manifest must have beats dict")
	var required: Array = [
		"cqb_cover_pass_clean",
		"cqb_cover_pass_rough",
		"cqb_enter",
		"cqb_end_won",
		"cqb_end_lost",
		"cqb_end_fled",
		"cqb_end_casualty",
	]
	for id in required:
		assert_true(data["beats"].has(id), "missing beat: %s" % id)
		var b: Dictionary = data["beats"][id]
		assert_true(b.has("speaker"), "beat %s missing speaker" % id)
		assert_true(b.has("text"), "beat %s missing text" % id)
		assert_true(b.has("choices"), "beat %s missing choices" % id)
		for c in b["choices"]:
			assert_true(c.has("label"), "choice in %s missing label" % id)
			assert_true(c.has("to"), "choice in %s missing to" % id)
