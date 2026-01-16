class_name ControlsDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"layout"):
		data_.layout = []
		
	if not data_.has(&"groups"):
		data_.groups = {}
		
	if not data_.has(&"overlaps"):
		data_.overlaps = {}

	for key_: StringName in data_.groups:
		data_.groups[key_] = data_.groups[key_].map(func(value: String) -> StringName: return StringName(value))
	
	for key_: StringName in data_.overlaps:
		data_.overlaps[key_] = data_.overlaps[key_].map(func(value: String) -> StringName: return StringName(value))
	
	for index_: int in data_.layout.size():
		data_.layout[index_].alias = StringName(data_.layout[index_].get(&"alias", &""))
		var items_: Array[StringName] = []
		
		for items_index_: int in data_.layout[index_].items.size():
			var item_: StringName = StringName(data_.layout[index_].items[items_index_])
			
			if Core.inputs.has_action(item_):
				items_.push_back(item_)
			elif data_.groups.has(item_):
				for group_action_: StringName in data_.groups[item_]:
					if Core.inputs.has_action(group_action_):
						items_.push_back(item_)
						break
			
		data_.layout[index_].items = items_

	return data_
