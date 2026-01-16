extends BaseJsonFile
class_name InputFile

const FILE_PATH: String = "user://inputs.json"

func _init() -> void:
	super._init(FILE_PATH)

func clean_load_data(data_: Variant) -> Variant:
	return InputDataFormatter.clean_input_events_load_data(data_)
	
func clean_save_data(data_: Variant) -> Variant:
	return InputDataFormatter.clean_input_events_save_data(data_)
