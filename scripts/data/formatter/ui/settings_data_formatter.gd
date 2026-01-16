class_name SettingsDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"enabled"):
		data_.enabled = {}
		
	if not data_.has(&"layout"):
		data_.layout = {}
		
	if not data_.has(&"settings"):
		data_.settings = {}
		
	data_.enabled = data_.enabled.map(func(value: String) -> StringName: return StringName(value))
	
	for index_: int in data_.layout.size():
		data_.layout[index_].alias = StringName(data_.layout[index_].get(&"alias", &""))
		var items_: Array[StringName] = []
		
		for items_index_: int in data_.layout[index_].items.size():
			var item_: StringName = StringName(data_.layout[index_].items[items_index_])
			
			if data_.enabled.has(item_) and data_.settings.has(item_):
				items_.push_back(item_)
			
		data_.layout[index_].items = items_
		
	for key_: StringName in data_.settings:
		data_.settings[key_].type = StringName(data_.settings[key_].type)
		
	return data_
