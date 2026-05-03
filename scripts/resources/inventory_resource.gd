extends Resource
class_name InventoryResource

@export var items: Array[InventoryItemResource] = []
@export var slots: int = -1
@export_storage var selected_slot: int = 0:
	set(value):
		assert(_is_in_range(value), "Slot is out of range.")

		if _is_in_range(value):
			selected_slot = value

func _init(slots_: int = -1) -> void:
	slots = slots_

func clear() -> void:
	selected_slot = 0
	items.clear()
	
	if slots != -1:
		for i: int in slots:
			items.push_back(null)


func move_selection_next() -> void:
	if slots == 0:
		selected_slot = 0
		return
		
	if slots == -1:
		if items.size() == 0:
			selected_slot = 0
			return
			
		selected_slot = (selected_slot + 1) % items.size()
	else:
		selected_slot = (selected_slot + 1) % slots
		
func move_selection_previous() -> void:
	if slots == 0:
		selected_slot = 0
		return
		
	if selected_slot == 0:
		if slots == -1:
			if items.size() == 0:
				selected_slot = 0
				return
			
			selected_slot = items.size() - 1
		else:
			selected_slot = slots - 1
	else:
		selected_slot -= 1

func select_item(slot_: int) -> bool:
	if not _is_in_range(slot_):
		return false
	
	selected_slot = slot_
	return true
	
func select_item_of_type(type_: Core.ItemType) -> bool:
	for i: int in items.size():
		if items[i].item.type == type_:
			selected_slot = i
			return true
		
	return false
	
func is_selected_item_of_type(type_: Core.ItemType) -> bool:
	if items[selected_slot] == null:
		return false
		
	if items[selected_slot].item.type == type_:
		return true
	
	return false

func get_slot(inventory_item_: InventoryItemResource) -> int:
	for index_: int in items.size():
		if items[index_] == inventory_item_:
			return index_
			
	return -1

func get_item(slot_: int) -> InventoryItemResource:
	assert(_is_in_range(slot_), "Slot is out of range.")

	if not _is_in_range(slot_):
		return null
	
	return items[slot_]
	
func get_selected_item() -> InventoryItemResource:
	if items.size() == 0:
		return null
		
	return items[selected_slot]
	
func get_selected_item_type() -> Core.ItemType:
	if items.size() == 0:
		return Core.ItemType.NONE
		
	if items[selected_slot] == null:
		return Core.ItemType.NONE

	return items[selected_slot].item.type

func get_items_from_alias(alias_: StringName) -> Array[InventoryItemResource]:
	var items_: Array[InventoryItemResource] = []
	
	for item_: InventoryItemResource in items:
		if item_ != null and item_.alias == alias_:
			items_.push_back(item_)
	
	return items_
	
func get_items_from_meta(meta_: Dictionary) -> Array[InventoryItemResource]:
	var items_: Array[InventoryItemResource] = []
	
	for item_: InventoryItemResource in items:
		if item_ != null and Core.dictionary_contains(item_.item.meta, meta_):
			items_.push_back(item_)
	
	return items_
	
func get_items_from_type(type_: Core.ItemType) -> Array[InventoryItemResource]:
	var inventory_items_: Array[InventoryItemResource] = []
	
	for inventory_item_: InventoryItemResource in items:
		if inventory_item_ != null and inventory_item_.item.type == type_:
			inventory_items_.push_back(inventory_item_)
	
	return inventory_items_

func can_add_item(
	inventory_item_: InventoryItemResource, 
	merge_: bool = false,
	unselected_: bool = false,
) -> bool:
	var has_empty: bool = false
	var match_count: int = 0
	
	for index_: int in items.size():
		if index_ == selected_slot and unselected_:
			continue
		
		if items[index_] == null:
			has_empty = true
			continue
	
		if items[index_].item.alias != inventory_item_.item.alias:
			continue
			
		match_count += 1
		
		if merge_ and items[index_].can_merge(inventory_item_):
			return true
		
	if slots == -1 or has_empty:
		if match_count >= inventory_item_.item.max_stacks:
			return false
			
		return true
	
	return false
	
func add_item(
	inventory_item_: InventoryItemResource,
	merge_: bool = false,
	unselected_: bool = false,
) -> bool:
	# TODO: If ZoneItemResource, modify count and create new InventoryItemResource
	var empty_slot_: int = -1
	var match_count: int = 0
	var has_merged_: bool = false
	
	# Prioritize selected slot
	if not unselected_:
		if slots == -1:
			if selected_slot < items.size() and items[selected_slot] == null:
				empty_slot_ = selected_slot
		elif items[selected_slot] == null:
			empty_slot_ = selected_slot
	
	var item_stack_: ItemStackResource = inventory_item_.item.inventory_stack
	if item_stack_ == null:
		item_stack_ = ItemStackResource.new()
		
	for index_: int in items.size():
		if index_ == selected_slot and unselected_:
			continue
			
		if items[index_] == null:
			if empty_slot_ == -1:
				empty_slot_ = index_
				
			continue
			
		if items[index_].item.alias != inventory_item_.item.alias:
			continue
			
		match_count += 1
		
		if items[index_].count == 0 and items[index_].merge(inventory_item_):
			return true
		elif items[index_].merge(inventory_item_):
			if inventory_item_.count <= 0:
				return true
				
			if item_stack_.item_mode == Core.ItemMode.SINGLE:
				return true
				
			has_merged_ = true
	
	if has_merged_ and item_stack_.item_mode == Core.ItemMode.SINGLE:
		return true
	
	# No available slots
	if slots != -1 and empty_slot_ == -1:
		return has_merged_
	
	if match_count >= inventory_item_.item.max_stacks:
		return has_merged_
	
	var new_inventory_item_: InventoryItemResource
	
	if inventory_item_ is ZoneItemResource:
		new_inventory_item_ = inventory_item_.get_inventory_item()
	else:
		new_inventory_item_ = inventory_item_.duplicate(true) as InventoryItemResource
	
	if inventory_item_.count == -1:
		if item_stack_.add_infinite:
			inventory_item_.count = 0
		elif item_stack_.item_mode == Core.ItemMode.SINGLE:
			new_inventory_item_.count = 1
			inventory_item_.count -= 1
		elif item_stack_.item_mode == Core.ItemMode.MULTIPLE:
			inventory_item_.count = 0
	elif item_stack_.item_mode == Core.ItemMode.SINGLE:
		new_inventory_item_.count = 1
		inventory_item_.count -= 1
	elif item_stack_.item_mode == Core.ItemMode.MULTIPLE:
		var count_: int = maxi(1, item_stack_.stack_size)
		
		if count_ > inventory_item_.count:
			count_ = inventory_item_.count
			
		new_inventory_item_.count = count_
		inventory_item_.count -= count_

	if empty_slot_ == -1:
		items.push_back(new_inventory_item_)
	else:
		items[empty_slot_] = new_inventory_item_
	
	return true

func replace_item(slot_: int, inventory_item_: InventoryItemResource) -> void:
	assert(_is_in_range(slot_), "Slot is out of range.")

	if not _is_in_range(slot_):
		return
		
	items[slot_] = inventory_item_
	
func replace_selected_item(item_: InventoryItemResource) -> void:
	replace_item(selected_slot, item_)
	
func remove_item(slot_: int) -> void:
	assert(_is_in_range(slot_), "Slot is out of range.")

	if not _is_in_range(slot_):
		return
	
	items[slot_] = null
	
	if slots == -1:
		while items.back() == null:
			items.pop_back()
	
func remove_selected_item() -> void:
	remove_item(selected_slot)

func is_empty() -> bool:
	for item_: InventoryItemResource in items:
		if item_ != null:
			return false
			
	return true

func is_slot_empty(slot_: int) -> bool:
	assert(_is_in_range(slot_), "Slot is out of range.")

	if not _is_in_range(slot_):
		return false
	
	return items[slot_] == null

func is_selected_slot_empty() -> bool:
	return is_slot_empty(selected_slot)
	
func has_empty() -> bool:
	if slots == -1:
		return true
		
	for item_: InventoryItemResource in items:
		if item_ == null:
			return true
	
	return false

func _is_in_range(slot_) -> bool:
	if slots == -1:
		if slot_ < 0 or slot_ >= items.size():
			return false
	else:
		if slot_ < 0 or slot_ >= slots:
			return false
			
	return true
