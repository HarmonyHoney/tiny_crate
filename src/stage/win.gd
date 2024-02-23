extends CanvasItem

onready var gem_label := $VBox/Gems/Label
onready var gem_time_label := $VBox/Gems/Label2
onready var note_label := $VBox/Notes/Label
onready var note_time_label := $VBox/Notes/Label2
onready var die_label := $VBox/Die/Label
onready var total_label := $VBox/Total/Label
onready var total_time_label := $VBox/Total/Label2

func _ready():
	gem_label.text = str(Shared.count_gems)
	gem_time_label.text = Shared.time_to_string(Shared.count_gems_time)
	note_label.text = str(Shared.count_notes)
	note_time_label.text = Shared.time_to_string(Shared.count_notes_time)
	total_label.text = str(Shared.count_percent * 100.0).pad_decimals(2) + "%"
	total_time_label.text = Shared.time_to_string(Shared.save_clock)
	die_label.text = str(Shared.count_die)
