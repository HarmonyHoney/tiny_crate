extends Node

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

# The URL we will connect to
export var websocket_url = "wss://ws.silentwolfmp.com/server"
export var ws_room_init_url = "wss://ws.silentwolfmp.com/init"

signal ws_client_ready

# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	SWLogger.debug("Entering MPClient _ready function")
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		#SWLogger.debug("Unable to connect to WS server")
		print("Unable to connect to WS server")
		set_process(false)
	emit_signal("ws_client_ready")

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	SWLogger.debug("WS connection closed, clean: " + str(was_clean))
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	#SWLogger.debug("Connected with protocol: " + str(proto))
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#var test_packet = { "data": "Test packet" }
	#send_to_server(test_packet)
	#_client.get_peer(1).put_packet("Test packet".to_utf8())


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	#SWLogger.debug("Got data from WS server: " + str(_client.get_peer(1).get_packet().get_string_from_utf8()))
	print("Got data from WS server: ", _client.get_peer(1).get_packet().get_string_from_utf8())


func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


# send arbitrary data to backend
func send_to_server(message_type, data):
	data["message_type"] = message_type
	print("Sending data to server: " + str(data))
	_client.get_peer(1).put_packet(str(JSON.print(data)).to_utf8())


func init_mp_session(player_name):
	print("WSClient init_mp_session, sending initialisation packet to server")
	var init_packet = { 
		"player_name": player_name 
	}
	return send_to_server("init", init_packet)
	

func create_room():
	pass
