extends Node2D

onready var viewport := $ViewportContainer/Viewport
onready var view_node := $ViewportContainer/Viewport/Node2D

func _ready():
	
	Shared.is_level_select = true
	for i in Shared.scene_dict.keys():
		var inst = Shared.scene_dict[i].instance()
		
		for c in view_node.get_children():
			c.queue_free()
		
		view_node.add_child(inst)
		
		var cb = inst.get_node("CamBounds")
		if is_instance_valid(cb):
			inst.position -= cb.position
		var ps = inst.get_node("Actors/Player/Sprite")
		if is_instance_valid(ps):
			ps.material = null
		
		for f in 2:
			yield(get_tree(), "idle_frame")
		
		var image = viewport.get_texture().get_data()
		image.flip_y()
		
		image.save_png("user://save/map/" + str(i).split("/")[-1].trim_suffix(".tscn") + ".png")
	
	
	yield(get_tree(), "idle_frame")
	Music.play()
	Audio.play("menu_bell")
	yield(get_tree().create_timer(1.5), "timeout")
	Shared.wipe_scene(Shared.main_menu_path)
	
