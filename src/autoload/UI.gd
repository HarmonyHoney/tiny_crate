extends CanvasLayer

onready var x := $Center/Control/List/X
onready var x_label := $Center/Control/List/X/Desc
onready var c := $Center/Control/List/C
onready var c_label := $Center/Control/List/C/Desc
onready var top := $Center/Control/Top
onready var pause_label := $Center/Control/Top/P/Desc

onready var notes := $Center/Control/Notes
onready var notes_label := $Center/Control/Notes/Label
onready var gems := $Center/Control/Gems
onready var gems_label := $Center/Control/Gems/Label

onready var spacer := $Center/Control/List/Spacer

func _ready():
	keys(false, false)
	notes.visible = false

func keys(left := true, right := true, is_expand := true, _top := false):
	x.visible = left
	c.visible = right
	top.visible = _top
	spacer.size_flags_horizontal = spacer.SIZE_EXPAND_FILL if is_expand else spacer.SIZE_FILL

func labels (_x := "pick", _c := "back", _pause := "menu"):
	x_label.text = _x
	c_label.text = _c
	pause_label.text = _pause
