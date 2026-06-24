class_name ShipState
extends RefCounted

# ShipState — per-run ship state.
#
# Held by the AI runtime during a single run; reset on run start.
# Phase 3a.1: shape locked; persistence per-run only. Phase 3b
# (combat) will write hull-delta here on each combat round; Phase 3c
# will register supply-consumption per time tick.

const DEFAULT_FUEL := 100
const DEFAULT_HULL := 100
const DEFAULT_SUPPLIES := 100

var captain_name: String = ""
var genship_id: String = ""

# Axial hex coords — current position on the belt.
var current_q: int = 0
var current_r: int = 0

# Resources: all integer counters, capped at start values.
var fuel: int = DEFAULT_FUEL
var hull: int = DEFAULT_HULL
var supplies: int = DEFAULT_SUPPLIES

# Time elapsed (transit-ticks; per CARTOGRAPHY.md §3).
var time_elapsed: int = 0

## Whether the ship is at a station (hex is station_hex).
## Cached at last transit for readability; recomputable from cartography.
var is_docked: bool = false

## Total fuel consumed across the run (audit). Diagnostic.
var fuel_total_consumed: int = 0

static func new_default(captain: String, genship: String, q: int = 0, r: int = 0) -> ShipState:
	var s := ShipState.new()
	s.captain_name = captain
	s.genship_id = genship
	s.current_q = q
	s.current_r = r
	s.fuel = DEFAULT_FUEL
	s.hull = DEFAULT_HULL
	s.supplies = DEFAULT_SUPPLIES
	s.time_elapsed = 0
	s.is_docked = false
	s.fuel_total_consumed = 0
	return s

## Dictionary snapshot for serialization into Persist.
func to_dict() -> Dictionary:
	return {
		"captain_name": captain_name,
		"genship_id": genship_id,
		"current_q": current_q,
		"current_r": current_r,
		"fuel": fuel,
		"hull": hull,
		"supplies": supplies,
		"time_elapsed": time_elapsed,
		"is_docked": is_docked,
		"fuel_total_consumed": fuel_total_consumed,
	}

## Restore from a Persist dict. Returns self for chaining.
func from_dict(d: Dictionary) -> ShipState:
	captain_name = str(d.get("captain_name", ""))
	genship_id = str(d.get("genship_id", ""))
	current_q = int(d.get("current_q", 0))
	current_r = int(d.get("current_r", 0))
	fuel = int(d.get("fuel", DEFAULT_FUEL))
	hull = int(d.get("hull", DEFAULT_HULL))
	supplies = int(d.get("supplies", DEFAULT_SUPPLIES))
	time_elapsed = int(d.get("time_elapsed", 0))
	is_docked = bool(d.get("is_docked", false))
	fuel_total_consumed = int(d.get("fuel_total_consumed", 0))
	return self
