extends CanvasLayer

onready var x := $Center/Control/List/X
onready var c := $Center/Control/List/C
onready var top := $Center/Control/Top
onready var pause_label := $Center/Control/Top/P/Desc

onready var notes := $Center/Control/Notes
onready var notes_label := $Center/Control/Notes/Label
onready var spacer := $Center/Control/List/Spacer

func _ready():
	keys(false, false)
	notes.visible = false

func keys(left := true, right := true, is_expand := true, _top := false):
	x.visible = left
	c.visible = right
	top.visible = _top
	spacer.size_flags_horizontal = spacer.SIZE_EXPAND_FILL if is_expand else spacer.SIZE_FILL

func pause_label(arg := "menu"):
	pause_label.text = arg
