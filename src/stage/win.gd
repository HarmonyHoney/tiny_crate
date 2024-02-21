extends CanvasItem

onready var gem_label := $VBox/Gems/Label
onready var note_label := $VBox/Notes/Label
onready var die_label := $VBox/Die/Label
onready var total_label := $VBox/Total/Label

func _ready():
	total_label.text = str(Shared.count_percent * 100.0).pad_decimals(2) + "%"
	gem_label.text = str(Shared.count_gems)# + " / 36"
	note_label.text = str(Shared.count_notes)# + " / 36"
	die_label.text = str(Shared.count_die)
