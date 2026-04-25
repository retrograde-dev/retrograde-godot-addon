extends UnitActor
class_name DropItemActor

var _items: ItemsActor

var drop_offset: Vector2 = Vector2.ZERO

var drop_mode: Core.ItemMode = Core.ItemMode.SINGLE
var drop_swap: bool = false

var drop_action_enabled: bool = true
var drop_action_enabled_default: bool = true
var signal_can_drop: bool = false
var signal_drop_handled: bool = false

var action_drop: StringName = &"item_drop"

signal drop_error(inventory_item_: InventoryItemResource, error_: Core.Error) 
signal drop_before(inventory_item_: InventoryItemResource)
signal drop_after(inventory_item_: InventoryItemResource)

func _init(items_: ItemsActor, unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"drop_item", enabled_)
	_items = items_

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		drop_action_enabled = drop_action_enabled_default
	
func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return

	_action_drop_selected_item()
	
func _action_drop_selected_item() -> void:
	if not drop_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_drop):
		return
		
	if not unit.actions.has(action_drop):
		drop_error.emit(_items.get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return

	drop_selected_item()
		
func can_drop_item(inventory_item_: InventoryItemResource) -> bool:
	if inventory_item_ == null:
		return false
	
	if drop_mode == Core.ItemMode.NONE:
		return false
	
	if not inventory_item_.can_drop:
		return false
		
	if not _items.is_in_item_area:
		return true
		
	if drop_mode == Core.ItemMode.MULTIPLE:
		return true
	
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	if items_.size() == 0:
		return true
	
	for item_: ItemUnitResource in items_:
		if item_.zone_item.can_merge(inventory_item_):
			return true
	
	return false

func can_drop_selected_item() -> bool:
	var inventory_item_: InventoryItemResource = _items.get_selected_item()
	return can_drop_item(inventory_item_)

func drop_item(inventory_item_: InventoryItemResource) -> bool:
	var can_drop_: bool = can_drop_item(inventory_item_)
	
	if not can_drop_ and drop_swap:
		# Can only swap items in inventory
		var slot_: int = _items.get_slot(inventory_item_)
		
		if slot_ != -1 and _items.swap.can_swap_item(inventory_item_):
			return _items.swap.swap_item(inventory_item_)
	
	if not can_drop_:
		drop_error.emit(inventory_item_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_drop = true
	signal_drop_handled = false
	
	drop_before.emit(inventory_item_)
	
	if signal_can_drop == false:
		drop_error.emit(inventory_item_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_drop_handled:
		if not _drop_item(inventory_item_):
			drop_error.emit(inventory_item_, Core.Error.UNHANDLED)
			return false

	drop_after.emit(inventory_item_)
	return true
	
func drop_selected_item() -> bool:
	var inventory_item_: InventoryItemResource = _items.get_selected_item()
	return drop_item(inventory_item_)
	
func _drop_item(inventory_item_: InventoryItemResource) -> bool:
	if Core.level == null:
		return false
	
	if Core.zone == null:
		return false
		
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	var zone_stack_: ItemStackResource = inventory_item_.item.zone_stack
	if zone_stack_ == null:
		zone_stack_ = ItemStackResource.new()
	
	# Merge slot item into matching level item
	for item_: ItemUnitResource in items_:
		if item_.zone_item.can_merge(inventory_item_):
			item_.zone_item.merge(inventory_item_)
			
			if inventory_item_.count == 0:
				_remove_empty_inventory_item(inventory_item_)
				return true
			
			if zone_stack_.item_mode == Core.ItemMode.SINGLE:
				# Set to only drop single item at a time
				return true
	
	return _drop_new_zone_item(inventory_item_)

func _drop_new_zone_item(inventory_item_: InventoryItemResource) -> bool:
	var unit_position_: Vector2 = unit.get_align_global_position(_items.unit_alignment)
	var item_position_: Vector2 = unit_position_ - Core.zone.global_position
	
	if _items.item_position_mode == Core.ItemPositionMode.TILE:
		item_position_ = ((item_position_ + drop_offset) / Core.TILE_SIZE).floor() * Core.TILE_SIZE
	else:
		item_position_ += drop_offset
		
	var count_: int = 0
	var meta_: Dictionary = inventory_item_.meta.duplicate(true)
	meta_.set(&"alignment", _items.item_alignment)
	
	var zone_stack_: ItemStackResource = inventory_item_.item.zone_stack
	if zone_stack_ == null:
		zone_stack_ = ItemStackResource.new()
	
	if zone_stack_.item_mode == Core.ItemMode.SINGLE:
		if inventory_item_.count > 1:
			count_ = 1
			inventory_item_.count -= 1
		elif inventory_item_.count == -1:
			count_ = 1
	else:
		count_ = inventory_item_.count
		inventory_item_.count = 0
		
	if inventory_item_.count == 0:
		_remove_empty_inventory_item(inventory_item_)
	
	var zone_item_: ZoneItemResource = ZoneItemResource.new(
		inventory_item_.item,
		count_,
		meta_
	)
	
	var item_ = ItemUnitResource.new(zone_item_)
	item_.position = item_position_
	
	Core.zone.items.add_item(item_)
	
	return true

func _remove_empty_inventory_item(inventory_item_: InventoryItemResource) -> bool:
	if inventory_item_.count != 0:
		return false
	
	if (inventory_item_.inventory_stack != null and
		not inventory_item_.inventory_stack.remove_empty
	):
		return false
		
	var slot_: int = _items.get_slot(inventory_item_)
	
	if slot_ == -1:
		return false
	
	_items.remove_item(slot_)
	
	return true

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_drop,
	]
		
	return actions_
