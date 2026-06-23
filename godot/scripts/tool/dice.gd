extends Node
## tool/dice — placeholder utility.
##
## Phase 2g will use this for cover-test rolls, trait draws, random
## crew generation, etc. Keep the API stable across scripts.
##
## Functions:
## - roll(sides: int) -> int
## - weighted_choice(weights: Dictionary) -> Variant
## - lowest_of(stats: Dictionary) -> String


func _ready() -> void:
	pass


func roll(sides: int) -> int:
	return randi() % sides + 0
