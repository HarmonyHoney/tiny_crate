extends Node

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd") 

# Retrieves data stored as JSON in local storage
# example path: "user://swsession.save"

# store lookup (not logged in player name) and validator in local file
static func save_data(path: String, data: Dictionary, debug_message: String='Saving data to file in local storage: ') -> void:
	var local_file = File.new()
	local_file.open(path, File.WRITE)
	SWLogger.debug(debug_message + str(data))
	local_file.store_line(to_json(data))
	local_file.close()


static func remove_data(path: String, debug_message: String='Removing data from file in local storage: ') -> void:
	var local_file = File.new()
	local_file.open(path, File.WRITE)
	var data = {}
	SWLogger.debug(debug_message + str(data))
	local_file.store_line(to_json(data))
	local_file.close()


static func does_file_exist(path: String, file: File=null) -> bool:
	var local_file = file
	if local_file == null:
		local_file = File.new()
	return local_file.file_exists(path)


static func get_data(path: String) -> Dictionary:
	var local_file = File.new()
	var return_data = null
	if does_file_exist(path, local_file):
		local_file.open(path, File.READ)
		var data = parse_json(local_file.get_as_text())
		if typeof(data) == TYPE_DICTIONARY:
			return_data = data
		else:
			SWLogger.debug("Invalid data in local storage")
	else:
		SWLogger.debug("Could not find any data at: " + str(path))
	return return_data
