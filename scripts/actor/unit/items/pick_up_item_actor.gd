extends UnitActor
class_name PickUpItemActor

var _items: ItemsActor

var pick_up_mode: Core.ItemMode = Core.ItemMode.SINGLE
var pick_up_swap: bool = false
var pick_up_use: bool = false # When true, if slots are full, will attempt to use item on pickup

var pick_up_action_enabled: bool = true
var pick_up_action_enabled_default: bool = true
var signal_can_pick_up: bool = false
var signal_pick_up_handled: bool = false

var action_pick_up: StringName = &"item_pick_up"

signal pick_up_error(inventory_item_: InventoryItemResource, error_: Core.Error) 
signal pick_up_before(inventory_item_: InventoryItemResource)
signal pick_up_after(inventory_item_: InventoryItemResource)

func _init(items_: ItemsActor, unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"drop_item", enabled_)
	_items = items_

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		pick_up_action_enabled = pick_up_action_enabled_default
	
func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return

	_action_pick_up_item()
	
func _action_pick_up_item() -> void:
	if not pick_up_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_pick_up):
		return
		
	if not unit.actions.has(action_pick_up):
		pick_up_error.emit(_items.get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return

	if pick_up_mode == Core.ItemMode.MULTIPLE:
		pick_up_items()
	else:
		pick_up_item()

func can_pick_up_item() -> bool:
	if pick_up_mode == Core.ItemMode.NONE:
		return false
		
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	if items_.size() == 0:
		return false
	
	return _can_pick_up_zone_item(items_, null, pick_up_mode)
	
func _can_pick_up_zone_item(
	items_: Array[ItemUnitResource],
	item_: ItemUnitResource,
	pick_up_mode_: Core.ItemMode
) -> bool:
	if items_.size() == 0:
		return false
		
	if pick_up_mode_ == Core.ItemMode.MULTIPLE:
		for current_item_: ItemUnitResource in items_:
			if (_can_pick_up_zone_item(
				items_,
				current_item_,
				Core.ItemMode.SINGLE
			)):
				return true
		
		return false
		
	if item_ == null:
		item_ = _get_closest_pick_up_zone_item(items_)
		
		if item_ == null:
			return false
	
	if not item_.zone_item.item.can_pick_up:
		return false
	
	if _items.can_add_item(item_.zone_item, true):
		return true
		
	return false

func pick_up_item() -> bool:
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	var item_: ItemUnitResource = _get_closest_pick_up_zone_item(items_)
	
	var can_pick_up_: bool = _can_pick_up_zone_item(
		items_, 
		item_,
		Core.ItemMode.SINGLE
	)

	if not can_pick_up_:
		# Try swap
		if pick_up_swap and _items.swap.can_swap_selected_item():
			return _items.swap.swap_selected_item()
		
		# Try use
		if pick_up_use and _items.use.can_use_item(item_.zone_item):
			if _items.use.use_item(item_.zone_item):
				_remove_empty_zone_item(item_)
				return true
			else:
				return false
		
	if not can_pick_up_:
		pick_up_error.emit(item_.zone_item, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_pick_up = true
	signal_pick_up_handled = false
	
	pick_up_before.emit(item_.zone_item)
	
	if signal_can_pick_up == false:
		pick_up_error.emit(item_.zone_item, Core.Error.GAME_RESTRICTION)
		return false

	if not signal_pick_up_handled:
		if not _pick_up_item(item_):
			pick_up_error.emit(item_.zone_item, Core.Error.UNHANDLED)
			return false
	
	pick_up_after.emit(item_.zone_item)
	return true

func pick_up_items() -> void:
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	if items_.size() == 0:
		pick_up_error.emit(null, Core.Error.ACTOR_RESTRICTION)
		return
	elif items_.size() == 1:
		return pick_up_item()
	
	while items_.size() > 0:
		var item_: ItemUnitResource = items_.back()
		
		if not _can_pick_up_zone_item(
			items_,
			item_,
			Core.ItemMode.SINGLE
		):
			pick_up_error.emit(item_.zone_item, Core.Error.ACTOR_RESTRICTION)
			items_.pop_back()
			continue
			
		signal_can_pick_up = true
		signal_pick_up_handled = false
		
		pick_up_before.emit(item_.zone_item)
		
		if signal_can_pick_up == false:
			pick_up_error.emit(item_.zone_item, Core.Error.GAME_RESTRICTION)
			items_.pop_back()
			continue

		if not signal_pick_up_handled:
			if not _pick_up_item(item_):
				pick_up_error.emit(item_.zone_item, Core.Error.UNHANDLED)
				items_.pop_back()
				continue
		
		pick_up_after.emit(item_.zone_item)
		items_.pop_back()

func _pick_up_item(item_: ItemUnitResource) -> bool:
	if Core.level == null:
		return false

	if _items.add_item(item_.zone_item, true):
		_remove_empty_zone_item(item_)
		return true
	
	return false

func get_closest_pick_up_zone_item() -> ItemUnitResource:
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	return _get_closest_pick_up_zone_item(items_)
	
func _get_closest_pick_up_zone_item(items_: Array[ItemUnitResource]) -> ItemUnitResource:
	if items_.size() == 0:
		return null
		
	if items_.size() == 1:
		if items_[0].zone_item.item.meta.can_pick_up:
			return items_[0]
			
		return null
	
	var unit_position_: Vector2 = unit.get_align_global_position(_items.unit_alignment)
	
	var closest_item_: ItemUnitResource = null
	var closest_position_: Vector2
	
	for item_: ItemUnitResource in items_:
		if not item_.zone_item.item.meta.can_pick_up:
			continue
			
		var item_position_: Vector2 = item_.node.get_align_global_position(_items.item_alignment)
		
		if closest_item_ == null:
			closest_item_ = item_
			closest_position_ = item_position_
			continue
	
		var current_position_: Vector2 = item_.node.get_align_global_position(_items.item_alignment)
		var test_position_: Vector2 = Core.get_closest_vector2(unit_position_, closest_position_, current_position_)
		
		if test_position_ == current_position_:
			closest_item_ = item_
			closest_position_ = current_position_
	
	return closest_item_
	
func _remove_empty_zone_item(item_: ItemUnitResource) -> bool:
	if item_.zone_item.count != 0:
		return false
	
	if (item_.zone_item.item.zone_stack != null and
		not item_.zone_item.item.zone_stack.remove_empty
	):
		return false
		
	if Core.zone == null:
		return false
	
	if not Core.zone.items.has_item(item_):
		return false
	
	Core.zone.items.remove_item(item_)
	
	return true
	
func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_pick_up,
	]
		
	return actions_
