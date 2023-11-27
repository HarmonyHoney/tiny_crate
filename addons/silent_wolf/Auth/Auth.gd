extends Node

const CommonErrors = preload("res://addons/silent_wolf/common/CommonErrors.gd")
const SWLocalFileStorage = preload("res://addons/silent_wolf/utils/SWLocalFileStorage.gd")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")
const UUID = preload("res://addons/silent_wolf/utils/UUID.gd")

signal sw_login_succeeded
signal sw_login_failed
signal sw_logout_succeeded
signal sw_registration_succeeded
signal sw_registration_user_pwd_succeeded
signal sw_registration_failed
signal sw_email_verif_succeeded
signal sw_email_verif_failed
signal sw_resend_conf_code_succeeded
signal sw_resend_conf_code_failed
signal sw_session_check_complete
signal sw_request_password_reset_succeeded
signal sw_request_password_reset_failed
signal sw_reset_password_succeeded
signal sw_reset_password_failed
signal sw_get_player_details_succeeded
signal sw_get_player_details_failed

var tmp_username = null
var logged_in_player = null
var logged_in_player_email = null
var logged_in_anon = false
var token = null
var id_token = null

var RegisterPlayer = null
var VerifyEmail = null
var ResendConfCode = null
var LoginPlayer = null
var ValidateSession = null
var RequestPasswordReset = null
var ResetPassword = null
var GetPlayerDetails = null

# wekrefs
var wrRegisterPlayer = null
var wrVerifyEmail = null
var wrResendConfCode = null
var wrLoginPlayer = null
var wrValidateSession = null
var wrRequestPasswordReset = null
var wrResetPassword = null
var wrGetPlayerDetails = null

var login_timeout = 0
var login_timer = null

var complete_session_check_wait_timer

func _ready():
	pass


func set_player_logged_in(player_name):
	logged_in_player  = player_name
	SWLogger.info("SilentWolf - player logged in as " + str(player_name))
	if SilentWolf.auth_config.has("session_duration_seconds") and typeof(SilentWolf.auth_config.session_duration_seconds) == 2:
		login_timeout = SilentWolf.auth_config.session_duration_seconds
	else:
		login_timeout = 0
	SWLogger.info("SilentWolf login timeout: " + str(login_timeout))
	if login_timeout != 0:
		setup_login_timer()


func get_anon_user_id() -> String:
	var anon_user_id = OS.get_unique_id()
	if anon_user_id == '':
		anon_user_id = UUID.generate_uuid_v4()
	print("anon_user_id: " + str(anon_user_id))
	return anon_user_id


func logout_player():
	logged_in_player = null
	# remove any player data if present
	SilentWolf.Players.clear_player_data()
	# remove stored session if any
	remove_stored_session()
	emit_signal("sw_logout_succeeded")


func register_player_anon(player_name=null) -> Node:
	var user_local_id: String = get_anon_user_id()
	RegisterPlayer = HTTPRequest.new()
	wrRegisterPlayer = weakref(RegisterPlayer)
	if OS.get_name() != "HTML5":
		RegisterPlayer.set_use_threads(true)
	get_tree().get_root().add_child(RegisterPlayer)
	RegisterPlayer.connect("request_completed", self, "_on_RegisterPlayer_request_completed")
	SWLogger.info("Calling SilentWolf to register an anonymous player")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "anon": true, "player_name": player_name, "user_local_id": user_local_id }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	RegisterPlayer.request("https://api.silentwolf.com/create_new_player", headers, true, HTTPClient.METHOD_POST, query)
	return self


func register_player(player_name, email, password, confirm_password):
	tmp_username = player_name
	RegisterPlayer = HTTPRequest.new()
	wrRegisterPlayer = weakref(RegisterPlayer)
	if OS.get_name() != "HTML5":
		RegisterPlayer.set_use_threads(true)
	get_tree().get_root().add_child(RegisterPlayer)
	RegisterPlayer.connect("request_completed", self, "_on_RegisterPlayer_request_completed")
	SWLogger.info("Calling SilentWolf to register a player")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "anon": false, "player_name": player_name, "email":  email, "password": password, "confirm_password": confirm_password }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	RegisterPlayer.request("https://api.silentwolf.com/create_new_player", headers, true, HTTPClient.METHOD_POST, query)
	return self


func register_player_user_password(player_name, password, confirm_password):
	tmp_username = player_name
	RegisterPlayer = HTTPRequest.new()
	wrRegisterPlayer = weakref(RegisterPlayer)
	if OS.get_name() != "HTML5":
		RegisterPlayer.set_use_threads(true)
	get_tree().get_root().add_child(RegisterPlayer)
	RegisterPlayer.connect("request_completed", self, "_on_RegisterPlayerUserPassword_request_completed")
	SWLogger.info("Calling SilentWolf to register a player")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "player_name": player_name, "password": password, "confirm_password": confirm_password }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	RegisterPlayer.request("https://api.silentwolf.com/create_new_player", headers, true, HTTPClient.METHOD_POST, query)
	return self


func verify_email(player_name, code):
	tmp_username = player_name
	VerifyEmail = HTTPRequest.new()
	wrVerifyEmail = weakref(VerifyEmail)
	if OS.get_name() != "HTML5":
		VerifyEmail.set_use_threads(true)
	get_tree().get_root().add_child(VerifyEmail)
	VerifyEmail.connect("request_completed", self, "_on_VerifyEmail_request_completed")
	SWLogger.info("Calling SilentWolf to verify email address for: " + str(player_name))
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "username":  player_name, "code": code }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	VerifyEmail.request("https://api.silentwolf.com/confirm_verif_code", headers, true, HTTPClient.METHOD_POST, query)
	return self


func resend_conf_code(player_name):
	ResendConfCode = HTTPRequest.new()
	wrResendConfCode = weakref(ResendConfCode)
	if OS.get_name() != "HTML5":
		ResendConfCode.set_use_threads(true)
	get_tree().get_root().add_child(ResendConfCode)
	ResendConfCode.connect("request_completed", self, "_on_ResendConfCode_request_completed")
	SWLogger.info("Calling SilentWolf to resend confirmation code for: " + str(player_name))
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "username": player_name }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	ResendConfCode.request("https://api.silentwolf.com/resend_conf_code", headers, true, HTTPClient.METHOD_POST, query)
	return self


func login_player(username, password, remember_me=false):
	tmp_username = username
	LoginPlayer = HTTPRequest.new()
	wrLoginPlayer = weakref(LoginPlayer)
	print("OS name: " + str(OS.get_name()))
	if OS.get_name() != "HTML5":
		LoginPlayer.set_use_threads(true)
	print("get_tree().get_root(): " + str(get_tree().get_root()))
	get_tree().get_root().add_child(LoginPlayer)
	LoginPlayer.connect("request_completed", self, "_on_LoginPlayer_request_completed")
	SWLogger.info("Calling SilentWolf to log in a player")
	var game_id = SilentWolf.config.game_id
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "username": username, "password": password, "remember_me": str(remember_me) }
	if SilentWolf.auth_config.has("saved_session_expiration_days") and typeof(SilentWolf.auth_config.saved_session_expiration_days) == 2:
		payload["remember_me_expires_in"] = str(SilentWolf.auth_config.saved_session_expiration_days)
	SWLogger.debug("SilentWolf login player payload: " + str(payload))
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]#print("login_player headers: " + str(headers))
	LoginPlayer.request("https://api.silentwolf.com/login_player", headers, true, HTTPClient.METHOD_POST, query)
	return self


func request_player_password_reset(player_name):
	RequestPasswordReset = HTTPRequest.new()
	wrRequestPasswordReset = weakref(RequestPasswordReset)
	print("OS name: " + str(OS.get_name()))
	if OS.get_name() != "HTML5":
		RequestPasswordReset.set_use_threads(true)
	get_tree().get_root().add_child(RequestPasswordReset)
	RequestPasswordReset.connect("request_completed", self, "_on_RequestPasswordReset_request_completed")
	SWLogger.info("Calling SilentWolf to request a password reset for: " + str(player_name))
	var game_id = SilentWolf.config.game_id
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "player_name": player_name }
	SWLogger.debug("SilentWolf request player password reset payload: " + str(payload))
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	RequestPasswordReset.request("https://api.silentwolf.com/request_player_password_reset", headers, true, HTTPClient.METHOD_POST, query)
	return self


func reset_player_password(player_name, conf_code, new_password, confirm_password):
	ResetPassword = HTTPRequest.new()
	wrResetPassword = weakref(ResetPassword)
	if OS.get_name() != "HTML5":
		ResetPassword.set_use_threads(true)
	get_tree().get_root().add_child(ResetPassword)
	ResetPassword.connect("request_completed", self, "_on_ResetPassword_request_completed")
	SWLogger.info("Calling SilentWolf to reset password for: " + str(player_name))
	var game_id = SilentWolf.config.game_id
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "player_name": player_name, "conf_code": conf_code, "password": new_password, "confirm_password": confirm_password }
	SWLogger.debug("SilentWolf request player password reset payload: " + str(payload))
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	ResetPassword.request("https://api.silentwolf.com/reset_player_password", headers, true, HTTPClient.METHOD_POST, query)
	return self


func get_player_details(player_name):
	GetPlayerDetails = HTTPRequest.new()
	wrRegisterPlayer = weakref(GetPlayerDetails)
	if OS.get_name() != "HTML5":
		GetPlayerDetails.set_use_threads(true)
	get_tree().get_root().add_child(GetPlayerDetails)
	GetPlayerDetails.connect("request_completed", self, "_on_GetPlayerDetails_request_completed")
	SWLogger.info("Calling SilentWolf to get player details")
	var game_id = SilentWolf.config.game_id
	var game_version = SilentWolf.config.game_version
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "player_name": player_name }
	var query = JSON.print(payload)
	var headers = [
		"Content-Type: application/json", 
		"x-api-key: " + api_key, 
		"x-sw-plugin-version: " + SilentWolf.version,
		"x-sw-game-id: " + SilentWolf.config.game_id,
		"x-sw-godot-version: " + SilentWolf.godot_version
	]
	#print("register_player headers: " + str(headers))
	GetPlayerDetails.request("https://api.silentwolf.com/get_player_details", headers, true, HTTPClient.METHOD_POST, query)
	return self


func _on_LoginPlayer_request_completed( result, response_code, headers, body ):
	SWLogger.info("LoginPlayer request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#LoginPlayer.queue_free()
	SilentWolf.free_request(wrLoginPlayer, LoginPlayer)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	#SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			if "lookup" in response.keys():
				print("remember me lookup: " + str(response.lookup))
				save_session(response.lookup, response.validator)
			if "validator" in response.keys():
				print("remember me validator: " + str(response.validator))
			SWLogger.info("SilentWolf login player success? : " + str(response.success))
			# TODO: get JWT token and store it
			# send a different signal depending on login success or failure
			if response.success:
				token = response.swtoken
				#id_token = response.swidtoken
				SWLogger.debug("token: " + token)
				set_player_logged_in(tmp_username)
				emit_signal("sw_login_succeeded")
			else:
				emit_signal("sw_login_failed", response.error)


func _on_RegisterPlayer_request_completed( result, response_code, headers, body ):
	SWLogger.info("RegisterPlayer request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#RegisterPlayer.queue_free()
	SilentWolf.free_request(wrRegisterPlayer, RegisterPlayer)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf create new player success? : " + str(response.success))
			# also get a JWT token here
			# send a different signal depending on registration success or failure
			if response.success:
				var anon = response.anon
				if anon:
					SWLogger.info("Anonymous Player registration succeeded")
					logged_in_anon = true
					if 'player_name' in response:
						logged_in_player = response.player_name
					elif 'player_local_id' in response: 
						logged_in_player = str("anon##" + response.player_local_id)
					else:
						logged_in_player = "anon##unknown"
					print("Anon registration, logged in player: " + str(logged_in_player))
				else: 
					# if email confirmation is enabled for the game, we can't log in the player just yet
					var email_conf_enabled = response.email_conf_enabled
					if email_conf_enabled:
						SWLogger.info("Player registration succeeded, but player still needs to verify email address")
					else:
						SWLogger.info("Player registration succeeded, email verification is disabled")
						logged_in_player = tmp_username
					emit_signal("sw_registration_succeeded")
			else:
				emit_signal("sw_registration_failed", response.error)


func _on_RegisterPlayerUserPassword_request_completed( result, response_code, headers, body ):
	SWLogger.info("RegisterPlayerUserPassword request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#RegisterPlayer.queue_free()
	SilentWolf.free_request(wrRegisterPlayer, RegisterPlayer)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf create new player success? : " + str(response.success))
			# also get a JWT token here
			# send a different signal depending on registration success or failure
			if response.success:
				# if email confirmation is enabled for the game, we can't log in the player just yet
				var email_conf_enabled = response.email_conf_enabled
				SWLogger.info("Player registration with username/password succeeded, player account autoconfirmed")
				logged_in_player = tmp_username
				emit_signal("sw_registration_user_pwd_succeeded")
			else:
				emit_signal("sw_registration_failed", response.error)


func _on_VerifyEmail_request_completed( result, response_code, headers, body ):
	SWLogger.info("VerifyEmail request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	SilentWolf.free_request(wrVerifyEmail, VerifyEmail)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerauth")
		else:
			SWLogger.info("SilentWolf verify email success? : " + str(response.success))
			# also get a JWT token here
			# send a different signal depending on registration success or failure
			if response.success:
				logged_in_player  = tmp_username
				emit_signal("sw_email_verif_succeeded")
			else:
				emit_signal("sw_email_verif_failed", response.error)


func _on_ResendConfCode_request_completed( result, response_code, headers, body ):
	SWLogger.info("ResendConfCode request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	SilentWolf.free_request(wrResendConfCode, ResendConfCode)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerauth")
		else:
			SWLogger.info("SilentWolf resend conf code success? : " + str(response.success))
			# also get a JWT token here
			# send a different signal depending on registration success or failure
			if response.success:
				emit_signal("sw_resend_conf_code_succeeded")
			else:
				emit_signal("sw_resend_conf_code_failed", response.error)


func _on_RequestPasswordReset_request_completed( result, response_code, headers, body ):
	SWLogger.info("RequestPasswordReset request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	SilentWolf.free_request(wrRequestPasswordReset, RequestPasswordReset)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerauth")
		else:
			SWLogger.info("SilentWolf request player password reset success? : " + str(response.success))
			if response.success:
				emit_signal("sw_request_password_reset_succeeded")
			else:
				emit_signal("sw_request_password_reset_failed", response.error)


func _on_ResetPassword_request_completed( result, response_code, headers, body ):
	SWLogger.info("ResetPassword request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	SilentWolf.free_request(wrResetPassword, ResetPassword)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerauth")
		else:
			SWLogger.info("SilentWolf reset player password success? : " + str(response.success))
			if response.success:
				emit_signal("sw_reset_password_succeeded")
			else:
				emit_signal("sw_reset_password_failed", response.error)


func setup_login_timer():
	login_timer = Timer.new()
	login_timer.set_one_shot(true)
	login_timer.set_wait_time(login_timeout)
	login_timer.connect("timeout", self, "on_login_timeout_complete")
	add_child(login_timer)


func on_login_timeout_complete():
	logout_player()


# store lookup (not logged in player name) and validator in local file
func save_session(lookup, validator):
	var path = "user://swsession.save"
	var session_data = {
		"lookup": lookup,
		"validator": validator
	}
	SWLocalFileStorage.save_data("user://swsession.save", session_data, "Saving SilentWolf session: ")


func remove_stored_session():
	var path = "user://swsession.save"
	SWLocalFileStorage.remove_data(path, "Removing SilentWolf session if any: " )


# reload lookup and validator and send them back to the server to auto-login user
func load_session() -> Dictionary:
	var sw_session_data = null
	var path = "user://swsession.save"
	sw_session_data = SWLocalFileStorage.get_data(path)
	if sw_session_data == null:
		SWLogger.debug("No local SilentWolf session stored, or session data stored in incorrect format")
	SWLogger.info("Found session data: " + str(sw_session_data))
	return sw_session_data


func auto_login_player():
	var sw_session_data = load_session()
	if sw_session_data:
		SWLogger.debug("Found saved SilentWolf session data, attempting autologin...")
		var lookup = sw_session_data.lookup
		var validator = sw_session_data.validator
		# whether successful or not, in the end the "sw_session_check_complete" signal will be emitted
		validate_player_session(lookup, validator)
	else:
		SWLogger.debug("No saved SilentWolf session data, so no autologin will be performed")
		# the following is needed to delay the emission of the signal just a little bit, otherwise the signal is never received!
		setup_complete_session_check_wait_timer()
		complete_session_check_wait_timer.start()
	return self


# Signal can't be emitted directly from auto_login_player() function
# otherwise it won't connect back to calling script
func complete_session_check(return_value=null):
	SWLogger.debug("emitting signal....")
	emit_signal("sw_session_check_complete", return_value)


func validate_player_session(lookup, validator, scene=get_tree().get_current_scene()):
	ValidateSession = HTTPRequest.new()
	wrValidateSession = weakref(ValidateSession)
	if OS.get_name() != "HTML5":
		ValidateSession.set_use_threads(true)
	scene.add_child(ValidateSession)
	ValidateSession.connect("request_completed", self, "_on_ValidateSession_request_completed")
	SWLogger.info("Calling SilentWolf to validate an existing player session")
	var game_id = SilentWolf.config.game_id
	var api_key = SilentWolf.config.api_key
	var payload = { "game_id": game_id, "lookup": lookup, "validator": validator }
	SWLogger.debug("Validate session payload: " + str(payload))
	var query = JSON.print(payload)
	var headers = ["Content-Type: application/json", "x-api-key: " + api_key, "x-sw-plugin-version: " + SilentWolf.version]
	ValidateSession.request("https://api.silentwolf.com/validate_remember_me", headers, true, HTTPClient.METHOD_POST, query)
	return self


func _on_ValidateSession_request_completed( result, response_code, headers, body ):
	SWLogger.info("SilentWolf - ValidateSession request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#ValidateSession.queue_free()
	SilentWolf.free_request(wrValidateSession, ValidateSession)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/leaderboard")
		else:
			SWLogger.info("SilentWolf validate session success? : " + str(response.success))
			if response.success:
				set_player_logged_in(response.player_name)
				complete_session_check(logged_in_player)
			else:
				complete_session_check(response.error)


func _on_GetPlayerDetails_request_completed( result, response_code, headers, body ):
	SWLogger.info("SilentWolf - GetPlayerDetails request completed")
	var status_check = CommonErrors.check_status_code(response_code)
	#ValidateSession.queue_free()
	SilentWolf.free_request(wrGetPlayerDetails, GetPlayerDetails)
	SWLogger.debug("response headers: " + str(response_code))
	SWLogger.debug("response headers: " + str(headers))
	SWLogger.debug("response body: " + str(body.get_string_from_utf8()))
	
	if status_check:
		var json = JSON.parse(body.get_string_from_utf8())
		var response = json.result
		SWLogger.debug("reponse: " + str(response))
		if "message" in response.keys() and response.message == "Forbidden":
			SWLogger.error("You are not authorized to call the SilentWolf API - check your API key configuration: https://silentwolf.com/playerauth")
		else:
			SWLogger.info("SilentWolf get player details success? : " + str(response.success))
			if response.success:
				emit_signal("sw_get_player_details_succeeded", response.player_details)
			else:
				emit_signal("sw_get_player_details_failed")


func setup_complete_session_check_wait_timer():
	complete_session_check_wait_timer = Timer.new()
	complete_session_check_wait_timer.set_one_shot(true)
	complete_session_check_wait_timer.set_wait_time(0.01)
	complete_session_check_wait_timer.connect("timeout", self, "complete_session_check")
	add_child(complete_session_check_wait_timer)
