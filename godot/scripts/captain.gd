extends Node
## Captain — state holder for the captain of the current run.
##
## Phase 2g. Bound to one (genship_id, country_fragment_id) pair at run-start.
## Holds T1/T2/T3 (3 traits), H-tier, B-status, latent-flag (Archetype C only).
##
## API:
##   - new_run(genship_id, fragment_id) -> Dictionary  # builds cap from origin matrix
##   - lock_traits(rng_seed) -> Array[String]          # draws 3 T-pool traits
##   - to_record() -> Dictionary                       # full captain record (post-run)
##
## Signal:
##   captain_locked(record: Dictionary)               # emitted after new_run
class_name Captain

const ARCHETYPE_IDS := ["A", "B", "C"]   # A=Recoverer, B=Helper, C=Carrier (placeholders)

var captain_n: int = 0
var genship_id: String
var country_fragment_id: String
var t_slots: Array = []   # 3 string IDs from TRAITS.md T-pool
var h_tier: int = 1
var b_status: String = "active"   # active | withdrawn | not-granted
var l_status: String = "dormant"  # dormant | unfolding | resolved | not-applicable (Archetype C only)
var archetype: String = "A"

# Builds a fresh captain from the origin matrix. Returns the record so
# the host can hand it straight to the ledger writer.
static func new_run(genship_id: String, fragment_id: String) -> Dictionary:
	var archs = NarrativeData.origins()
	if archs == null:
		push_error("[Captain] cannot read captain-origins.json")
		return {}
	for o in archs["origins"]:
		if o["genship_id"] == genship_id:
			for cf in o["country_fragments"]:
				if cf["id"] == fragment_id:
					return {
						"captain_n": 0,                                  # assigned by ledger writer
						"genship_id": genship_id,
						"country_fragment_id": fragment_id,
						"t_slots": [],                                    # drawn next; 3 random from tag_pool
						"h_tier_peak": int(cf["h_tier_default"]),
						"b_status": "active",
						"l_status": "not-applicable",                     # unless Archetype C
						"archetype": "A",                                 # placeholder; selected in step 2
						"tag_pool": cf["tag_pool"],
						"ship_class": o["first_ship_class"],
					}
	push_error("[Captain] origin fragment not found: %s/%s" % [genship_id, fragment_id])
	return {}

# Draw 3 trait IDs at random (without replacement) from the supplied tag_pool.
# If pool has fewer than 3, returns whatever's there.
static func lock_traits(tag_pool: Array) -> Array:
	var pool: Array = tag_pool.duplicate()
	var out: Array = []
	while out.size() < 3 and not pool.is_empty():
		var idx = Dice.roll(pool.size()) - 1
		out.append(pool[idx])
		pool.remove_at(idx)
	return out
