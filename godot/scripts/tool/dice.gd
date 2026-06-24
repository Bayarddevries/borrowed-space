extends Node
## tool/dice — probability and selection utilities.
##
## Phase 2 used for trait draws, random crew generation, and cover-test rolls
## when those land in Phase 3. Keep the API stable across scripts; do not
## deepen the surface area without a Phase-2g review.
##
## Public API:
##   - roll(sides: int) -> int        # 1..sides inclusive
##   - weighted_choice(items: Array, weights: Array) -> Variant   # mirror-indexed
##   - lowest_of(stats: Dictionary) -> String                       # for cover-test
class_name Dice

static func roll(sides: int) -> int:
	assert(sides > 0)
	return randi() % sides + 1

static func weighted_choice(items: Array, weights: Array) -> Variant:
	assert(items.size() == weights.size())
	assert(items.size() > 0)
	var total := 0.0
	for w in weights:
		total += float(w)
	var pick := randf() * total
	var cumulative := 0.0
	for i in range(items.size()):
		cumulative += float(weights[i])
		if pick <= cumulative:
			return items[i]
	return items[items.size() - 1]

static func lowest_of(stats: Dictionary) -> String:
	# Returns the key whose numeric value is lowest.
	# Used by cover-test (TRAITS.md §cover-test).
	assert(not stats.is_empty())
	var lowest_key: String
	var lowest_value := INF
	for k in stats.keys():
		var v = stats[k]
		if typeof(v) in [TYPE_INT, TYPE_FLOAT] and float(v) < lowest_value:
			lowest_value = float(v)
			lowest_key = k
	return lowest_key
