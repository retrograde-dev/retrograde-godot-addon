class_name AreaDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	assert(data_.has(&"alias"), "Area alias missing.")
	
	data_.alias = StringName(data_.alias)
	
	if not data_.has(&"name"):
		data_.set(&"name", data_.alias.capitalize())
	
	if data_.has(&"doors"):
		for i: int in data_.doors.size():
			data_.doors[i] = _clean_area_door_load_data(data_, data_.doors[i])
				
	
	if data_.has(&"items"):
		for i: int in data_.items.size():
			data_.items[i] = _clean_area_item_load_data(data_, data_.items[i])
			
	
	return data_
	
static func _clean_area_door_load_data(area: Dictionary, door: Dictionary) -> Dictionary:
	assert(door.has(&"alias"), "Area door missing alias. (" + area.alias + ")")
	
	door.alias = StringName(door.alias)
	
	if door.has(&"area"):
		assert(door.area.has("alias"), "Area door area missing alias. (" + area.alias + ", " + door.alias + ")")
		assert(door.area.has("position"), "Area door area missing position. (" + area.alias + ", " + door.alias + ")")
	
		door.area.alias = StringName(door.area.alias)
		door.area.position = Vector2(door.area.position[0], door.area.position[1])	
		
	return door
	
static func _clean_area_item_load_data(area: Dictionary, item: Dictionary) -> Dictionary:
	assert(item.has(&"alias"), "Item area missing alias. (" + area.alias + ")")
	assert(item.has(&"position"), "Item area missing position. (" + area.alias + ", " + item.alias + ")")
	
	item.alias = StringName(item.alias)
	item.position = Vector2(item.position[0], item.position[1])
	
	return item
