extends Node
## cqb_ai.gd — Phase 3e v0 alien AI.
##
## Single-aggro, LOS-aware, step-toward pathfinding.
## No behaviors (guard/coward) until Phase 4.

class_name CqbAI

## CqbAction is a Dictionary literal:
## {
##   "kind": "attack" | "move" | "wait",
##   "actor": enemy_id,
##   "target_id": String,      # for attack; "" otherwise
##   "step_to": Vector2i       # for move; (0,0) otherwise
## }

static func decide_action(enemy_id: String, grid: CqbGrid, fold_mod: int = 0) -> Dictionary:
	## fold_mod is accepted for future suspicion-aware AI but not used in v0.
	if not grid.actors.has(enemy_id):
		return _wait(enemy_id)
	var target_id: String = _pick_nearest_crew(enemy_id, grid)
	if target_id == "":
		return _wait(enemy_id)
	var weapon_id: String = str(grid.actors[enemy_id]["weapon_id"])
	var weapon_range: int = _weapon_range(weapon_id)
	var dist: int = _chebyshev_distance(enemy_id, target_id, grid)
	# In range + LOS -> attack if we have AP.
	if dist <= weapon_range and grid.line_of_sight(enemy_id, target_id):
		if grid.ap_remaining(enemy_id) >= 1:
			return _attack(enemy_id, target_id)
	# Otherwise try to close distance.
	if grid.ap_remaining(enemy_id) >= 1:
		var step_to: Vector2i = grid.step_toward(enemy_id, target_id)
		if step_to != Vector2i.ZERO:
			return _move(enemy_id, step_to)
	return _wait(enemy_id)

static func _pick_nearest_crew(enemy_id: String, grid: CqbGrid) -> String:
	var src: Dictionary = grid.actors[enemy_id]
	var src_x: int = int(src["x"])
	var src_y: int = int(src["y"])
	var my_side: String = src["side"]
	var best_id: String = ""
	var best_dist: int = 9999
	for id in grid.actors:
		if id == enemy_id:
			continue
		var a: Dictionary = grid.actors[id]
		if a["side"] == my_side:
			continue
		if not grid.is_alive(id):
			continue
		var ax: int = int(a["x"])
		var ay: int = int(a["y"])
		var dx: int = ax - src_x
		var dy: int = ay - src_y
		var d: int = max(abs(dx), abs(dy))
		if d < best_dist:
			best_dist = d
			best_id = id
	return best_id

static func _weapon_range(weapon_id: String) -> int:
	if CqbGrid.WEAPON_TABLE.has(weapon_id):
		return int(CqbGrid.WEAPON_TABLE[weapon_id]["range"])
	return 1

static func _chebyshev_distance(enemy_id: String, target_id: String, grid: CqbGrid) -> int:
	var a: Dictionary = grid.actors[enemy_id]
	var b: Dictionary = grid.actors[target_id]
	var ax: int = int(a["x"])
	var ay: int = int(a["y"])
	var bx: int = int(b["x"])
	var by: int = int(b["y"])
	return max(abs(ax - bx), abs(ay - by))

static func _attack(enemy_id: String, target_id: String) -> Dictionary:
	return {
		"kind": "attack",
		"actor": enemy_id,
		"target_id": target_id,
		"step_to": Vector2i.ZERO,
	}

static func _move(enemy_id: String, step_to: Vector2i) -> Dictionary:
	return {
		"kind": "move",
		"actor": enemy_id,
		"target_id": "",
		"step_to": step_to,
	}

static func _wait(enemy_id: String) -> Dictionary:
	return {
		"kind": "wait",
		"actor": enemy_id,
		"target_id": "",
		"step_to": Vector2i.ZERO,
	}
