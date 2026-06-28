class_name Travel
extends RefCounted

## Travel — the transit orchestrator.
##
## `transit(ship, to_q, to_r, stations) -> TransitResult`
## 1) validate destination + fuel
## 2) compute cost
## 3) mutate ship state
## 4) roll encounter from encounter_pool if present

const _DEFAULT_ENCOUNTER_BEAT := "station_arrival_default_1"

## One-shot encounter registry — preserved for test-determined seams.
## Phase 3d.1: when EncounterPool is absent, caller may register a
## fallback beat_id per arrival_kind to avoid null returns in tests.
static var _registry := {}

static func register_encounter(arrival_kind: String, beat_id: String) -> void:
	_registry[arrival_kind] = beat_id

static func clear_registry() -> void:
	_registry.clear()

## Transits the ship, consumes fuel, advances time, returns TransitResult.
static func transit(ship: ShipState, to_q: int, to_r: int, stations: Array) -> Dictionary:
	# Out-of-belt guard.
	if Hex.distance(Vector2i(0, 0), Vector2i(to_q, to_r)) > Hex.BELT_RADIUS:
		push_warning("[Travel] destination (%d,%d) out-of-belt" % [to_q, to_r])
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

	# Out-of-fuel pre-check.
	if ship.fuel <= 0:
		return {
			"ok": false,
			"reason": "out_of_fuel",
			"arrived_at": Vector2i(ship.current_q, ship.current_r),
			"arrival_kind": Cartography.hex_kind_at(ship.current_q, ship.current_r, stations),
			"fuel_after": ship.fuel,
			"cost": 0,
			"tick": ship.time_elapsed,
			"encounter_rolled": null,
		}

	var cost := transit_cost(
		ship.current_q, ship.current_r,
		to_q, to_r,
		stations
	)
	if cost > ship.fuel:
		return {
			"ok": false,
			"reason": "out_of_fuel",
			"arrived_at": Vector2i(ship.current_q, ship.current_r),
			"arrival_kind": Cartography.hex_kind_at(ship.current_q, ship.current_r, stations),
			"fuel_after": ship.fuel,
			"cost": cost,
			"tick": ship.time_elapsed,
			"encounter_rolled": null,
		}

	# Apply transit.
	ship.fuel -= cost
	ship.fuel_total_consumed += cost
	ship.current_q = to_q
	ship.current_r = to_r
	ship.time_elapsed += 1

	var arrival_kind := Cartography.hex_kind_at(to_q, to_r, stations)
	ship.is_docked = arrival_kind == "station_hex"

	var encounter: Variant = null
	if _registry.has(arrival_kind):
		encounter = _registry[arrival_kind]
	if encounter == null:
		var rolled: Variant = EncounterPool.roll(ship.to_dict(), arrival_kind, stations)
		if rolled != null:
			encounter = rolled
	if encounter == null and arrival_kind == "station_hex":
		encounter = _DEFAULT_ENCOUNTER_BEAT

	return {
		"ok": true,
		"arrived_at": Vector2i(to_q, to_r),
		"arrival_kind": arrival_kind,
		"fuel_after": ship.fuel,
		"cost": cost,
		"tick": ship.time_elapsed,
		"encounter_rolled": encounter,
	}

## Fuel cost from `(from)` to `(to)` using hazard + distance.
static func transit_cost(from_q: int, from_r: int,
                         to_q: int, to_r: int,
                         stations: Array) -> int:
	var from_hex := Vector2i(from_q, from_r)
	var to_hex := Vector2i(to_q, to_r)
	var distance := Hex.distance(from_hex, to_hex)
	if distance <= 0:
		return 0
	var kind := Cartography.hex_kind_at(to_q, to_r, stations)
	var modifier := Cartography.hazard_modifier(kind)
	return int(round(float(distance) * modifier))

## Fuel cost for a given hex distance (no stations lookup needed).
## Uses generic deep_belt modifier (1.0) as floor.
static func fuel_cost_for_distance(dist: int) -> int:
	if dist <= 0:
		return 0
	var modifier := Cartography.hazard_modifier("deep_belt")
	return int(round(float(dist) * modifier))

## Consume fuel from ship. Returns actual amount consumed.
static func consume_fuel(ship: ShipState, amount: int) -> int:
	var actual := mini(amount, ship.fuel)
	ship.fuel -= actual
	ship.fuel_total_consumed += actual
	return actual
