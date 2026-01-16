extends BaseJsonFile
class_name SettingsDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	return SettingsDataFormatter.clean_load_data(data_)
