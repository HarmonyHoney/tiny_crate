extends Node

const version = "0.6.20"
var godot_version = Engine.get_version_info().string

const SWHashing = preload("res://addons/silent_wolf/utils/SWHashing.gd")

onready var Auth = Node.new()
onready var Scores = Node.new()
onready var Players = Node.new()
onready var Multiplayer = Node.new()

#
# SILENTWOLF CONFIG: THE CONFIG VARIABLES BELOW WILL BE OVERRIDED THE 
# NEXT TIME YOU UPDATE YOUR PLUGIN!
#
# As a best practice, use SilentWolf.configure from your game's
# code instead to set the SilentWolf configuration.
#
# See https://silentwolf.com for more details
#
var config = {
	"api_key": "FmKF4gtm0Z2RbUAEU62kZ2OZoYLj4PYOURAPIKEY",
	"game_id": "YOURGAMEID",
	"game_version": "0.0.0",
	"log_level": 0
}

var scores_config = {
	"open_scene_on_close": "res://scenes/Splash.tscn"
}

var auth_config = {
	"redirect_to_scene": "res://scenes/Splash.tscn",
	"login_scene": "res://addons/silent_wolf/Auth/Login.tscn",
	"email_confirmation_scene": "res://addons/silent_wolf/Auth/ConfirmEmail.tscn",
	"reset_password_scene": "res://addons/silent_wolf/Auth/ResetPassword.tscn",
	"session_duration_seconds": 0,
	"saved_session_expiration_days": 30
}

var SWLogger = load("res://addons/silent_wolf/utils/SWLogger.gd")

var auth_script = load("res://addons/silent_wolf/Auth/Auth.gd")
var scores_script = load("res://addons/silent_wolf/Scores/Scores.gd")
var players_script = load("res://addons/silent_wolf/Players/Players.gd")
var multiplayer_script = load("res://addons/silent_wolf/Multiplayer/Multiplayer.gd")

func _init():
	print("SW Init timestamp: " + str(OS.get_time()))

func _ready():
	# The following line would keep SilentWolf working even if the game tree is paused.
	#pause_mode = Node.PAUSE_MODE_PROCESS
	print("SW ready start timestamp: " + str(OS.get_time()))
	Auth.set_script(auth_script)
	add_child(Auth)
	Scores.set_script(scores_script)
	add_child(Scores)
	Players.set_script(players_script)
	add_child(Players)
	Multiplayer.set_script(multiplayer_script)
	add_child(Multiplayer)
	print("SW ready end timestamp: " + str(OS.get_time()))

func configure(json_config):
	config = json_config

func configure_api_key(api_key):
	config.apiKey = api_key

func configure_game_id(game_id):
	config.game_id = game_id

func configure_game_version(game_version):
	config.game_version = game_version

##################################################################
# Log levels:
# 0 - error (only log errors)
# 1 - info (log errors and the main actions taken by the SilentWolf plugin) - default setting
# 2 - debug (detailed logs, including the above and much more, to be used when investigating a problem). This shouldn't be the default setting in production.
##################################################################
func configure_log_level(log_level):
	config.log_level = log_level

func configure_scores(json_scores_config):
	scores_config = json_scores_config

func configure_scores_open_scene_on_close(scene):
	scores_config.open_scene_on_close = scene
	
func configure_auth(json_auth_config):
	auth_config = json_auth_config

func configure_auth_redirect_to_scene(scene):
	auth_config.open_scene_on_close = scene
	
func configure_auth_session_duration(duration):
	auth_config.session_duration = duration


func free_request(weak_ref, object):
	if (weak_ref.get_ref()):
		object.queue_free()


func send_get_request(http_node, request_url):
	var headers = [
		"x-api-key: " + SilentWolf.config.api_key, 
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-godot-version: " + godot_version
	]
	if !http_node.is_inside_tree():
		yield(get_tree().create_timer(0.01), "timeout")
	SWLogger.debug("Method: GET")
	SWLogger.debug("request_url: " + str(request_url))
	SWLogger.debug("headers: " + str(headers))
	http_node.request(request_url, headers) 


func send_post_request(http_node, request_url, payload):
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + SilentWolf.config.api_key, 
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-godot-version: " + godot_version 
	]
	# TODO: this os specific to post_new_score - should be made generic 
	# or make a section for each type of post request with inetgrity check
	# (e.g. also push player data)
	if "post_new_score" in request_url:
		SWLogger.info("We're doing a post score")
		var player_name = payload["player_name"]
		var player_score = payload["score"]
		var timestamp = OS.get_system_time_msecs()
		var to_be_hashed = [player_name, player_score, timestamp]
		SWLogger.debug("send_post_request to_be_hashed: " + str(to_be_hashed))
		var hashed = SWHashing.hash_values(to_be_hashed)
		SWLogger.debug("send_post_request hashed: " + str(hashed))
		headers.append("x-sw-act-tmst: " + str(timestamp))
		headers.append("x-sw-act-dig: " + hashed)
	var use_ssl = true
	if !http_node.is_inside_tree():
		yield(get_tree().create_timer(0.01), "timeout")
	var query = JSON.print(payload)
	SWLogger.info("Method: POST")
	SWLogger.info("request_url: " + str(request_url))
	SWLogger.info("headers: " + str(headers))
	SWLogger.info("query: " + str(query))
	http_node.request(request_url, headers, use_ssl, HTTPClient.METHOD_POST, query)


func check_auth_ready():
	if !Auth:
		yield(get_tree().create_timer(0.01), "timeout")


func check_scores_ready():
	if !Scores:
		yield(get_tree().create_timer(0.01), "timeout")


func check_players_ready():
	if !Players:
		yield(get_tree().create_timer(0.01), "timeout")


func check_multiplayer_ready():
	if !Multiplayer:
		yield(get_tree().create_timer(0.01), "timeout")


func check_sw_ready():
	if !Auth or !Scores or !Players or !Multiplayer:
		yield(get_tree().create_timer(0.01), "timeout")
