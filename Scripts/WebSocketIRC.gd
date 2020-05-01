extends Node

var client:WebSocketClient = WebSocketClient.new()
var is_connect = false
var ping_timer:Timer = Timer.new()
var ping_timeout_timer:Timer = Timer.new()

signal message(user, message, args)
#signal subscribed(subscriber)
#signal donate(donor)
#signal cheer(user)

func _ready():
	set_process(false)
	add_child(ping_timer)
	add_child(ping_timeout_timer)
	
func listen():
	set_process(true)
	client.connect("connection_established", self, "connection_established")
	client.connect("connection_closed", self, "connection_closed")
	client.connect("connection_error", self, "connection_error")
	client.connect("data_received", self, "data_received")
	client.connect("server_close_request", self, "server_close_request")
	
	
	ping_timer.wait_time = 4*60
	ping_timer.connect("timeout", self, "send_ping")
	
	ping_timeout_timer.wait_time = 10
	ping_timeout_timer.connect("timeout", self, "ping_timeout")
	
	repeat_connect()
	
func stop():
	client.disconnect_from_host()


func repeat_connect():
	
	client.connect_to_url("wss://pubsub-edge.twitch.tv")#wss://pubsub-edge.twitch.tv


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if client.get_connection_status() == client.CONNECTION_CONNECTING || client.get_connection_status() == client.CONNECTION_CONNECTED:
#		client.poll()
		
	if client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		print(client.get_connection_status())
		return
	client.poll()

func send_ping():
	send_data({"type": "PING"})
	ping_timeout_timer.start()
	
func ping_timeout():
	ping_timeout_timer.stop()
	repeat_connect()

func data_received():
	if client.get_peer(1).get_available_packet_count() > 0 :
		var packet = parse_json(client.get_peer(1).get_packet().get_string_from_utf8())
		var is_string = client.get_peer(1).was_string_packet()
		print(packet)
		
		if packet["type"] == "PONG":
			print("pong")
			var listen = {
			"type": "LISTEN",
			"data": {
				"topics": [
						"channel-bits-events-v2.{channel_id}".format({"channel_id": Ayarlar.load()["twitch"]["login_id"]}),
						"channel-subscribe-events-v1.{channel_id}".format({"channel_id": Ayarlar.load()["twitch"]["login_id"]})
				],
				"auth_token": Ayarlar.load()["twitch"]["access_token"]
				}
			}
			
			send_data(listen)

		if packet["type"] == "RECONNECT":
			yield(get_tree().create_timer(10), "timeout")
			repeat_connect()

		if packet["type"] == "MESSAGE":
			var message = parse_json(packet["type"]["message"])
			if message["data"]["context"] == "cheer":
				emit_signal("message", message["data"]["user_name"], "cheer")
				
				
			if "subgift" in message["data"]["context"]:
				emit_signal("message", message["data"]["user_name"], "subgift", message["data"]["recipient_user_name"])
				
			
			if "anonsubgift" in message["data"]["context"]:
				emit_signal("message", message["data"]["user_name"], "anonsubgift", message["data"]["recipient_user_name"])
				
			
			if "sub" in message["data"]["context"]:
				emit_signal("message", message["data"]["user_name"], "sub")
				


		if packet["type"] == "RESPONSE":
			if packet["error"] != "": #ERR_BADMESSAGE, ERR_BADAUTH, ERR_SERVER, ERR_BADTOPIC
				pass
	

	
func peer_connect(id):
	print(id, " peer")
	
func client_connect(pro):
	print("client connect ", pro)
	
func client_disconnect():
	print("disconnect")
	repeat_connect()
	
func send_data(data):
	client.get_peer(1).put_packet(to_json(data).to_utf8())
	
func connection_established(x):
	print(x,"est")
	client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	send_ping()
	ping_timer.start()
	
func connection_closed(close):
	print("close ", close)
	ping_timer.stop()
	repeat_connect()
	
func connection_error():
	print("err")
	ping_timer.stop()
	
func server_close_request(code, reason):
	print(code," s ", reason)
	ping_timer.stop()
