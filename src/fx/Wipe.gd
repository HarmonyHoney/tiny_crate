extends Node2D

var sprite : Sprite
var sprites : Node2D

export var act = false
export var backwards = false

var tick = 0.03
var clock = 0

var frame = 0
# last frame
export var last = 14

signal finish

var audio : AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $Sprites/Sprite.duplicate()
	$Sprites/Sprite.queue_free()
	sprites = $Sprites
	audio = $AudioStreamPlayer2D
	
	for y in 12:
		for x in 21:
			var s = sprite.duplicate()
			s.position = Vector2(x, y) * 16
			sprites.add_child(s)
	
	start() if act else stop(false)

func _process(delta):
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
	set_process(true)
	frame = 0
	clock = tick
	backwards = _backwards
	sprites.visible = true
	if !backwards:
		audio.pitch_scale = 0.6
		audio.play()

func stop(_emit_signal = true):
	act = false
	set_process(false)
	sprites.visible = false
	
	if _emit_signal:
		emit_signal("finish")


