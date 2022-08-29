extends CanvasLayer

signal finish

var is_wipe := false
export var is_reverse = false

var frame = 0
# last frame
export var last = 14

onready var easing := EaseMover.new(0.45)
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var image := $ColorRect
onready var mat : ShaderMaterial = $ColorRect.material

func _ready():
	image.visible = false
	easing.clock = easing.time

func _physics_process(delta):
	if is_wipe:
		easing.count(delta)
		var f = lerp(0.0, last, easing.frac())
		mat.set_shader_param("frame", (last - f) if is_reverse else f)
		
		if easing.is_complete:
			print(f)
			stop()

func start(_reverse = false):
	is_wipe = true
	easing.reset()
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
			yield(get_tree(),"idle_frame")
		emit_signal("finish")
		start(true)


