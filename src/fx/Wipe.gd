extends Node2D

var sprite : Sprite
onready var sprites : Node2D = $Sprites

export var act = false
export var backwards = false

var tick = 0.03
var clock = 0

var frame = 0
# last frame
export var last = 14

signal finish

onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	sprite = $Sprites/Sprite.duplicate()
	$Sprites/Sprite.queue_free()
	
	for y in 12:
		for x in 21:
			var s = sprite.duplicate()
			s.position = Vector2(x, y) * 16
			sprites.add_child(s)
	
	start() if act else stop(false)

func _physics_process(delta):
	clock -= delta
	if clock < 0:
		clock += tick
		frame += 1
		
		if frame > last:
			sprites.visible = false
			stop(not backwards)
			return
		
		for i in sprites.get_children():
			i.frame = clamp(last - frame if backwards else frame, 0, last)

func start(_backwards = false):
	act = true
	set_physics_process(true)
	frame = 0
	clock = tick
	backwards = _backwards
	sprites.visible = true
	if !backwards:
		audio.play()

func stop(_emit_signal = true):
	act = false
	set_physics_process(false)
	sprites.visible = false
	
	if _emit_signal:
		emit_signal("finish")


