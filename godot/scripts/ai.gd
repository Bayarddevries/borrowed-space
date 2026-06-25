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

# Phase 3a.1 travel-system integration:
#   - `ship` holds the in-run ship state (fuel, hull, etc., hex coords).
#   - On every step_5_6 invocation we instantiate a fresh ship + run a
#     real Transit.transit() so the Persist.run_state[captain_n].ship
#     block gets written with authentic travel data.
#   - The beat_runner still drives Ink dialog as before — Phase 3a.1
#     integrates travel without ripping up the existing Phase 2g flow.
var ship: ShipState = null

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
# After step_3 the cursor sits on ai_briefing_1 with 1 choice (crew_meetup_1).
# After step_4 (meet crew) the cursor hasn't moved, so we burn picks 0,0 to
# reach overworld_choose_1, then 0,0 to pick refueling + brief encounter.
#
# Phase 3a.1: in addition to the manifest-driven dialog, we instantiate a
# ShipState and run one real Travel.transit() to demonstrate the integration.
# The transit result is patched into Persist.run_state.[captain_n].ship.
func step_5_6_overworld_and_station() -> Dictionary:
	if not beat_runner.is_loaded():
		return {"text": "BeatRunner manifest not loaded.", "choices": []}
	# Burn the briefing + crew_meetup choices to land on overworld_choose_1.
	beat_runner.choose(0)   # ai_briefing_1 -> crew_meetup_1
	beat_runner.choose(0)   # crew_meetup_1  -> overworld_choose_1
	# Now choose a destination -> station arrival.
	var station = beat_runner.choose(0)   # pick refueling (conservative)
	# Station has 1 choice -> end-of-run.
	var end_beat = beat_runner.choose(0)
	# Synthetic discovery — real gameplay gates this against an event system.
	beat_runner.apply_to_state({"discoveries_caught": ["ink_first_arrival"]})
	discoveries.append("ink_first_arrival")

	# Phase 3a.1: real travel-system integration.
	ship = ShipState.new_default(captain.get("name", "Play-Captain"),
		captain.get("genship_id", "NAC"), 0, 0)
	Travel.register_encounter("station_hex", "station_arrival_default_1")
	var stations: Array = Cartography.load_stations()
	# Real transit: from (0,0) to STATION_10 at (1,-1).
	var transit_result := Travel.transit(ship, 1, -1, stations)
	Travel.clear_registry()
	if transit_result.get("ok", false):
		persist_ship_snapshot(transit_result)
	return station

## Patch the ShipState into Persist.run_state under a per-captain key.
## Phase 3a.1 stub: a sentinel captain_n of <run_iteration> is used here
## because we don't have the finalised captain_n yet from step_7 — that
## wiring lands when LedgerWriter adopts run_state.* keys (Phase 3c).
func persist_ship_snapshot(transit_result: Dictionary) -> void:
	if ship == null:
		return
	var snapshot := ship.to_dict()
	snapshot["last_transit"] = {
		"arrived_at": [int(transit_result.get("arrived_at", Vector2i(-1, -1)).x),
		               int(transit_result.get("arrived_at", Vector2i(-1, -1)).y)],
		"arrival_kind": str(transit_result.get("arrival_kind", "")),
		"fuel_after": int(transit_result.get("fuel_after", 0)),
		"cost": int(transit_result.get("cost", 0)),
		"tick": int(transit_result.get("tick", 0)),
	}
	Persist.patch({"run_state": {"phase3a_demo_ship": snapshot}})

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
