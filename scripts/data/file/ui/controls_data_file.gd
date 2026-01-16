extends BaseJsonFile
class_name ControlsDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	return ControlsDataFormatter.clean_load_data(data_)
