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
	var origin_block: Dictionary = captain.get("origin", {})
	var origin_flavor: Dictionary = origin_block.get("narrative_flavor", {})
	var corp_rel: Dictionary = origin_block.get("corp_relationships", {})
	var uc: Dictionary = origin_block.get("unique_content", {})
	var briefing_state := {
		"captain_name": captain_name,
		"genship_id": captain["genship_id"],
		"t_slots": traits,
	}
	# Pipe origin flavor + faction standing + content chain into the
	# Ink-bound state so later systems can consume it.
	briefing_state["origin_flavor"] = {
		"ai_tone": str(origin_flavor.get("ai_tone", "")),
		"cover_test_modifier": int(origin_flavor.get("cover_test_modifier", 0)),
		"reaction_tokens": origin_flavor.get("reaction_tokens", []),
	}
	briefing_state["corp_relationships"] = corp_rel
	briefing_state["unique_content_chain"] = str(uc.get("chain_id", ""))
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

	# Phase 3e/21: if transit rolled an encounter, check if it routes to CQB.
	if transit_result.get("encounter_rolled", null) != null:
		var cqb_outcome := step_X_meet_aliens(ship)
		if cqb_outcome.get("combat_fired", false):
			# CQB ran. Append combat outcome to the discoveries list so the
			# ledger records it. The beat_runner state already has the CQB
			# beat loaded — stash the outcome for the end-of-run summary.
			discoveries.append("cqb_%s" % cqb_outcome.get("outcome", "unknown"))
			discoveries.append("cqb_combat_fired")
			return cqb_outcome.get("beat_result", station)

	if transit_result.get("ok", false):
		persist_ship_snapshot(transit_result)
	return station

# ── Phase 3e/21: CoverTest → CQB → CasualtyPipeline → Ink beat ──
# Called when a travel encounter has a combat resolution. Runs the
# full combat flow and returns the resulting beat text.
#
# Returns:
#   { combat_fired: bool, outcome: String, beat_result: Dictionary }
#   When combat_fired is false, the calling code should fall through
#   to the normal station-arrival flow.
func step_X_meet_aliens(ship_state: ShipState) -> Dictionary:
	# 1) Pick crew for contact — all alive crew members.
	if crew.is_empty():
		return {"combat_fired": false, "outcome": "no_crew", "beat_result": {}}
	var crew_stats: Array = []
	for c in crew:
		crew_stats.append(int(c.get("bond_score", 0)))

	# 2) Run CoverTest.
	var cover: Dictionary = CoverTest.roll(captain, crew_stats)
	var tier: String = cover.get("tier", "fail-hard")

	# 3) Route by CoverTest tier.
	if tier == "pass-clean":
		return _route_cover_pass("cqb_cover_pass_clean", {})
	if tier == "pass-rough":
		return _route_cover_pass("cqb_cover_pass_rough", {"suspicion_delta": 1})

	# fail-soft → CQB engagement
	if tier == "fail-soft":
		return _trigger_cqb_engagement()

	# fail-hard → detention arc (Ink beat placeholder)
	return _route_cover_pass("cqb_cover_pass_rough", {"suspicion_delta": 2,
		"note": "cover_fail_hard"})

# Route to a pass-through Ink beat (clean or rough).
# Loads the cqb manifest briefly, navigates to the beat, returns.
func _route_cover_pass(beat_id: String, extra_delta: Dictionary) -> Dictionary:
	var loaded: bool = beat_runner.load_manifest_from(
			"/../narrative/beats/cqb-ink-beats.json")
	if not loaded:
		return {"combat_fired": false, "outcome": "beat_missing", "beat_result": {}}
	var result: Dictionary = beat_runner.run_beat(beat_id)
	if not extra_delta.is_empty():
		beat_runner.apply_to_state(extra_delta)
	return {
		"combat_fired": false,
		"outcome": "cover_pass",
		"beat_result": result,
	}

# Run a full CQB engagement, process casualties, route to outcome beat.
func _trigger_cqb_engagement() -> Dictionary:
	# Build crew actor data for the grid.
	var crew_actors: Array = []
	for c in crew:
		crew_actors.append({
			"id": c.get("crew_name", c.get("name", "crew_x")),
			"hp_max": 10,
			"weapon_id": "light_pistol",
		})

	# Build alien actor data from the aliens JSON.
	var aliens_data: Variant = NarrativeData.aliens()
	var alien_actors: Array = []
	if aliens_data != null:
		var archetypes: Array = aliens_data.get("archetypes", [])
		for a in archetypes:
			alien_actors.append({
				"id": a.get("id", "alien"),
				"hp_max": int(a.get("hp_max", 6)),
				"weapon_id": a.get("weapon_id", "claw"),
				"display_name": a.get("display_name", "Alien"),
			})

	if alien_actors.is_empty():
		# Fallback: one generic alien
		alien_actors.append({"id": "alien_0", "hp_max": 6, "weapon_id": "claw"})

	# Run the engagement.
	var engagement: Dictionary = CqbEngagement.run(crew_actors, alien_actors)
	var outcome: String = engagement.get("outcome", "won")
	var casualties: Array = engagement.get("casualties", [])

	# Process casualties through the pipeline (if any crew died).
	var pipeline_result: Dictionary = {}
	if not casualties.is_empty():
		pipeline_result = CasualtyPipeline.process_casualties(casualties)
		# Write the casualty summary to the ledger.
		Persist.patch({"run_state": {"cqb_casualties": pipeline_result}})
		Persist.save()

	# Load the CQB manifest and route to the outcome beat.
	var beat_id: String = _cqb_outcome_beat(outcome, casualties)
	var loaded: bool = beat_runner.load_manifest_from(
		"/../narrative/beats/cqb-ink-beats.json")
	if not loaded:
		push_error("[AI] CQB manifest not found — combat ran but beat missing")
		return {"combat_fired": true, "outcome": outcome, "beat_result": {}}

	# Bind combat outcome state into beat_runner for Ink variable interpolation.
	beat_runner.bind_state({
		"station": "Transit Lane",
		"captain": {"short_form": captain.get("name", "Captain")},
		"alien_archetype": alien_actors[0].get("display_name", "entity") if alien_actors.size() > 0 else "entity",
		"grid_size": CqbEngagement.GRID_SIZE,
		"tribute_cite": pipeline_result.get("tributes", [""])[0] if pipeline_result.get("tributes", []).size() > 0 else "",
	})

	var beat: Dictionary = beat_runner.run_beat(beat_id)
	return {
		"combat_fired": true,
		"outcome": outcome,
		"casualties": casualties,
		"pipeline": pipeline_result,
		"beat_result": beat,
	}

# Map engagement outcome + casualties to the right CQB beat id.
func _cqb_outcome_beat(outcome: String, casualties: Array) -> String:
	if not casualties.is_empty():
		return "cqb_end_casualty"
	match outcome:
		"won":
			return "cqb_end_won"
		"lost":
			return "cqb_end_lost"
		"fled":
			return "cqb_end_fled"
		_:
			return "cqb_end_fled"
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
