extends Node
## AI — orchestrator for a single run.
##
## Phase 2g. Drives the 7-step sequence per issue #7:
##   1. Pick a genship origin (optional country fragment).
##   2. Pick an archetype (3 options).
##   3. Run the AI briefing (run-start.ink).
##   4. Meet 2 procedurally-generated crew.
##   5. Pick a destination on the overworld.
##   6. Arrive at a station, run a brief encounter, return.
##   7. End-of-run summary: Ledger entry.
##
## API:
##   - run() -> Dictionary   # returns the final captain record
##   - log() -> void         # prints the human-readable playthrough trail
class_name AI

var captain: Dictionary = {}
var crew: Array = []
var discoveries: Array = []
var beat_runner: Node = null
var ledger: Node = null

func _ready() -> void:
	beat_runner = BeatRunner.new()
	add_child(beat_runner)
	ledger = LedgerWriter.new()
	add_child(ledger)

# === Step 1: origin selection ===
# For the playable run, the host picks the origin so the run is reproducible in tests.
# This is the same surface an interactive UI would call.
func step_1_pick_origin(genship_id: String, fragment_id: String) -> Dictionary:
	captain = Captain.new_run(genship_id, fragment_id)
	if captain.is_empty():
		return {}
	return captain

# === Step 2: archetype selection ===
func step_2_pick_archetype(arch_id: String) -> void:
	captain["archetype"] = arch_id
	captain["l_status"] = "unfolding" if arch_id == "C" else "not-applicable"

# === Step 3: AI briefing via beat_runner ===
func step_3_ai_briefing(captain_name: String) -> Dictionary:
	# Lock the 3 T-pool traits using the origin's tag_pool.
	var traits = Captain.lock_traits(captain.get("tag_pool", []))
	captain["t_slots"] = traits
	var briefing_state := {
		"captain_name": captain_name,
		"genship_id": captain["genship_id"],
		"t_slots": traits,
	}
	beat_runner.bind_state(briefing_state)
	return beat_runner.run_beat()

# === Step 4: meet 2 procedurally-generated crew ===
func step_4_meet_crew() -> Array:
	# Crew slot 1 = NPC1 (Sherpa); slot 2 = NPC2 (Engineer) for the playable floor.
	var pilot = Crew.generate("NPC1")
	var engineer = Crew.generate("NPC2")
	crew = [pilot, engineer]
	return crew

# === Step 5 + 6: pick destination, run brief encounter, return ===
func step_5_6_overworld_and_station() -> Dictionary:
	# Drive 3 beats end-to-end: overworld choice -> station arrival -> debrief.
	# Each beat ends at the choice index the procedural test profile picks.
	if not beat_runner.is_loaded():
		return {"text": "BeatRunner manifest not loaded.", "choices": []}
	var dest: Dictionary = beat_runner.choose(0)
	if not dest.get("choices", []).is_empty():
		beat_runner.choose(0)
	# Station has 1 choice — debrief into end-of-run.
	if beat_runner.get_current_beat() != "":
		var final_beat = beat_runner.run_beat(beat_runner.get_current_beat())
		if not final_beat.get("choices", []).is_empty():
			beat_runner.choose(0)
	# Discovered something on the way (synthetic — real gameplay gates this).
	beat_runner.apply_to_state({"discoveries_caught": ["ink_first_arrival"]})
	discoveries.append("ink_first_arrival")
	return beat_runner.get_state()

# === Step 7: end-of-run summary ===
func step_7_finalise() -> int:
	var final_state = beat_runner.get_state()
	final_state["outcome"] = "ledger-closed"
	var n: int = ledger.finalise_run(final_state, captain, crew, discoveries)
	return n

# Run the entire sequence end-to-end. Returns the newly-finalised captain record.
# Deterministic when given (genship_id, fragment_id, archetype) — same inputs, same captain.
func full_run(genship_id: String, fragment_id: String, archetype_id: String,
		captain_name := "Play-Captain") -> Dictionary:
	step_1_pick_origin(genship_id, fragment_id)
	step_2_pick_archetype(archetype_id)
	step_3_ai_briefing(captain_name)
	step_4_meet_crew()
	step_5_6_overworld_and_station()
	var n := step_7_finalise()
	return {
		"captain_n": n,
		"captain": captain,
		"crew_count": crew.size(),
		"discovery_count": discoveries.size(),
	}

# Print a human-readable playthrough trail — useful for both demo and tests.
func log_trail() -> void:
	print("=== Captain record ===")
	print("genship=%s fragment=%s archetype=%s"
		% [captain.get("genship_id"), captain.get("country_fragment_id"),
		   captain.get("archetype")])
	print("t_slots=%s" % str(captain.get("t_slots")))
	print("h_tier_peak=%d" % int(captain.get("h_tier_peak")))
	print("b_status=%s l_status=%s"
		% [captain.get("b_status"), captain.get("l_status")])
	print("crew: ")
	for c in crew:
		print("  - %s (%s/%s)" %
			[c.get("crew_name"), c.get("archetype_id"), c.get("variant_id")])
	print("discoveries: %s" % str(discoveries))
	print("--- beat history: ---")
	for h in beat_runner.get_history():
		print("  beat=%s choice=%s" % [h.beat, h.choice])
