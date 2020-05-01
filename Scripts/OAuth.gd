extends Node

var client_id = "9zw309xshw6ogn5c7nyg4nj37m25kn"
var client_secret = "6wqqx4ezc6nikdq9xxo3pomuxmeqde"
var scope = "bits:read+channel_subscriptions+chat:read+chat:edit"
var redirect_uri = "http://localhost:5000/twitch"

var __validate = null
var __refresh = null
var __user_follows = null

var http:HTTPRequest = HTTPRequest.new()

func _ready():
	add_child(http)
	var settings = Ayarlar.load()
	if settings["twitch"]["access_token"] != "":
		if !validate_token().resume():
			refresh_token().resume()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func refresh_token():
	var settings = Ayarlar.load()
	http.connect("request_completed", self, "_refresh_token")
	var url = "https://id.twitch.tv/oauth2/token?grant_type=refresh_token&refresh_token={refresh_token}&client_id={client_id}&client_secret={client_secret}"
	url = url.format({"refresh_token":settings["twitch"]["refresh_token"],
					"client_id":client_id, "client_secret":client_secret})

	var headers := PoolStringArray()
	http.request(url, headers, true, HTTPClient.METHOD_POST)
	yield(http, "request_completed")
	http.disconnect("request_completed", self, "_refresh_token")
	
	if __refresh:
		settings["twitch"]["refresh_token"] = __refresh["refresh_token"]
		settings["twitch"]["access_token"] = __refresh["access_token"]
		Ayarlar.save(settings)
	
func _refresh_token(result, response_code, headers, body:PoolByteArray):
	if response_code == 200:
		__refresh =  parse_json(body.get_string_from_utf8())

func validate_token() -> bool:
	http.connect("request_completed", self, "_validate_token")
	var settings = Ayarlar.load()
	
	var headers := PoolStringArray()
	headers.append("Authorization: OAuth {token}".format({"token": settings["twitch"]["access_token"]}))
	http.request("https://id.twitch.tv/oauth2/validate", headers)
	yield(http, "request_completed")
	http.disconnect("request_completed", self, "_validate_token")
	print(__validate)
	if __validate:
		settings["twitch"]["login_id"] = __validate["user_id"]
		settings["twitch"]["login_name"] = __validate["login"]
		Ayarlar.save(settings)
		return true
		
	else: return false


func _validate_token(result, response_code, headers, body:PoolByteArray):
	if response_code == 200:
		__validate =  parse_json(body.get_string_from_utf8())
		

#func get_user():
#	var settings = Ayarlar.load()
#	http.connect("request_completed", self, "_validate_token")
#	var headers := PoolStringArray()
#	headers.append("Authorization: Bearer {token}".format({"token": settings["twitch"]["token"]}))
#	http.request("https://api.twitch.tv/helix/users", headers)

func user_follows():
	var settings = Ayarlar.load()
	http.connect("request_completed", self, "_user_follows")
	var url = "https://api.twitch.tv/helix/users/follows?to_id={user_id}&first=10"#first=1
	url = url.format({"user_id": settings["twitch"]["login_id"]})
	var headers := PoolStringArray()
	headers.append("Client-ID: {client_id}".format({"client_id": client_id}))
	http.request(url, headers)
	yield(http, "request_completed")
	http.disconnect("request_completed", self, "_user_follows")
	print(__user_follows)
	var total = __user_follows["total"]
	var follower = __user_follows["data"][0]["from_name"]
	print(total, " ", follower)

func _user_follows(result, response_code, headers, body:PoolByteArray):
	if response_code == 200:
		__user_follows =  parse_json(body.get_string_from_utf8())

