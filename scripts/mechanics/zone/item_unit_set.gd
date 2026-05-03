class_name ItemUnitSet

var items: Array[ItemUnitResource] = []:
	get = get_items,
	set = set_items

signal add_item_before(item_: ItemUnitResource)
signal add_item_after(item_: ItemUnitResource)

signal remove_item_before(item_: ItemUnitResource)
signal remove_item_after(item_: ItemUnitResource)

func populate_items() -> void:
	for item_: ItemUnitResource in items:
		await populate_item(item_)
			
func populate_chunk_items(rect_: Rect2) -> void:
	# TODO: For open world chunk loading
	pass

func depopulate_items() -> void:
	for item_: ItemUnitResource in items:
		await depopulate_item(item_)

func depopulate_chunk_items(rect_: Rect2) -> void:
	# TODO: For open world chunk loading
	pass

func populate_item(item_: ItemUnitResource) -> void:
	assert(Core.level != null, "Level is null.")
	
	if Core.level == null:
		return
	
	assert(Core.zone != null, "Level zone is null.")
	
	if Core.zone == null:
		return

	if item_.node != null:
		return
	
	item_.node = await Core.items.get_level_item_unit(
		item_.zone_item.item,
		func(node_: Node, reset_type_: Core.ResetType) -> void:
			node_.import(item_)
	)

func depopulate_item(item_: ItemUnitResource) -> void:
	assert(Core.level != null, "Level is null.")
	
	if Core.level == null:
		return
	
	assert(Core.zone != null, "Level zone is null.")
	
	if Core.zone == null:
		return
		
	if item_.node != null:
		await Core.nodes.free_node(item_.node)
		item_.node = null

func get_adjacent_item(rect_: Rect2, edge_: Core.Edge) -> ItemUnitResource:
	for item_: ItemUnitResource in items:
		if item_.node == null:
			continue

		if Core.is_adjacent_rect(
			rect_, 
			item_.node.get_position_rect(), 
			edge_
		):
			return item_

	return null

func get_items() -> Array[ItemUnitResource]:
	return items
	
func set_items(value_: Array[ItemUnitResource]) -> void:
	items = value_

func get_items_from_meta(meta: Dictionary) -> Array[ItemUnitResource]:
	var items_: Array[ItemUnitResource] = []

	for item_: ItemUnitResource in items:
		if Core.dictionary_contains(item_.meta, meta):
			items_.push_back(item_)

	return items_

func get_items_from_type(item_type_: Core.ItemType) -> Array[ItemUnitResource]:
	var items_: Array[ItemUnitResource] = []

	for item_: ItemUnitResource in items:
		if item_.zone_item.item.item_type == item_type_:
			items_.push_back(item_)

	return items_
	
func get_item_from_zone_item(zone_item_: ZoneItemResource) -> ItemUnitResource:
	for index_: int in items.size():
		if items[index_].zone_item == zone_item_:
			return items[index_]
	
	return null
	
func has_item(item_: ItemUnitResource) -> bool:
	for index_: int in items.size():
		if items[index_] == item_:
			return true
			
	return false
	
func add_item(item_: ItemUnitResource) -> void:
	add_item_before.emit(item_)

	items.push_back(item_)

	await populate_item(item_)

	add_item_after.emit(item_)

func remove_item(item_: ItemUnitResource) -> void:
	for index_: int in items.size():
		if items[index_] != item_:
			continue

		remove_item_before.emit(items[index_])
		await depopulate_item(items[index_])

		var removed_item_: ItemUnitResource = items[index_]

		items.remove_at(index_)

		removed_item_.node = null
		remove_item_after.emit(removed_item_)
		break

func remove_items() -> void:
	for index_: int in range(items.size() - 1, -1, -1):
		remove_item_before.emit(items[index_])
		await depopulate_item(items[index_])

		var removed_item_: ItemUnitResource = items[index_]

		items.remove_at(index_)

		removed_item_.node = null
		remove_item_after.emit(removed_item_)
