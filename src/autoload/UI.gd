extends CanvasLayer

onready var bottom := $Center/Control/Bottom
onready var arrows := $Center/Control/Bottom/Arrows
onready var spacer := $Center/Control/Bottom/Spacer
onready var x := $Center/Control/Bottom/Keys/X
onready var x_label := $Center/Control/Bottom/Keys/X/Desc
onready var c := $Center/Control/Bottom/Keys/C
onready var c_label := $Center/Control/Bottom/Keys/C/Desc
onready var v := $Center/Control/Bottom/Keys/V
onready var v_label := $Center/Control/Bottom/Keys/V/Desc

onready var keys_node := $Center/Control
onready var top := $Center/Control/Top
onready var pause_label := $Center/Control/Top/P/Desc

onready var map := $Center/Info/Map
onready var notes := $Center/Info/Map/Notes
onready var notes_label := $Center/Info/Map/Notes/Label
onready var gems := $Center/Info/Map/Gems
onready var gems_label := $Center/Info/Map/Gems/Label

onready var stats := $Center/Info/Stats
onready var stat_time := $Center/Info/Stats/Time
onready var stat_time_label := $Center/Info/Stats/Time/Label
onready var stat_note := $Center/Info/Stats/Note
onready var stat_note_label := $Center/Info/Stats/Note/Label
onready var stat_die := $Center/Info/Stats/Die
onready var stat_die_label := $Center/Info/Stats/Die/Label

export var pos_left := 0
export var pos_right := 0

func _ready():
	keys(false, false, false, false, false)
	map.visible = false
	stats.visible = false

func keys(is_expand := true, _top := false, _arrows := true, _x := true, _c := true, _stack := false, _v := false):
	if spacer: spacer.size_flags_horizontal = spacer.SIZE_EXPAND_FILL if is_expand else spacer.SIZE_FILL
	if top: top.visible = _top
	if arrows: arrows.visible = _arrows
	if x: x.visible = _x
	if c: c.visible = _c
	if bottom: bottom.columns = 2 if _stack or !_arrows else 3
	if v: v.visible = _v

func labels(_x := "pick", _c := "back", _pause := "pause", _v := "clear"):
	x_label.text = _x
	c_label.text = _c
	pause_label.text = _pause
	v_label.text = _v

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
