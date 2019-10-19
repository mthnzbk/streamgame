extends Node

var server:TCP_Server = TCP_Server.new()
onready var request:HTTPRequest = HTTPRequest.new()

signal accept_data(site, data)
signal finish

func _ready():
	add_child(request)
	connect("accept_data", self, "_accept_data")
	request.connect("request_completed", self, "_get_token")
#	set_process(false)
#	server.listen(5000, "localhost")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if server.is_connection_available():
		var peer = server.take_connection()
		print("server", peer)
		var thread = Thread.new()
		var err = thread.start(self, "_handle", [peer, thread])
		
	#close
		print(server.is_listening(),"listening", server.is_connection_available(),"available")

func server_bind():
	print("server_bind")
#	set_process(true)
	server.listen(5000)
	
func _handle(args):
	var peer:StreamPeerTCP = args[0]
	var thread:Thread = args[1]
	
	if peer.get_available_bytes():
		var get_parameters = http_parse(peer.get_utf8_string(peer.get_available_bytes()))
		if typeof(get_parameters) == TYPE_DICTIONARY:
			emit_signal("accept_data", "twitch", get_parameters)
			peer.put_data("HTTP/1.1 301 Moved Permanently\r\n".to_ascii())
			peer.put_data("Location: https://metehan.us/\r\n".to_ascii())
	
	peer.disconnect_from_host()
	thread.call_deferred("wait_to_finish")
	
func http_parse(http_code):
	var dict:Dictionary
	var get_line:String = http_code.split("\r\n")[0].split(" ")[1]
	
	if get_line.substr(0, 7) == "/twitch":
		var parameters = get_line.substr(8, get_line.length()-8).split("&")
		
		for i in parameters:
			var d = i.split("=")
			dict[d[0]] = d[1]

		return dict
		
#	elif get_line.substr(0, 8) == "/youtube":
#		var parameters = get_line.substr(9, get_line.length()-9).split("&")
#
#		for i in parameters:
#			var d = i.split("=")
#			dict[d[0]] = d[1]
#
#		return dict
		
	else:
		return null

func _accept_data(site:String, data:Dictionary):
	server.stop()
	var url = "https://id.twitch.tv/oauth2/token?client_id={client_id}&client_secret={client_secret}&code={code}&grant_type=authorization_code&redirect_uri={redirect_uri}"
	url = url.format({"client_id": OAuth.client_id, "client_secret": OAuth.client_secret,
	"code": data["code"], "redirect_uri": OAuth.redirect_uri})

	var headers = PoolStringArray()
	headers.append("User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0")
	request.request(url, headers, true, HTTPClient.METHOD_POST)


func _get_token(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray):
	if result == HTTPRequest.RESULT_SUCCESS:
		if response_code == 200:
			var token = parse_json(body.get_string_from_utf8())
			var settings = Ayarlar.load()
			print(token)
			if settings.get("twitch") == null:
				settings["twitch"] = {}
				Ayarlar.save(settings)
				
			settings = Ayarlar.load()
			settings["twitch"]["access_token"] = token["access_token"]
			settings["twitch"]["refresh_token"] = token["refresh_token"]
			settings["twitch"]["expires_in"] = token["expires_in"]
			settings["twitch"]["scope"] = token["scope"]
			settings["twitch"]["token_type"] = token["token_type"]
			Ayarlar.save(settings)
			OAuth.validate_token()
			emit_signal("finish")
			
