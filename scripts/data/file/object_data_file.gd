extends BaseJsonFile
class_name ObjectDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	if not data_.has(&"alias"):
		data_.alias = path.get_basename().get_file()
		
	return ObjectDataFormatter.clean_load_data(data_)
