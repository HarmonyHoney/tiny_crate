extends CanvasLayer

onready var x := $Center/Control/List/X
onready var c := $Center/Control/List/C

onready var notes := $Center/Control/Notes
onready var notes_label := $Center/Control/Notes/Label
onready var spacer := $Center/Control/List/Spacer

func _ready():
	keys(false, false)
	notes.visible = false

func keys(left := true, right := true, is_expand := true):
	x.visible = left
	c.visible = right
	spacer.size_flags_horizontal = spacer.SIZE_EXPAND_FILL if is_expand else spacer.SIZE_FILL
	
