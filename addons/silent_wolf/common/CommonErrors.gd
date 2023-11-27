extends Node

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

func _ready():
	pass
	
static func check_status_code(status_code):
	SWLogger.debug("status_code: " + str(status_code))
	var check_ok = true
	if status_code == 0:
		no_connection_error()
		check_ok = false
	return check_ok

static func no_connection_error():
	SWLogger.error("Godot couldn't connect to the SilentWolf backend. There are several reasons why this might happen. See https://silentwolf.com/troubleshooting for more details. If the problem persists you can reach out to us at support@silentwolf.com")
