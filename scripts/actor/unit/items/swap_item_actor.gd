extends UnitActor
class_name SwapItemActor

var _items: ItemsActor
var _current_item: ItemUnitResource = null

var swap_mode: Core.ItemMode = Core.ItemMode.SINGLE

var swap_action_enabled: bool = true
var swap_action_enabled_default: bool = true
var signal_can_swap: bool = false
var signal_swap_handled: bool = false

var action_swap: StringName = &"item_swap"

signal swap_error(inventory_item_: InventoryItemResource, zone_item_: ZoneItemResource, error_: Core.Error) 
signal swap_before(inventory_item_: InventoryItemResource, zone_item_: ZoneItemResource)
signal swap_after(inventory_item_: InventoryItemResource, zone_item_: ZoneItemResource)

func _init(items_: ItemsActor, unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"drop_item", enabled_)
	_items = items_

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		swap_action_enabled = swap_action_enabled_default
		
func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return

	_action_swap_selected_item()
	
func _action_swap_selected_item() -> void:
	if not swap_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_swap):
		return
		
	if not unit.actions.has(action_swap):
		var items_: Array[ItemUnitResource] = _items.get_item_area_items()
		
		if items_.size() == 0:
			swap_error.emit(_items.get_selected_item(), null, Core.Error.UNIT_RESTRICTION)
		else:
			swap_error.emit(_items.get_selected_item(), items_[0].zone_item, Core.Error.UNIT_RESTRICTION)
		return
	
	swap_selected_item()

func can_swap_item(inventory_item_: InventoryItemResource) -> bool:
	if inventory_item_ == null:
		return false
	
	# Item must be in inventory
	var slot_: int = _items.get_slot(inventory_item_)
	if slot_ == -1:
		return false
	
	if not inventory_item_.can_drop:
		return false
		
	if not _items.is_in_item_area:
		return false
	
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	if items_.size() == 0:
		return false
	
	for item_: ItemUnitResource in items_:
		if _can_swap_zone_item(items_, item_, inventory_item_):
			_current_item = item_
			return true
	
	return false

func can_swap_selected_item() -> bool:
	var inventory_item_: InventoryItemResource = _items.get_selected_item()
	return can_swap_item(inventory_item_)

# Returns true the item is a single item
func _can_swap_zone_item(
	items_: Array[ItemUnitResource],
	item_: ItemUnitResource,
	inventory_item_: InventoryItemResource,
) -> bool:
	if inventory_item_ == null:
		return false
		
	if (items_.size() != 1 and
		_items.drop.drop_mode != Core.ItemMode.MULTIPLE and 
		swap_mode != Core.ItemMode.MULTIPLE
	):
		return false
		
	if not item_.zone_item.item.can_pick_up:
		return false
	
	if not inventory_item_.can_drop:
		return false
	
	var zone_stack_: ItemStackResource = item_.zone_item.item.zone_stack
	if zone_stack_ == null:
		zone_stack_ = ItemStackResource.new()
	
	if not item_.zone_item.item.zone_stack.remove_empty:
		return false
		
	var inventory_stack_: ItemStackResource = inventory_item_.item.inventory_stack
	if inventory_stack_ == null:
		inventory_stack_ = ItemStackResource.new()
	
	if not inventory_stack_.item.zone_stack.remove_empty:
		return false
		
	if _items.drop.drop_mode == Core.ItemMode.MULTIPLE:
		return true
		
	if (inventory_item_.item.alias != item_.zone_item.item.alias and
		not item_.zone_item.item.allow_multiple_stacks and
		_items.get_items_from_alias(item_.zone_item.item.alias).size() > 0
	):
		return false

	if (item_.zone_item.is_valid_inventory_stack() and
		inventory_item_.is_valid_zone_stack()
	):
		return true
	
	return false
	
func swap_item(inventory_item_: InventoryItemResource) -> bool:
	var items_: Array[ItemUnitResource] = _items.get_item_area_items()
	
	_current_item = null
	
	if not can_swap_item(inventory_item_):
		if items_.size() == 0:
			swap_error.emit(inventory_item_, null, Core.Error.ACTOR_RESTRICTION)
		else:
			swap_error.emit(inventory_item_, items_[0].zone_item, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_swap = true
	signal_swap_handled = false
	
	swap_before.emit(inventory_item_, _current_item.zone_item)
	
	if signal_can_swap == false:
		swap_error.emit(inventory_item_, _current_item.zone_item, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_swap_handled:
		if not _swap_item(inventory_item_, _current_item):
			swap_error.emit(inventory_item_, _current_item.zone_item, Core.Error.UNHANDLED)
			return false

	swap_after.emit(inventory_item_, _current_item.zone_item)
	return true

func swap_selected_item() -> bool:
	var inventory_item_: InventoryItemResource = _items.get_selected_item()
	return swap_item(inventory_item_)
		
func _swap_item(inventory_item_: InventoryItemResource, item_: ItemUnitResource) -> bool:
	if Core.zone == null:
		return false
	
	if _items.can_add_item(item_.zone_item, false, true):
		_items._add_item(item_.zone_item, false, true)
		_items.pick_up._remove_empty_zone_item(item_)
		return _items.drop._drop_item(inventory_item_)
	else:
		#_items.replace_selected_item(zone_items_[0])
		#inventory_item_ = zone_items_[0]
		#TODO swap item
		pass
	
	return true

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_swap,
	]
		
	return actions_
