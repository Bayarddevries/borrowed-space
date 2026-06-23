extends SceneTree
func _init():
	var N = load("res://scripts/narrative_data.gd")
	print("smoke_test:", N.smoke_test())
	print("genship count:", N.list_genships().size())
	for g in N.list_genships():
		print("  ", g)
	print("npc counts:")
	for k in N.npc_variant_counts():
		print("  ", k, "=", N.npc_variant_counts()[k])
	quit()
