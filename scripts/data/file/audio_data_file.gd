extends BaseJsonFile
class_name AudioDataFile

func clean_load_data(data_: Variant) -> Variant:
	return AudioDataFormatter.clean_load_data(data_)
