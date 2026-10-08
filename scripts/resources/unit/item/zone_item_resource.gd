extends InventoryValue
class_name ZoneItemResource

@export_storage var id: StringName = &"":
	get = get_id,
	set = set_id
		
func get_id() -> StringName:
	if id == &"":
		id = Core.create_id(&"item_")
	return id
func set_id(id_: StringName) -> void:
	id = id_

func get_inventory_value() -> InventoryValue:
	var count_: int = count
	
	if count_ >= 0:
		var item_stack_: ItemStackResource = item.inventory_stack
		if item_stack_ == null:
			item_stack_ = ItemStackResource.new()
		
		if item_stack_.stack_size == 0:
			count_ = 1
		elif item_stack_.stack_size > count_:
			count_ = item_stack_.stack_size
	
	return InventoryValue.new(
		item,
		count_,
		attr.duplicate(true),
	)
	
func _get_item_stack() -> ItemStackResource:
	return item.zone_stack
