class_name LevelSelectDataFormatter
 
static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has("levels"):
		data_.levels = []
	
	for index_: int in data_.levels.size():
		data_.levels[index_] = StringName(data_.levels[index_])

	return data_
