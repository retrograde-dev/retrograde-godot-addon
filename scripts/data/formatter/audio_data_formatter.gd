class_name AudioDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	for key: Variant in data_:
		var item_: Dictionary = data_[key]
		
		if item_.has(&"format"):
			item_.format = StringName(item_.format)
		else:
			item_.format = &""

		if not item_.has(&"count"):
			item_.count = 1
			
		if not item_.has(&"rand"):
			item_.rand = false
			
		if not item_.has(&"pitch"):
			item_.pitch = false
		elif item_.pitch:
			if not item_.has(&"min_pitch"):
				item_.min_pitch = Core.MIN_AUDIO_PITCH

			if not item_.has(&"max_pitch"):
				item_.max_pitch = Core.MAX_AUDIO_PITCH

	return data_
