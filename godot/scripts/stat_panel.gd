extends ColorRect
## StatPanel — visual ship stats overlay (fuel, hull, suspicion, crew).

@onready var _fuel_bar: ColorRect        = $FuelBar/Bg/Fill
@onready var _fuel_label: Label          = $FuelBar/Label
@onready var _hull_bar: ColorRect        = $HullBar/Bg/Fill
@onready var _hull_label: Label          = $HullBar/Label
@onready var _suspicion_bar: ColorRect   = $SuspicionBar/Bg/Fill
@onready var _suspicion_label: Label     = $SuspicionBar/Label
@onready var _crew_label: Label          = $CrewLabel
@onready var _pos_label: Label           = $PosLabel
@onready var _time_label: Label          = $TimeLabel

const MAX_FUEL := 100.0
const MAX_HULL := 100.0

func update(ship_dict: Dictionary, crew_count: int) -> void:
	if ship_dict.is_empty():
		return

	var fuel: float = float(ship_dict.get("fuel", 0))
	var hull: float = float(ship_dict.get("hull", MAX_HULL))
	var suspicion: float = float(ship_dict.get("suspicion", 0))
	var q: int = int(ship_dict.get("current_q", 0))
	var r: int = int(ship_dict.get("current_r", 0))

	# Fuel
	var fuel_pct: float = clamp(fuel / MAX_FUEL, 0.0, 1.0)
	_fuel_bar.custom_minimum_size.x = 120 * fuel_pct
	_fuel_bar.size.x = 120 * fuel_pct
	_fuel_bar.color = Color(0.4, 0.7, 0.9) if fuel_pct > 0.3 else Color(0.85, 0.4, 0.3)
	_fuel_label.text = "Fuel: %d/%d" % [fuel, MAX_FUEL]

	# Hull
	var hull_pct: float = clamp(hull / MAX_HULL, 0.0, 1.0)
	_hull_bar.custom_minimum_size.x = 120 * hull_pct
	_hull_bar.size.x = 120 * hull_pct
	_hull_bar.color = Color(0.6, 0.8, 0.5) if hull_pct > 0.5 else Color(0.85, 0.6, 0.3)
	_hull_label.text = "Hull: %d/%d" % [hull, MAX_HULL]

	# Suspicion
	var susp_pct: float = clamp(suspicion / 20.0, 0.0, 1.0)
	_suspicion_bar.custom_minimum_size.x = 120 * susp_pct
	_suspicion_bar.size.x = 120 * susp_pct
	_suspicion_bar.color = Color(0.9, 0.8, 0.3) if susp_pct < 0.5 else Color(0.85, 0.3, 0.3)
	_suspicion_label.text = "Suspicion: %d" % suspicion

	# Crew
	_crew_label.text = "Crew: %d" % crew_count

	# Position
	_pos_label.text = "(%d, %d)" % [q, r]

	# Time
	var days: int = int(ship_dict.get("time_elapsed", 0))
	_time_label.text = "Day %d" % days
