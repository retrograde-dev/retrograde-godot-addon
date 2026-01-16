class_name InputDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"default"):
		data_.default = {}
		
	if not data_.has(&"enabled"):
		data_.enabled = data_.default.keys()
	else:
		data_.enabled = data_.enabled.map(func(value: String) -> StringName: return StringName(value))
		
	data_.default = clean_input_events_load_data(data_.default)
	
	return data_

static func clean_input_events_load_data(data_: Dictionary) -> Dictionary:
	for key_: StringName in data_:
		for index_: int in data_[key_].size():
			data_[key_][index_] = clean_input_event_load_data(data_[key_][index_])
	
	return data_
	
static func clean_input_event_load_data(data_: Dictionary) -> Dictionary:
	match data_.type:
		"key":
			data_.type = Core.InputType.KEY
			data_.physical_keycode = int(data_.physical_keycode)
		"mouse_button":
			data_.type = Core.InputType.MOUSE_BUTTON
		"joypad_button":
			data_.type = Core.InputType.JOYPAD_BUTTON
		"joypad_motion":
			data_.type = Core.InputType.JOYPAD_MOTION
		_:
			data_.type = Core.InputType.NONE
			
	return data_

static func clean_input_events_save_data(data_: Dictionary) -> Dictionary:
	var save_data_: Dictionary = {}
	
	for key_: StringName in data_:
		save_data_[key_] = []
		
		for index_: int in data_[key_].size():
			var input_event_: Dictionary = clean_input_event_save_data(data_[key_][index_])
			if not input_event_.is_empty():
				save_data_[key_].push_back(input_event_)
	
	return save_data_
	
static func clean_input_event_save_data(data_: Dictionary) -> Dictionary:
	var save_data_: Dictionary = data_.duplicate()
	
	match save_data_.type:
		Core.InputType.KEY:
			save_data_.type = "key"
		Core.InputType.MOUSE_BUTTON:
			save_data_.type = "mouse_button"
		Core.InputType.JOYPAD_BUTTON:
			save_data_.type = "joypad_button"
		Core.InputType.JOYPAD_MOTION:
			save_data_.type = "joypad_motion"
		Core.InputType.NONE:
			return {}
			
	return save_data_
