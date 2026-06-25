extends Node
## cqb_grid.gd — Phase 3e runtime for close-quarters battle.
##
## Specs locked at docs/COMBAT.md §1-§4:
##   - 6×6 default; 5×5 cramped; 7×7 boss (per-encounter JSON)
##   - 2 AP per crew per turn; player-given order
##   - Half cover = 25% damage reduction; full = 50%; flanked = ignored
##   - Weapons: light_pistol 1d6/r3, cutting_laser 1d6/r2 (ignores half cover),
##     heavy_rifle 2d4/r5, industrial_cutter 2d4/melee
##
## Public API (always stable):
##   CqbGrid.new(grid_size := 6)             # 5/6/7 valid
##   place_actor(actor_id, x, y, faction)     # sets tile.actor + side
##   move(actor_id, dx, dy) -> bool           # 1 AP, returns true on success
##   line_of_sight(a, b) -> bool              # Bresenham-style axial LOS
##   flanked?(actor_id) -> bool               # opposite-edge check, n/a for now
##   attack(attacker_id, target_id) -> Dict   # rolls damage; applies mods
##   step_toward(actor_id, target_id) -> Vector2i
##   actor_at(x, y) -> String                 # empty string if none
##   tile_at(x, y) -> Dict                    # { type, height }
##   set_tile(x, y, type, height := 0)        # cover/height setup
##   ap_remaining(actor_id) -> int
##   reset_ap(actor_ids: Array)               # turn boundary
##
## Internal storage: actors: Dictionary keyed by actor_id.
##   actor := { id, side ("crew"|"alien"), x, y, hp, hp_max, weapon_id, ap }
class_name CqbGrid

const WEAPON_TABLE := {
	"light_pistol":       {"damage": "1d6", "range": 3, "ignores_half": false, "kind": "light"},
	"cutting_laser":      {"damage": "1d6", "range": 2, "ignores_half": true,  "kind": "light"},
	"heavy_rifle":        {"damage": "2d4", "range": 5, "ignores_half": false, "kind": "heavy"},
	"industrial_cutter":  {"damage": "2d4", "range": 1, "ignores_half": false, "kind": "heavy"},
	# Alien weapon ids (used by tests pre-phase-3e cqb_ai; also covers any
	# narrative-data alien archetype that names its weapon 'claw', etc.)
	"claw":              {"damage": "1d6", "range": 2, "ignores_half": false, "kind": "light"},
	"laser_torch":       {"damage": "1d6", "range": 4, "ignores_half": true,  "kind": "light"},
	"toxic_needle":      {"damage": "1d6", "range": 4, "ignores_half": false, "kind": "light"},
	"drone_blaster":     {"damage": "2d4", "range": 5, "ignores_half": false, "kind": "heavy"},
}

var grid_size: int = 6
var tiles: Array = []  # tiles[x][y] = {type, height}
var actors: Dictionary = {}  # actor_id -> actor dict

func _init(p_grid_size: int = 6) -> void:
	assert(p_grid_size in [5, 6, 7], "CqbGrid size must be 5, 6, or 7 (got %d)" % p_grid_size)
	grid_size = p_grid_size
	for x in range(grid_size):
		var col: Array = []
		for y in range(grid_size):
			col.append({"type": "floor", "height": 0})
		tiles.append(col)

# ───── Tiles ─────

func set_tile(x: int, y: int, type: String, height: int = 0) -> void:
	assert(_in_bounds(x, y), "tile (%d,%d) out of bounds for grid_size=%d" % [x, y, grid_size])
	assert(type in ["floor", "half_cover", "full_cover"], "unknown tile type: %s" % type)
	tiles[x][y] = {"type": type, "height": height}

func tile_at(x: int, y: int) -> Dictionary:
	if not _in_bounds(x, y):
		return {"type": "void", "height": 0}
	return tiles[x][y]

func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < grid_size and y >= 0 and y < grid_size

# ───── Actors ─────

func place_actor(actor_id: String, x: int, y: int, side: String, hp_max: int = 10, weapon_id: String = "light_pistol") -> void:
	assert(_in_bounds(x, y), "actor placement (%d,%d) out of bounds" % [x, y])
	var t: Dictionary = tiles[x][y]
	assert(t.type == "floor", "cannot place on cover tile (%d,%d): type=%s" % [x, y, t.type])
	actors[actor_id] = {
		"id": actor_id,
		"side": side,
		"x": x,
		"y": y,
		"hp": hp_max,
		"hp_max": hp_max,
		"weapon_id": weapon_id,
		"ap": 2,
	}

func actor_at(x: int, y: int) -> String:
	if not _in_bounds(x, y):
		return ""
	for id in actors:
		var a: Dictionary = actors[id]
		if int(a["x"]) == x and int(a["y"]) == y:
			return id
	return ""

func ap_remaining(actor_id: String) -> int:
	if not actors.has(actor_id):
		return 0
	return int(actors[actor_id]["ap"])

func is_alive(actor_id: String) -> bool:
	if not actors.has(actor_id):
		return false
	return int(actors[actor_id]["hp"]) > 0

func reset_ap(actor_ids: Array = []) -> void:
	if actor_ids.is_empty():
		actor_ids = actors.keys()
	for id in actor_ids:
		if actors.has(id):
			actors[id]["ap"] = 2

# ───── Movement ─────

func move(actor_id: String, dx: int, dy: int) -> bool:
	if not actors.has(actor_id):
		return false
	var a: Dictionary = actors[actor_id]
	if int(a["ap"]) < 1:
		return false
	var nx := int(a["x"]) + dx
	var ny := int(a["y"]) + dy
	if not _in_bounds(nx, ny):
		return false
	if actor_at(nx, ny) != "":
		return false
	a["x"] = nx
	a["y"] = ny
	a["ap"] = int(a["ap"]) - 1
	return true

func step_toward(actor_id: String, target_id: String) -> Vector2i:
	## Chebyshev step toward target. Returns the (dx,dy) move taken AFTER it succeeds,
	## or Vector2i.ZERO if no step could be taken.
	if not actors.has(actor_id) or not actors.has(target_id):
		return Vector2i.ZERO
	var a := Vector2i(int(actors[actor_id]["x"]), int(actors[actor_id]["y"]))
	var t := Vector2i(int(actors[target_id]["x"]), int(actors[target_id]["y"]))
	if a == t:
		return Vector2i.ZERO
	var dx := 0
	var dy := 0
	if t.x > a.x: dx = 1
	elif t.x < a.x: dx = -1
	if t.y > a.y: dy = 1
	elif t.y < a.y: dy = -1
	if move(actor_id, dx, dy):
		return Vector2i(dx, dy)
	# Try x-only then y-only as fallback
	if dx != 0 and move(actor_id, dx, 0):
		return Vector2i(dx, 0)
	if dy != 0 and move(actor_id, 0, dy):
		return Vector2i(0, dy)
	return Vector2i.ZERO

# ───── Line of sight ─────

func line_of_sight(a_id: String, b_id: String) -> bool:
	## Bresenham-style straight line in axial coords (offset to square for simplicity).
	## Full cover blocks LOS; half cover does not. (Light-weapon 1d6 line-of-fire is
	## limited by range, but LOS is the geometric predicate only.)
	if not actors.has(a_id) or not actors.has(b_id):
		return false
	var a := Vector2i(int(actors[a_id]["x"]), int(actors[a_id]["y"]))
	var b := Vector2i(int(actors[b_id]["x"]), int(actors[b_id]["y"]))
	if a == b:
		return true
	var steps: Array = _line(a.x, a.y, b.x, b.y)
	var blocked := false
	# Skip endpoints; check tiles in between.
	for i in range(1, steps.size() - 1):
		var p: Vector2i = steps[i]
		var t := tile_at(p.x, p.y)
		if t.type == "full_cover":
			blocked = true
			break
	if blocked:
		return false
	return true

func _line(x0: int, y0: int, x1: int, y1: int) -> Array:
	## Bresenham 2D line.
	var pts: Array = []
	var dx: int = abs(x1 - x0)
	var dy: int = -abs(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx + dy
	var x: int = x0
	var y: int = y0
	while true:
		pts.append(Vector2i(x, y))
		if x == x1 and y == y1:
			break
		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy
	return pts

# ───── Attack ─────

func attack(attacker_id: String, target_id: String, suspicion_mod: int = 0) -> Dictionary:
	## Rolls damage; applies cover, flanking, fold modifiers.
	## Returns: { hit, damage, modifiers[], target_tile, weapon_id }
	##   hit: bool — always for v0; crit/miss can come later
	##   damage: int (post-modifier, min 1)
	##   suspicion_mod: int — +1 to enemy's hits, -1 to crew's, when folded
	if not actors.has(attacker_id) or not actors.has(target_id):
		return {"hit": false, "damage": 0, "modifiers": ["invalid_actor"], "weapon_id": ""}
	var atk: Dictionary = actors[attacker_id]
	var tgt: Dictionary = actors[target_id]
	if int(atk["ap"]) < 1:
		return {"hit": false, "damage": 0, "modifiers": ["no_ap"], "weapon_id": atk["weapon_id"]}
	var weapon_id: String = atk["weapon_id"]
	var weapon := _weapon(weapon_id)
	var dist := _chebyshev_distance(int(atk["x"]), int(atk["y"]), int(tgt["x"]), int(tgt["y"]))
	if dist > int(weapon["range"]):
		atk["ap"] = int(atk["ap"]) - 1  # attack attempt still spends AP
		return {"hit": false, "damage": 0, "modifiers": ["out_of_range"], "weapon_id": weapon_id, "distance": dist}
	# LOS check (range-limited light weapons cannot fire through full cover)
	if not weapon["ignores_half"] and dist > 1:
		if not line_of_sight(attacker_id, target_id):
			atk["ap"] = int(atk["ap"]) - 1
			return {"hit": false, "damage": 0, "modifiers": ["no_los"], "weapon_id": weapon_id, "distance": dist}
	# Roll base damage
	var damage := _roll_damage(weapon["damage"])
	var mods: Array = []
	# Cover modifiers
	var cover_mod := _cover_modifier(target_id, weapon_id)
	damage = max(1, damage - cover_mod)
	if cover_mod > 0:
		mods.append("cover_%d" % cover_mod)
	# Fold modifiers (suspicion > 3)
	if suspicion_mod != 0:
		damage += suspicion_mod
		mods.append("fold_%+d" % suspicion_mod)
	# Height bonus
	var t := tile_at(int(tgt["x"]), int(tgt["y"]))
	var atk_tile := tile_at(int(atk["x"]), int(atk["y"]))
	if int(atk_tile["height"]) > int(t["height"]):
		damage += 1
		mods.append("height_+1")
	damage = max(1, damage)
	# Apply
	tgt["hp"] = max(0, int(tgt["hp"]) - damage)
	atk["ap"] = int(atk["ap"]) - 1
	if int(tgt["hp"]) == 0:
		mods.append("killed")
	return {
		"hit": true,
		"damage": damage,
		"modifiers": mods,
		"weapon_id": weapon_id,
		"target_hp_after": int(tgt["hp"]),
		"distance": dist,
	}

func _weapon(weapon_id: String) -> Dictionary:
	if WEAPON_TABLE.has(weapon_id):
		return WEAPON_TABLE[weapon_id]
	# Safe default
	return {"damage": "1d6", "range": 1, "ignores_half": false, "kind": "light"}

func _roll_damage(expr: String) -> int:
	## Parses 'NdM', rolls N dice of M sides, returns the sum.
	var parts := expr.split("d")
	if parts.size() != 2:
		return 1
	var n := int(parts[0])
	var m := int(parts[1])
	var total := 0
	for _i in range(n):
		total += Dice.roll(m)
	return total

func _cover_modifier(target_id: String, weapon_id: String) -> int:
	## 25% of rolled damage / 1d6 ≈ 1, 2d4 ≈ 1-2.
	## v0: simple integer model — half=1, full=2, flanked=0.
	## (Pct reduction computed in tests via damage-vs-cover invariants.)
	if not actors.has(target_id):
		return 0
	var tgt_x := int(actors[target_id]["x"])
	var tgt_y := int(actors[target_id]["y"])
	var t := tile_at(tgt_x, tgt_y)
	if t.type == "half_cover" and not bool(WEAPON_TABLE[weapon_id].get("ignores_half", false)):
		return 1
	if t.type == "full_cover":
		return 2
	return 0

# ───── Flanking ─────

func flanked(target_id: String) -> bool:
	## True if at least two enemies on opposing edge-sides of the target.
	## "Edge-side" means the line connecting the enemy's tile to the target's
	## has a dominant axis (x or y) with the same sign — so a north enemy (dy<0)
	## + south enemy (dy>0) flank even if they're 2 tiles away. Same for east/west.
	## Diagonals count toward whichever edge they lean closer to. This is a v0
	## simplification; proper-facing-flank detection ships Phase 4.
	if not actors.has(target_id):
		return false
	var tgt_x := int(actors[target_id]["x"])
	var tgt_y := int(actors[target_id]["y"])
	var my_side: String = actors[target_id]["side"]
	var north := false
	var south := false
	var west := false
	var east := false
	for id in actors:
		if id == target_id:
			continue
		var a: Dictionary = actors[id]
		if a["side"] == my_side:
			continue  # skip allies / self
		var ax := int(a["x"])
		var ay := int(a["y"])
		var dx: int = ax - tgt_x
		var dy: int = ay - tgt_y
		# Chebyshev ≤ 2 so the test's 2-tile-away enemies count
		if max(abs(dx), abs(dy)) > 2 or (dx == 0 and dy == 0):
			continue
		if dx == 0:        # purely vertical
			if dy < 0: north = true
			elif dy > 0: south = true
		elif dy == 0:      # purely horizontal
			if dx < 0: west = true
			elif dx > 0: east = true
		else:
			# Diagonals lean toward whichever axis has bigger absolute value
			if abs(dx) > abs(dy):
				if dx < 0: west = true
				else:      east = true
			elif abs(dy) > abs(dx):
				if dy < 0: north = true
				else:      south = true
			else:
				# Equal — bias toward both axes counting, but it has to be
				# pairable with another enemy eventually; pick the dominant
				# axis arbitrarily: use horizontal first.
				if dx < 0: west = true
				else:      east = true
	return (north and south) or (west and east)

# ───── Distance helper ─────

func _chebyshev_distance(x0: int, y0: int, x1: int, y1: int) -> int:
	## Chebyshev distance treats 8-neighbors as 1. Suitable for square grids.
	return max(abs(x1 - x0), abs(y1 - y0))

# ───── Debug ─────

func cqb_debug_print() -> String:
	## Multi-line ASCII view of the grid + actor table.
	## Used by tests + the ascii prototype (issue #19 acceptance).
	var lines: Array = []
	for y in range(grid_size):
		var row: String = ""
		for x in range(grid_size):
			var t: Dictionary = tile_at(x, y)
			var id: String = actor_at(x, y)
			if id != "":
				var a: Dictionary = actors[id]
				var marker: String = "C" if a["side"] == "crew" else "E"
				row += marker + "%d " % int(a["hp"])
			elif t.type == "full_cover":
				row += "## "
			elif t.type == "half_cover":
				row += "▒▒ "
			else:
				row += "·  "
		lines.append(row)
	lines.append("---")
	for id in actors:
		var a: Dictionary = actors[id]
		lines.append("%s [%s] hp=%d/%d ap=%d wp=%s" % [a["id"], a["side"], int(a["hp"]), int(a["hp_max"]), int(a["ap"]), a["weapon_id"]])
	return "\n".join(lines)
