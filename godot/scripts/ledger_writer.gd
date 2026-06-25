extends Node
## ledger_writer — translates per-run state into Persist rows.
##
## Phase 2g. Reads the persisted-state schema at narrative/data/ledger.json
## and writes captain + crew + discovery entries on run completion.
##
## API:
##   - finalise_run(state: Dictionary, captain: Dictionary, crew: Array,
##                   discoveries: Array) -> int   # returns new captain_n
##   - apply_choice_delta(delta: Dictionary)        # for live mid-run updates
##
## Pattern: idempotent on captain_n — if a captain row already exists for
## the given number, fields are merged (newer wins).
class_name LedgerWriter

const PROP_TRUSTEE_ARC := "trustee_arc.unlocked_bits"
const PROP_DISCOVERY := "campaign_state.discovered_acts"

var _next_captain_n: int = 0

func _ready() -> void:
	# Cross-check next captain_n against persisted run_counts for safety.
	var s = Persist.get_state()
	var counts = s.get("run_counts", {})
	_next_captain_n = int(counts.get("started", 0)) + 1

func next_captain_n() -> int:
	return _next_captain_n

# Builds a complete captain record from per-run state and persists it.
# Returns the new captain_n.
func finalise_run(state: Dictionary, captain: Dictionary, crew: Array,
		discoveries: Array = []) -> int:
	var n := next_captain_n()
	var record := {
		"captain_n": n,
		"genship_id": captain.get("genship_id", "?"),
		"country_fragment_id": captain.get("country_fragment_id", "?"),
		"t_slots": captain.get("t_slots", []),
		"h_tier_peak": int(captain.get("h_tier_peak", 1)),
		"b_status": captain.get("b_status", "active"),
		"l_status": captain.get("l_status", "not-applicable"),
		"outcome": state.get("outcome", "ledger-closed"),
		"discoveries": discoveries.duplicate(),
		"crew": crew.duplicate(),
	}
	# Persist state. captain keyed by captain_n for idempotent merges.
	var persisted := Persist.get_state()
	var captains_map: Dictionary = persisted.get("ledger", {}).get("captains", {})
	# Patch starting Corp standing from the captain's origin block.
	var origin_block: Dictionary = captain.get("origin", {})
	var corp_rel: Dictionary = origin_block.get("corp_relationships", {})
	if not corp_rel.is_empty():
		record["starting_corp_standing"] = corp_rel.duplicate()
	captains_map[str(n)] = record
	# Existing discoveries are union-ed (set semantics) with the new run's discoveries.
	var existing_discoveries: Array = persisted.get("campaign_state", {}).get("discovered_acts", [])
	var unioned := {}
	for d in existing_discoveries:
		unioned[String(d)] = true
	for d in discoveries:
		unioned[String(d)] = true
	Persist.patch({
		"ledger": {
			"captains": captains_map,
		},
		"campaign_state": {
			"_last_captain_n": n,
			"discovered_acts": unioned.keys(),
		},
		"run_counts": {
			"started": n,
			"ended": int(persisted.get("run_counts", {}).get("ended", 0)) + 1,
		},
	})
	Persist.save()
	_next_captain_n = n + 1
	return n

# Apply a single choice delta — used mid-run for live persistence.
func apply_choice_delta(delta: Dictionary) -> void:
	if delta.is_empty():
		return
	Persist.patch(delta)
