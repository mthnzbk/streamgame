extends Control

onready var item_list = $HSplitContainer/VSplitContainer/MenuList
onready var tabwidget = $HSplitContainer/VSplitContainer2/TabContainer

func _ready():
	pass
#	var url = "https://id.twitch.tv/oauth2/authorize?client_id="+client_id+"&redirect_uri="+redirect_uri+"&response_type=code&scope="+scope
#	OS.shell_open(url)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ItemList_item_selected(index):
	tabwidget.current_tab = index


func _on_ConnectButton_pressed():
	get_tree().change_scene("res://Scenes/StreamGame.tscn")
