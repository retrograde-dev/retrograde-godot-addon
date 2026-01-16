extends BaseJsonFile
class_name SaveFile

const FILE_PATH: String = "user://save.json"

func _init() -> void:
	super._init(FILE_PATH)
