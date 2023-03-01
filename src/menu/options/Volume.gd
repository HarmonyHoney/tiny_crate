extends Node2D

@export var bus := 1

@onready var arrows := $Arrows
@onready var audio := $AudioStreamPlayer
@onready var meter := $Meter
@onready var label := $Label

@export var col_on := Color("00e436")
@export var col_off := Color("ff004d")

func _ready():
	set_color()
	audio.bus = AudioServer.get_bus_name(bus)

func select():
	arrows.visible = true

func deselect():
	arrows.visible = false

func scroll(arg = 1):
	Shared.set_bus_volume(bus, Shared.bus_volume[bus] + arg)
	set_color()
	audio.pitch_scale = 1 + randf_range(-0.2, 0.2)
	audio.play()

func set_color():
	var m = meter.get_children()
	for i in 10: # 0 - 9
		m[i].color = col_on if i < Shared.bus_volume[bus] else col_off
