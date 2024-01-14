extends CanvasLayer

signal finish

var is_wipe := false
export var is_reverse = false

var frame = 0
# last frame
export var last = 14

export var duration := 0.45 setget set_duration
onready var easing := EaseMover.new(duration)
onready var image := $ColorRect
onready var mat : ShaderMaterial = $ColorRect.material

func _ready():
	image.visible = false
	easing.clock = easing.time
	
	image.connect("item_rect_changed", self, "item_rect")
	item_rect()

func _physics_process(delta):
	if is_wipe:
		easing.count(delta)
		var f = lerp(0.0, last, easing.frac())
		mat.set_shader_param("frame", (last - f) if is_reverse else f)
		
		if easing.is_complete:
			stop()

func start(_reverse = false):
	is_wipe = true
	easing.reset()
	image.visible = true
	
	is_reverse = _reverse
	if !is_reverse:
		Audio.play("menu_wipe")

func stop():
	if is_reverse:
		is_wipe = false
		image.visible = false
	else:
		for i in 2:
			yield(get_tree(),"idle_frame")
		emit_signal("finish")
		start(true)

func item_rect():
	mat.set_shader_param("size", (image.rect_size / Vector2(228, 128)) * Vector2(14.25, 8))
	mat.set_shader_param("offset", Vector2(fposmod(image.rect_size.x / 32, 1.0), 0))
	
	print(mat.get_shader_param("size"), " / ", mat.get_shader_param("offset"))

func set_duration(arg):
	duration = arg
	if is_instance_valid(easing):
		easing.time = arg
