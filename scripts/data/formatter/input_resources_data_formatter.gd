class_name InputResourcesDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"default"):
		data_.default = {
			&"frame_set": [
				[0, 1],
			],
			&"frame_count": 1,
			&"frame_orientation": "horizontal"
		}
	
	data_.default = clean_animation_load_data(data_.default)
	data_.default.erase(&"inputs")
	
	if not data_.has(&"animations"):
		data_.animations = []
		
	for index_: int in data_.animations.size():
		data_.animations[index_] = clean_animation_load_data(data_.animations[index_])
	
	return data_

static func clean_animation_load_data(data_: Dictionary) -> Dictionary:
	if data_.has(&"frame_count"):
		if data_.frame_count is int:
			data_.frame_count = Vector2i(data_.frame_count, data_.frame_count)
		else:
			data_.frame_count = Vector2i(data_.frame_count[0], data_.frame_count[1])
	else:
		data_.frame_coun = Vector2i(1, 1)
		
	if data_.has(&"frame_orientation"):
		match data_.frame_orientation:
			"horizontal":
				data_.frame_orientation = Core.Orientation.HORIZONTAL
			"vertical":
				data_.frame_orientation = Core.Orientation.VERTICAL
			_:
				data_.frame_orientation = Core.Orientation.HORIZONTAL
	else:
		data_.frame_orientation = Core.Orientation.HORIZONTAL


	if data_.has(&"frame_set"):
		data_.frame_set = clean_frame_set_load_data(data_.frame_set)
	else:
		data_.frame_set = AnimationFrameSet.new([
			AnimationFrameValue.new(0, 1)
		])

	if not data_.has(&"inputs"):
		data_.inputs = []
		
	for index_: int in data_.inputs.size():
		data_.inputs[index_] = clean_input_load_data(
			data_.inputs[index_]
		)
	
	return data_

static func clean_frame_set_load_data(data_: Array) -> AnimationFrameSet:
	var frames_: Array[AnimationFrameValue] = []
	
	for frame_: Array in data_:
		frames_.push_back(AnimationFrameValue.new(frame_[0], frame_[1]))
		
	return AnimationFrameSet.new(frames_)

static func clean_input_load_data(data_: Dictionary) -> Dictionary:
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
