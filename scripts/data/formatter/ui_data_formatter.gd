class_name UIDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	if not data_.has(&"enabled"):
		data_.enabled = []
	else:
		data_.enabled = data_.enabled.map(func(value: String) -> StringName: return StringName(value))

	if not data_.has(&"uis"):
		data_.uis = {}

	if not data_.has(&"buttons"):
		data_.buttons = {}
	
	if not data_.has(&"check_boxes"):
		data_.check_boxes = {}
	
	if not data_.has(&"h_sliders"):
		data_.h_sliders = {}
	
	if not data_.has(&"labels"):
		data_.labels = {}
		
	if not data_.has(&"separators"):
		data_.separators = {}
		
	if not data_.has(&"margin_containers"):
		data_.margin_containers = {}
		
	if not data_.has(&"panel_containers"):
		data_.panel_containers = {}

	data_.buttons = _clean_buttons(data_.buttons)
	
	data_.check_boxes = _clean_check_boxes(data_.check_boxes)
	
	data_.h_sliders = _clean_h_sliders(data_.h_sliders)
	
	data_.labels = _clean_labels(data_.labels)
	
	data_.separators = _clean_separators(data_.separators)
	
	data_.margin_containers = _clean_margin_containers(data_.margin_containers)
	
	data_.panel_containers = _clean_panel_containers(data_.panel_containers)
	
	return data_

static func _clean_buttons(buttons_: Dictionary) -> Dictionary:
	for key_: StringName in buttons_:
		buttons_[key_].type = StringName(buttons_[key_].type)
		
		if buttons_[key_].has(&"label") and buttons_[key_].label:
			buttons_[key_].label = StringName(buttons_[key_].label)
		else:
			buttons_[key_].label = &""
			
		if not buttons_[key_].has(&"icon") or not buttons_[key_].icon:
			buttons_[key_].icon = ""
			
		if buttons_[key_].has(&"margin_container") and buttons_[key_].margin_container:
			buttons_[key_].margin_container = StringName(buttons_[key_].margin_container)
		else:
			buttons_[key_].margin_container = &""
		
		if not buttons_[key_].has(&"texture"):
			buttons_[key_].texture = {}
			
		if not buttons_[key_].texture.has(&"normal"):
			buttons_[key_].texture.normal = null
			
		if not buttons_[key_].texture.has(&"pressed"):
			buttons_[key_].texture.pressed = null
			
		if not buttons_[key_].texture.has(&"hover"):
			buttons_[key_].texture.hover = null
			
		if not buttons_[key_].texture.has(&"disabled"):
			buttons_[key_].texture.disabled = null
			
		if not buttons_[key_].texture.has(&"focused"):
			buttons_[key_].texture.focused = null
			
		if not buttons_[key_].texture.has(&"click_mask"):
			buttons_[key_].texture.click_mask = null
			
		if not buttons_[key_].has(&"sfx"):
			buttons_[key_].sfx = {}
			
		if not buttons_[key_].sfx.has(&"entered"):
			buttons_[key_].sfx.entered = &""
			
		if not buttons_[key_].sfx.has(&"exited"):
			buttons_[key_].sfx.entered = &""
			
		if not buttons_[key_].sfx.has(&"pressed"):
			buttons_[key_].sfx.entered = &""
			
		if not buttons_[key_].has(&"theme"):
			buttons_[key_].theme = null
		
		if not buttons_[key_].has(&"theme_type_variation"):
			buttons_[key_].theme_type_variation = &""
			
	return buttons_

static func _clean_check_boxes(check_boxes_: Dictionary) -> Dictionary:
	return _clean_controls(check_boxes_)

static func _clean_h_sliders(h_sliders_: Dictionary) -> Dictionary:
	return _clean_controls(h_sliders_)

static func _clean_labels(labels_: Dictionary) -> Dictionary:
	return _clean_controls(labels_)

static func _clean_separators(separators_: Dictionary) -> Dictionary:
	for key_: StringName in separators_:
		if not separators_[key_].has(&"visible"):
			separators_[key_].visible = true
		
		if separators_[key_].has(&"size"):
			separators_[key_].size = Vector2(separators_[key_].size[0], separators_[key_].size[1])
		else:
			separators_[key_].size = Vector2.ZERO
		
	return separators_

static func _clean_margin_containers(margin_containers_: Dictionary) -> Dictionary:
	return _clean_controls(margin_containers_)

static func _clean_panel_containers(panel_containers_: Dictionary) -> Dictionary:
	return _clean_controls(panel_containers_)

static func _clean_controls(controls_: Dictionary) -> Dictionary:
	for key_: StringName in controls_:
		if controls_[key_] is String:
			controls_[key_] = {
				&"theme": controls_[key_],
				&"theme_type_variation": &""
			}
		else:
			if not controls_[key_].has(&"theme"):
				controls_[key_].theme = null

			if not controls_[key_].has(&"theme_type_variation"):
				controls_[key_].theme_type_variation = &""
	
	return controls_
