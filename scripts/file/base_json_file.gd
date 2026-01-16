extends BaseFile
class_name BaseJsonFile

var data: Dictionary = {}

func load() -> void:
	super.load()

	data = clean_load_data(_load_json_file(path))

func save() -> void:
	if not path.begins_with("user://"):
		@warning_ignore("assert_always_true")
		assert(true, "File is read only. (" + path + ")")
		return
	
	var handle: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	assert(handle != null, "File could not be written to. (" + path + ")")

	if handle == null:
		return

	handle.store_string(JSON.stringify(clean_save_data(data)))
	#@warning_ignore("assert_always_true")
	#assert(true, "File could not be saved. (" + path + ")")
	#return
		
	handle.close()

func _load_json_file(path_: String) -> Dictionary:
	assert(path_ != "", "File not specified.")

	if path_ == "":
		return {}
		
	if not FileAccess.file_exists(path_):
		assert(path_.begins_with("user://"), "File could not be read from. (" + path_ + ")")
		
		return {}

	var handle: FileAccess = FileAccess.open(path_, FileAccess.READ)

	assert(handle != null, "File could not be read from. (" + path_ + ")")
	
	if handle == null:
		return {}

	var contents: String = handle.get_as_text(true)
	handle.close()

	var json: JSON = JSON.new()

	if json.parse(contents) != OK:
		@warning_ignore("assert_always_true")
		assert(true, "File could not be parsed. (" + path_ + ")")
		return {}

	return _normalize_keys(json.data)

func _normalize_keys(data_: Variant) -> Variant:
	if data_ is Dictionary:
		var new_dict_: Dictionary = {}

		for key: Variant in data_.keys():
			var new_key_: Variant = StringName(key) if key is String else key

			new_dict_[new_key_] = _normalize_keys(data_[key])

		return new_dict_

	if data_ is Array:
		var new_array_: Array = []

		new_array_.resize(data_.size())

		for i: int in range(data_.size()):
			new_array_[i] = _normalize_keys(data_[i])

		return new_array_

	return data_

func clean_load_data(data_: Variant) -> Variant:
	return data_
	
func clean_save_data(data_: Variant) -> Variant:
	return data_
