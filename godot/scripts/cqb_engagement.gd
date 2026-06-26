extends RefCounted
## CqbEngagement — runs a full CQB engagement to completion.
##
## Takes crew actor data + alien archetype data, creates a grid, runs
## a turn loop (crew phase → alien phase) until one side is eliminated
## or a retreat condition is met.
##
## API:
##   run(crew_data, alien_data) -> Dictionary
##     Returns { outcome, casualties, turn_count, kill_count }
##
## crew_data: Array[Dictionary] with keys:
##   id, weapon_id (or defaults used), hp_max (or 10 default)
##
## alien_data: Array[Dictionary] with keys:
##   id, weapon_id, hp_max, display_name (optional)
class_name CqbEngagement

const GRID_SIZE := 6

## Run a full CQB engagement to completion.
## Returns { outcome: String, casualties: Array, turn_count: int }
##
## outcome is one of: "won", "lost", "fled", "casualty"
##   "won"  — all aliens eliminated, at least one crew alive
##   "lost" — all crew eliminated
##   "fled" — crew retreated (future — not yet wired)
##   "casualty" — at least one crew died but engagement still won
static func run(crew_data: Array, alien_data: Array) -> Dictionary:
	var grid: CqbGrid = CqbGrid.new(GRID_SIZE)

	# Place actors: crew on left column, aliens on right column
	_place_crew(grid, crew_data)
	_place_aliens(grid, alien_data)

	var turn_count: int = 0
	var max_turns: int = 20  # safety limit

	while turn_count < max_turns:
		turn_count += 1
		grid.reset_ap()

		# === Crew phase: each living crew member acts ===
		var crew_ids: Array = _living_crew_ids(grid)
		for cid in crew_ids:
			_crew_auto_action(grid, cid)

		# === Check victory after crew phase ===
		if _count_alive_of_side(grid, "alien") == 0:
			var cas: Array = _crew_casualties(grid, crew_data)
			var outcome: String = "won" if cas.is_empty() else "casualty"
			return _result(outcome, cas, turn_count, _count_alien_kills(grid))

		# === Alien phase: CqbAI drives each alien ===
		var alien_ids: Array = _living_alien_ids(grid)
		for aid in alien_ids:
			var action: Dictionary = CqbAI.decide_action(aid, grid)
			_execute_action(grid, action)

		# === Check defeat after alien phase ===
		if _count_alive_of_side(grid, "crew") == 0:
			var cas: Array = _crew_casualties(grid, crew_data)
			return _result("lost", cas, turn_count, _count_alien_kills(grid))

	# Timed out — treat as "fled"
	var cas: Array = _crew_casualties(grid, crew_data)
	return _result("fled", cas, turn_count, _count_alien_kills(grid))


# ─── Placement ────────────────────────────────────────────────────

static func _place_crew(grid: CqbGrid, crew_data: Array) -> void:
	var y_step: int = max(1, (GRID_SIZE - 1) / max(1, crew_data.size()))
	for i in range(crew_data.size()):
		var cd: Dictionary = crew_data[i] if crew_data[i] is Dictionary else {}
		var actor_id: String = str(cd.get("id", "crew_%d" % i))
		var hp: int = int(cd.get("hp_max", 10))
		var weapon: String = str(cd.get("weapon_id", "light_pistol"))
		var px: int = 0
		var py: int = min(i * y_step, GRID_SIZE - 1)
		grid.place_actor(actor_id, px, py, "crew", hp, weapon)

static func _place_aliens(grid: CqbGrid, alien_data: Array) -> void:
	var count: int = min(alien_data.size(), GRID_SIZE - 1)
	var y_step: int = max(1, (GRID_SIZE - 1) / max(1, count))
	for i in range(count):
		var ad: Dictionary = alien_data[i] if alien_data[i] is Dictionary else {}
		var actor_id: String = str(ad.get("id", "alien_%d" % i))
		var hp: int = int(ad.get("hp_max", 6))
		var weapon: String = str(ad.get("weapon_id", "claw"))
		var px: int = GRID_SIZE - 1
		var py: int = min(i * y_step, GRID_SIZE - 1)
		grid.place_actor(actor_id, px, py, "alien", hp, weapon)


# ─── Crew auto-pilot ──────────────────────────────────────────────

static func _crew_auto_action(grid: CqbGrid, crew_id: String) -> void:
	if grid.ap_remaining(crew_id) < 1:
		return
	var target: String = _nearest_alien(grid, crew_id)
	if target == "":
		return
	var weapon_id: String = str(grid.actors[crew_id].get("weapon_id", "light_pistol"))
	var range: int = _weapon_range(weapon_id)
	var dist: int = _chebyshev_dist(grid, crew_id, target)
	if dist <= range and grid.line_of_sight(crew_id, target):
		# Attack if in range + LOS
		grid.attack(crew_id, target, 0)
	else:
		# Step toward
		var step: Vector2i = grid.step_toward(crew_id, target)
		if step != Vector2i.ZERO and grid.ap_remaining(crew_id) >= 1:
			# step_toward already consumed AP via move()
			pass  # fall through — try to use remaining AP
		# If still has AP after moving, attack if now in range
		if grid.ap_remaining(crew_id) >= 1 and grid.is_alive(crew_id):
			var target2: String = _nearest_alien(grid, crew_id)
			if target2 != "":
				var dist2: int = _chebyshev_dist(grid, crew_id, target2)
				if dist2 <= _weapon_range(str(grid.actors[crew_id].get("weapon_id", "light_pistol"))) \
						and grid.line_of_sight(crew_id, target2):
					grid.attack(crew_id, target2, 0)


# ─── AI action execution ──────────────────────────────────────────

static func _execute_action(grid: CqbGrid, action: Dictionary) -> void:
	var kind: String = str(action.get("kind", "wait"))
	var actor_id: String = str(action.get("actor", ""))
	match kind:
		"attack":
			var target: String = str(action.get("target_id", ""))
			if target != "" and grid.actors.has(actor_id) and grid.actors.has(target):
				grid.attack(actor_id, target, 0)
		"move":
			var step: Vector2i = action.get("step_to", Vector2i.ZERO)
			if step != Vector2i.ZERO:
				grid.move(actor_id, step.x, step.y)
		"wait":
			pass  # no-op


# ─── Query helpers ────────────────────────────────────────────────

static func _living_crew_ids(grid: CqbGrid) -> Array:
	var out: Array = []
	for id in grid.actors:
		if grid.actors[id].get("side") == "crew" and grid.is_alive(id):
			out.append(id)
	return out

static func _living_alien_ids(grid: CqbGrid) -> Array:
	var out: Array = []
	for id in grid.actors:
		if grid.actors[id].get("side") == "alien" and grid.is_alive(id):
			out.append(id)
	return out

static func _count_alive_of_side(grid: CqbGrid, side: String) -> int:
	var n: int = 0
	for id in grid.actors:
		if grid.actors[id]["side"] == side and int(grid.actors[id]["hp"]) > 0:
			n += 1
	return n

static func _nearest_alien(grid: CqbGrid, actor_id: String) -> String:
	var a: Dictionary = grid.actors[actor_id]
	var ax: int = int(a["x"])
	var ay: int = int(a["y"])
	var best_id: String = ""
	var best_dist: int = 9999
	for id in grid.actors:
		if id == actor_id:
			continue
		var other: Dictionary = grid.actors[id]
		if other["side"] != "alien":
			continue
		if int(other["hp"]) <= 0:
			continue
		var d: int = max(abs(int(other["x"]) - ax), abs(int(other["y"]) - ay))
		if d < best_dist:
			best_dist = d
			best_id = id
	return best_id

static func _count_alien_kills(grid: CqbGrid) -> int:
	var n: int = 0
	for id in grid.actors:
		if grid.actors[id]["side"] == "alien" and int(grid.actors[id]["hp"]) == 0:
			n += 1
	return n

static func _crew_casualties(grid: CqbGrid, crew_data: Array) -> Array:
	var out: Array = []
	for cd in crew_data:
		var cid: String = str(cd.get("id", ""))
		if cid == "":
			continue
		if grid.actors.has(cid) and int(grid.actors[cid]["hp"]) == 0:
			out.append({
				"actor_id": cid,
				"faction": "crew",
			})
	return out

static func _chebyshev_dist(grid: CqbGrid, a_id: String, b_id: String) -> int:
	var a: Dictionary = grid.actors[a_id]
	var b: Dictionary = grid.actors[b_id]
	return max(abs(int(a["x"]) - int(b["x"])), abs(int(a["y"]) - int(b["y"])))

static func _weapon_range(weapon_id: String) -> int:
	if CqbGrid.WEAPON_TABLE.has(weapon_id):
		return int(CqbGrid.WEAPON_TABLE[weapon_id]["range"])
	return 1

static func _result(outcome: String, casualties: Array, turn_count: int, kills: int) -> Dictionary:
	return {
		"outcome": outcome,
		"casualties": casualties,
		"turn_count": turn_count,
		"kill_count": kills,
	}
