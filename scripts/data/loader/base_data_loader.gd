class_name BaseDataLoader

var files: Array[BaseFile]

var path: String
var has_loaded: bool = false
	
func _init(path_: String) -> void:
	path = path_

func load() -> void:
	has_loaded = true
	files = _load_files(path)

func _load_files(path_: String) -> Array[BaseFile]:
	var files_: Array[BaseFile] = []
	
	var dir_: DirAccess = DirAccess.open(path_)
	
	if dir_ == null:
		return files_

	dir_.list_dir_begin()
	
	var file_name_: String = dir_.get_next()

	while file_name_ != "":
		if dir_.current_is_dir():
			var sub_map: Array[BaseFile] = _load_files(path_ + "/" + file_name_)
			files_.append_array(sub_map)
		elif file_name_.ends_with(".json"):
			var file_: BaseFile = _get_file(path_ + "/" + file_name_)
			file_.load()
			
			files_.push_back(file_)
				
		file_name_ = dir_.get_next()

	dir_.list_dir_end()
	
	return files_

func _get_file(_file: String) -> BaseFile:
	return null
	
func _iter_init(iter_: Array) -> bool:
	iter_[0] = 0
	return iter_[0] < files.size()

func _iter_next(iter_: Array) -> bool:
	iter_[0] += 1
	return iter_[0] < files.size()

func _iter_get(iter_: Variant) -> BaseFile:
	return files[iter_] if iter_ < files.size() else null
