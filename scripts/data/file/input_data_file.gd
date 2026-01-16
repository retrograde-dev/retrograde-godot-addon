extends BaseJsonFile
class_name InputDataFile

func clean_load_data(data_: Variant) -> Variant:
	return InputDataFormatter.clean_load_data(data_)
