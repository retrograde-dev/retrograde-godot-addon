extends BaseJsonFile
class_name InputResourcesDataFile

func clean_load_data(data_: Variant) -> Variant:
	return InputResourcesDataFormatter.clean_load_data(data_)
