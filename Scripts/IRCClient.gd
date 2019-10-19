extends Control


var client := StreamPeerTCP.new()
var stream := PacketPeerStream.new()

const HOST := "irc.chat.twitch.tv"
const PORT := 6667
const BOTNAME := "BenceEmerik"

var CHANNEL := "benceemerik"
var FILTER_LIST = ["streamelements", "streamlabs"]
var USER_LIST = []
var ready = false
var first_msg_list:Array = []

signal connected
signal user_part(user)
signal user_join(user)
signal user_msg(user, msg)
var is_connection := false


func _ready():
	set_process(false)

func client_connect():
	var status := client.connect_to_host(HOST, PORT)

	if status == OK:
		is_connection = true
		stream.set_stream_peer(client)
		set_process(true)
		print("OK")

	connect("connected", self, "chat_connect")

		
func _process(delta):
		
	var status = client.get_status()

	if status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
#			game.emit_signal("disconnect_to_server")
		client.disconnect_from_host()
		set_process(false)

	elif status == StreamPeerTCP.STATUS_CONNECTED:
		if is_connection:
			is_connection = false
			print("CONNECT")
			emit_signal("connected")

		var bytes = stream.stream_peer.get_available_bytes()
		if  bytes > 0:
			var data_list = client.get_utf8_string(bytes).split("\r\n")
			data_list.remove(data_list.size()-1)
			
			for data in data_list:
				
				if "End of /NAMES list" in data:
					ready = true
				
				if ready:
					var data_parse = data.split(" ")
					var command = data_parse[1]
					var user = data_parse[0].split("!")[0]
					user = user.substr(1, user.length()-1)
#					print(data_parse)
#					data_parse.remove(data_parse.size()-1) #niye böyle yazmışız
					
					if data.substr(0, 4) == "PING":
						stream.stream_peer.put_data("PONG :tmi.twitch.tv".to_utf8())
						
					if command == "PRIVMSG":
						var msg = data_parse[3]
						msg = msg.substr(1, msg.length() -1)
						
						if user in USER_LIST:
							emit_signal("user_msg", user, msg)
							print("MESSAGE ", user, " ", msg)
						
					if command == "JOIN":
						if !user in FILTER_LIST:
							USER_LIST.append(user)
							emit_signal("user_join", user)
							print("JOIN ", user)
						
					if command == "PART":
						if !user in FILTER_LIST:
							USER_LIST.erase(user)
							emit_signal("user_part", user)
							print("PART ", user)

	elif status == StreamPeerTCP.STATUS_CONNECTING:
		is_connection = true

	else:
		client.disconnect_from_host()
		set_process(false)


func chat_connect():
	var text = "PASS oauth:%s \r\n"%Ayarlar.load()["twitch"]["access_token"]
	stream.stream_peer.put_data(text.to_utf8())
	text = "NICK %s \r\n"%BOTNAME
	stream.stream_peer.put_data(text.to_utf8())
	text = "JOIN #%s \r\n"%CHANNEL
	stream.stream_peer.put_data(text.to_utf8())
	text = "CAP REQ :twitch.tv/membership\r\n"
	stream.stream_peer.put_data(text.to_utf8())
	print("PUT")


func send_message(): pass


func _on_Button_pressed():
	BasicHttpServer.server_bind()
	var url = "https://id.twitch.tv/oauth2/authorize?client_id="+OAuth.client_id+"&redirect_uri="+OAuth.redirect_uri+"&response_type=code&scope="+OAuth.scope
	OS.shell_open(url)



