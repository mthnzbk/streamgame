extends Control

onready var item_list = $HSplitContainer/VSplitContainer/MenuList
onready var tabwidget = $HSplitContainer/VSplitContainer2/TabContainer
onready var connect_button = $HSplitContainer/VSplitContainer/ConnectButton

onready var language = $HSplitContainer/VSplitContainer2/PanelContainer/MarginContainer/HBoxContainer/LangOptionButton

onready var max_avatar_spawn = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/HBoxContainer/MaxAvatarSpawn
onready var who = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/WhoButton
onready var how = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/HowButton
onready var auto_connect = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer3/EnableAutoConnect
onready var hide_mouse_cursor = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer4/HideMouseCursor
onready var window_width = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer6/VBoxContainer2/HBoxContainer/WindowWidth
onready var window_height = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer6/VBoxContainer2/HBoxContainer/WindowHeight
onready var default_avatar = $HSplitContainer/VSplitContainer2/TabContainer/General/MarginContainer/VBoxContainer/VBoxContainer2/VBoxContainer/HBoxContainer2/DefaultAvatarButton
onready var twitch_button = $HSplitContainer/VSplitContainer2/TabContainer/LoginDetails/MarginContainer/VBoxContainer/Twitch/TwitchButton

onready var whitelist = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/WhiteList
onready var blacklist = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/BlackList
onready var modlist = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer3/ModList

onready var whiteline = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/HBoxContainer/WhiteLineEdit
onready var whitebutton = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/HBoxContainer/WhiteButton
onready var blackline = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/HBoxContainer/BlackLineEdit
onready var blackbutton = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/HBoxContainer/BlackButton
onready var modline = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer3/HBoxContainer/ModLineEdit
onready var modbutton = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer3/HBoxContainer/ModButton
onready var deletebutton = $HSplitContainer/VSplitContainer2/TabContainer/UserEditing/MarginContainer/VBoxContainer/HBoxContainer5/DeleteAllButton


var settings


func _ready():
	reload()

func reload() -> void:
	settings = Ayarlar.load()
	language.select(settings["language"] or 0)
	max_avatar_spawn.set_value(settings["general"]["max_avatars"])
	who.select(settings["general"]["spawning"][0] or 0)
	how.select(settings["general"]["spawning"][1] or 0)
	auto_connect.set_pressed(settings["general"]["auto_connect"])
	hide_mouse_cursor.set_pressed(settings["general"]["hide_mouse_cursor"])
	
	window_width.set_text(str(settings["general"]["window_width"]))
	window_height.set_text(str(settings["general"]["window_height"]))
	OS.set_window_size(Vector2(int(settings["general"]["window_width"]), int(settings["general"]["window_height"])))
	
	default_avatar.select(settings["general"]["default_avatar"] or 0)
	if settings["twitch"]["access_token"] != "":
		connect_button.disabled = false
		twitch_button.set_button_icon(load("res://Textures/checked.png"))
	
	whitelist.clear()
	blacklist.clear()
	modlist.clear()
	for item in settings["user_editing"]["whitelist"]:
		whitelist.add_item(item)

	for item in settings["user_editing"]["blacklist"]:
		blacklist.add_item(item)
		
	for item in settings["user_editing"]["modlist"]:
		modlist.add_item(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ItemList_item_selected(index:int):
	if !item_list.is_item_disabled(index):
		tabwidget.current_tab = index


func _on_ConnectButton_pressed():
	get_tree().change_scene("res://Scenes/StreamGame.tscn")


func _on_OpenFolderButton_pressed():
	OS.shell_open(OS.get_user_data_dir())


func _on_DocButton_pressed():
	OS.shell_open("https://streamgame.com/doc")


func _on_SaveButton_pressed():
	settings["general"]["max_avatars"] = max_avatar_spawn.value
	settings["general"]["spawning"] = [who.get_selected_id(), how.get_selected_id()]
	settings["general"]["auto_connect"] = auto_connect.pressed
	settings["general"]["hide_mouse_cursor"] = hide_mouse_cursor.pressed
	settings["general"]["default_avatar"] = default_avatar.get_selected_id()
	settings["general"]["window_width"] = int(window_width.get_text())
	settings["general"]["window_height"] = int(window_height.get_text())
	settings["language"] = language.get_selected_id()
	Ayarlar.save(settings)
	reload()


func _on_DeleteAllButton_pressed():
	var conf_dialog = $ConfirmationDialog
	conf_dialog.popup_centered_clamped()
	conf_dialog.show_modal()
	yield(conf_dialog, "confirmed")
	print("confir")


func _on_TwitchButton_pressed():
	BasicHttpServer.server_bind()
	var url = "https://id.twitch.tv/oauth2/authorize?client_id="+OAuth.client_id+"&redirect_uri="+OAuth.redirect_uri+"&response_type=code&scope="+OAuth.scope
	OS.shell_open(url)



func _on_WhiteButton_pressed():
	if whiteline.get_text() != "":
		if !whiteline.get_text() in whitelist.items:
			whitelist.add_item(whiteline.get_text())
			settings["user_editing"]["whitelist"].append(whiteline.get_text())
		whiteline.clear()


func _on_BlackButton_pressed():
	if blackline.get_text() != "":
		if !blackline.get_text() in blacklist.items:
			blacklist.add_item(blackline.get_text())
			settings["user_editing"]["blacklist"].append(blackline.get_text())
		blackline.clear()


func _on_ModButton_pressed():
	if modline.get_text() != "":
		if !modline.get_text() in modlist.items:
			modlist.add_item(modline.get_text())
			settings["user_editing"]["modlist"].append(modline.get_text())
		modline.clear()
