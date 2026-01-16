class_name HUDDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"enabled"):
		data_.enabled = []
	else:
		data_.enabled = data_.enabled.map(func(value: String) -> StringName: return StringName(value))

	if not data_.has(&"huds"):
		data_.huds = {}

	if not data_.has(&"default"):
		data_.default = {}
	
	data_.default = clean_huds_load_data(data_.default)
	
	return data_
	
static func clean_huds_load_data(data_: Dictionary) -> Dictionary:
	for key_: StringName in data_:
		data_[key_] = clean_hud_load_data(data_[key_])
	
	return data_
	
static func clean_hud_load_data(data_: Dictionary) -> Dictionary:
	if data_.has(&"offset"):
		data_.offset = Vector2(data_.offset[0], data_.offset[1])
		
	if data_.has(&"alignment"):
		if data_.alignment[0] == "left":
			if data_.alignment[1] == "top":
				data_.alignment = Core.Alignment.TOP_LEFT
			elif data_.alignment[1] == "center":
				data_.alignment = Core.Alignment.CENTER_LEFT
			elif data_.alignment[1] == "bottom":
				data_.alignment = Core.Alignment.BOTTOM_LEFT
		elif data_.alignment[0] == "center":
			if data_.alignment[1] == "top":
				data_.alignment = Core.Alignment.TOP_CENTER
			elif data_.alignment[1] == "center":
				data_.alignment = Core.Alignment.CENTER_CENTER
			elif data_.alignment[1] == "bottom":
				data_.alignment = Core.Alignment.BOTTOM_CENTER
		elif data_.alignment[0] == "right":
			if data_.alignment[1] == "top":
				data_.alignment = Core.Alignment.TOP_RIGHT
			elif data_.alignment[1] == "center":
				data_.alignment = Core.Alignment.CENTER_RIGHT
			elif data_.alignment[1] == "bottom":
				data_.alignment = Core.Alignment.BOTTOM_RIGHT
		else:
			data_.alignment = Core.Alignment.TOP_CENTER
	else:
		data_.alignment = Core.Alignment.TOP_CENTER
		
	if not data_.has(&"visible"):
		data_.visible = false
		
	return data_
