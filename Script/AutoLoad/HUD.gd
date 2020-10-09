extends CanvasLayer

var node_timer : Label
var node_death : Label

func _ready():
	node_timer = $Timer
	node_death = $Death
