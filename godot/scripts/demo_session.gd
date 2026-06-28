extends Node
## DemoSession autocomplete singleton that carries captain/crew/transit across
## scene transitions in the Day-1 demo loop.
##
## Day-1 wiring only. This is NOT a game-state singleton (Persist is).
## It's the demo glue so run_start.tscn and overworld.tscn can share
## state without each scene re-running the full AI orchestrator.

# Intentionally no `class_name` — the autoload already gives us the
# global symbol /root/DemoSession; adding a class_name with the same
# identifier triggers Godot 4.6 "hides an autoload singleton" parse error.

var captain: Dictionary = {}
var crew: Array = []
var transit_result: Dictionary = {}
var ledger_written: bool = false
var run_states: Array = []   # ledger rows from finalised runs
var ship: Object = null      # ShipState object carried across scenes
var visited_stations: Dictionary = {}  # station_id -> visit_count, per-run

func reset() -> void:
	captain.clear()
	crew.clear()
	transit_result.clear()
	ledger_written = false
	visited_stations.clear()
