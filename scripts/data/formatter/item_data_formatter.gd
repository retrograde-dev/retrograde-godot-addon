class_name ItemDataFormatter

static func clean_load_data(data_: Dictionary) -> Dictionary:
	assert(data_.has(&"alias"), "Item missing alias.")
	assert(data_.has(&"type"), "Item missing type. (" + data_.alias + ")")
	
	var alias_: StringName = StringName(data_.alias)
	var type_: Core.ItemType
	
	if data_.type is Core.ItemType:
		type_ = data_.type
	else:
		type_ = Core.ItemType.NONE

	match data_.type:
		"accessory":
			type_ = Core.ItemType.ACCESSORY
		"armor":
			type_ = Core.ItemType.ARMOR
		"armor_health":
			type_ = Core.ItemType.ARMOR_HEALTH
		"component":
			type_ = Core.ItemType.COMPONENT
		"food":
			type_ = Core.ItemType.FOOD
		"health":
			type_ = Core.ItemType.HEALTH
		"food_health":
			type_ = Core.ItemType.HEALTH_FOOD
		"key":
			type_ = Core.ItemType.KEY
		"knife":
			type_ = Core.ItemType.KNIFE
		"lock_pick":
			type_ = Core.ItemType.LOCK_PICK
		"repair":
			type_ = Core.ItemType.REPAIR
		"shield":
			type_ = Core.ItemType.SHIELD
		"tool":
			type_ = Core.ItemType.TOOL
			
	if data_.has(&"meta"):
		if not data_.meta.has(&"can_drop"):
			data_.meta.can_drop = true
			
		if not data_.meta.has(&"can_pick_up"):
			data_.meta.can_pick_up = true
		
		if not data_.meta.has(&"can_stack"):
			data_.meta.can_stack = false
		
		if not data_.meta.has(&"can_stack_in_items"):
			data_.meta.can_stack_in_items = false
		
		if not data_.meta.has(&"can_stack_in_level"):
			data_.meta.can_stack_in_level = false
		
		# TODO: Implement these
		#if not data_.meta.has("drop_stack"):
			#data_.meta.drop_stack = false
			#
		#if not data_.meta.has("pick_up_stack"):
			#data_.meta.pick_up_stack = false
	else:
		data_.meta = {
			&"can_drop": true,
			&"can_pick_up": true,
			&"can_stack": false,
			&"can_stack_in_items": false,
			&"can_stack_in_level": false,
		}
			
	if data_.has(&"scene"):
		data_.scene = _clean_scene_load_data(data_.scene)
	
	return {
		&"alias": alias_,
		&"type": type_,
		&"meta": data_.meta,
		&"scene": data_.scene if data_.has(&"scene") else {},
	}
	
static func get_value(data_: Dictionary) -> ItemValue:
	var item_value_: ItemValue = ItemValue.new(
		data_.alias,
		data_.type,
		data_.meta if data_.has(&"meta") else {}
	)
	
	if data_.has(&"scene"):
		item_value_.scene = SceneValue.new()
				
		if data_.scene.has(&"path"):
			item_value_.scene.is_path = true
			item_value_.scene.path = data_.scene.path
		
		if data_.scene.has(&"scale"):
			item_value_.scene.is_scale = true
			item_value_.scene.scale = data_.scene.scale
		
		if data_.scene.has(&"tile_set_coords"):
			item_value_.scene.is_tile_set_coords = true
			item_value_.scene.tile_set_coords = data_.scene.tile_set_coords
		
	return item_value_

static func _clean_scene_load_data(data_: Dictionary) -> Dictionary:
	if data_.has(&"path"):
		data_.path = StringName(data_.path)
		
	if data_.has(&"tile_set_coords") and not data_.tile_set_coords is Vector2i:
		data_.tile_set_coords = Vector2i(
			data_.tile_set_coords[0],
			data_.tile_set_coords[1]
		)
	
	if data_.has(&"scale") and not data_.scale is Vector2:
		data_.scale = Vector2(data_.scale[0], data_.scale[1])	
		
	return data_
