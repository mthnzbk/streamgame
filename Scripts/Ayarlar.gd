extends Node

var file:File = File.new()
var default_settings_file:File = File.new()
var file_name = "settings.bin"
var file_path = "user://{file_name}".format({"file_name": file_name})
var content:String

signal update_settings

func _ready():
	if !Directory.new().dir_exists("user://avatars"):
		Directory.new().make_dir("user://avatars")
		
	if !File.new().file_exists(file_path):
		file.open(file_path, File.WRITE)
		default_settings_file.open("res://default_settings.json", File.READ)
		file.store_string(default_settings_file.get_as_text()) # ???
		default_settings_file.close()
		file.close()
#		save({})
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func save(json): 
	file.open(file_path, File.WRITE)
	file.store_string(JSON.print(json, "    ", true)) # to_json()
	file.close()
	emit_signal("update_settings")


func load():
	file.open(file_path, File.READ)
	content = file.get_as_text()
	file.close()
	return parse_json(content)
	
