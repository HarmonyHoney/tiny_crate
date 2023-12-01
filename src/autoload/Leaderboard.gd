extends Node

onready var api_file = load("silent_wolf_api_key.gd")
var api_key := ""
var is_online := false
var username := "player_name"

func _ready():
	is_online = api_file is Script
	if !is_online: return
	
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	print("Leaderboard username: ", username)
	
	api_key = api_file.source_code.strip_edges().replace('"', "")
	SilentWolf.configure({
		"api_key": api_key,
		"game_id": "TinyCrate",
		"game_version": "1.0.0",
		"log_level": 1})

	SilentWolf.configure_scores({"open_scene_on_close": "res://scenes/MainPage.tscn"})
	
	yield(get_tree(), "idle_frame")
#	SilentWolf.Players.post_player_data("player_name", {"1-1" : 23}, false)
	SilentWolf.Scores.persist_score("player_name", 1)
	
	pass # Replace with function body.


func submit_score(board_name, score):
	SilentWolf.Scores.persist_score("not_" + username + "3", score, board_name)

func get_scores(board_name):
	yield(SilentWolf.Scores.get_high_scores(0, board_name), "sw_scores_received")
	var s = SilentWolf.Scores.leaderboards[board_name]
	
	print("Scores from the ", board_name, " leaderboard: " + str(s))
	for i in s:
		print(i["player_name"], ": ", -int(i["score"]))
	
	return s
	
