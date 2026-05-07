extends UnitActor
class_name UseItemActor

var _items: ItemsActor

var signal_can_use: bool = false
var signal_use_handled: bool = false

var action_use: StringName = &"item_use"

signal use_error(inventory_item_: InventoryItemResource, error_: Core.Error) 
signal use_before(inventory_item_: InventoryItemResource)
signal use_after(inventory_item_: InventoryItemResource)

func _init(items_: ItemsActor, unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"drop_item", enabled_)
	_items = items_

func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return

	_action_use_selected_item()
	
func _action_use_selected_item() -> void:
	if not unit.actions.is_just_pressed(action_use):
		return
	
	if not unit.actions.has(action_use):
		use_error.emit(_items.get_selected_item(), Core.Error.UNIT_RESTRICTION)
		return
		
	use_selected_item()
	
func can_use_item(inventory_item_: InventoryItemResource) -> bool:
	if inventory_item_ == null:
		return false
		
	if inventory_item_.count == 0:
		return false
	
	return true

func can_use_selected_item() -> bool:
	return can_use_item(_items.get_selected_item())
	
func use_item(inventory_item_: InventoryItemResource) -> bool:
	if not can_use_item(inventory_item_):
		use_error.emit(inventory_item_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_use = true
	signal_use_handled = false
	
	use_before.emit(inventory_item_)
	
	if signal_can_use == false:
		use_error.emit(inventory_item_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_use_handled:
		if not _use_item(inventory_item_):
			use_error.emit(inventory_item_, Core.Error.UNHANDLED)
			return false
	
	use_after.emit(inventory_item_)
	return true
		
func use_selected_item() -> bool:
	var inventory_item_: InventoryItemResource = _items.get_selected_item()
	
	return use_item(inventory_item_)

func _use_item(inventory_item_: InventoryItemResource) -> bool:
	if not unit.has_method(&"use_item"):
		return false

	if not unit.use_item(inventory_item_.item):
		return false
	
	#TODO: Change to itterate over all slots if match
	var selected_item_value_: InventoryItemResource = _items.get_selected_item()
	
	if inventory_item_.meta.can_stack:
		if inventory_item_.meta.count > 0:
			inventory_item_.meta.count -= 1
		
		if inventory_item_.meta.count == 0 and inventory_item_ == selected_item_value_:
			_items.remove_selected_item()
	elif inventory_item_ == selected_item_value_:
		_items.remove_selected_item()
	
	return true

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_use,
	]
		
	return actions_
