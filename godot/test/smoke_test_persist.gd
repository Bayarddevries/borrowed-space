extends SceneTree
## smoke_test_persist.gd — runs once at scene-load to verify Persist
## round-trips correctly. Invoked via `godot --headless -s smoke_test_persist.gd`.

func _init() -> void:
	print("[smoke_test] start")
	# Wait one frame so Persist's _ready runs.
	await process_frame

	var persist_node = root.get_node_or_null("/root/Persist")
	if persist_node == null:
		print("[smoke_test] FAIL: Persist autoload not found")
		quit(1)
		return

	# 1. Reset to defaults.
	persist_node.reset()
	var s = persist_node.get_state()
	assert(s["campaign_state"]["he3_dismantling_progress"] == 0.0, "default progress is 0")
	print("[smoke_test] OK reset():", s["campaign_state"]["he3_dismantling_progress"])

	# 2. Patch in some data.
	persist_node.patch({
		"campaign_state": {
			"he3_dismantling_progress": 12.5,
			"discovered_acts": ["act1", "act2"],
		},
		"ledger": {
			"captains": {
				"Captain 47": {
					"origin_genship": "G6-Coalition",
					"outcomes": "alive"
				}
			}
		}
	})

	# 3. Save.
	var saved = persist_node.save()
	assert(saved == true, "save() returned true")
	print("[smoke_test] OK save()")

	# 4. Reset (in-memory wipe), then load_state.
	persist_node.reset()
	var s_after_reset = persist_node.get_state()
	assert(s_after_reset["campaign_state"]["he3_dismantling_progress"] == 0.0, "reset wiped progress")
	# Now load back from disk.
	var loaded = persist_node.load_state()
	assert(loaded == true, "load_state returned true")
	var s_final = persist_node.get_state()
	assert(s_final["campaign_state"]["he3_dismantling_progress"] == 12.5, "round-trip preserved progress")
	assert(s_final["campaign_state"]["discovered_acts"].size() == 2, "round-trip preserved array")
	assert(s_final["ledger"]["captains"].has("Captain 47"), "round-trip preserved ledger entry")
	print("[smoke_test] OK round-trip:", s_final["campaign_state"])

	# 5. Cleanup test file so next runs start fresh.
	var dir = DirAccess.open("user://")
	if dir != null:
		dir.remove("persist.json")

	print("[smoke_test] PASS")
	quit(0)
