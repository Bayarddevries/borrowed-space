class_name Hex
extends RefCounted

# Hex — axial hex-coordinate math (Red Blob Games convention).
#
# The belt is charted as a 2D axial hex grid; (q, r) are the only
# coords we serialize. Distance is closed-form: |dq| + |dr| + |ds|
# (where s = -dq - dr, the implicit third coord), all divided by 2.
#
# Why axial, not cube:
#   - Two ints serialize cleanly (q, r pairs in JSON)
#   - Closed-form math, no lookups, O(1)
#   - Standard hex-dev ref: https://www.redblobgames.com/grids/hexagons/

const DIRECTIONS := [
	[+1,  0], [+1, -1], [ 0, -1],
	[-1,  0], [-1, +1], [ 0, +1],
] # 6 cardinal neighbors in axial coords

const BELT_RADIUS := 25 # Inner ring playable surface per MAP.md §1

## Axial distance between two hexes.
##
## Examples:
##   distance((0,0), (3,0)) -> 3
##   distance((0,0), (-5,2)) -> 5
##   adjacent hexes -> 1
static func distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	var ds := -dq - dr
	return (abs(dq) + abs(dr) + abs(ds)) / 2

## Are `a` and `b` adjacent hexes?
static func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return distance(a, b) == 1

## Return the 6 axial neighbor offsets of `h`.
static func neighbors(h: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in DIRECTIONS:
		out.append(Vector2i(h.x + d[0], h.y + d[1]))
	return out

## Is `h` within the playable belt (radius 25 of origin)?
static func in_belt(h: Vector2i) -> bool:
	return distance(Vector2i(0, 0), h) <= BELT_RADIUS

## Are two hexes at tactical-range distance (≤ 2)?
static func in_tactical_range(a: Vector2i, b: Vector2i) -> bool:
	return distance(a, b) <= 2

## String-pairs helper for log lines: "(q,r)"
static func to_str(h: Vector2i) -> String:
	return "(%d,%d)" % [h.x, h.y]
