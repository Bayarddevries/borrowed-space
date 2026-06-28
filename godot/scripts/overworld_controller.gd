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
@onready var _mission_btn: Button = $MissionButton

var ship: ShipState = null
var stations: Array = []
var captain: Dictionary = {}
var crew: Array = []
var _pending_choices: Array = []

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
			DemoSession.encounter_log.append({"type": "arrival", "name": "routine", "outcome": "docked"})
	else:
		# Routine station arrival — show station arrival beat if available,
		# using visit count to pick the right variant (_01, _11, or _12)
		var sid: String = str(target.get("id", ""))
		if sid != "":
			_track_visit(sid)
			if _load_station_arrival_beat(sid):
				return
		_encounter_label.text = "[b]Arrived.[/b] No encounter."
		_end_run_btn.disabled = false
		_mission_btn.show()

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

	# Build run summary
	var cap_name: String = captain.get("name", "Captain")
	var genship: String = captain.get("genship_id", "?")
	var origin_label: String = captain.get("origin", {}).get("genship_label", "?")
	var days: int = ship.time_elapsed if ship != null else 0
	var fuel_used: int = ship.fuel_total_consumed if ship != null else 0

	var summary: String = "[b]Run Complete[/b]\n\n"
	summary += "[b]Captain:[/b] %s (%s — %s)\n" % [cap_name, genship, origin_label]
	summary += "[b]Duration:[/b] %d days\n" % days
	summary += "[b]Fuel consumed:[/b] %d units\n" % fuel_used

	# Crew roster
	summary += "\n[b]Crew:[/b]\n"
	if crew.is_empty():
		summary += "  (none)\n"
	else:
		for c in crew:
			var cname: String = c.get("name", c.get("crew_name", "?"))
			var arch: String = c.get("archetype_id", "?")
			summary += "  • %s (%s)\n" % [cname, arch]

	# Encounter log
	if not DemoSession.encounter_log.is_empty():
		summary += "\n[b]Encounters:[/b]\n"
		for e in DemoSession.encounter_log:
			summary += "  • %s — %s\n" % [e.get("type", "?"), e.get("name", e.get("outcome", "?"))]

	# Update ship fuel display from any deltas applied during run
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

	# Write to Persist
	var LW: GDScript = load("res://scripts/ledger_writer.gd"); var lw: Node = LW.new(); add_child(lw)
	var n: int = lw.finalise_run({"outcome":"ledger-closed","discoveries_caught":["demo_run"]}, captain, crew, ["demo_run"])

	# Return to briefing after a pause
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

## Convert a delta dict to a human-readable string like "-5 fuel, +1 suspicion"
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

	# Terminal choice — show result and return to overworld
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

	# Show offers in the encounter label
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

## Load the correct station arrival beat based on visit count.
## First visit: _01/_02/..._10 suffix. Second: _11 suffix. Third+: _12 suffix.
func _load_station_arrival_beat(station_id: String) -> bool:
	var data: Dictionary = _load_beat_file("/../narrative/beats/station_arrival_beats.json")
	if data.is_empty() or not data.has("beats"):
		return false
	var beats: Dictionary = data["beats"]

	# First, find the base beat (the _01 variant for this station)
	var num_part: String = station_id.replace("STATION_", "")
	var base_key: String = ""
	for key in beats.keys():
		if key.to_upper().ends_with("_" + num_part):
			base_key = key
			break
	if base_key == "":
		return false

	# Extract the station name from the base key (e.g. "KASHNER" from "station_arrival_KASHNER_01")
	var prefix := "station_arrival_"
	var name_part: String = base_key.replace(prefix, "")
	# Strip the _NN suffix to get just the name
	var last_underscore: int = name_part.rfind("_")
	if last_underscore < 0:
		return false
	var station_name: String = name_part.left(last_underscore)

	# Determine visit variant suffix
	var visit_suffix: String = _visit_suffix(station_id)
	var visit_key: String = prefix + station_name + visit_suffix

	# Try the visit-specific beat; fall back to the base beat
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
