extends Node2D


var bar_timer:Timer = Timer.new()
var hide_tween:Tween = Tween.new()

onready var bar_container := $PanelContainer
onready var auto_hide = $PanelContainer/BarContainer/VBoxContainer/PanelContainer/AutoHide
onready var quick_access_container = $PanelContainer/BarContainer/VBoxContainer/QuickAccessContainer

onready var avatars = $Avatars
var queue_avatars:Array = []
var queue_timer:Timer = Timer.new()

var barrier:StaticBody2D = StaticBody2D.new()
var barrier_collision:CollisionPolygon2D = CollisionPolygon2D.new()
var polygon:PoolVector2Array

var settings

func _ready():
	add_child(bar_timer)
	add_child(hide_tween)
	barrier.add_child(barrier_collision)
	add_child(barrier)
	add_child(queue_timer)
	
	settings = Ayarlar.load()
	var width = settings["general"]["window_width"]
	var height = settings["general"]["window_height"]
	
	
	bar_container.rect_size = Vector2(width, 58)
	auto_hide.set_pressed(settings["stream"]["auto_hide"])
	
	bar_timer.wait_time = 3
	bar_timer.connect("timeout", self, "auto_hide")
	
	if auto_hide.pressed:
		bar_timer.start()
	
	
	polygon = PoolVector2Array([Vector2(0, 0), Vector2(0, height), Vector2(width, height), Vector2(width, 0),
	Vector2(width+10, 0), Vector2(width+10, height+10), Vector2(-10, height+10), Vector2(-10, 0)])
	barrier_collision.set_polygon(polygon)
	
	IRCClient.client_connect()
	IRCClient.connect("user_join", self, "on_avatar_spawn")
	IRCClient.connect("user_part", self, "out_avatar_spawn")
	
	WebSocketIRC.listen()
	
	
	queue_timer.wait_time = 2
	queue_timer.start()
	queue_timer.connect("timeout", self, "on_spawn")



func _input(event):
	if event is InputEventMouseMotion and event.get_relative() != Vector2.ZERO and auto_hide.pressed:
		bar_container.show()
		bar_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
		bar_timer.start()
		


func auto_hide():
	hide_tween.interpolate_property(bar_container, "modulate", Color(1.0, 1.0, 1.0, 1.0),
		Color(1.0, 1.0, 1.0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	hide_tween.start()
	bar_timer.stop()
	yield(hide_tween, "tween_completed")
	bar_container.hide()


func _on_DisconnectButton_pressed():
	IRCClient.client_disconnect()
	get_tree().change_scene("res://Scenes/Settings.tscn")
	


func _on_AutoHide_toggled(button_pressed):
	settings = Ayarlar.load()
	if button_pressed:
		bar_timer.start()
		settings["stream"]["auto_hide"] = true
	else:
		bar_timer.stop()
		settings["stream"]["auto_hide"] = false
	
	Ayarlar.save(settings)


func _on_QuickAccessButton_toggled(button_pressed):
	quick_access_container.visible = button_pressed


func on_avatar_spawn(avatar_name:String) -> void:
	queue_avatars.append(avatar_name)

func on_spawn():
	var avatar_name = queue_avatars.pop_front()
	if avatar_name:
		var avatar := preload("res://Scenes/Avatar.tscn").instance()
		avatar.set_name(avatar_name)
		avatar.set_title(avatar_name)
		avatar.set_position($Position.position)
		avatars.add_child(avatar)

func out_avatar_spawn(avatar_name:String) -> void:
	for avatar in avatars.get_children():
		print(avatar)
		if avatar.get_name() == avatar_name:
			avatar.avatar_dead()
