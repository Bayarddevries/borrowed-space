extends Node
## StationHubController — station docked hub screen.
##
## Shows a hub menu (Bar, Store, Missions, Depart) when the player
## docks at a station. Sub-screens open on top with NPC dialogue.
class_name StationHubController

@onready var _hub_menu: ColorRect        = $HubMenu
@onready var _bar_screen: ColorRect      = $BarScreen
@onready var _store_screen: ColorRect    = $StoreScreen
@onready var _station_label: Label       = $HubMenu/StationLabel
@onready var _faction_label: Label       = $HubMenu/FactionLabel
@onready var _visit_label: Label         = $HubMenu/VisitLabel
@onready var _encounter_label: RichTextLabel = $EncounterLabel
@onready var _stat_panel = $StatPanel
@onready var _dialogue_panel = $DialoguePanel

var _station_data: Dictionary = {}

func _ready() -> void:
	# Get station data from DemoSession
	var sid: String = DemoSession.current_station_id
	if sid == "":
		_encounter_label.text = "[b]Error:[/b] No station data."
		return

	# Load station from NarrativeData
	var stations: Array = Cartography.load_stations()
	for s in stations:
		if str(s.get("id", "")) == sid:
			_station_data = s
			break

	if _station_data.is_empty():
		_encounter_label.text = "[b]Error:[/b] Station '%s' not found in data." % sid
		return

	# Display station info
	var name_str: String = str(_station_data.get("name", sid))
	var faction_str: String = str(_station_data.get("faction_id", "?"))
	var visit_count: int = DemoSession.visited_stations.get(sid, 1)
	_station_label.text = name_str
	_faction_label.text = "Faction: %s" % faction_str
	_visit_label.text = "Visit #%d" % visit_count

	# Hide sub-screens by default
	_bar_screen.visible = false
	_store_screen.visible = false

	# Init dialogue panel (hidden until first dialogue)
	_dialogue_panel.visible = false
	_dialogue_panel.dialogue_ended.connect(_on_hub_dialogue_ended)

	# Update stat panel
	var ship_dict: Dictionary = DemoSession.ship.to_dict() if DemoSession.ship != null else {}
	_stat_panel.update(ship_dict, DemoSession.crew.size())


# ── Hub menu buttons ────────────────────────────────────────────

func _on_bar_pressed() -> void:
	_hub_menu.visible = false
	_bar_screen.visible = true
	# Show bartender dialogue
	_start_hub_dialogue("bartender_greeting_%s" % DemoSession.current_station_id.to_lower())


func _on_store_pressed() -> void:
	_hub_menu.visible = false
	_store_screen.visible = true
	# Show merchant dialogue
	_start_hub_dialogue("merchant_greeting_%s" % DemoSession.current_station_id.to_lower())


func _on_missions_pressed() -> void:
	# Re-use existing mission board display from overworld controller
	var state: Dictionary = Persist.get_state()
	var ledger: Dictionary = state.get("ledger", {})
	var run_count: int = state.get("run_counts", {}).get("started", 1)
	var ship_dict: Dictionary = DemoSession.ship.to_dict() if DemoSession.ship != null else {}
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
	# Return to overworld
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")


func _on_back_pressed() -> void:
	_bar_screen.visible = false
	_store_screen.visible = false
	_hub_menu.visible = true


# ── Hub dialogue ────────────────────────────────────────────────

func _start_hub_dialogue(dialogue_id: String) -> void:
	var dlg_path: String = ProjectSettings.globalize_path("res://") + "/../narrative/dialogues/%s.json" % dialogue_id
	if not FileAccess.file_exists(dlg_path):
		# Fallback: generic greeting
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

	# Build state
	var captain: Dictionary = DemoSession.captain
	var crew: Array = DemoSession.crew
	var ship_dict: Dictionary = DemoSession.ship.to_dict() if DemoSession.ship != null else {}

	var dlg_state: Dictionary = {
		"captain": captain,
		"crew": crew,
		"ship": ship_dict,
		"suspicion": ship_dict.get("suspicion", 0),
		"fuel": ship_dict.get("fuel", 100),
		"current_station": DemoSession.current_station_id,
		"visit_count": DemoSession.visited_stations.get(DemoSession.current_station_id, 1),
	}

	# Load portraits from NPC rogues-gallery
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
	else:
		# Return to sub-screen
		pass
