extends Node
## OverworldController — moves 3-5 of the Day-1 demo loop.
##
## Attached to overworld.tscn. Owns the visual hex map, transit,
## encounter display, and end-of-run flow.
class_name OverworldController

@onready var _hex_label: RichTextLabel         = $HexLabel
@onready var _encounter_label: RichTextLabel    = $EncounterLabel
@onready var _status_label: RichTextLabel       = $StatusLabel
@onready var _station_dropdown: OptionButton    = $StationDropdown
@onready var _transit_btn: Button               = $TransitButton
@onready var _end_run_btn: Button               = $EndRunButton
@onready var _proceed_btn: Button               = $ProceedButton
@onready var _choice_btns: Array[Button]        = [$Choice1Button, $Choice2Button, $Choice3Button]
@onready var _mission_btn: Button               = $MissionButton
@onready var _hex_map = $MapContainer/HexMap
@onready var _camera: Camera2D = $Camera2D
@onready var _stat_panel = $StatPanel

var ship: ShipState = null
var stations: Array = []
var captain: Dictionary = {}
var crew: Array = []
var _pending_choices: Array = []
var _cartography_data: Dictionary = {}

# NPC state
var _npc_rogues: Dictionary = {}
var _npc_portraits: Dictionary = {}
var _dialogue_panel = null

# Camera drag state
var _dragging: bool = false
var _drag_start_mouse: Vector2 = Vector2.ZERO
var _drag_start_cam: Vector2 = Vector2.ZERO

# ── Beat-file cache ──────────────────────────────────────────────
var _beat_cache: Dictionary = {}

func _ready() -> void:
	captain = DemoSession.captain.duplicate(true)
	crew = DemoSession.crew.duplicate(true)
	if captain.is_empty():
		_status_label.text = "[b]No captain data.[/b] Go back to briefing."
		_end_run_btn.disabled = false
		_transit_btn.disabled = true
		return

	# Load cartography + stations
	_cartography_data = Cartography.load_map()
	stations = Cartography.load_stations()

	# Build visual hex map
	ship = ShipState.new_default(
		captain.get("name", "Captain"),
		captain.get("genship_id", "NAC"), 0, 0)
	DemoSession.ship = ship
	_hex_map.build_map(_cartography_data, stations, ship.current_q, ship.current_r)

	# Connect hex map signals
	_hex_map.station_clicked.connect(_on_station_clicked)
	_hex_map.travel_finished.connect(_on_travel_finished)

	# Load NPC rogues-gallery
	var rg_path: String = ProjectSettings.globalize_path("res://") + "/../narrative/data/npc-rogues-gallery.json"
	if FileAccess.file_exists(rg_path):
		var f := FileAccess.open(rg_path, FileAccess.READ)
		if f != null:
			var parsed = JSON.parse_string(f.get_as_text())
			if parsed is Dictionary:
				_npc_rogues = parsed.get("npcs", {})
				var pm: Dictionary = parsed.get("portrait_map", {})
				for npc_id: String in pm.keys():
					var tex_path: String = "res://assets/sprites/" + pm[npc_id]
					var tex: Texture2D = load(tex_path)
					if tex != null:
						_npc_portraits[npc_id] = tex

	# Init dialogue panel (hidden until first dialogue)
	_dialogue_panel = null

	_populate_station_dropdown()
	_refresh_view()
	_transit_btn.disabled = false
	_end_run_btn.disabled = true
	_proceed_btn.hide()
	for i in range(3):
		if _choice_btns[i] != null:
			_choice_btns[i].pressed.connect(_on_choice_pressed.bind(i))
		if _choice_btns[i] != null:
			_choice_btns[i].hide()
	_mission_btn.hide()


func _populate_station_dropdown() -> void:
	_station_dropdown.clear()
	for s in stations:
		var sid: String = str(s.get("id", "???"))
		var q: int = int(s.get("q", 0))
		var r: int = int(s.get("r", 0))
		var dist: int = Hex.distance(Vector2i(ship.current_q, ship.current_r), Vector2i(q, r))
		var faction: String = str(s.get("faction_id", "?"))
		_station_dropdown.add_item("%s (%d,%d) — %d ly — %s" % [sid, q, r, dist, faction])


func _refresh_view() -> void:
	if ship == null: return
	# Update visual stat panel
	_stat_panel.update(ship.to_dict(), crew.size())


# ── Station clicked on hex map ──────────────────────────────────

func _on_station_clicked(station: Dictionary) -> void:
	if _hex_map.is_travel_animating():
		return
	if ship == null: return

	var sq: int = int(station.get("q", 0))
	var sr: int = int(station.get("r", 0))
	_begin_transit_to(sq, sr, station)


# ── Transit (from dropdown or hex-map click) ────────────────────

func _on_transit_pressed() -> void:
	if _hex_map.is_travel_animating():
		return
	if ship == null or stations.is_empty(): return
	var idx: int = _station_dropdown.selected
	if idx < 0 or idx >= stations.size():
		_status_label.text = "[color=red]Pick a destination.[/color]"; return
	var target: Dictionary = stations[idx]
	var sq: int = int(target.get("q", 0))
	var sr: int = int(target.get("r", 0))
	_begin_transit_to(sq, sr, target)


func _begin_transit_to(tq: int, tr: int, target: Dictionary) -> void:
	var dist: int = Hex.distance(Vector2i(ship.current_q, ship.current_r), Vector2i(tq, tr))
	if dist < 1:
		_status_label.text = "[color=yellow]Already at this station.[/color]"
		return

	# Check fuel
	var fuel_cost: float = Travel.fuel_cost_for_distance(dist)
	if ship.fuel < fuel_cost:
		_status_label.text = "[color=red]Not enough fuel! (%d needed)[/color]" % fuel_cost
		return

	# Pathfind
	var path: Array[Vector2i] = _hex_map.pathfind(ship.current_q, ship.current_r, tq, tr)
	if path.size() < 2:
		_status_label.text = "[color=red]No path found.[/color]"
		return

	_status_label.text = "[color=yellow]Traveling to %s...[/color]" % target.get("id", "?")

	# Animate ship along path, rolling encounters per hop
	_hex_map.animate_travel(path, _per_hop_encounter)

	# Apply fuel cost immediately (the move is committed)
	Travel.consume_fuel(ship, fuel_cost)
	_refresh_view()


## Called per hop during hex map travel animation.
## Returns true if the encounter consumed the turn (stop further travel).
func _per_hop_encounter(q: int, r: int) -> bool:
	ship.current_q = q
	ship.current_r = r
	ship.time_elapsed += 1
	_refresh_view()

	# Roll encounter for this hex
	var hex_kind: String = _get_hex_kind(q, r)
	var result: Variant = EncounterPool.roll(ship.to_dict(), hex_kind, stations)

	if result.is_empty():
		# No encounter this hop
		_status_label.text = "[color=dim]Hop to (%d, %d)... clear.[/color]" % [q, r]
		return false

	# Check for dialogue_id (Schema C dialogue beat)
	var dialogue_id: String = str(result.get("dialogue_id", ""))
	if dialogue_id != "":
		_start_dialogue(dialogue_id)
		return true  # stop travel, dialogue consumes the turn

	# Encounters that stop travel (hostile, combat, major events)
	var stop: bool = result.get("stop_on_encounter", false)

	# Display encounter
	_fallback_encounter_display(result)
	return stop


func _get_hex_kind(q: int, r: int) -> String:
	var key: String = "%d,%d" % [q, r]
	if _cartography_data.has("hex_kinds"):
		return _cartography_data["hex_kinds"].get(key, "deep_belt")
	if _cartography_data.has("features"):
		for f in _cartography_data["features"]:
			if int(f.get("q", 0)) == q and int(f.get("r", 0)) == r:
				return f.get("kind", "deep_belt")
	return "deep_belt"


func _on_travel_finished() -> void:
	# Ship arrived at destination
	_transit_btn.disabled = false

	var sid: String = ""
	for s in stations:
		if int(s.get("q", 0)) == ship.current_q and int(s.get("r", 0)) == ship.current_r:
			sid = str(s.get("id", ""))
			break

	if sid != "":
		_track_visit(sid)
		DemoSession.current_station_id = sid
		# Transition to station hub
		get_tree().change_scene_to_file("res://scenes/station_hub.tscn")
		return

	_encounter_label.text = "[b]Arrived.[/b] Docked at station."
	_end_run_btn.disabled = false
	_mission_btn.show()
	_status_label.text = "[color=green]Docked.[/color]"


# ── Transit result display (copied from existing code) ──────────

func _track_visit(station_id: String) -> void:
	var count: int = DemoSession.visited_stations.get(station_id, 0) + 1
	DemoSession.visited_stations[station_id] = count

func _visit_suffix(station_id: String) -> String:
	var count: int = DemoSession.visited_stations.get(station_id, 0)
	if count <= 1:
		return "_" + station_id.replace("STATION_", "")
	elif count == 2:
		return "_11"
	else:
		return "_12"

func _fallback_encounter_display(rolled: Variant) -> void:
	if rolled is Dictionary:
		_encounter_label.text = "[b]Encounter — %s[/b]\n%s" % [rolled.get("category","?"), rolled.get("flavor_hook","A belt encounter unfolds.")]
		_proceed_btn.show()
		_status_label.text = "[color=yellow]Encounter — proceed?[/color]"
	else:
		_encounter_label.text = "[b]Routine arrival.[/b] No eventful encounter this trip."
		_proceed_btn.hide()
		_end_run_btn.disabled = false
		_status_label.text = "[color=green]Docked.[/color]"


func _on_proceed_pressed() -> void:
	_proceed_btn.hide()
	_transit_btn.disabled = false
	var ai_s: GDScript = load("res://scripts/ai.gd"); var ai: Node = ai_s.new(); add_child(ai)
	ai.captain = captain; ai.crew = crew
	var cqb: Dictionary = ai.step_X_meet_aliens(ship)
	var fired: bool = cqb.get("combat_fired", false)
	var outcome: String = cqb.get("outcome", "unknown")

	var beat_result: Dictionary = cqb.get("beat_result", {})
	if beat_result.has("text") and str(beat_result.get("text", "")) != "":
		_show_beat(beat_result)
		DemoSession.encounter_log.append({"type": "combat", "name": outcome, "outcome": outcome})
		return
	var outcome_labels := {"pass-clean": "You pass through cleanly.", "pass-rough": "You squeeze through — someone noticed.", "fail-soft": "CQB combat breaks out.", "fail-hard": "Detained. No combat this run.", "won": "Combat won. Crew battered but alive.", "lost": "Combat lost. The aliens take the field.", "fled": "You retreat under fire.", "casualty": "A crew member falls."}
	if fired:
		var cas: Array = cqb.get("casualties", [])
		var label: String = outcome_labels.get(outcome, "Combat resolved.")
		_encounter_label.text = "[b]Combat — %s[/b]\n%s\nCasualties: %d" % [outcome.to_upper(), label, cas.size()]
	else:
		_encounter_label.text = "[b]Cover Pass — %s[/b]" % outcome
	_status_label.text = "[color=green]Resolved.[/color]"
	_end_run_btn.disabled = false


func _on_end_run_pressed() -> void:
	if captain.is_empty(): return

	var cap_name: String = captain.get("name", "Captain")
	var genship: String = captain.get("genship_id", "?")
	var origin_label: String = captain.get("origin", {}).get("genship_label", "?")
	var days: int = ship.time_elapsed if ship != null else 0
	var fuel_used: int = ship.fuel_total_consumed if ship != null else 0

	var summary: String = "[b]Run Complete[/b]\n\n"
	summary += "[b]Captain:[/b] %s (%s — %s)\n" % [cap_name, genship, origin_label]
	summary += "[b]Duration:[/b] %d days\n" % days
	summary += "[b]Fuel consumed:[/b] %d units\n" % fuel_used

	summary += "\n[b]Crew:[/b]\n"
	if crew.is_empty():
		summary += "  (none)\n"
	else:
		for c in crew:
			var cname: String = c.get("name", c.get("crew_name", "?"))
			var arch: String = c.get("archetype_id", "?")
			summary += "  \u2022 %s (%s)\n" % [cname, arch]

	if not DemoSession.encounter_log.is_empty():
		summary += "\n[b]Encounters:[/b]\n"
		for e in DemoSession.encounter_log:
			summary += "  \u2022 %s \u2014 %s\n" % [e.get("type", "?"), e.get("name", e.get("outcome", "?"))]

	if ship != null:
		summary += "\n[b]Fuel remaining:[/b] %d" % ship.fuel

	summary += "\n\n[b]The ledger records another captain.[/b]"

	_encounter_label.text = summary
	_hex_label.text = ""
	_status_label.text = ""
	_mission_btn.hide()
	_end_run_btn.disabled = true
	_transit_btn.disabled = true
	_station_dropdown.hide()

	var LW: GDScript = load("res://scripts/ledger_writer.gd"); var lw: Node = LW.new(); add_child(lw)
	var n: int = lw.finalise_run({"outcome":"ledger-closed","discoveries_caught":["demo_run"]}, captain, crew, ["demo_run"])

	await get_tree().create_timer(4.0).timeout
	DemoSession.reset()
	get_tree().change_scene_to_file("res://scenes/run_start.tscn")


# ── Shared beat display ──────────────────────────────────────────

func _show_beat(beat_dict: Dictionary) -> void:
	var prose: String = str(beat_dict.get("text", ""))
	var choices: Array = beat_dict.get("choices", [])
	_pending_choices = choices
	_encounter_label.text = prose
	_proceed_btn.hide()
	for i in range(3):
		if i < choices.size():
			var label: String = choices[i].get("text", choices[i].get("label", ""))
			_choice_btns[i].text = label
			_choice_btns[i].show()
		else:
			_choice_btns[i].hide()
	_status_label.text = "[color=yellow]Make a choice.[/color]"

func _describe_delta(delta: Dictionary) -> String:
	var parts: Array = []
	if delta.has("fuel_delta"):
		var v: int = int(delta["fuel_delta"])
		parts.append("%+d fuel" % v)
	if delta.has("suspicion_delta"):
		var v: int = int(delta["suspicion_delta"])
		parts.append("%+d suspicion" % v)
	if delta.has("bond_score"):
		var v: int = int(delta["bond_score"])
		parts.append("%+d bond" % v)
	if delta.has("credit_delta"):
		var v: int = int(delta["credit_delta"])
		parts.append("%+d credits" % v)
	if delta.has("crew_xp"):
		var v: int = int(delta["crew_xp"])
		parts.append("%+d crew XP" % v)
	if delta.has("discoveries"):
		var d: Array = delta["discoveries"]
		parts.append("discovery: %s" % ", ".join(d))
	if parts.is_empty():
		return "No immediate effect."
	return "Effects: " + ", ".join(parts)


# ── Choice button clicked ────────────────────────────────────────

func _on_choice_pressed(index: int) -> void:
	if index < 0 or index >= _pending_choices.size():
		return
	var picked: Dictionary = _pending_choices[index]
	for b in _choice_btns:
		b.hide()

	if picked.has("delta") and not picked["delta"].is_empty():
		Persist.patch(picked["delta"])
		Persist.save()

	var next_beat_id: String = picked.get("next_beat", picked.get("to", ""))
	_pending_choices = []

	if next_beat_id != "" and next_beat_id != "run_end_summary" and _load_manifest_beat(next_beat_id):
		return

	_transit_btn.disabled = false
	var choice_text: String = picked.get("text", picked.get("label", "Chosen"))
	var delta_text: String = _describe_delta(picked.get("delta", {}))
	_encounter_label.text = "[b]You chose:[/b] %s\n%s\n\n[b]Result:[/b] You can now transit to another station." % [choice_text, delta_text]
	_status_label.text = "[color=green]%s[/color]" % choice_text
	_end_run_btn.disabled = false


# ── Mission board ────────────────────────────────────────────────

func _on_mission_pressed() -> void:
	var state: Dictionary = Persist.get_state()
	var ledger: Dictionary = state.get("ledger", {})
	var run_count: int = state.get("run_counts", {}).get("started", 1)
	var offers: Array = MissionBoard.generate(ship.to_dict(), ledger, run_count)

	var text := "[b]Mission Board[/b]\n\n"
	if offers.is_empty():
		text += "No missions available at this station."
		_encounter_label.text = text
		return

	for i in offers.size():
		var o: Dictionary = offers[i]
		text += "[b]%d.[/b] %s\n" % [i + 1, o.get("title", "Untitled")]
		text += "  Source: %s | Risk: %s\n" % [o.get("source", "?"), o.get("risk", "?")]
		text += "  %s\n\n" % o.get("flavor_hook", "")

	_encounter_label.text = text
	_status_label.text = "[color=yellow]Missions available.[/color]"


# ── Beat-file loaders ────────────────────────────────────────────

func _load_beat_file(relative_path: String) -> Dictionary:
	if _beat_cache.has(relative_path):
		return _beat_cache[relative_path]
	var godot_root := ProjectSettings.globalize_path("res://")
	var path := godot_root + relative_path.lstrip("/")
	if not FileAccess.file_exists(path):
		push_warning("[Overworld] beat file not found: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var raw := f.get_as_text()
	f.close()
	var data = JSON.parse_string(raw)
	if data == null or not data is Dictionary:
		return {}
	_beat_cache[relative_path] = data
	return data

func _load_encounter_beat(beat_id: String) -> bool:
	var data: Dictionary = _load_beat_file("/../narrative/beats/encounter-pool-beats.json")
	if data.is_empty() or not data.has("beats"):
		return false
	var beats: Dictionary = data["beats"]
	if not beats.has(beat_id):
		return false
	var beat: Dictionary = beats[beat_id]
	if beat.is_empty() or not beat.has("prose"):
		return false
	var display: Dictionary = {
		"text": beat.get("prose", ""),
		"choices": beat.get("choices", []),
		"speaker": "narrator",
	}
	_show_beat(display)
	return true

func _load_station_arrival_beat(station_id: String) -> bool:
	var data: Dictionary = _load_beat_file("/../narrative/beats/station_arrival_beats.json")
	if data.is_empty() or not data.has("beats"):
		return false
	var beats: Dictionary = data["beats"]
	var num_part: String = station_id.replace("STATION_", "")
	var base_key: String = ""
	for key in beats.keys():
		if key.to_upper().ends_with("_" + num_part):
			base_key = key
			break
	if base_key == "":
		return false

	var prefix := "station_arrival_"
	var name_part: String = base_key.replace(prefix, "")
	var last_underscore: int = name_part.rfind("_")
	if last_underscore < 0:
		return false
	var station_name: String = name_part.left(last_underscore)

	var visit_suffix: String = _visit_suffix(station_id)
	var visit_key: String = prefix + station_name + visit_suffix

	var beat_key: String = visit_key if beats.has(visit_key) else base_key
	var beat: Dictionary = beats[beat_key]
	if beat.is_empty():
		return false

	var display: Dictionary = {
		"text": beat.get("text", ""),
		"choices": beat.get("choices", []),
		"speaker": beat.get("speaker", "narrator"),
	}
	var visit_num: int = DemoSession.visited_stations.get(station_id, 1)
	if visit_num > 1:
		display["text"] = "[b](Visit %d)[/b]\n\n%s" % [visit_num, beat.get("text", "")]
	_show_beat(display)
	_mission_btn.show()
	return true

func _load_manifest_beat(beat_id: String) -> bool:
	var sources := [
		"/../narrative/beats/encounter-pool-beats.json",
		"/../narrative/beats/cqb-ink-beats.json",
		"/../narrative/beats/station_arrival_beats.json",
	]
	for src in sources:
		var data: Dictionary = _load_beat_file(src)
		if data.has("beats") and data["beats"].has(beat_id):
			var beat: Dictionary = data["beats"][beat_id]
			var display: Dictionary = {
				"text": beat.get("prose", beat.get("text", "")),
				"choices": beat.get("choices", []),
				"speaker": "narrator",
			}
			if str(display["text"]) != "":
				_show_beat(display)
				return true
	return false


# ── Dialogue system ──────────────────────────────────────────────

## Start a dialogue beat by ID. Loads from narrative/dialogues/.
func _start_dialogue(dialogue_id: String) -> void:
	# Lazy-init dialogue panel (load() not preload() — avoids Godot 4 sub-scene bug)
	if _dialogue_panel == null:
		var scene = load("res://scenes/dialogue_panel.tscn")
		if scene == null:
			push_error("Failed to load dialogue_panel.tscn")
			return
		_dialogue_panel = scene.instantiate()
		add_child(_dialogue_panel)
		_dialogue_panel.dialogue_ended.connect(_on_dialogue_ended)
	var dlg_path: String = ProjectSettings.globalize_path("res://") + "/../narrative/dialogues/%s.json" % dialogue_id
	if not FileAccess.file_exists(dlg_path):
		# Try encounter-pool-beats as fallback (Schema B -> Schema C converter)
		var beat_data: Dictionary = _load_beat_file("/../narrative/beats/encounter-pool-beats.json")
		if beat_data.has("beats") and beat_data["beats"].has(dialogue_id):
			var beat: Dictionary = beat_data["beats"][dialogue_id]
			_show_beat({
				"text": beat.get("prose", ""),
				"choices": beat.get("choices", []),
				"speaker": "narrator",
			})
		return

	var f := FileAccess.open(dlg_path, FileAccess.READ)
	if f == null:
		return
	var raw := f.get_as_text()
	var parsed = JSON.parse_string(raw)
	if parsed == null or not parsed is Dictionary:
		return

	var beat: Dictionary = parsed.get(dialogue_id, parsed)
	if beat.is_empty() or not beat.has("lines"):
		return

	# Build state for condition evaluation
	var dlg_state: Dictionary = {
		"captain": captain,
		"crew": crew,
		"ship": ship.to_dict() if ship != null else {},
		"suspicion": ship.suspicion if ship != null else 0,
		"fuel": ship.fuel if ship != null else 100,
		"_npcs": _npc_rogues,
		"_portraits": _npc_portraits,
	}

	# Add session state
	dlg_state["visited_stations"] = DemoSession.visited_stations.duplicate()

	# Add persist state
	if has_node("/root/Persist"):
		var pstate: Dictionary = Persist.get_state()
		dlg_state["run_counts"] = pstate.get("run_counts", {})
		dlg_state["standing"] = pstate.get("faction_standing", {})

	_dialogue_panel.start_dialogue(beat, dlg_state, _npc_portraits)


func _on_dialogue_ended(next_id: String) -> void:
	# Re-enable buttons
	_transit_btn.disabled = false
	_status_label.text = "[color=green]Dialogue complete.[/color]"

	if next_id != "":
		# Chain to next dialogue or encounter
		_start_dialogue(next_id)
	else:
		_end_run_btn.disabled = false


# ── Camera drag-to-pan ──────────────────────────────────────────

func _input(event: InputEvent) -> void:
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_camera.zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_camera.zoom = max(_camera.zoom * 0.9, Vector2(0.5, 0.5))

	# Right-click drag pan
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			_dragging = true
			_drag_start_mouse = get_viewport().get_mouse_position()
			_drag_start_cam = _camera.position
		else:
			_dragging = false

	if event is InputEventMouseMotion and _dragging:
		var delta: Vector2 = get_viewport().get_mouse_position() - _drag_start_mouse
		_camera.position = _drag_start_cam - delta * (1.0 / _camera.zoom.x)
