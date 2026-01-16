extends BaseJsonFile
class_name AreaDataFile

func clean_load_data(data_: Variant) -> Variant:
	if not data_.has(&"alias"):
		data_.alias = path.get_basename().get_file()
		
	return AreaDataFormatter.clean_load_data(data_)
