extends BaseDataLoader
class_name AreaDataLoader

func _get_file(file_: String) -> BaseFile:
	return AreaDataFile.new(file_)

func has_area(area_alias_: StringName) -> bool:
	for file_: AreaDataFile in files:
		if file_.data.alias == area_alias_:
			return true
			
	return false

func get_area(area_alias_: StringName) -> Dictionary:
	for file_: AreaDataFile in files:
		if file_.data.alias == area_alias_:
			return file_.data
	
	@warning_ignore("assert_always_true")
	assert(true, "Area not found.")
	
	return {}
