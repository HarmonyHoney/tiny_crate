extends Node2D

func _ready():
	yield(get_tree(), "idle_frame")
	Music.play()
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(1.5), "timeout")
	#Shared.wipe_scene(Shared.main_menu_path)
	Shared.wipe_scene("res://src/menu/Creator.tscn")
