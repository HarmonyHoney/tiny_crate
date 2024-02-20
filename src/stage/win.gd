extends CanvasItem

onready var gem_label := $VBox/Gems/Label
onready var note_label := $VBox/Notes/Label
onready var die_label := $VBox/Die/Label

func _ready():
	gem_label.text = str(Shared.count_gems) + " / 36"
	note_label.text = str(Shared.count_notes) + " / 36"
	die_label.text = str(Shared.count_die)
