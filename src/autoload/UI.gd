extends CanvasLayer

onready var x := $Center/Control/Buttons/X
onready var c := $Center/Control/Buttons/C

onready var notes := $Center/Control/Notes
onready var notes_label := $Center/Control/Notes/Label

func _ready():
	keys(false, false)
	notes.visible = false

func keys(left := true, right := true):
	x.visible = left
	c.visible = right
