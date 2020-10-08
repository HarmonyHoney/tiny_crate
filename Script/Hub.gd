extends Node2D


func _ready():
	for p in get_tree().get_nodes_in_group("player"):
		p.position = Shared.hub_pos
