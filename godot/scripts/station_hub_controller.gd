extends Node
## StationHubController — station docked hub screen.
##
## Builds UI from code to avoid Godot 4's sub-scene instantiation
## issues. Shows hub menu (Bar, Store, Missions, Depart) when docked.
class_name StationHubController

var _station_data: Dictionary = {}
var _dialogue_panel = null
var _session = null
var _hub_menu: ColorRect = null
var _bar_screen: ColorRect = null
var _store_screen: ColorRect = null
var _encounter_label: RichTextLabel = null
var _station_label: Label = null

func _ready() -> void:
	_session = get_node_or_null("/root/DemoSession")
	if _session == null:
		return

	var sid: String = _session.current_station_id
	if sid == "":
		return

	var stations: Array = Cartography.load_stations()
	for s in stations:
		if str(s.get("id", "")) == sid:
			_station_data = s
			break

	if _station_data.is_empty():
		return

	var name_str: String = str(_station_data.get("name", sid))
	var faction_str: String = str(_station_data.get("faction_id", "?"))
	var visit_count: int = _session.visited_stations.get(sid, 1)

	# Build UI in code
	var bg := TextureRect.new()
	bg.texture = preload("res://assets/sprites/bg_station.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.size = Vector2(1400, 800)
	bg.position = Vector2(0, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var panel := ColorRect.new()
	panel.color = Color(0.08, 0.07, 0.10, 0.92)
	panel.size = Vector2(600, 400)
	panel.position = Vector2(400, 200)
	add_child(panel)
	_hub_menu = panel

	# Station name
	_station_label = Label.new()
	_station_label.text = name_str
	_station_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	_station_label.add_theme_font_size_override("font_size", 22)
	_station_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_station_label.position = Vector2(40, 24)
	_station_label.size = Vector2(520, 32)
	panel.add_child(_station_label)

	# Faction
	var faction_label := Label.new()
	faction_label.text = "Faction: %s" % faction_str
	faction_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	faction_label.add_theme_font_size_override("font_size", 14)
	faction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	faction_label.position = Vector2(40, 64)
	faction_label.size = Vector2(520, 20)
	panel.add_child(faction_label)

	# Visit count
	var visit_label := Label.new()
	visit_label.text = "Visit #%d" % visit_count
	visit_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	visit_label.add_theme_font_size_override("font_size", 12)
	visit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	visit_label.position = Vector2(40, 86)
	visit_label.size = Vector2(520, 20)
	panel.add_child(visit_label)

	# Buttons
	var bar_btn := Button.new()
	bar_btn.text = "Bar"
	bar_btn.position = Vector2(80, 130)
	bar_btn.size = Vector2(440, 40)
	bar_btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	bar_btn.add_theme_color_override("button_normal", Color(0.15, 0.13, 0.20))
	bar_btn.add_theme_color_override("button_hover", Color(0.22, 0.18, 0.28))
	bar_btn.pressed.connect(_on_bar_pressed)
	panel.add_child(bar_btn)

	var store_btn := Button.new()
	store_btn.text = "Store"
	store_btn.position = Vector2(80, 180)
	store_btn.size = Vector2(440, 40)
	store_btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	store_btn.add_theme_color_override("button_normal", Color(0.15, 0.13, 0.20))
	store_btn.add_theme_color_override("button_hover", Color(0.22, 0.18, 0.28))
	store_btn.pressed.connect(_on_store_pressed)
	panel.add_child(store_btn)

	var missions_btn := Button.new()
	missions_btn.text = "Missions"
	missions_btn.position = Vector2(80, 230)
	missions_btn.size = Vector2(440, 40)
	missions_btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	missions_btn.add_theme_color_override("button_normal", Color(0.15, 0.13, 0.20))
	missions_btn.add_theme_color_override("button_hover", Color(0.22, 0.18, 0.28))
	missions_btn.pressed.connect(_on_missions_pressed)
	panel.add_child(missions_btn)

	var depart_btn := Button.new()
	depart_btn.text = "Depart"
	depart_btn.position = Vector2(80, 290)
	depart_btn.size = Vector2(440, 40)
	depart_btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	depart_btn.add_theme_color_override("button_normal", Color(0.15, 0.13, 0.20))
	depart_btn.add_theme_color_override("button_hover", Color(0.22, 0.18, 0.28))
	depart_btn.pressed.connect(_on_depart_pressed)
	panel.add_child(depart_btn)

	# Encounter label for mission board output
	_encounter_label = RichTextLabel.new()
	_encounter_label.bbcode_enabled = true
	_encounter_label.size = Vector2(1336, 220)
	_encounter_label.position = Vector2(24, 320)
	_encounter_label.add_theme_color_override("default_color", Color(0.85, 0.85, 0.9))
	_encounter_label.add_theme_font_size_override("normal_font_size", 16)
	_encounter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_encounter_label)
	_encounter_label.text = ""

	# Init dialogue panel
	_dialogue_panel = null


# ── Hub menu buttons ────────────────────────────────────────────

func _on_bar_pressed() -> void:
	_encounter_label.text = "The bar is quiet. No bartender here yet."
	_start_hub_dialogue("bartender_greeting_%s" % _session.current_station_id.to_lower())


func _on_store_pressed() -> void:
	_encounter_label.text = "The store shelves are bare. No merchant here yet."
	_start_hub_dialogue("merchant_greeting_%s" % _session.current_station_id.to_lower())


func _on_missions_pressed() -> void:
	var state: Dictionary = Persist.get_state()
	var ledger: Dictionary = state.get("ledger", {})
	var run_count: int = state.get("run_counts", {}).get("started", 1)
	var ship_dict: Dictionary = _session.ship.to_dict() if _session.ship != null else {}
	var offers: Array = MissionBoard.generate(ship_dict, ledger, run_count)

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


func _on_depart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")


# ── Hub dialogue ────────────────────────────────────────────────

func _start_hub_dialogue(dialogue_id: String) -> void:
	if _dialogue_panel == null:
		var scene = load("res://scenes/dialogue_panel.tscn")
		if scene == null:
			return
		_dialogue_panel = scene.instantiate()
		add_child(_dialogue_panel)
		_dialogue_panel.dialogue_ended.connect(_on_hub_dialogue_ended)

	var dlg_path: String = ProjectSettings.globalize_path("res://") + "/../narrative/dialogues/%s.json" % dialogue_id
	if not FileAccess.file_exists(dlg_path):
		_encounter_label.text = "[b]Station NPC[/b]\n\"Welcome to %s.\"" % _station_data.get("name", "station")
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

	var captain: Dictionary = _session.captain
	var crew: Array = _session.crew
	var ship_dict: Dictionary = _session.ship.to_dict() if _session.ship != null else {}

	var dlg_state: Dictionary = {
		"captain": captain,
		"crew": crew,
		"ship": ship_dict,
		"suspicion": ship_dict.get("suspicion", 0),
		"fuel": ship_dict.get("fuel", 100),
		"current_station": _session.current_station_id,
		"visit_count": _session.visited_stations.get(_session.current_station_id, 1),
	}

	var npc_portraits: Dictionary = {}
	var rg_path: String = ProjectSettings.globalize_path("res://") + "/../narrative/data/npc-rogues-gallery.json"
	if FileAccess.file_exists(rg_path):
		var rf := FileAccess.open(rg_path, FileAccess.READ)
		if rf != null:
			var rp = JSON.parse_string(rf.get_as_text())
			if rp is Dictionary:
				var pm: Dictionary = rp.get("portrait_map", {})
				for npc_id: String in pm.keys():
					var tex: Texture2D = load("res://assets/sprites/" + pm[npc_id])
					if tex != null:
						npc_portraits[npc_id] = tex

	dlg_state["_npcs"] = {}
	dlg_state["_portraits"] = npc_portraits

	_dialogue_panel.start_dialogue(beat, dlg_state, npc_portraits)


func _on_hub_dialogue_ended(next_id: String) -> void:
	if next_id != "":
		_start_hub_dialogue(next_id)
