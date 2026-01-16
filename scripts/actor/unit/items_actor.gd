extends UnitActor
class_name ItemsActor

var can_select: bool = true

var items: Array[ItemValue] = []
var slots: int
var item_types: Array[Core.ItemType] = []
var selected_slot: int = 0
var drop_offset: Vector2 = Vector2.ZERO
var unit_alignment: Core.Alignment = Core.Alignment.CENTER_CENTER
var item_alignment: Core.Alignment = Core.Alignment.CENTER_CENTER

var is_in_item_area: bool = false
var item_area_items: Array[ItemUnit] = []
var item_collision_mode: Core.ItemCollisionMode = Core.ItemCollisionMode.PLAYER

var drop_mode: Core.ItemMode = Core.ItemMode.SINGLE
var drop_swap: bool = false

var swap_mode: Core.ItemMode = Core.ItemMode.SINGLE

var pick_up_mode: Core.ItemMode = Core.ItemMode.SINGLE
var pick_up_swap: bool = false
var pick_up_use: bool = false # When true, if slots are full, will attempt to use item on pickup

var use_action_enabled: bool = true
var use_action_enabled_default: bool = true
var signal_can_use: bool = false
var signal_use_handled: bool = false

var drop_action_enabled: bool = true
var drop_action_enabled_default: bool = true
var signal_can_drop: bool = false
var signal_drop_handled: bool = false

var swap_action_enabled: bool = true
var swap_action_enabled_default: bool = true
var signal_can_swap: bool = false
var signal_swap_handled: bool = false


var pick_up_action_enabled: bool = true
var pick_up_action_enabled_default: bool = true
var signal_can_pick_up: bool = false
var signal_pick_up_handled: bool = false

var action_left: StringName = &"item_left"
var action_right: StringName = &"item_right"
var action_use: StringName = &"item_use"
var action_drop: StringName = &"item_drop"
var action_swap: StringName = &"item_swap"
var action_pick_up: StringName = &"item_pick_up"
var action_select: StringName = &"item_select_"

signal use_error(item_value_: ItemValue, error_: Core.Error) 
signal use_before(item_value_: ItemValue)
signal use_after(item_value_: ItemValue)

signal drop_error(item_value_: ItemValue, error_: Core.Error) 
signal drop_before(item_value_: ItemValue)
signal drop_after(item_value_: ItemValue)

signal swap_error(item_value_: ItemValue, level_item_value: LevelItemValue, error_: Core.Error) 
signal swap_before(item_value_: ItemValue, level_item_value: LevelItemValue,)
signal swap_after(item_value_: ItemValue, level_item_value: LevelItemValue,)

signal pick_up_error(item_value_: ItemValue, error_: Core.Error) 
signal pick_up_before(item_value_: ItemValue)
signal pick_up_after(item_value_: ItemValue)

func _init(unit_: PlayerUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"items", enabled_)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_in_item_area = false
		item_area_items.clear()
		selected_slot = 0
		items.clear()
		
		use_action_enabled = use_action_enabled_default
		drop_action_enabled = drop_action_enabled_default
		swap_action_enabled = swap_action_enabled_default
		pick_up_action_enabled = pick_up_action_enabled_default
		
		reset_slots()
		
		if reset_type_ == Core.ResetType.START:
			_add_areas()
			
		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()

func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"Item", Core.Edge.NONE)

func _connect_events() -> void:
	var item_area_: Area2D = unit.get_area_or_null(&"Item")
	if item_area_ != null:
		item_area_.connect(&"body_entered", _on_item_body_entered)
		item_area_.connect(&"body_exited", _on_item_body_exited)
	
func _disconnect_events() -> void:
	var item_area_: Area2D = unit.get_area_or_null(&"Item")
	if item_area_ != null:
		item_area_.disconnect(&"body_entered", _on_item_body_entered)
		item_area_.disconnect(&"body_exited", _on_item_body_exited)

func reset_slots() -> void:
	items = []
	
	selected_slot = 0
	
	for i: int in slots:
		items.push_back(null)
	
func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return
		
	if Core.game.is_win or Core.game.is_lose:
		return
	
	_action_move_selection_left()
	_action_move_selection_right()
			
	for i: int in slots:
		_action_select_item(i)

func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return

	_action_use_selected_item()
	_action_drop_selected_item()
	_action_swap_selected_item()
	_action_pick_up_item()

func _on_item_body_entered(body: Node2D) -> void:
	if not body is ItemUnit:
		return
	
	item_area_items.push_back(body)
	is_in_item_area = true

func _on_item_body_exited(body: Node2D) -> void:
	if not body is ItemUnit:
		return
	
	for i: int in item_area_items.size():
		if item_area_items[i] == body:
			item_area_items.remove_at(i)
			break
	
	is_in_item_area = item_area_items.size() > 0
	
func _action_move_selection_left() -> void:
	if not can_select:
		return

	if not unit.actions.is_just_pressed(action_left, true):
		return
	
	if unit.actions.is_just_pressed(action_right, true):
		return
		
	move_selection_left()

func _action_move_selection_right() -> void:
	if not can_select:
		return

	if not unit.actions.is_just_pressed(action_right, true):
		return
	
	if unit.actions.is_just_pressed(action_left, true):
		return
		
	move_selection_right()

func _action_select_item(slot_: int) -> void:
	if not can_select:
		return
	
	if not unit.actions.is_just_pressed(action_select + str(slot_ + 1), true):
		return
		
	select_item(slot_)
	
func _action_use_selected_item() -> void:
	if not use_action_enabled:
		return
	
	if not unit.actions.is_just_pressed(action_use):
		return
	
	if not unit.actions.has(action_use):
		use_error.emit(get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return
		
	use_selected_item()
	
func _action_drop_selected_item() -> void:
	if not drop_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_drop):
		return
		
	if not unit.actions.has(action_drop):
		drop_error.emit(get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return

	drop_selected_item()
	
func _action_swap_selected_item() -> void:
	if not swap_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_swap):
		return
		
	if not unit.actions.has(action_swap):
		var level_item_values_: Array[LevelItemValue] = get_item_area_items()
		
		if level_item_values_.size() == 0:
			swap_error.emit(get_selected_item(), null, Core.Error.UNIT_RESTRICTION)
		else:
			swap_error.emit(get_selected_item(), level_item_values_[0], Core.Error.UNIT_RESTRICTION)
		return
	
	swap_selected_item()
	
func _action_pick_up_item() -> void:
	if not pick_up_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_pick_up):
		return
		
	if not unit.actions.has(action_pick_up):
		pick_up_error.emit(get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return

	if pick_up_mode == Core.ItemMode.MULTIPLE:
		pick_up_items()
	else:
		pick_up_item()

func move_selection_left() -> void:
	if selected_slot == 0:
		selected_slot = slots - 1
	else:
		selected_slot -= 1

func move_selection_right() -> void:
	if selected_slot == slots - 1:
		selected_slot = 0
	else:
		selected_slot += 1

func can_use_item(item_value_: ItemValue) -> bool:
	if item_value_ == null:
		return false
		
	if item_value_.meta.can_stack:
		if item_value_.meta.count == 0:
			return false
	
	return true

func can_use_selected_item() -> bool:
	return can_use_item(get_selected_item())
		
func can_drop_selected_item() -> bool:
	var selected_item_: ItemValue = get_selected_item()
	
	if selected_item_ == null:
		return false
		
	if not selected_item_.meta.can_drop:
		return false
		
	if not is_in_item_area:
		return true
		
	if drop_mode == Core.ItemMode.MULTIPLE:
		return true
	
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	
	if level_item_values_.size() == 0:
		return true
	
	# TODO: Support swapping of multiple if all match
	if level_item_values_.size() > 1:
		return false
	
	# Can the item be dropped on a stack
	if (level_item_values_[0].item.alias == selected_item_.alias and
		level_item_values_[0].item.meta.can_stack and
		level_item_values_[0].item.meta.can_stack_in_level and
		selected_item_.meta.can_stack
	):
		return true
	
	return false
	
func can_swap_selected_item() -> bool:
	var selected_item_: ItemValue = get_selected_item()
	
	if selected_item_ == null:
		return false
	
	if not selected_item_.meta.can_drop:
		return false
		
	if not is_in_item_area:
		return false
	
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	
	if level_item_values_.size() == 0:
		return false
	
	if not _can_swap_level_item(level_item_values_, level_item_values_[0], selected_item_):
		return false
	
	return true

func can_pick_up_item() -> bool:
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	
	if level_item_values_.size() == 0:
		return false
	
	return _can_pick_up_level_item(level_item_values_, null, pick_up_mode)

func _can_pick_up_level_item(
	level_item_values_: Array[LevelItemValue],
	level_item_value_: LevelItemValue,
	pick_up_mode_: Core.ItemMode
) -> bool:
	if level_item_values_.size() == 0:
		return false
		
	if pick_up_mode_ == Core.ItemMode.MULTIPLE:
		for current_level_item_value_: LevelItemValue in level_item_values_:
			if (_can_pick_up_level_item(
				level_item_values_,
				current_level_item_value_,
				Core.ItemMode.SINGLE
			)):
				return true
		
		return false
		
	if level_item_value_ == null:
		level_item_value_ = _get_closest_pick_up_level_item(level_item_values_)
		
		if level_item_value_ == null:
			return false
	
	if not level_item_value_.item.meta.can_pick_up:
		return false
	
	if can_add_item(level_item_value_.item):
		return true
		
	return false

# Returns true the item is a single item
func _can_swap_level_item(
	level_item_values_: Array[LevelItemValue],
	level_item_value_: LevelItemValue,
	selected_item_value_: ItemValue,
) -> bool:
	if selected_item_value_ == null:
		return false
		
	if (level_item_values_.size() != 1 and
		drop_mode != Core.ItemMode.MULTIPLE and 
		swap_mode != Core.ItemMode.MULTIPLE
	):
		return false
		
	if not level_item_value_.item.meta.can_pick_up:
		return false
	
	if not selected_item_value_.meta.can_drop:
		return false
	
	# If level item can be added without swapping, then
	# Can alaways drop item in its place
	if _can_add_item_internal(level_item_value_.item, true):
		return true
		
	if (level_item_value_.item.meta.can_stack and 
		not level_item_value_.item.meta.can_stack_in_items
	):
		if drop_mode != Core.ItemMode.MULTIPLE:
			if level_item_value_.item.meta.count == -1:
				return false
				
			if level_item_value_.item.meta.count > 1:
				return false
	
	if (selected_item_value_.meta.can_stack and 
		selected_item_value_.meta.can_stack_in_level
	):
		return true
	
	if selected_item_value_.meta.count == 0:
		return true
		
	if selected_item_value_.meta.count == 1:
		return true	
	
	return false
	
func use_item(item_value_: ItemValue) -> bool:
	if not can_use_item(item_value_):
		use_error.emit(item_value_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_use = true
	signal_use_handled = false
	
	use_before.emit(item_value_)
	
	if signal_can_use == false:
		use_error.emit(item_value_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_use_handled:
		if not _use_item(item_value_):
			use_error.emit(item_value_, Core.Error.UNHANDLED)
			return false
	
	use_after.emit(item_value_)
	return true
		
func use_selected_item() -> bool:
	var item_value_: ItemValue = get_selected_item()
	
	return use_item(item_value_)

func _use_item(item_value_: ItemValue) -> bool:
	var used: bool = false
	
	if item_value_.meta.can_stack and item_value_.meta.count == 0:
		return used
	
	if item_value_.type == Core.ItemType.FOOD:
		if item_value_.meta.has("hunger"):
			_increase_unit_hunger(item_value_.meta.hunger)
		
		used = true
	elif item_value_.type == Core.ItemType.HEALTH_FOOD:
		if item_value_.meta.has("hunger"):
			_increase_unit_hunger(item_value_.meta.hunger)
			
		if item_value_.meta.has("health"):
			_increase_unit_health(item_value_.meta.health)
			
		used = true
	elif item_value_.type == Core.ItemType.ARMOR:
		if item_value_.meta.has("armor"):
			_increase_unit_armor(item_value_.meta.armor)
			
		used = true
	elif item_value_.type == Core.ItemType.ARMOR_HEALTH:
		if item_value_.meta.has("armor"):
			_increase_unit_armor(item_value_.meta.armor)
			
		if item_value_.meta.has("health"):
			_increase_unit_health(item_value_.meta.health)
			
		used = true
	elif item_value_.type == Core.ItemType.HEALTH or item_value_.type == Core.ItemType.REPAIR:
		if item_value_.meta.has("health"):
			_increase_unit_health(item_value_.meta.health)
			
		used = true
	
	var selected_item_value_: ItemValue = get_selected_item()
	
	if item_value_.meta.can_stack:
		if item_value_.meta.count > 0:
			item_value_.meta.count -= 1
		
		if item_value_.meta.count == 0 and item_value_ == selected_item_value_:
			remove_selected_item()
	elif item_value_ == selected_item_value_:
		remove_selected_item()
	
	return used
	
func drop_selected_item() -> bool:
	var item_value_: ItemValue = get_selected_item()
	
	var can_drop_: bool = can_drop_selected_item()
	
	if not can_drop_ and drop_swap and can_swap_selected_item():
		return swap_selected_item()
	
	if not can_drop_:
		drop_error.emit(item_value_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_drop = true
	signal_drop_handled = false
	
	drop_before.emit(item_value_)
	
	if signal_can_drop == false:
		drop_error.emit(item_value_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_drop_handled:
		if not _drop_item(item_value_):
			drop_error.emit(item_value_, Core.Error.UNHANDLED)
			return false

	drop_after.emit(item_value_)
	return true
	
func _drop_item(item_value_: ItemValue) -> bool:
	if Core.level == null:
		return false
	
	if Core.level.area == null:
		return false
		
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	var selected_item_value_: ItemValue = get_selected_item()

	# Merge slot item into matching level item
	for level_item_value_: LevelItemValue in level_item_values_:
		if (level_item_value_.item.alias == item_value_.alias and
			level_item_value_.item.meta.can_stack and
			level_item_value_.item.meta.can_stack_in_level and
			item_value_.meta.can_stack
		):
			level_item_value_.item.meta.count = _get_total_count(level_item_value_.item, item_value_)
			if item_value_ == selected_item_value_:
				remove_selected_item()
			return true
	
	var unit_position_: Vector2 = unit.get_align_global_position(unit_alignment)
	
	if item_value_.meta.can_stack and not item_value_.meta.can_stack_in_level:
		if item_value_.meta.count > 1:
			item_value_.meta.count -= 1
		elif item_value_.meta.count == 1 and item_value_ == selected_item_value_:
			remove_selected_item()
		
	item_value_ = item_value_.duplicate()

	if item_value_.meta.can_stack and item_value_.meta.count != 0:
		item_value_.meta.count = 1
		
	var item_position_: Vector2 = unit_position_ - Core.level.area.global_position
	if item_collision_mode == Core.ItemCollisionMode.TILE:
		item_position_ = ((item_position_ + drop_offset) / Core.TILE_SIZE).floor() * Core.TILE_SIZE
	else:
		item_position_ += drop_offset
		
	var level_item_value: LevelItemValue = LevelItemValue.new(
		item_value_,
		Core.level.area.alias,
		item_position_,
		{"alignment": item_alignment}
	)
	
	Core.level.items.add_item(level_item_value)
	
	return true
	
func swap_selected_item() -> bool:
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	var selected_item_value_: ItemValue = get_selected_item()
	
	if not can_swap_selected_item():
		if level_item_values_.size() == 0:
			swap_error.emit(selected_item_value_, null, Core.Error.ACTOR_RESTRICTION)
		else:
			swap_error.emit(selected_item_value_, level_item_values_[0], Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_swap = true
	signal_swap_handled = false
	
	swap_before.emit(selected_item_value_, level_item_values_[0])
	
	if signal_can_swap == false:
		swap_error.emit(selected_item_value_, level_item_values_[0], Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_swap_handled:
		if not _swap_item(selected_item_value_):
			swap_error.emit(selected_item_value_, level_item_values_[0], Core.Error.UNHANDLED)
			return false

	swap_after.emit(selected_item_value_, level_item_values_[0])
	return true
		
func _swap_item(item_value_: ItemValue) -> bool:
	if Core.level == null:
		return false
	
	if Core.level.area == null:
		return false
		
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	var selected_item_value_: ItemValue = get_selected_item()
	
	if level_item_values_.size() == 0:
		return false
	
	if not _can_swap_level_item(level_item_values_, level_item_values_[0], item_value_):
		return false
	
	if _can_add_item_internal(level_item_values_[0].item, true):
		_add_item_internal(level_item_values_[0].item, true)
		
		var remove_one_item_: bool = false
		
		if (selected_item_value_.meta.can_stack and
			not selected_item_value_.meta.can_stack_in_level
		):
			if selected_item_value_.meta.count == -1:
				remove_one_item_ = true
				
			if selected_item_value_.meta.count > 1:
				remove_one_item_ = true
				
		if remove_one_item_:
			if selected_item_value_.meta.can_stack and not selected_item_value_.meta.can_stack_in_level:
				if selected_item_value_.meta.count > 1:
					selected_item_value_.meta.count -= 1
			
			item_value_ = item_value_.duplicate()

			if item_value_.meta.can_stack and item_value_.meta.count != 0:
				item_value_.meta.count = 1
	else:
		replace_selected_item(level_item_values_[0].item)
		selected_item_value_ = level_item_values_[0].item
		
	Core.level.items.remove_item(level_item_values_[0])

	var unit_position_: Vector2 = unit.get_align_global_position(unit_alignment)
	var item_position_: Vector2 = unit_position_ - Core.level.area.global_position
	
	if item_collision_mode == Core.ItemCollisionMode.TILE:
		item_position_ = ((item_position_ + drop_offset) / Core.TILE_SIZE).floor() * Core.TILE_SIZE
	else:
		item_position_ += drop_offset
	
	var level_item_value: LevelItemValue = LevelItemValue.new(
		item_value_,
		Core.level.area.alias,
		item_position_,
		{"alignment": item_alignment}
	)
	
	Core.level.items.add_item(level_item_value)
	
	return true
	
func _get_total_count(item_value_a_: ItemValue, item_value_b_: ItemValue) -> int:
	if item_value_a_.meta.count < 0 or item_value_b_.meta.count < 0:
		return -1
		
	return item_value_a_.meta.count + item_value_b_.meta.count
	
func pick_up_item() -> bool:
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	var level_item_value_: LevelItemValue = _get_closest_pick_up_level_item(level_item_values_)
	
	var pick_up_mode_: Core.ItemMode = pick_up_mode
	if pick_up_mode_ == Core.ItemMode.MULTIPLE:
		pick_up_mode_ = Core.ItemMode.SINGLE
	
	var can_pick_up_: bool = _can_pick_up_level_item(
		level_item_values_, 
		level_item_value_,
		pick_up_mode_
	)

	if not can_pick_up_:
		if pick_up_swap and can_swap_selected_item():
			return swap_selected_item()
		
		if pick_up_use and can_use_item(level_item_value_.item):
			if use_item(level_item_value_.item):
				if (not level_item_value_.item.meta.can_stack or 
					level_item_value_.item.meta.count == 0
				):
					Core.level.items.remove_item(level_item_value_)
				return true
			else:
				return false
		
	if not can_pick_up_:
		if level_item_value_ == null:
			pick_up_error.emit(null, Core.Error.ACTOR_RESTRICTION)
		else:
			pick_up_error.emit(level_item_value_.item, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_pick_up = true
	signal_pick_up_handled = false
	
	pick_up_before.emit(level_item_value_.item)
	
	if signal_can_pick_up == false:
		pick_up_error.emit(level_item_value_.item, Core.Error.GAME_RESTRICTION)
		return false

	if not signal_pick_up_handled:
		if not _pick_up_item(level_item_value_):
			pick_up_error.emit(level_item_value_.item, Core.Error.UNHANDLED)
			return false
	
	pick_up_after.emit(level_item_value_.item)
	return true

func pick_up_items() -> void:
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	
	if level_item_values_.size() == 0:
		pick_up_error.emit(null, Core.Error.ACTOR_RESTRICTION)
		return
	elif level_item_values_.size() == 1:
		return pick_up_item()
	
	while level_item_values_.size() > 0:
		var level_item_value_: LevelItemValue = level_item_values_.back()
		
		if not _can_pick_up_level_item(
			level_item_values_,
			level_item_value_,
			Core.ItemMode.MULTIPLE
		):
			pick_up_error.emit(level_item_value_.item, Core.Error.ACTOR_RESTRICTION)
			level_item_values_.pop_back()
			continue
			
		signal_can_pick_up = true
		signal_pick_up_handled = false
		
		pick_up_before.emit(level_item_value_.item)
		
		if signal_can_pick_up == false:
			pick_up_error.emit(level_item_value_.item, Core.Error.GAME_RESTRICTION)
			level_item_values_.pop_back()
			continue

		if not signal_pick_up_handled:
			if not _pick_up_item(level_item_value_):
				pick_up_error.emit(level_item_value_.item, Core.Error.UNHANDLED)
				level_item_values_.pop_back()
				continue
		
		pick_up_after.emit(level_item_value_.item)
		level_item_values_.pop_back()

func _pick_up_item(level_item_value_: LevelItemValue) -> bool:

	if Core.level == null:
		return false

	if add_item(level_item_value_.item):
		Core.level.items.remove_item(level_item_value_)
		return true
	
	return false

func get_closest_pick_up_level_item() -> LevelItemValue:
	var level_item_values_: Array[LevelItemValue] = get_item_area_items()
	return _get_closest_pick_up_level_item(level_item_values_)
	
func _get_closest_pick_up_level_item(level_item_values_: Array[LevelItemValue]) -> LevelItemValue:
	if level_item_values_.size() == 0:
		return null
		
	if level_item_values_.size() == 1:
		if level_item_values_[0].item.meta.can_pick_up:
			return level_item_values_[0]
			
		return null
	
	var unit_position_: Vector2 = unit.get_align_global_position(unit_alignment)
	
	var closest_level_item_value_: LevelItemValue = null
	var closest_position_: Vector2
	
	for level_item_value_: LevelItemValue in level_item_values_:
		if not level_item_value_.item.meta.can_pick_up:
			continue
			
		var item_position_: Vector2 = level_item_value_.node.get_align_global_position(item_alignment)
		
		if closest_level_item_value_ == null:
			closest_level_item_value_ = level_item_value_
			closest_position_ = item_position_
			continue
	
		var current_position_: Vector2 = level_item_value_.node.get_align_global_position(item_alignment)
		var test_position_: Vector2 = Core.get_closest_vector2(unit_position_, closest_position_, current_position_)
		
		if test_position_ == current_position_:
			closest_level_item_value_ = level_item_value_
			closest_position_ = current_position_
	
	return closest_level_item_value_
	
func get_item_area_items() -> Array[LevelItemValue]:
	var level_item_values_: Array[LevelItemValue] = []
	
	if not is_in_item_area:
		return level_item_values_
	
	if Core.level == null:
		return level_item_values_
	
	var area_alias_: StringName = Core.game.get_level_area_alias()
	if area_alias_ == &"":
		return level_item_values_
	
	for level_item_value_: LevelItemValue in Core.level.items.get_items_from_area(area_alias_):
		if not item_area_items.has(level_item_value_.node):
			continue

		if not level_item_value_.visible:
			continue

		if item_types.size() > 0 and not item_types.has(level_item_value_.item.type):
			continue

		if not level_item_value_.node is ItemUnit:
			continue

		if item_collision_mode == Core.ItemCollisionMode.TILE:
			var unit_position_: Vector2 = ((unit.get_align_global_position(unit_alignment) + drop_offset) / Core.TILE_SIZE).floor()
			var item_position_: Vector2 = (level_item_value_.node.get_align_global_position(item_alignment) / Core.TILE_SIZE).floor()
			
			if unit_position_ != item_position_:
				continue
			
			level_item_values_.push_back(level_item_value_)
		
	return level_item_values_
	
func select_item(slot_: int) -> void:
	assert(slot_ >= 0 and slot_ < slots, "Slot is out of range.")
	
	if slot_ < 0 or slot_ >= slots:
		return
	
	selected_slot = slot_
	
func select_item_of_type(type_: Core.ItemType) -> bool:
	for i: int in items.size():
		if items[i].type == type_:
			selected_slot = i
			return true
		
	return false
	
func is_item_of_type_selected(type_: Core.ItemType) -> bool:
	if items[selected_slot].type == type_:
		return true
	
	return false

func get_item(slot_: int) -> ItemValue:
	assert(slot_ >= 0 or slot_ < slots, "Slot is out of range.")
	
	if slot_ < 0 or slot_ >= slots:
		return null
	
	return items[slot_]
	
func get_selected_item() -> ItemValue:
	return items[selected_slot]
	
func get_selected_item_type() -> Core.ItemType:
	if items[selected_slot] == null:
		return Core.ItemType.NONE

	return items[selected_slot].type

func get_items_from_meta(meta: Dictionary) -> Array[ItemValue]:
	var items_: Array[ItemValue] = []
	
	for item_: ItemValue in items:
		if item_ != null and Core.dictionary_contains(item_.meta, meta):
			items_.push_back(item_)
	
	return items_
	
func get_items_from_type(type_: Core.ItemType) -> Array[ItemValue]:
	var items_: Array[ItemValue] = []
	
	for item_: ItemValue in items:
		if item_ != null and item_.type == type_:
			items_.push_back(item_)
	
	return items_

func can_add_item(item_value_: ItemValue) -> bool:
	return _can_add_item_internal(item_value_, false)
	
func _can_add_item_internal(item_value_: ItemValue, unselected_: bool) -> bool:
	for index_: int in items.size():
		if index_ == selected_slot and unselected_:
			continue
			
		var current_item_value_: ItemValue = items[index_]
		
		if current_item_value_ == null:
			return true
	
		if current_item_value_.alias != item_value_.alias:
			continue
		
		if (current_item_value_.meta.can_stack and 
			current_item_value_.meta.can_stack_in_items and 
			item_value_.meta.can_stack and
			item_value_.meta.can_stack_in_items
		):
			return true
			
		if current_item_value_.meta.count == 0:
			if item_value_.meta.count == 0 or item_value_.meta.count == 1:
				return true
	
	return false
	
func add_item(item_value_: ItemValue) -> bool:
	return _add_item_internal(item_value_, false)
	
func _add_item_internal(item_value_: ItemValue, unselected_: bool) -> bool:
	if items[selected_slot] == null:
		items[selected_slot] = item_value_
		return true
	
	var empty_slot_: int = -1
	
	for index_: int in items.size():
		if index_ == selected_slot and unselected_:
			continue
			
		if items[index_] == null:
			if empty_slot_ == -1:
				empty_slot_ = index_
				
			continue
		
		if (items[index_].alias == item_value_.alias and 
			items[index_].meta.can_stack and
			items[index_].meta.can_stack_in_items and
			item_value_.meta.can_stack and
			item_value_.meta.can_stack_in_items
		):
			if items[index_].meta.count < 0: # Infinite
				return true
				
			if item_value_.meta.count < 0:
				items[index_].meta.count = -1
			else:
				items[index_].meta.count += item_value_.meta.count
				
			return true
		
	if empty_slot_ != -1:
		items[empty_slot_] = item_value_
		return true
			
	return false

func replace_item(slot_: int, item_: ItemValue) -> void:
	items[slot_] = item_
	
func replace_selected_item(item_: ItemValue) -> void:
	items[selected_slot] = item_
	
func remove_item(slot_: int) -> void:
	assert(slot_ >= 0 and slot_ < slots, "Slot is out of range.")
	
	if slot_ < 0 or slot_ >= slots:
		return
	
	items[slot_] = null
	
func remove_selected_item() -> void:
	items[selected_slot] = null

func is_empty() -> bool:
	for item_: ItemValue in items:
		if item_ != null:
			return false
			
	return true

func is_slot_empty(slot_: int) -> bool:
	assert(slot_ >= 0 and slot_ < slots, "Slot is out of range.")
	
	if slot_ < 0 or slot_ >= slots:
		return false
	
	return items[slot_] == null

func is_selected_slot_empty() -> bool:
	return is_slot_empty(selected_slot)
	
func has_empty() -> bool:
	for item_: ItemValue in items:
		if item_ == null:
			return true
	
	return false

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_left,
		action_right,
		action_use,
		action_drop,
		action_swap,
		action_pick_up,
	]
	
	for i: int in slots:
		actions_.push_back(action_select + str(i + 1))
		
	return actions_

func _increase_unit_health(amount: float) -> void:
	if amount == 0.0:
		return
	
	var health_actor: BaseActor = unit.get_actor_or_null(&"health")
	
	if health_actor == null:
		return
	
	health_actor.increase_health(amount)
	
func _increase_unit_armor(amount: float) -> void:
	if amount == 0.0:
		return
		
	var health_actor: BaseActor = unit.get_actor_or_null(&"health")
	
	if health_actor == null:
		return
	
	health_actor.increase_armor(amount)

func _increase_unit_hunger(amount: float) -> void:
	if amount == 0.0:
		return
		
	var hunger_actor: BaseActor = unit.get_actor_or_null(&"hunger")
	
	if hunger_actor == null:
		return
	
	hunger_actor.increase_hunger(amount)
