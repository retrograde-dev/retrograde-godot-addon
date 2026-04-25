extends Resource
class_name InventoryItemResource

@export var item: ItemResource = null
@export_range(-1, 9999, 1, "or_greater", "hide_control") var count: int = 1
@export var meta: Dictionary = {}

func _init(
	item_: ItemResource = null,
	count_: int = 1,
	meta_: Dictionary = {}
) -> void:
	item = item_
	count = count_
	meta = meta_

func _get_item_stack() -> ItemStackResource:
	return item.inventory_stack
	
func is_full() -> bool:
	if count == 0:
		return false
		
	if count == -1:
		return true
		
	var item_stack_: ItemStackResource = _get_item_stack()
	if item_stack_ == null:
		item_stack_ = ItemStackResource.new()
	
	return count >= maxi(1, item_stack_.stack_size)
	
func can_merge(inventory_item_: InventoryItemResource) -> bool:
	if item.alias != inventory_item_.item.alias:
		return false
	
	var item_stack_: ItemStackResource = _get_item_stack()
	if item_stack_ == null:
		item_stack_ = ItemStackResource.new()
	
	if item_stack_.item_mode == Core.ItemMode.NONE:
		return false
		
	if inventory_item_.count == 0:
		return false
	
	if count == -1:
		if inventory_item_.count == -1:
			return item_stack_.merge_infinite
			
		return true
	
	return not is_full()

func merge(inventory_item_: InventoryItemResource) -> bool:
	if not can_merge(inventory_item_):
		return false
		
	var item_stack_: ItemStackResource = _get_item_stack()
	if item_stack_ == null:
		item_stack_ = ItemStackResource.new()
		
	if count == -1:
		if inventory_item_.count == -1:
			inventory_item_.count = 0
		elif item_stack_.item_mode == Core.ItemMode.SINGLE:
			inventory_item_.count -= 1
		elif item_stack_.item_mode == Core.ItemMode.MULTIPLE:
			inventory_item_.count = 0
			
		return true
	
	if item_stack_.item_mode == Core.ItemMode.SINGLE:
		count += 1
		if inventory_item_.count != -1:
			inventory_item_.count -= 1
	elif item_stack_.item_mode == Core.ItemMode.MULTIPLE:
		var count_: int = maxi(1, item_stack_.stack_size) - count
		
		if inventory_item_.count != -1 and count_ > inventory_item_.count:
			count_ = inventory_item_.count
			
		count += count_
		if inventory_item_.count != -1:
			inventory_item_.count -= count_
	
	return true

func is_valid_inventory_stack() -> bool:
	return _is_valid_stack(item.inventory_stack)
	
func is_valid_zone_stack() -> bool:
	return _is_valid_stack(item.zone_stack)
	
func _is_valid_stack(item_stack_: ItemStackResource) -> bool:
	if count == 1:
		return true
	
	if item_stack_ == null:
		item_stack_ = ItemStackResource.new()
	
	if count == 0:
		return !item_stack_.remove_empty
	
	if count > maxi(1, item_stack_.stack_size):
		return false
	
	return true
