extends Node2D

export var is_build_sheet := false

onready var color_rect := $CanvasLayer/ColorRect
onready var logo := $CanvasLayer/Center/Control/Logo

onready var viewport := $ViewportContainer/Viewport
onready var view_node := $ViewportContainer/Viewport/Node2D

func _ready():
	if is_build_sheet:
		color_rect.modulate = Color.black
		logo.modulate = Color.white
	
		yield(get_tree(), "idle_frame")
		
		Shared.is_level_select = true
		Shared.map_dict = {}
		var ix = 136
		var iy = 96
		var vx = 5
		var vy = 8
		
		var image_sheet = viewport.get_texture().get_data()
		image_sheet.resize(ix * vx, iy * vy)
		
		for i in Shared.maps.size():
			var dx = int(i % vx)
			var dy = int(floor(i / vx))
			var s = str(Shared.maps[i])
			Shared.map_dict[s] = [dx,dy,0,0,0,0,0,0]
			var dict = Shared.map_dict[s]
			
			var inst = load(Shared.map_dir + s + ".tscn").instance()
			
			for c in view_node.get_children():
				c.queue_free()
			
			view_node.add_child(inst)
			
			var cb = inst.get_node("CamBounds")
			if is_instance_valid(cb):
				inst.position -= cb.position
				
				var p = inst.get_node("Actors/Player")
				if is_instance_valid(p):
					p.visible = false
					dict[2] = int(p.position.x - cb.position.x)
					dict[3] = int(p.position.y - cb.position.y)
				
				var e = inst.get_node("Actors/Exit")
				if is_instance_valid(e):
					e.visible = false
					dict[4] = int(e.position.x - cb.position.x)
					dict[5] = int(e.position.y - cb.position.y)
				
			yield(get_tree(), "idle_frame")
			
			var image = viewport.get_texture().get_data()
			image.flip_y()
			
			image_sheet.blit_rect(image, Rect2(0, 0, ix, iy), Vector2(dx * ix, dy * iy))
		image_sheet.save_png("res://src/stage/sheet.png")
		
		var sd := SaveDict.new()
		sd.dict = Shared.map_dict
		
		ResourceSaver.save("res://src/stage/sheet.tres", sd)
		
		yield(get_tree(), "idle_frame")
	
	color_rect.modulate = Color.white
	logo.modulate = Color.black
	Music.play()
	Audio.play("menu_bell")
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	Shared.wipe_scene(Shared.main_menu_path)
	
