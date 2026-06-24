extends GutTest
## demo_visible_run.gd — walks the full 7-step run via GUT (which runs
## after autoloads are wired so <root>/Persist / BeatRunner work).
## ASCII-prints each step. Use it to *show* a player the loop.

func test_demo_run_visible() -> void:
	# Reset persist so the demo is reproducible.
	Persist.reset()

	var AI_Script: GDScript = load("res://scripts/ai.gd")
	var ai = AI_Script.new()
	add_child_autofree(ai)
	# Wait one frame so BeatRunner._ready runs and loads the manifest.
	await wait_frames(2)

	print("\n==> BORROWED SPACE — boot demo <==\n")

	print("STEP 1 — pick an origin.")
	var captain: Dictionary = ai.step_1_pick_origin("SAA", "SAA-coalition")
	print("  genship=%s fragment=%s ship_class=%s h_tier_default=%d"
		% [captain["genship_id"], captain["country_fragment_id"],
		   captain["ship_class"], captain["h_tier_peak"]])
	print("  tag_pool=%s" % str(captain["tag_pool"]))

	print("\nSTEP 2 — pick an archetype.")
	ai.step_2_pick_archetype("A")
	print("  archetype=%s l_status=%s"
		% [captain["archetype"], captain["l_status"]])

	print("\nSTEP 3 — AI briefing.")
	var brief: Dictionary = ai.step_3_ai_briefing("Captain-Test-001")
	print("  %s: %s" % [brief["speaker"], brief["text"]])
	for c in brief["choices"]:
		print("    - %s -> %s" % [c["label"], c["to"]])
	print("  traits locked: %s" % str(captain["t_slots"]))

	print("\nSTEP 4 — meet 2 procedurally-generated crew.")
	var crew: Array = ai.step_4_meet_crew()
	for c in crew:
		print("  - %s (%s/%s) held_trust=%d"
			% [c["name"], c["archetype_id"], c["variant_id"], c["held_trust"]])

	print("\nSTEP 5+6 — pick destination + station encounter.")
	var enc: Dictionary = ai.step_5_6_overworld_and_station()
	print("  %s: %s" % [enc["speaker"], enc["text"]])
	print("  discoveries so far: %s" % str(ai.discoveries))

	print("\nSTEP 7 — finalise.")
	var n: int = ai.step_7_finalise()
	print("  ledger entry stamped with captain_n=%d" % n)

	var pstate = Persist.get_state()
	print("\n=== Final ledger state ===")
	print("  ledger.captains: %s" % str(pstate["ledger"]["captains"]))
	print("  run_counts: %s" % str(pstate["run_counts"]))
	print("\n==> BORROWED SPACE — run complete <==\n")

	# Trivial assertion — the demo passes if the run completed end-to-end.
	assert_gt(n, 0, "demo_run should produce a positive captain_n")
