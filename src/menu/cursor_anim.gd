extends Control

onready var kids := get_children()

var clock := 0.0
var frac := 0.0
var smooth := 0.0
export var time := 0.2
export var distance := 5.0
export var offset := 0.0
var time_scale = 1.0
export var size := Vector2(136, 104)

var to := PoolVector2Array([Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)])

func _ready():
	pass


func _physics_process(delta):
	clock = clamp(clock + (delta * time_scale), 0.0, time)
	frac = clock / time
	smooth = smoothstep(0.0, 1.0, frac)
	
	if frac == 0.0 or frac == 1.0:
		time_scale = -1.0 if frac == 1.0 else 1.0
	
	
	var from = [Vector2.ZERO, Vector2(size.x, 0), Vector2(0, size.y), size]
	for i in 4:
		kids[i].position = from[i] + (to[i] * offset) + (to[i] * distance * smooth)
