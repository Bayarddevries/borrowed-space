@tool
extends GutTest
## test_captain.gd — placeholder smoke-test.
##
## Phase 2g will expand this with actual tests covering:
## - Captain origin locking to matrix
## - Trait pool draw against archetype
## - He-3 literacy tier application
## - Cover-test roll against expected thresholds
## - Persist round-trip
## - Ink variable flow into persistence
##
## Run via Godot's GUT add-on. Stub here so Phase 2f can attach
## the add-on without rewriting.


func before_each() -> void:
	pass


func test_placeholder() -> void:
	assert_true(true, "Placeholder test passes. Real tests in Phase 2f.")
