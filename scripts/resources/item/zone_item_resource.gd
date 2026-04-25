extends InventoryItemResource
class_name ZoneItemResource

func get_inventory_item() -> InventoryItemResource:
	var count_: int = count
	
	if count_ >= 0:
		var item_stack_: ItemStackResource = item.inventory_stack
		if item_stack_ == null:
			item_stack_ = ItemStackResource.new()
		
		if item_stack_.stack_size == 0:
			count_ = 1
		elif item_stack_.stack_size > count_:
			count_ = item_stack_.stack_size
	
	return InventoryItemResource.new(
		item,
		count_,
		meta.duplicate(true),
	)
	
func _get_item_stack() -> ItemStackResource:
	return item.zone_stack
