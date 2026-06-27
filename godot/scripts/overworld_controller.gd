extends Node
## OverworldController — moves 3-5 of the Day-1 demo loop.
##
## Attached to overworld.tscn. Owns the hex display, transit,
## encounter display, and end-of-run flow.
class_name OverworldController

@onready var _hex_label: RichTextLabel    = $HexLabel
@onready var _encounter_label: RichTextLabel = $EncounterLabel
@onready var _status_label: RichTextLabel = $StatusLabel
@onready var _station_dropdown: OptionButton = $StationDropdown
@onready var _transit_btn: Button         = $TransitButton
@onready var _end_run_btn: Button         = $EndRunButton
@onready var _proceed_btn: Button         = $ProceedButton
@onready var _choice_btns: Array[Button] = [$Choice1Button, $Choice2Button, $Choice3Button]

var ship: ShipState = null
var stations: Array = []
var captain: Dictionary = {}
var crew: Array = []
var _beat_manifest: Dictionary = {}
var _pending_choices: Array = []

# ── Beat-file cache ──────────────────────────────────────────────
var _beat_cache: Dictionary = {}
var _last_beat_id: String = ""

func _ready() -> void:
	captain = DemoSession.captain.duplicate(true)
	crew = DemoSession.crew.duplicate(true)
	if captain.is_empty():
		_status_label.text = "[b]No captain data.[/b] Go back to briefing."
		_end_run_btn.disabled = false
		_transit_btn.disabled = true
		return
	stations = Cartography.load_stations()
	ship = ShipState.new_default(
		captain.get("name", "Captain"),
		captain.get("genship_id", "NAC"), 0, 0 )
	DemoSession.ship = ship
	_populate_station_dropdown()
	_refresh_view()
	_transit_btn.disabled = false
	_end_run_btn.disabled = true
	_proceed_btn.hide()
	for i in range(3):
		_choice_btns[i].pressed.connect(_on_choice_pressed.bind(i))
		_choice_btns[i].hide()

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
	var msg := "[b]Belt Map — Sector View[/b]\n"
	msg += "Position: (%d, %d)\n" % [ship.current_q, ship.current_r]
	msg += "Fuel: %d / 100\n" % ship.fuel
	msg += "Hull: %d / 100\n" % ship.hull
	msg += "Time: %d days\n" % ship.time_elapsed
	_hex_label.text = msg
	_render_debug_hex()

func _render_debug_hex() -> void:
	if ship == null: return
	var lines: Array = []
	var radius: int = 3
	for r in range(-radius, radius + 1):
		var row: String = "  ".repeat(abs(r)) if r != 0 else ""
		for q in range(-radius, radius + 1):
			var d: int = Hex.distance(Vector2i(ship.current_q + q, ship.current_r + r), Vector2i(ship.current_q, ship.current_r))
			if d > radius: row += "  .  "; continue
			if q == 0 and r == 0: row += "[ X ] "
			else:
				var is_station := false
				var sid: String = ""
				for s in stations:
					if int(s.get("q",-999)) == ship.current_q+q and int(s.get("r",-999)) == ship.current_r+r:
						is_station = true; sid = str(s.get("id","")).substr(-2,2); break
				if is_station: row += "[%s] " % sid
				else: row += "  .  "
		lines.append(row)
	_hex_label.text += "\n[code]" + "\n".join(lines) + "[/code]"

func _on_transit_pressed() -> void:
	if ship == null or stations.is_empty(): return
	var idx: int = _station_dropdown.selected
	if idx < 0 or idx >= stations.size():
		_status_label.text = "[color=red]Pick a destination.[/color]"; return
	var target: Dictionary = stations[idx]
	var result: Dictionary = Travel.transit(ship, int(target.get("q",0)), int(target.get("r",0)), stations)
	Travel.clear_registry()
	if not result.get("ok", false):
		_status_label.text = "[color=red]Transit failed: %s[/color]" % result.get("reason","unknown"); return
	_refresh_view()
	var rolled: Variant = result.get("encounter_rolled", null)
	if rolled != null:
		if rolled is Dictionary:
			var beat_id: String = rolled.get("beat_id", "")
			if beat_id != "" and _load_encounter_beat(beat_id):
				return
			_fallback_encounter_display(rolled)
			_transit_btn.disabled = true
		else:
			# String fallback (_DEFAULT_ENCOUNTER_BEAT) = routine arrival, keep transit active
			_fallback_encounter_display(rolled)
			_transit_btn.disabled = false
	else:
		# Routine station arrival — show station arrival beat if available
		var sid: String = str(target.get("id", ""))
		if sid != "" and _load_station_arrival_beat(sid):
			return
		_encounter_label.text = "[b]Arrived.[/b] No encounter."
		_end_run_btn.disabled = false

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

	# Check if the CQB flow returned a rich beat with prose + choices
	var beat_result: Dictionary = cqb.get("beat_result", {})
	if beat_result.has("text") and str(beat_result.get("text", "")) != "":
		_show_beat(beat_result)
		return

	# Fallback: hardcoded outcome labels
	var outcome: String = cqb.get("outcome", "unknown")
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
	var LW: GDScript = load("res://scripts/ledger_writer.gd"); var lw: Node = LW.new(); add_child(lw)
	var n: int = lw.finalise_run({"outcome":"ledger-closed","discoveries_caught":["demo_run"]}, captain, crew, ["demo_run"])
	var total: int = int(Persist.get_state().get("run_counts",{}).get("started",0))
	_status_label.text = "[b]Run complete.[/b] Captain #%d\nCaptains so far: %d\nReturning..." % [n, total]
	_end_run_btn.disabled = true; _transit_btn.disabled = true
	DemoSession.reset()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/run_start.tscn")

# ── Shared beat display ──────────────────────────────────────────

## Display a beat dict with prose text + up to 3 choice buttons.
## beat_dict must have `text` (prose string) and optionally `choices` (Array).
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

# ── Choice button clicked ────────────────────────────────────────
func _on_choice_pressed(index: int) -> void:
	if index < 0 or index >= _pending_choices.size():
		return
	var picked: Dictionary = _pending_choices[index]
	for b in _choice_btns:
		b.hide()

	# Apply delta to Persist
	if picked.has("delta") and not picked["delta"].is_empty():
		Persist.patch(picked["delta"])
		Persist.save()

	var next_beat_id: String = picked.get("next_beat", picked.get("to", ""))
	_pending_choices = []

	# If the choice chains to a known beat in a loaded manifest, advance.
	if next_beat_id != "" and next_beat_id != "run_end_summary" and _load_manifest_beat(next_beat_id):
		return  # multi-turn encounter — next beat now showing

	# Terminal choice — return to overworld
	_transit_btn.disabled = false
	var choice_text: String = picked.get("text", picked.get("label", "Chosen"))
	_status_label.text = "[color=green]%s[/color]" % choice_text
	_end_run_btn.disabled = false

# ── Beat-file loaders ────────────────────────────────────────────

## Load a beat file relative to repo root and return its data dict.
## Caches by path to avoid re-parsing.
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

## Load and display an encounter beat from encounter-pool-beats.json.
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

	# Build a display dict in BeatRunner-compatible shape
	var display: Dictionary = {
		"text": beat.get("prose", ""),
		"choices": beat.get("choices", []),
		"speaker": "narrator",
	}
	_show_beat(display)
	return true

## Load and display a station arrival beat from station_arrival_beats.json.
## Station IDs like STATION_01 map to beat keys like station_arrival_KASHNER_01.
func _load_station_arrival_beat(station_id: String) -> bool:
	var data: Dictionary = _load_beat_file("/../narrative/beats/station_arrival_beats.json")
	if data.is_empty() or not data.has("beats"):
		return false
	var beats: Dictionary = data["beats"]
	# Try direct station-beat match
	var beat_key: String = ""
	for key in beats.keys():
		if key.to_upper().ends_with(station_id.replace("STATION_", "").lstrip("0")):
			beat_key = key
			break
	if beat_key == "":
		return false
	var beat: Dictionary = beats[beat_key]
	if beat.is_empty():
		return false
	var display: Dictionary = {
		"text": beat.get("text", ""),
		"choices": beat.get("choices", []),
		"speaker": beat.get("speaker", "narrator"),
	}
	_show_beat(display)
	return true

## Load a beat by ID from the currently cached manifest (used for multi-turn chains).
func _load_manifest_beat(beat_id: String) -> bool:
	# Check if we already have encounter-pool-beats.json cached — it's the most
	# likely source for chain beats not using the run_end_summary terminal.
	var data: Dictionary = _load_beat_file("/../narrative/beats/encounter-pool-beats.json")
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
