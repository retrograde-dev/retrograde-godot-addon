extends BaseJsonFile
class_name CreditsDataFile
	
func clean_load_data(data_: Variant) -> Variant:
	return CreditsDataFormatter.clean_load_data(data_)
