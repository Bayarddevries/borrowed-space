extends Node
## DemoSession — singleton that carries captain/crew/ship state across
## scene transitions in the Day-1 demo loop.
##
## Day-1 wiring only. This is NOT a game-state singleton (Persist is).
## It's the demo glue so run_start.tscn and overworld.tscn can share
## state without each scene re-running the full AI orchestrator.
##
## Registered as autoload in project.godot:
##   DemoSession="*res://scripts/demo_session.gd"
class_name DemoSession

var captain: Dictionary = {}
var crew: Array = []
var transit_result: Dictionary = {}
var ledger_written: bool = false
var run_states: Array = []   # ledger rows from finalised runs

func reset() -> void:
	captain.clear()
	crew.clear()
	transit_result.clear()
	ledger_written = false
