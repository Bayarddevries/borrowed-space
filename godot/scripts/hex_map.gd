extends Node2D
## HexMap — visual isometric hex map.
##
## Renders the asteroid belt as isometric hex tiles. Manages station pins,
## ship position, pathfinding, and hop-by-hop ship movement with
## per-hop encounter rolling.
##
## PROGRAMMATIC API (for AI test agents):
##   build_map(carto_data, stations_list, ship_start_q, ship_start_r)
##   get_ship_hex() -> Vector2i
##   is_travel_animating() -> bool
##   pathfind(from_q, from_r, to_q, to_r) -> Array[Vector2i]
##   animate_travel(path: Array[Vector2i], encounter_callback) -> void
##   get_station_at(q, r) -> Dictionary or null
##   get_visible_stations() -> Array[Dictionary]

class_name HexMap

const HEX_W := 120.0   # pixel width of a hex tile
const HEX_H := 140.0   # pixel height of a hex tile
const HEX_RADIUS := 60.0  # effective radius (half of ~width/height)

# Tint map: hex kind -> overlay Color
const KIND_TINT := {
	"deep_belt":     Color("1a1824"),
	"lane":          Color("282632"),
	"station_hex":   Color("1c2230"),
	"derelict_hex":  Color("2a1e1e"),
	"anomaly_hex":   Color("221a2e"),
}

# Hex tile textures (loaded once)
var _hex_textures: Dictionary = {}
var _station_pin_texture: Texture2D = null
var _ship_texture: Texture2D = null

# Map state
var _stations: Array = []
var _station_at: Dictionary = {}  # "q,r" -> station dict
var _ship_hex: Vector2i = Vector2i(0, 0)
var _tile_nodes: Dictionary = {}   # "q,r" -> Sprite2D
var _station_nodes: Dictionary = {} # "q,r" -> Sprite2D
var _ship_node: Sprite2D = null
var _label_nodes: Dictionary = {}   # "q,r" -> Label (station names)
var _travel_tween: Tween = null
var _building: bool = false

# Signals
signal station_clicked(station: Dictionary)
signal ship_arrived(q: int, r: int)
signal travel_hop(q: int, r: int)
signal travel_finished()

# ── Lifecycle ─────────────────────────────────────────────────────

func _ready() -> void:
	_load_textures()
	_ship_texture = load("res://assets/sprites/ship_placeholder.png")
	_station_pin_texture = load("res://assets/sprites/station_pin.png")


func _load_textures() -> void:
	var kinds := ["deep_belt", "lane", "station_hex", "derelict_hex", "anomaly_hex"]
	for k in kinds:
		var tex: Texture2D = load("res://assets/sprites/hex_%s.png" % k)
		if tex != null:
			_hex_textures[k] = tex
	# Fallback
	_hex_textures["default"] = load("res://assets/sprites/hex_tile.png")


# ── Public API ────────────────────────────────────────────────────

## Build or rebuild the entire map. Call this when the scene loads.
func build_map(carto_data: Dictionary, stations_list: Array, ship_q: int, ship_r: int) -> void:
	_building = true
	_clear_map()
	_stations = stations_list.duplicate()
	_ship_hex = Vector2i(ship_q, ship_r)

	# Build lookup
	_station_at = {}
	for s in _stations:
		var key: String = "%d,%d" % [int(s.get("q", 0)), int(s.get("r", 0))]
		_station_at[key] = s

	# Determine hex kinds from cartography
	var hex_kinds: Dictionary = {}
	if carto_data.has("hex_kinds"):
		hex_kinds = carto_data["hex_kinds"]
	elif carto_data.has("features"):
		for f in carto_data["features"]:
			var hk: String = f.get("kind", "deep_belt")
			var q: int = int(f.get("q", 0))
			var r: int = int(f.get("r", 0))
			hex_kinds["%d,%d" % [q, r]] = hk

	# Determine visible radius from current ship position
	var view_radius: int = 8  # show 8 hexes in each direction
	var ship_v: Vector2i = _ship_hex

	# Place hex tiles in visible area
	for r in range(-view_radius, view_radius + 1):
		for q in range(-view_radius, view_radius + 1):
			var hq: int = ship_v.x + q
			var hr: int = ship_v.y + r
			var key: String = "%d,%d" % [hq, hr]

			# Skip if outside belt
			if not Hex.in_belt(Vector2i(hq, hr)):
				continue

			var kind: String = hex_kinds.get(key, "deep_belt")
			_create_tile(hq, hr, kind)

	# Place station pins on top
	for s in _stations:
		var sq: int = int(s.get("q", 0))
		var sr: int = int(s.get("r", 0))
		var skey: String = "%d,%d" % [sq, sr]
		if _tile_nodes.has(skey):
			_create_station_pin(sq, sr, s)

	# Place ship
	_place_ship(ship_q, ship_r)

	_building = false


## Get the ship's current hex position.
func get_ship_hex() -> Vector2i:
	return _ship_hex


## Is the ship currently animating a travel?
func is_travel_animating() -> bool:
	return _travel_tween != null and _travel_tween.is_running()


## A* pathfind from (q1,r1) to (q2,r2). Returns array of axial Vector2i steps.
func pathfind(from_q: int, from_r: int, to_q: int, to_r: int) -> Array[Vector2i]:
	var start := Vector2i(from_q, from_r)
	var goal := Vector2i(to_q, to_r)
	if start == goal:
		return [start]

	# A* on hex grid
	var open_set: Array = [start]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}
	var key := "%d,%d"
	g_score[key % [start.x, start.y]] = 0
	f_score[key % [start.x, start.y]] = Hex.distance(start, goal)

	while open_set.size() > 0:
		# Find lowest f_score in open set
		var current: Vector2i = open_set[0]
		var cur_key: String = key % [current.x, current.y]
		var best_f: float = f_score.get(cur_key, INF)
		var best_idx: int = 0
		for i in range(1, open_set.size()):
			var nk: String = key % [open_set[i].x, open_set[i].y]
			var nf: float = f_score.get(nk, INF)
			if nf < best_f:
				best_f = nf
				current = open_set[i]
				best_idx = i
		open_set.remove_at(best_idx)
		cur_key = key % [current.x, current.y]

		if current == goal:
			# Reconstruct
			var path: Array[Vector2i] = [goal]
			var ck: String = key % [goal.x, goal.y]
			while came_from.has(ck):
				var prev: Vector2i = came_from[ck]
				path.push_front(prev)
				ck = key % [prev.x, prev.y]
			return path

		for nb in Hex.neighbors(current):
			if not Hex.in_belt(nb):
				continue
			var nb_key: String = key % [nb.x, nb.y]
			var tentative_g: float = g_score.get(cur_key, INF) + 1.0
			if tentative_g < g_score.get(nb_key, INF):
				came_from[nb_key] = current
				g_score[nb_key] = tentative_g
				f_score[nb_key] = tentative_g + Hex.distance(nb, goal)
				if not _contains(open_set, nb):
					open_set.append(nb)

	# Fallback: direct line
	return [start, goal]


## Animate the ship along a path (Array of Vector2i). Calls encounter_callback(ship_hex) per hop.
## encounter_callback should return true if the encounter consumed the turn (stop travel).
func animate_travel(path: Array[Vector2i], encounter_callback: Callable) -> void:
	if path.size() < 2:
		emit_signal("travel_finished")
		return

	if _travel_tween != null and _travel_tween.is_running():
		_travel_tween.kill()

	_travel_tween = create_tween()
	_travel_tween.set_parallel(false)
	_travel_tween.set_trans(Tween.TRANS_LINEAR)
	_travel_tween.set_ease(Tween.EASE_IN_OUT)

	# Hop through intermediate hexes (skip the start, include dest)
	for i in range(1, path.size()):
		var hop: Vector2i = path[i]
		var hop_screen: Vector2 = axial_to_screen(hop.x, hop.y)

		# Add hop callback as a tween callback
		_travel_tween.tween_callback(_on_hop_start.bind(hop, encounter_callback))
		_travel_tween.tween_property(_ship_node, "position", hop_screen, 0.4)

	_travel_tween.tween_callback(_on_travel_complete)


func get_station_at(q: int, r: int) -> Dictionary:
	var key: String = "%d,%d" % [q, r]
	return _station_at.get(key, {})


func get_visible_stations() -> Array:
	return _stations.duplicate()


# ── Coordinate conversion ─────────────────────────────────────────

## Convert axial (q,r) to isometric screen position (center of tile).
static func axial_to_screen(q: int, r: int) -> Vector2:
	var x: float = HEX_W * 0.75 * float(q)
	var odd_q: int = q % 2
	var y: float = HEX_H * 0.5 * float(2 * r + odd_q)
	return Vector2(x, y)


## Convert a screen position back to the nearest axial hex coordinate.
static func screen_to_axial(pos: Vector2) -> Vector2i:
	var px: float = pos.x
	var py: float = pos.y
	var qf: float = px / (HEX_W * 0.75)
	var qi: int = int(round(qf))
	var rf: float = (py - HEX_H * 0.5 * float(qi % 2)) / HEX_H
	return Vector2i(qi, round(rf))


# ── Private helpers ───────────────────────────────────────────────

func _clear_map() -> void:
	for node in get_children():
		node.queue_free()
	_tile_nodes.clear()
	_station_nodes.clear()
	_label_nodes.clear()
	_station_at.clear()
	_ship_node = null
	_stations.clear()


func _create_tile(q: int, r: int, kind: String) -> void:
	var key: String = "%d,%d" % [q, r]
	var tex: Texture2D = _hex_textures.get(kind, _hex_textures["default"])
	var pos: Vector2 = axial_to_screen(q, r)

	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.position = pos
	sprite.z_index = 0
	var t: Color = KIND_TINT.get(kind, Color.WHITE)
	sprite.self_modulate = t
	add_child(sprite)
	_tile_nodes[key] = sprite


func _create_station_pin(q: int, r: int, station: Dictionary) -> void:
	var key: String = "%d,%d" % [q, r]
	var pos: Vector2 = axial_to_screen(q, r)

	# Pin sprite
	var pin := Sprite2D.new()
	pin.texture = _station_pin_texture
	pin.position = Vector2(pos.x, pos.y - 20)  # float above hex
	pin.z_index = 2
	pin.name = "StationPin_%s" % station.get("id", key)
	add_child(pin)
	_station_nodes[key] = pin

	# Station name label
	var label := Label.new()
	label.text = str(station.get("id", "???"))
	label.position = Vector2(pos.x - 40, pos.y - 40)
	label.z_index = 3
	label.add_theme_color_override("font_color", Color("aac"))
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)
	_label_nodes[key] = label


func _place_ship(q: int, r: int) -> void:
	if _ship_node == null:
		_ship_node = Sprite2D.new()
		_ship_node.texture = _ship_texture
		_ship_node.z_index = 5
		add_child(_ship_node)
	_ship_node.position = axial_to_screen(q, r)
	_ship_hex = Vector2i(q, r)


func _on_hop_start(hop: Vector2i, encounter_callback: Callable) -> void:
	_ship_hex = hop
	emit_signal("travel_hop", hop.x, hop.y)

	# Fire encounter callback per hop
	if encounter_callback.is_valid():
		var consumed: bool = encounter_callback.call(hop.x, hop.y)
		if consumed:
			# Encounter consumed the turn — kill remaining tween
			if _travel_tween != null and _travel_tween.is_running():
				_travel_tween.kill()


func _on_travel_complete() -> void:
	emit_signal("travel_finished")


func _contains(arr: Array, v: Vector2i) -> bool:
	for e in arr:
		if e == v:
			return true
	return false


# ── Input handling (clickable stations) ──────────────────────────

func _input(event: InputEvent) -> void:
	if _building or is_travel_animating():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var hex_pos: Vector2i = screen_to_axial(mouse_pos)
		var key: String = "%d,%d" % [hex_pos.x, hex_pos.y]
		if _station_nodes.has(key):
			var station: Dictionary = _station_at.get(key, {})
			if not station.is_empty():
				emit_signal("station_clicked", station)
