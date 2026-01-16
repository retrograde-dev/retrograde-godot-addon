class_name CreditsDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	for index_: int in data_.order.size():
		data_.order[index_].alias = StringName(data_.order[index_].alias)
		data_.order[index_].names = data_.order[index_].names.map(func(value: String) -> StringName: return StringName(value))
		
	return data_
