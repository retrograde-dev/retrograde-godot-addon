class_name BaseFile

var path: String
var has_loaded: bool = false
var has_saved: bool = false

func _init(path_: String) -> void:
	path = path_

func load() -> void:
	has_loaded = true
	
func save() -> void:
	has_saved = true
