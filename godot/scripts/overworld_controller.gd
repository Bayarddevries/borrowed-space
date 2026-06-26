extends Node
## OverworldController — moves 3-5 of the Day-1 demo loop.
##
## Attached to overworld.tscn. Owns the hex display, transit,
## encounter display, and end-of-run flow.
##
## Phase 3 day-1 wiring only. No new content, no loader changes.
class_name OverworldController

# ── UI nodes ──────────────────────────────────────────────────────
@onready var _hex_label: RichTextLabel    = $HexLabel
@onready var _encounter_label: RichTextLabel = $EncounterLabel
@onready var _status_label: RichTextLabel = $StatusLabel
@onready var _station_dropdown: OptionButton = $StationDropdown
@onready var _transit_btn: Button         = $TransitButton
@onready var _end_run_btn: Button         = $EndRunButton
@onready var _proceed_btn: Button         = $ProceedButton

# ── State ─────────────────────────────────────────────────────────
var ship: ShipState = null
var stations: Array = []
var captain: Dictionary = {}
var crew: Array = []
var encounter_pending: Dictionary = {}  # last encounter result from Travel

func _ready() -> void:
	# Pull captain + crew from DemoSession (set by run_start scene).
	captain = DemoSession.captain.duplicate(true)
	crew = DemoSession.crew.duplicate(true)

	if captain.is_empty():
		_status_label.text = "[b]No captain data.[/b] Go back to briefing."
		_end_run_btn.disabled = false
		_transit_btn.disabled = true
		return

	# Initialise ship at STATION_01 (0,0) and load stations.
	stations = Cartography.load_stations()
	ship = ShipState.new_default(
		captain.get("name", "Captain"),
		captain.get("genship_id", "NAC"),
		0, 0
	)
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
		var label: String = "%s (%d,%d) — %d ly — %s" % [sid, q, r, dist, faction]
		_station_dropdown.add_item(label)

func _refresh_view() -> void:
	if ship == null:
		return
	var msg := "[b]Belt Map — Sector View[/b]\n"
	msg += "Position: (%d, %d)\n" % [ship.current_q, ship.current_r]
	msg += "Fuel: [color=%s]%d[/color] / 100\n" % [_fuel_color(ship.fuel), ship.fuel]
	msg += "Hull: %d / 100\n" % ship.hull
	msg += "Time elapsed: %d days\n" % ship.time_elapsed
	if ship.is_docked:
		msg += "Status: [color=green]DOCKED[/color]\n"
	else:
		msg += "Status: [color=yellow]IN TRANSIT[/color]\n"
	_hex_label.text = msg
	_render_debug_hex()

func _render_debug_hex() -> void:
	if ship == null:
		return
	# Compact ASCII hex view: show current position and nearby stations.
	var lines: Array = []
	var radius: int = 3  # show a 3-hex radius
	for r in range(-radius, radius + 1):
		var row: String = ""
		var indent: String = " ".repeat(abs(r)) if r != 0 else ""
		row += indent
		for q in range(-radius, radius + 1):
			var d: int = Hex.distance(Vector2i(ship.current_q + q, ship.current_r + r),
			                           Vector2i(ship.current_q, ship.current_r))
			if d > radius:
				row += "  .  "
				continue
			var is_current := (q == 0 and r == 0)
			var is_station := false
			var station_id: String = ""
			for s in stations:
				if int(s.get("q", -999)) == ship.current_q + q and int(s.get("r", -999)) == ship.current_r + r:
					is_station = true
					station_id = str(s.get("id", ""))
					break
			if is_current:
				row += "[color=green][ X ][/color]"
			elif is_station:
				row += "[color=yellow][%s][/color]" % station_id.substr(-2, 2).rpad(3)
			else:
				row += "  ·  "
		lines.append(row)
	_hex_label.text += "\n[code]" + "\n".join(lines) + "[/code]"

func _fuel_color(f: int) -> String:
	if f > 50: return "green"
	if f > 20: return "yellow"
	return "red"

# ── Transit ─────────────────────────────────────────────────────
func _on_transit_pressed() -> void:
	if ship == null or stations.is_empty():
		return
	var idx: int = _station_dropdown.selected
	if idx < 0 or idx >= stations.size():
		_status_label.text = "[color=red]Pick a destination first.[/color]"
		return
	var target: Dictionary = stations[idx]
	var tq: int = int(target.get("q", 0))
	var tr: int = int(target.get("r", 0))

	# Register a default station arrival encounter for station hexes.
	Travel.register_encounter("station_hex", "station_arrival_default_1")
	var result: Dictionary = Travel.transit(ship, tq, tr, stations)
	Travel.clear_registry()

	DemoSession.transit_result = result
	encounter_pending = result

	if not result.get("ok", false):
		_status_label.text = "[color=red]Transit failed: %s[/color]" % result.get("reason", "unknown")
		return

	_refresh_view()
	var arrival: String = str(result.get("arrival_kind", "deep_belt"))

	# Check if we have an encounter.
	var rolled: Variant = result.get("encounter_rolled", null)
	if rolled != null:
		if rolled is Dictionary:
			# Pool-style encounter with category/variant
			var cat: String = rolled.get("category", "Encounter")
			var desc: String = rolled.get("resolution_hint", "something happens")
			_encounter_label.text = "[b]Encounter: %s[/b]\n%s" % [cat, desc]
		else:
			# String beat id (registry default)
			_encounter_label.text = "[b]Arrival: %s[/b]\n%s" % [arrival, str(rolled)]

		# Show Proceed button for encounter resolution.
		_proceed_btn.show()
		_proceed_btn.text = "Proceed (Cover Test)"
		_transit_btn.disabled = true
		_status_label.text = "[color=yellow]Encounter triggered — proceed or stand down?[/color]"
	else:
		_encounter_label.text = "[b]Arrived at %s[/b] — no encounter." % arrival
		_end_run_btn.disabled = false
		_status_label.text = "[color=green]Arrived safely. End run or transit again?[/color]"

# ── Encounter / Combat resolution ───────────────────────────────
func _on_proceed_pressed() -> void:
	_proceed_btn.hide()
	var ai_script: GDScript = load("res://scripts/ai.gd")
	var ai: Node = ai_script.new()
	add_child(ai)
	ai.captain = captain
	ai.crew = crew

	# Run CoverTest → possible CQB via step_X_meet_aliens.
	var cqb_result: Dictionary = ai.step_X_meet_aliens(ship)
	var outcome: String = cqb_result.get("outcome", "unknown")
	var combat_fired: bool = cqb_result.get("combat_fired", false)

	if combat_fired:
		var cas: Array = cqb_result.get("casualties", [])
		var cas_count: int = cas.size()
		_encounter_label.text = "[b]CQB COMBAT — %s[/b]\n" % outcome.to_upper()
		_encounter_label.text += "Turns fought, casualties: %d\n" % cas_count
		if cas_count > 0:
			for c in cas:
				var actor: String = c.get("actor_id", "unknown")
				_encounter_label.text += "  ✗ %s lost\n" % actor
		else:
			_encounter_label.text += "All crew survived.\n"
	else:
		# Cover test passed or no combat — show pass beat text.
		var beat: Dictionary = cqb_result.get("beat_result", {})
		var beat_text: String = beat.get("text", "Encounter resolved — cover passed.")
		_encounter_label.text = "[b]Cover Pass — %s[/b]\n%s" % [outcome, beat_text]

	_status_label.text = "[color=green]Encounter resolved. End run or continue?[/color]"
	_end_run_btn.disabled = false

# ── End Run ─────────────────────────────────────────────────────
func _on_end_run_pressed() -> void:
	if captain.is_empty():
		_status_label.text = "[color=red]No captain to finalise.[/color]"
		return

	# Write the ledger row.
	var LW: GDScript = load("res://scripts/ledger_writer.gd")
	var lw: Node = LW.new()
	add_child(lw)
	var state: Dictionary = {"outcome": "ledger-closed", "discoveries_caught": ["demo_run"]}
	var captain_n: int = lw.finalise_run(state, captain, crew, ["demo_run"])

	# Read the total from Persist.
	var s: Dictionary = Persist.get_state()
	var counts: Dictionary = s.get("run_counts", {})
	var total_runs: int = int(counts.get("started", 0))

	DemoSession.ledger_written = true
	DemoSession.run_states.append({
		"captain_n": captain_n,
		"genship_id": captain.get("genship_id", "?"),
		"crew_count": crew.size(),
	})

	_status_label.text = "[b]Run complete.[/b] Ledger entry: Captain #%d\nCaptains so far: %d\n\nReturning to briefing..." % [captain_n, total_runs]
	_end_run_btn.disabled = true
	_transit_btn.disabled = true
	DemoSession.reset()

	# Brief delay then return to run_start.
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/run_start.tscn")
