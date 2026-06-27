extends GutTest
func test_beat_path_resolves() -> void:
	var godot_root := ProjectSettings.globalize_path("res://")
	var beat_path := godot_root + "../narrative/beats/encounter-pool-beats.json"
	assert_true(FileAccess.file_exists(beat_path), "Beat file should exist at: " + beat_path)
