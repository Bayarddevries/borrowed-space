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

var ship: ShipState = null
var stations: Array = []
var captain: Dictionary = {}
var crew: Array = []

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
			_encounter_label.text = "[b]Encounter — %s[/b]\n%s" % [rolled.get("category","?"), rolled.get("flavor_hook","A belt encounter unfolds.")]
		else:
			_encounter_label.text = "[b]Encounter[/b]\n%s" % str(rolled)
		_proceed_btn.show(); _transit_btn.disabled = true
		_status_label.text = "[color=yellow]Encounter — proceed?[/color]"
	else:
		_encounter_label.text = "[b]Arrived.[/b] No encounter."
		_end_run_btn.disabled = false

func _on_proceed_pressed() -> void:
	_proceed_btn.hide()
	var ai_s: GDScript = load("res://scripts/ai.gd"); var ai: Node = ai_s.new(); add_child(ai)
	ai.captain = captain; ai.crew = crew
	var cqb: Dictionary = ai.step_X_meet_aliens(ship)
	var fired: bool = cqb.get("combat_fired", false)
	var outcome: String = cqb.get("outcome", "unknown")
	var outcome_labels := {"pass-clean": "You pass through cleanly.", "pass-rough": "You squeeze through — someone noticed.", "fail-soft": "CQB combat breaks out.", "fail-hard": "Detained. No combat this run.", "won": "Combat won. Crew battered but alive.", "lost": "Combat lost. The aliens take the field.", "fled": "You retreat under fire.", "casualty": "A crew member falls."}
	if fired:
		var cas: Array = cqb.get("casualties", [])
		var label: String = outcome_labels.get(outcome, "Combat resolved.")
		_encounter_label.text = "[b]Combat — %s[/b]\n%s\nCasualties: %d" % [outcome.to_upper(), label, cas.size()]
	else: _encounter_label.text = "[b]Cover Pass — %s[/b]" % outcome
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
