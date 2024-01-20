extends CanvasLayer

onready var x := $Center/Control/Bottom/Keys/X
onready var x_label := $Center/Control/Bottom/Keys/X/Desc
onready var c := $Center/Control/Bottom/Keys/C
onready var c_label := $Center/Control/Bottom/Keys/C/Desc
onready var arrows := $Center/Control/Bottom/Arrows
onready var spacer := $Center/Control/Bottom/Spacer

onready var top := $Center/Control/Top
onready var pause_label := $Center/Control/Top/P/Desc

onready var map := $Center/Control/Map
onready var notes := $Center/Control/Map/Notes
onready var notes_label := $Center/Control/Map/Notes/Label
onready var gems := $Center/Control/Map/Gems
onready var gems_label := $Center/Control/Map/Gems/Label

onready var stats := $Center/Control/Stats
onready var stat_time := $Center/Control/Stats/Time
onready var stat_time_label := $Center/Control/Stats/Time/Label
onready var stat_note := $Center/Control/Stats/Note
onready var stat_note_label := $Center/Control/Stats/Note/Label
onready var stat_die := $Center/Control/Stats/Die
onready var stat_die_label := $Center/Control/Stats/Die/Label

export var pos_left := 0
export var pos_right := 0

func _ready():
	keys(false, false)
	map.visible = false
	stats.visible = false

func keys(left := true, right := true, is_expand := true, _top := false, _arrows := true):
	x.visible = left
	c.visible = right
	top.visible = _top
	spacer.size_flags_horizontal = spacer.SIZE_EXPAND_FILL if is_expand else spacer.SIZE_FILL
	arrows.visible = _arrows

func labels(_x := "pick", _c := "back", _pause := "pause"):
	x_label.text = _x
	c_label.text = _c
	pause_label.text = _pause

func show_stats():
	var m = {}
	if Shared.save_maps.has(Shared.map_name):
		m = Shared.save_maps[Shared.map_name]
	var has_die : bool = m.has("die")
	stat_die.visible = has_die
	if has_die:
		stat_die_label.text = str(m["die"])
	
	var has_time : bool = m.has("time")
	stat_time.visible = has_time
	if has_time:
		stat_time_label.text = Shared.time_to_string(m["time"])
	
	var has_note : bool = m.has("note")
	stat_note.visible = has_note
	if has_note:
		stat_note_label.text = Shared.time_to_string(m["note"])
