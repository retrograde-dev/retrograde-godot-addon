extends BaseJsonFile
class_name HUDDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	return HUDDataFormatter.clean_load_data(data_)
