extends Node
## CoverTest — pre-combat gating mechanic.
##
## Per docs/COMBAT.md §7:
##   roll(captain, crew_best_stat) returns one of:
##     "pass-clean"  (≥18) — enter station freely
##     "pass-rough"  (≥14) — enter, suspicion +1
##     "fail-soft"   (≥9)  — CQB combat triggers
##     "fail-hard"   (<9)  — detained; no combat this run
##
## The roll is d20 + captain.h_tier_peak + crew_best_stat
## where crew_best_stat is the highest bond_score among the crew
## selected for contact (proxy for "how well they handle tension").
class_name CoverTest

# Thresholds from COMBAT.md §7 (locked design).
const THRESHOLD_CLEAN: int = 18
const THRESHOLD_ROUGH: int = 14
const THRESHOLD_FAIL: int  = 9

## Roll the cover-test for a captain and their contact crew.
##   captain: Dictionary — the current captain record (must have h_tier_peak)
##   crew_stats: Array[int] — bond_score (or other tension-handling stat)
##                for each crew member selected for the contact.
## Returns { tier: String, raw_roll: int, modifiers_applied: Array }
static func roll(captain: Dictionary, crew_stats: Array) -> Dictionary:
	var bonus: int = int(captain.get("h_tier_peak", 1))
	var best_crew: int = 0
	for s in crew_stats:
		var v: int = int(s)
		if v > best_crew:
			best_crew = v
	var raw_roll: int = randi() % 20 + 1  # d20, 1-indexed
	var total: int = raw_roll + bonus + best_crew
	var mods: Array = []
	mods.append("h_tier_+%d" % bonus)
	mods.append("crew_bond_+%d" % best_crew)

	var tier: String = "fail-hard"
	if total >= THRESHOLD_CLEAN:
		tier = "pass-clean"
	elif total >= THRESHOLD_ROUGH:
		tier = "pass-rough"
	elif total >= THRESHOLD_FAIL:
		tier = "fail-soft"

	return {
		"tier": tier,
		"raw_roll": raw_roll,
		"total": total,
		"modifiers_applied": mods,
	}
