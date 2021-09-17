extends Node2D


var box = []


# Called when the node enters the scene tree for the first time.
func _ready():
	box.append($Box0)
	box.append($Box1)
	box.append($Box2)
	box.append($Box3)


func set_button_box():
	box[3].position = Vector2(64, -16)
	box[3].speed = Vector2.ZERO

func set_box_stack():
	box[0].position = Vector2(160, -16)
	box[1].position = Vector2(164, -32)
	box[2].position = Vector2(160, -48)
	
	box[0].speed = Vector2.ZERO
	box[1].speed = Vector2.ZERO
	box[2].speed = Vector2.ZERO
