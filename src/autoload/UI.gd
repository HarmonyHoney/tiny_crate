extends CanvasLayer

onready var x := $Buttons/X
onready var c := $Buttons/C

onready var notes := $Notes
onready var notes_label := $Notes/Label

func _ready():
	keys(false, false)
	notes.visible = false

func keys(left := true, right := true):
	x.visible = left
	c.visible = right
