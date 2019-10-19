extends Node

var file:File = File.new()
var default_settings_file:File = File.new()
var file_name = "ayarlar.json"
var file_path = "user://ayarlar/%s"%file_name
var content:String


func _ready():
	if !Directory.new().dir_exists("user://ayarlar"):
		Directory.new().make_dir("user://ayarlar")
		
	if !File.new().file_exists(file_path):
		file.open(file_path, File.WRITE)
		default_settings_file.open("res://default_settings.json", File.READ)
#		file.store_string(default_settings_file.get_as_text()) # ???
		default_settings_file.close()
		file.close()
		save({})
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func save(json): 
	file.open(file_path, File.WRITE)
	file.store_string(JSON.print(json, "    ", true)) # to_json()
	file.close()


func load():
	file.open(file_path, File.READ)
	content = file.get_as_text()
	file.close()
	return parse_json(content)
	
