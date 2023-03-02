extends CanvasLayer

signal finish

var is_wipe := false
@export var is_reverse = false

var frame = 0
# last frame
@export var last := 14.0

var clock := 0.0
var time := 0.45
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var image := $ColorRect
@onready var mat : ShaderMaterial = $ColorRect.material

func _ready():
	image.visible = false
	#clock = time

func _physics_process(delta):
	if is_wipe:
		clock = clamp(clock + delta, 0, time)
		var f = lerp(0.0, last, clock / time)
		mat.set_shader_parameter("frame", (last - f) if is_reverse else f)
		
		if clock == time:
			stop()

func start(_reverse = false):
	is_wipe = true
	clock = 0
	image.visible = true
	
	is_reverse = _reverse
	if !is_reverse:
		audio.play()

func stop():
	is_wipe = false
	if is_reverse:
		image.visible = false
	else:
		for i in 2:
			await get_tree().process_frame
		emit_signal("finish")
		start(true)


