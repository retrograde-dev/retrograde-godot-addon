extends BaseJsonFile
class_name ItemDataFile

var item_value_: ItemValue = null

func clean_load_data(data_: Variant) -> Variant:
	if not data_.has(&"alias"):
		data_.alias = path.get_basename().get_file()
	
	# If no scene assume same relative path.
	if not data_.has(&"scene") and path.begins_with("res://path/item/"):
		data_.scene = {
			&"path": "res://scenes/unit/item/" + path.substr(16, path.length() - 19) + "tscn"
		}
	
	return ItemDataFormatter.clean_load_data(data_)

func get_item_value() -> ItemValue:
	if item_value_ == null:
		item_value_ = ItemDataFormatter.get_value(data)
		
	return item_value_
