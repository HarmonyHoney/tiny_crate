extends CanvasLayer

onready var x := $Buttons/X
onready var c := $Buttons/C

func _ready():
	keys(false, false)

func keys(left := true, right := true):
	x.visible = left
	c.visible = right
