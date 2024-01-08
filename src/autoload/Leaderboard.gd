extends Node

onready var api_file = load("silent_wolf_api_key.gd")
var api_key := ""
var is_online := false
var scores := {}

signal new_score

func _ready():
	is_online = api_file is Script
	if !is_online: return
	
	print("Leaderboard Shared.username: ", Shared.username)
	
	api_key = api_file.source_code.strip_edges().replace('"', "")
	SilentWolf.configure({
		"api_key": api_key,
		"game_id": "TinyCrate",
		"game_version": "1.0.0",
		"log_level": 1})

	SilentWolf.configure_scores({"open_scene_on_close": "res://scenes/MainPage.tscn"})
	
	
	yield(get_tree(), "idle_frame")
	SilentWolf.Scores.persist_score(Shared.username, 1)

func refresh_scores():
	if !is_online: return
	
	var a = Shared.maps.duplicate()
	var notes = []
	for i in a:
		notes.append(i + "-note")
	a.append_array(notes)
	for i in a:
		yield(SilentWolf.Scores.get_high_scores(0, i), "sw_scores_received")
		if SilentWolf.Scores.leaderboards.has(i):
			var s = SilentWolf.Scores.leaderboards[i]
			scores[i] = s

func refresh_score(map_name):
	if !is_online: return
	
	yield(SilentWolf.Scores.get_high_scores(0, map_name), "sw_scores_received")
	if SilentWolf.Scores.leaderboards.has(map_name):
		var s = SilentWolf.Scores.leaderboards[map_name]
		scores[map_name] = s
		emit_signal("new_score")
		#print(s)

func submit_score(board_name, score, _username := Shared.username):
	if !is_online: return
	
	SilentWolf.Scores.persist_score(_username , score, board_name)
	
