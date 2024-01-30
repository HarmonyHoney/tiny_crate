extends CanvasItem

export var bus := 1

onready var arrows := [$Arrow/Sprite, $Arrow2/Sprite]
onready var audio := $AudioStreamPlayer
onready var meter := $Meter.get_children()
onready var label := $Label

export var col_on := Color("00e436")
export var col_off := Color("ff004d")

func _ready():
	set_color()
	deselect()
	audio.bus = AudioServer.get_bus_name(bus)

func select():
	for i in arrows:
		i.visible = true

func deselect():
	for i in arrows:
		i.visible = false

func scroll(arg = 1):
	Shared.set_bus_volume(bus, Shared.bus_volume[bus] + arg)
	set_color()
	audio.pitch_scale = 1 + rand_range(-0.2, 0.2)
	audio.play()

func set_color():
	for i in 10: # 0 - 9
		meter[i].color = col_on if i < Shared.bus_volume[bus] else col_off
