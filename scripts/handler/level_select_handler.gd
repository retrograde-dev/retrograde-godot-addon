class_name LevelSelectHandler

var _data: Dictionary

func _init() -> void:
	var level_select_file: LevelSelectDataFile = LevelSelectDataFile.new("res://data/ui/level_select.json")
	level_select_file.load()
	
	_data = level_select_file.data

func has_level(level_alias_: StringName) -> bool:
	return _data.levels.has(level_alias_)

func has_next_level(currnet_level_alias_: StringName) -> bool:
	var index: int = _data.levels.find(currnet_level_alias_)

	if index == -1:
		return false
		
	index += 1
	
	if index == _data.levels.size():
		return false
		
	return true
	
func get_next_level(currnet_level_alias_: StringName) -> StringName:
	var index: int = _data.levels.find(currnet_level_alias_)
	
	if index == -1:
		assert(false, "Level not found. (" + currnet_level_alias_ + ")")
		return &""
		
	index += 1
	
	if index == _data.levels.size():
		assert(false, "Level is last. (" + currnet_level_alias_ + ")")
		return &""
	
	return _data.levels[index]
