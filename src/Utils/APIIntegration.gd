extends Node

#const BASE_URL := "http://pm_api.ozzadar.com/"
const BASE_URL := "http://127.0.0.1:13337/"
onready var global_state = get_node("/root/GlobalState")

signal register_success
signal register_failed

signal login_success
signal login_failed

signal upload_success
signal upload_failed

signal download_level_success
signal download_level_failed

signal get_random_success
signal get_random_failed

signal get_level_success
signal get_level_failed

var httpServers = {}

func login(email: String, password: String):
	var client = _httpGet("users", "_login_request_completed")

	if client == null:
		#TODO: I should do error handling
		return  

	var url = BASE_URL + 'login'
	
	var body = {
		'email': email,
		'password': password    
	}
	
	print(client.request(url, [], false, HTTPClient.METHOD_POST, to_json(body)))
	pass
	
func register(email: String, nickname: String, password: String):
	var client = _httpGet("users", "_register_request_completed")
	if client == null:
		#TODO: I should do error handling
		return
	
	var url = BASE_URL + 'users'
	
	var body = {
		'email': email,
		'password': password,
		'nickname': nickname    
	}    
	
	client.request(url, [], false, HTTPClient.METHOD_POST, to_json(body))      
	pass

func get_levels_for_user():
	var token = global_state.currentPlayer.currentToken
	var id = global_state.currentPlayer.id
	
	var client = _httpGet("levels", "_all_levels_request_completed")
	if client == null:
		#TODO: I should do error handling
		return

	var url = BASE_URL + '/users/%s/levels' % [id]
	
	client.request(url, ["Authorization: Bearer %s" % [token]], false, HTTPClient.METHOD_GET)   
	
func get_levels_by_id(id):
	var token = global_state.currentPlayer.currentToken
	
	var client = _httpGet("levels", "_get_levels_by_id_completed")
	if client == null:
		#TODO: I should do error handling
		return

	var url = BASE_URL + '/levels/%s' % [id]
	
	client.request(url, ["Authorization: Bearer %s" % [token]], false, HTTPClient.METHOD_GET)  
	
func get_random_levels(count=5):
	var token = global_state.currentPlayer.currentToken
	
	var client = _httpGet("levels", "_random_levels_completed")
	if client == null:
		#TODO: I should do error handling
		return
		
	var url = BASE_URL + 'play/random?count=%s' % [count]

	client.request(url, ["Authorization: Bearer %s" % [token]], false, HTTPClient.METHOD_GET)
		
	pass
	
func uploadLevel(payload):
	var token = global_state.currentPlayer.currentToken
	
	var client = _httpGet("levels", "_upload_request_completed")
	if client == null:
		#TODO: I should do error handling
		return

	var url = BASE_URL + 'levels'

	client.request(url, ["Authorization: Bearer %s" % [token]], false, HTTPClient.METHOD_POST, to_json(payload))
		  
	pass

func download_level(id, with_meta):
	var token = global_state.currentPlayer.currentToken

	var client = _httpGet("levels", "_download_level_completed")
	if client == null:
		pass
		
	var url = BASE_URL + "levels/%s?withMeta=%s" % [id, with_meta]
	client.request(url, ["Authorization: Bearer %s" % [token]], false, HTTPClient.METHOD_GET, "")   
	pass
		
	
func _login_request_completed(_result, response_code, _headers, body):
	print('login complete')
	_httpFinished("users", "_login_request_completed")
	var response = parse_json(body.get_string_from_utf8())
		
	if response_code == 200:
		emit_signal("login_success", response.user_id, response.token)
	elif response_code == 0 || response_code == 502:
		emit_signal("login_failed", "Server Unavailable")
	else:
		emit_signal("login_failed", response.error)
	
	
func _register_request_completed(_result, response_code, _headers, body):
	_httpFinished("users", "_register_request_completed")
	var response = parse_json(body.get_string_from_utf8())
	
	if response_code == 201:
		emit_signal("register_success")
	else:
		emit_signal("register_failed", response.error)  
		
func _all_levels_request_completed(result, response_code, headers, body):
	print('response from all levels')
	
	_httpFinished("levels", "_all_levels_request_completed")

	var response = parse_json(body.get_string_from_utf8())
		
	if response_code == 200:
		global_state.currentPlayer.level_list = response.levels
	else:
		print('failed to get levels')
		print(body)
		pass
	
func _upload_request_completed(result, response_code, headers, body):
	_httpFinished("levels", "_upload_request_completed")    

	var response = parse_json(body.get_string_from_utf8())

	print(response)
	if response_code == 200:
		emit_signal("upload_success")
	else:
		emit_signal("upload_failed", response.error if response != null else null)
		
		
func _download_level_completed(result, response_code, headers, body):
	_httpFinished("levels", "_download_level_completed") 
	
	var response = parse_json(body.get_string_from_utf8())

	if response_code == 200:
		emit_signal("download_level_success", response)
	else:
		emit_signal("download_level_failed", response)
		
func _random_levels_completed(result, response_code, headers, body):
	_httpFinished("levels", "_random_levels_completed") 
	
	var response = parse_json(body.get_string_from_utf8())

	if response_code == 200:
		emit_signal("get_random_success", response.levels)
	else:
		emit_signal("get_random_failed", response)
	
func _get_levels_by_id_completed(result, response_code, headers, body):
	_httpFinished("levels", "_random_levels_completed") 
	
	var response = parse_json(body.get_string_from_utf8())

	if response_code == 200:
		emit_signal("get_level_success", response.level)
	else:
		emit_signal("get_level_failed", response)
	pass
		
func _httpGet(key, connectingMethod):
	if global_state.offline_mode:
		return null
		
	if !httpServers.has(key) || httpServers[key] == null:
		print('HTTP client %s being created connecting to %s' % [key, connectingMethod])
		httpServers[key] =  HTTPRequest.new()
		get_tree().get_root().add_child(httpServers[key])
		httpServers[key].connect("request_completed", self, connectingMethod)
		return httpServers[key]

	return null

func _httpFinished(key, connectingMethod):
	if httpServers.has(key) && httpServers[key] != null:
		print('HTTP client %s being destroyed' % [key])
		httpServers[key].queue_free()
		httpServers[key].disconnect("request_completed", self, connectingMethod)
		httpServers[key] =  null
		httpServers.erase(key)
  
func _exit_tree():
	
	pass
