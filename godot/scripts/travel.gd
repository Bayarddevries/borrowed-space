class_name Travel
extends RefCounted

# Travel — the transit orchestrator.
#
# `transit(ship, to_q, to_r) -> TransitResult` is the single entry point
# the runtime calls. It:
#   1. Verifies the destination is reachable (in-belt, within fuel).
#   2. Computes fuel cost = axial_distance * hazard_modifier.
#   3. Advances the ship on success (fuel, hex, time tick).
#   4. Rolls an encounter — Phase 3a.1 ships a stub; Phase 3d replaces
#      with the real EncounterPool.
#   5. Returns a TransitResult dict.
#
# Phase 3a.1 stub encounter roll:
#   - station_hex: rolls one of the canonical station encounters
#     (caller passes manifest, or we use the global encounter pool if
#     one is registered; otherwise returns null)
#   - other kinds: returns null (placeholder for Phase 3d)
#
# The stub is intentional — Phase 3a.1 proves transit math + state
# mutation. Phase 3d is the moment statistical encounter hooks fire.

const _STUB_ENCOUNTER_BEAT := "station_arrival_STATION_default_1"

## One-shot encounter registry — populated by EncounterPool when wired
## (Phase 3d). Phase 3a.1 ships an empty registry so transit() can be
## called without NullDeferences in tests.
static var _encounter_registry := {}

## Register an encounter kind -> beat_id mapping (test seam).
static func register_encounter(arrival_kind: String, beat_id: String) -> void:
	_encounter_registry[arrival_kind] = beat_id

## Reset encounter registry (test seam).
static func clear_encounters() -> void:
	_encounter_registry.clear()

## Compute the fuel cost of a single-step transit from `from` to `to`.
## Pure function; no mutation. Used by both Travel.transit() and the
## "preview fuel cost" UI (Phase 4).
static func transit_cost(from_q: int, from_r: int, to_q: int, to_r: int, stations: Array) -> int:
	var base := Hex.distance(Vector2i(from_q, from_r), Vector2i(to_q, to_r))
	if base == 0:
		return 0 # same hex; no cost
	var kind := Cartography.hex_kind_at(to_q, to_r, stations)
	var modifier := Cartography.hazard_modifier(kind)
	return int(round(float(base) * modifier))

## Run a transit. Returns a TransitResult dict:
##   {
##     "ok": bool,
##     "reason": String,           # only when ok=false
##     "arrived_at": Vector2i,
##     "arrival_kind": String,
##     "fuel_after": int,
##     "cost": int,
##     "tick": int,
##     "encounter_rolled": Variant # beat_id, or null
##   }
##
## On ok=false, ship's state is NOT mutated.
## On ok=true, ship's fuel/coord/time update.
static func transit(ship: ShipState, to_q: int, to_r: int, stations: Array) -> Dictionary:
	# Reject out-of-belt destinations outright.
	if Hex.distance(Vector2i(0, 0), Vector2i(to_q, to_r)) > Hex.BELT_RADIUS:
		return {
			"ok": false,
			"reason": "out_of_belt",
			"arrived_at": Vector2i(to_q, to_r),
			"arrival_kind": "out_of_play",
			"fuel_after": ship.fuel,
			"cost": 0,
			"tick": ship.time_elapsed,
			"encounter_rolled": null,
		}

	var from_h := Vector2i(ship.current_q, ship.current_r)
	var to_h := Vector2i(to_q, to_r)
	var base_distance := Hex.distance(from_h, to_h)

	# Pre-check fuel-sufficiency. If we can't even base-distance hop,
	# refuse (Phase 3a.1: refuse rather than strand mid-transit).
	if base_distance > ship.fuel:
		return {
			"ok": false,
			"reason": "out_of_fuel",
			"arrived_at": from_h,
			"arrival_kind": Cartography.hex_kind_at(ship.current_q, ship.current_r, stations),
			"fuel_after": ship.fuel,
			"cost": 0,
			"tick": ship.time_elapsed,
			"encounter_rolled": null,
		}

	var cost := transit_cost(ship.current_q, ship.current_r, to_q, to_r, stations)
	# Phase 3a.1: refuse if actual cost exceeds ship.fuel. Stranding
	# is a future-Phase mechanic, not Phase 3a.1.
	if cost > ship.fuel:
		return {
			"ok": false,
			"reason": "out_of_fuel",
			"arrived_at": from_h,
			"arrival_kind": Cartography.hex_kind_at(ship.current_q, ship.current_r, stations),
			"fuel_after": ship.fuel,
			"cost": cost,
			"tick": ship.time_elapsed,
			"encounter_rolled": null,
		}

	# Successful transit: mutate ship state.
	ship.fuel -= cost
	ship.fuel_total_consumed += cost
	ship.current_q = to_q
	ship.current_r = to_r
	ship.time_elapsed += 1

	var arrival_kind := Cartography.hex_kind_at(to_q, to_r, stations)
	ship.is_docked = arrival_kind == "station_hex"

	var encounter: Variant = null
	if _encounter_registry.has(arrival_kind):
		encounter = _encounter_registry[arrival_kind]

	return {
		"ok": true,
		"arrived_at": to_h,
		"arrival_kind": arrival_kind,
		"fuel_after": ship.fuel,
		"cost": cost,
		"tick": ship.time_elapsed,
		"encounter_rolled": encounter,
	}
