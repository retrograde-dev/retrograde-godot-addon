extends BaseJsonFile
class_name LevelDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	if not data_.has(&"alias"):
		data_.alias = path.get_basename().get_file()
		
	return LevelDataFormatter.clean_load_data(data_)
