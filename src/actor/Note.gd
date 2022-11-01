tool
extends Actor

onready var sprite := $Sprite

export var gra : Gradient
var clock := 0.0
export var duration := 1.0

var bounce := 0.0

func _physics_process(delta):
	if Engine.editor_hint: return
	
#	clock += delta
#	clock = fmod(clock, duration)
#	sprite.modulate = gra.interpolate(clock / duration)
	
	bounce += delta * 2.5
	sprite.offset.y = sin(bounce) * 1.5
	
