class_name LevelSelectHandler

var _data: Dictionary
var _levels: Array[StringName] = []

func _init() -> void:
	var level_select_file: LevelSelectDataFile = LevelSelectDataFile.new("res://data/ui/level_select.json")
	level_select_file.load()
	
	_data = level_select_file.data
	
	for layout_: Dictionary in _data.layout:
		for level_alias_: StringName in layout_.levels:
			_levels.push_back(level_alias_)
	
func get_layout() -> Array:
	return _data.layout
	
func has_level(level_alias_: StringName) -> bool:
	return _levels.has(level_alias_)

func has_next_level(currnet_level_alias_: StringName) -> bool:
	var index: int = _levels.find(currnet_level_alias_)

	if index == -1:
		return false
		
	index += 1
	
	if index == _levels.size():
		return false
		
	return true
	
func get_next_level(currnet_level_alias_: StringName) -> StringName:
	var index: int = _levels.find(currnet_level_alias_)
	
	if index == -1:
		assert(false, "Level not found. (" + currnet_level_alias_ + ")")
		return &""
		
	index += 1
	
	if index == _levels.size():
		assert(false, "Level is last. (" + currnet_level_alias_ + ")")
		return &""
	
	return _levels[index]
