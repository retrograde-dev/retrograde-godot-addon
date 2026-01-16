class_name InputHandler

var resources: InputResourceHandler = null

var _file: InputFile
var _data: Dictionary

signal input_device_changed(input_device_: Core.InputDevice)
signal joypad_device_changed(input_joypad_: Core.InputJoypad)

func _init() -> void:
	if Core.ENABLE_INPUT_RESOURCES:
		resources = InputResourceHandler.new()
		
	_file = InputFile.new()
	
	if FileAccess.file_exists("res://data/input.json"):
		var file_: InputDataFile = InputDataFile.new("res://data/input.json")
		file_.load()
		_data = file_.data
	else:
		_data = {
			&"enabled": [],
			&"default": []
		}

func load() -> void:
	_file.load()

	for action_: StringName in _data.enabled:
		var input_events_: Array[Dictionary] = []
	
		# Input save file action
		if _file.data.has(action_):
			for input_event_: Dictionary in _file.data.get(action_, {}):
				if input_event_.is_empty():
					continue
					
				input_events_.push_back(input_event_)
		elif _data.default.has(action_):
			for input_event_: Dictionary in _data.default.get(action_, {}):
				if input_event_.is_empty():
					continue
					
				input_events_.push_back(input_event_)
		
		set_input_events_data(action_, input_events_)

func reset() -> void:
	for action_: StringName in _data.enabled:
		var input_events_: Array[Dictionary] = []
	
		if _data.default.has(action_):
			for input_event_: Dictionary in _data.default.get(action_, {}):
				if input_event_.is_empty():
					continue
					
				input_events_.push_back(input_event_)
		
		set_input_events_data(action_, input_events_)

func save() -> void:
	var data_: Dictionary = {}
	
	for action_: StringName in _data.enabled:
		data_[action_] = get_input_events_data(action_)

	_file.data = data_
	_file.save()

func update(input_event_: InputEvent) -> void:
	var input_device_changed_: bool = false
	var joypad_device_changed_: bool = false
	
	if input_event_ is InputEventJoypadButton or input_event_ is InputEventJoypadMotion:
		if Core.last_input_device != Core.InputDevice.JOYPAD:
			Core.last_input_device = Core.InputDevice.JOYPAD
			input_device_changed_ = true
		
		if Core.last_joypad_device != input_event_.device:
			Core.last_joypad_device = input_event_.device
			joypad_device_changed_ = true
	elif input_event_ is InputEventKey:
		if Core.last_input_device != Core.InputDevice.KEYBOARD:
			Core.last_input_device = Core.InputDevice.KEYBOARD
			input_device_changed_ = true
	elif input_event_ is InputEventMouseButton or input_event_ is InputEventMouseMotion:
		if Core.last_input_device != Core.InputDevice.MOUSE:
			Core.last_input_device = Core.InputDevice.MOUSE
			input_device_changed_ = true
		
	if input_device_changed_:
		input_device_changed.emit(Core.last_input_device)
		
	if joypad_device_changed_:
		joypad_device_changed.emit(get_input_joypad(Core.last_joypad_device))

func has_action(action_: StringName) -> bool:
	return _data.enabled.has(action_)

func get_input_events_data(action_: StringName) -> Array[Dictionary]:
	var data_: Array[Dictionary] = []
	
	var input_events_: Array[InputEvent] = get_input_events(action_)
	
	for input_event_: InputEvent in input_events_:
		data_.push_back(_unserialize_input_event(input_event_))
			
	return data_

func set_input_events_data(action_: StringName, input_events_data_: Array[Dictionary]) -> void:
	var input_events_: Array[InputEvent] = []
	
	for input_event_data_: Dictionary in input_events_data_:
		var input_event_: InputEvent = _serialize_input_event(input_event_data_)
		
		if input_event_ != null:
			input_events_.push_back(input_event_)
			
	set_input_events(action_, input_events_)

func _unserialize_input_event(input_event_: InputEvent) -> Dictionary:
	if input_event_ is InputEventKey:
		# Ignore modifiers
		input_event_.alt_pressed = false
		input_event_.command_or_control_autoremap = false
		input_event_.ctrl_pressed = false
		input_event_.meta_pressed = false
		input_event_.shift_pressed = false

		return {
			&"type": Core.InputType.KEY,
			&"physical_keycode": input_event_.physical_keycode,
			&"text": get_key_label(input_event_)
		}
	elif input_event_ is InputEventMouseButton:
		return {
			&"type": Core.InputType.MOUSE_BUTTON,
			&"button_index": input_event_.button_index,
			&"text": get_mouse_button_label(input_event_)
		}
	elif input_event_ is InputEventJoypadButton:
		return {
			&"type": Core.InputType.JOYPAD_BUTTON,
			&"button_index": input_event_.button_index,
			&"text": get_joypad_button_label(input_event_)
		}
	elif input_event_ is InputEventJoypadMotion:
		return {
			&"type": Core.InputType.JOYPAD_MOTION,
			&"axis": input_event_.axis,
			&"axis_value": input_event_.axis_value,
			&"text": get_joypad_motion_label(input_event_)
		}
	
	return {}
	
func _serialize_input_event(data_: Dictionary) -> InputEvent:
	var input_event_: InputEvent
	
	if data_.type == Core.InputType.KEY:
		input_event_ = InputEventKey.new()
		input_event_.physical_keycode = data_.physical_keycode
	elif data_.type == Core.InputType.MOUSE_BUTTON:
		input_event_ = InputEventMouseButton.new()
		input_event_.button_index = data_.button_index
	elif data_.type == Core.InputType.JOYPAD_BUTTON:
		input_event_ = InputEventJoypadButton.new()
		input_event_.button_index = data_.button_index
	elif data_.type == Core.InputType.JOYPAD_MOTION:
		input_event_ = InputEventJoypadMotion.new()
		input_event_.axis = data_.axis
		input_event_.axis_value = data_.axis_value
	else:
		return null
	
	return input_event_
	
func is_input_event_data_equal(input_event1_: Dictionary, input_event2_: Dictionary) -> bool:
	if input_event1_.type != input_event2_.type:
		return false
		
	if input_event1_.type == Core.InputType.KEY:
		if input_event1_.physical_keycode != input_event2_.physical_keycode:
			return false
	elif input_event1_.type == Core.InputType.MOUSE_BUTTON:
		if input_event1_.button_index != input_event2_.button_index:
			return false
	elif input_event1_.type == Core.InputType.JOYPAD_BUTTON:
		if input_event1_.button_index != input_event2_.button_index:
			return false
	elif input_event1_.type == Core.InputType.JOYPAD_MOTION:
		if input_event1_.axis != input_event2_.axis:
			return false
		
		if input_event1_.axis_value != input_event2_.axis_value:
			return false
		
	return true

func get_input_events(action_: StringName, input_type_: Core.InputType = Core.InputType.NONE) -> Array[InputEvent]:
	if input_type_ == Core.InputType.NONE:
		return InputMap.action_get_events(action_)
	
	var events_: Array[InputEvent] = InputMap.action_get_events(action_)
	
	var result_events_: Array[InputEvent] = []
	
	for event_: InputEvent in events_:
		if input_type_ == Core.InputType.KEY and event_ is InputEventKey:
			result_events_.push_back(event_)
		elif input_type_ == Core.InputType.MOUSE_BUTTON and event_ is InputEventMouseButton:
			result_events_.push_back(event_)
		elif input_type_ == Core.InputType.JOYPAD_BUTTON and event_ is InputEventJoypadButton:
			result_events_.push_back(event_)
		elif input_type_ == Core.InputType.JOYPAD_MOTION and event_ is InputEventJoypadMotion:
			result_events_.push_back(event_)
	
	return result_events_
	
func set_input_events(action_: StringName, input_events_: Array[InputEvent]) -> void:
	if not InputMap.has_action(action_):
		InputMap.add_action(action_)
	else:
		InputMap.action_erase_events(action_)
	
	for input_event_: InputEvent in input_events_:
		InputMap.action_add_event(action_, input_event_)

func get_key_input_events(action_: StringName) -> Array[InputEvent]:
	return get_input_events(action_, Core.InputType.KEY)
	
func get_mouse_button_input_events(action_: StringName) -> Array[InputEvent]:
	return get_input_events(action_, Core.InputType.MOUSE_BUTTON)

func get_joypad_button_input_events(action_: StringName) -> Array[InputEvent]:
	return get_input_events(action_, Core.InputType.JOYPAD_BUTTON)
	
func get_joypad_motion_input_events(action_: StringName) -> Array[InputEvent]:
	return get_input_events(action_, Core.InputType.JOYPAD_MOTION)

func get_key_label(input_event_: InputEventKey) -> String:
	var key_: String = input_event_.as_text().trim_suffix(" (Physical)")
	
	var no_key_label_keys_: Array[int] = [
		KEY_ALT,
		KEY_BACKSPACE,
		KEY_CTRL,
		KEY_DELETE,
		KEY_END,
		KEY_ESCAPE,
		KEY_HOME,
		KEY_PAGEDOWN,
		KEY_PAGEUP,
		KEY_SPACE,
		KEY_SHIFT,
	]
	
	if no_key_label_keys_.has(input_event_.physical_keycode):
		return key_

	var label_: String = tr("KEY")
	return label_.replace("[key]", key_)

func get_mouse_button_label(input_event_: InputEventMouseButton) -> String:
	return tr("MOUSE_BUTTON_" + str(input_event_.button_index))
	
func get_joypad_button_label(input_event_: InputEventJoypadButton) -> String:
	var joypad_key_: String = _get_joypad_translation_key(Core.last_joypad_device)
	
	if joypad_key_ != "":
		var key_: String = "JOYPAD_BUTTON_" + joypad_key_ + "_" + str(input_event_.button_index)
		var translation_: String = tr(key_)
		if translation_ != key_:
			return translation_
	
	return tr("JOYPAD_BUTTON_" + str(input_event_.button_index))

func get_joypad_motion_label(input_event_: InputEventJoypadMotion) -> String:
	var key_: String
	
	var joypad_key_: String = _get_joypad_translation_key(Core.last_joypad_device)
	
	if joypad_key_ != "":
		key_ = "JOYPAD_MOTION_" + joypad_key_ + "_" + str(input_event_.axis)
		if input_event_.axis_value < 0:
			key_ += "_MINUS"
		else:
			key_ += "_PLUS"
			
		var translation_: String = tr(key_)
		if translation_ != key_:
			return translation_
	
	key_ = "JOYPAD_MOTION_" + str(input_event_.axis)
	if input_event_.axis_value < 0:
		key_ += "_MINUS"
	else:
		key_ += "_PLUS"
		
	return tr(key_)

func _get_joypad_translation_key(device_: int) -> String:
	var input_joypad_: Core.InputJoypad = get_input_joypad(device_)

	match input_joypad_:
		Core.InputJoypad.NINTENDO_JOYCON_L_2:
			return "NINTENDO_JOYCON"
		Core.InputJoypad.NINTENDO_JOYCON_L_1:
			return "NINTENDO_JOYCON"
		Core.InputJoypad.NINTENDO_JOYCON_R_2:
			return "NINTENDO_JOYCON"
		Core.InputJoypad.NINTENDO_JOYCON_R_1:
			return "NINTENDO_JOYCON"
	
	if input_joypad_ != Core.InputJoypad.DEFAULT:
		return Core.InputJoypad.keys()[input_joypad_]
		
	return ""

func get_input_joypad(device_: int) -> Core.InputJoypad:
	var name_: String = Input.get_joy_name(device_).to_lower()
	#var guid_: String = Input.get_joy_guid(device_index_).to_lower()
	
	if "xbox" in name_ or "x-box" in name_ or "xinput" in name_:
		return Core.InputJoypad.XBOX

	if "dualsense" in name_ or "ps5" in name_ or "playstation 5" in name_:
		return Core.InputJoypad.PS5
		
	if "dualshock 4" in name_ or "ps4" in name_ or "playstation 4" in name_:
		return Core.InputJoypad.PS4

	if "steam" in name_ and "deck" in name_:
		return Core.InputJoypad.STEAM_DECK

	if "joy-con (l)" in name_ or "joycon l" in name_:
		if "2" in name_:
			return Core.InputJoypad.NINTENDO_JOYCON_L_2
			
		return Core.InputJoypad.NINTENDO_JOYCON_L_1
		
	if "joy-con (r)" in name_ or "joycon r" in name_:
		if "2" in name_:
			return Core.InputJoypad.NINTENDO_JOYCON_R_2
			
		return Core.InputJoypad.NINTENDO_JOYCON_R_1
	
	if "pro controller" in name_ or "nintendo switch pro" in name_:
		return Core.InputJoypad.NINTENDO_PRO
	
	return Core.InputJoypad.DEFAULT
