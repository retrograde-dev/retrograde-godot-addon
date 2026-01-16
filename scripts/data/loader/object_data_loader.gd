extends BaseDataLoader
class_name ObjectDataLoader

func _get_file(file_: String) -> BaseFile:
	return ObjectDataFile.new(file_)
