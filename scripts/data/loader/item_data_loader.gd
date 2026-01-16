extends BaseDataLoader
class_name ItemDataLoader

func _get_file(file_: String) -> BaseFile:
	return ItemDataFile.new(file_)

func has_item(item_alias_: StringName) -> bool:
	for file_: ItemDataFile in files:
		if file_.data.alias == item_alias_:
			return true
			
	return false

func get_item(item_alias_: StringName) -> Dictionary:
	for file_: ItemDataFile in files:
		if file_.data.alias == item_alias_:
			return file_.data
	
	@warning_ignore("assert_always_true")
	assert(true, "Item not found.")
	
	return {}

func get_item_value(item_alias_: StringName) -> ItemValue:
	for file_: ItemDataFile in files:
		if file_.data.alias == item_alias_:
			return file_.get_item_value()

	@warning_ignore("assert_always_true")
	assert(true, "Item not found.")
	
	return null
