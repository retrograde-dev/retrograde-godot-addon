extends BaseJsonFile
class_name LevelSelectDataFile

func clean_load_data(data_: Variant) -> Variant:
	return LevelSelectDataFormatter.clean_load_data(data_)
