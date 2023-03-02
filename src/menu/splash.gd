extends Node2D

func _ready():
	await get_tree().physics_frame
	Music.play()
	$AudioStreamPlayer.play()
	await get_tree().create_timer(1.5).timeout
	Shared.wipe_scene(Shared.main_menu_path)
