class_name ItemHandler

var _data: ItemDataLoader

func _init() -> void:
	_data = ItemDataLoader.new("res://data/item")
	_data.load()
	
func has_item(alias_: StringName) -> bool:	
	if Core.level != null:
		return Core.level.data.items.has_item(alias_)
		
	if _data.has_item(alias_):
		return true
		
	return false
	
func get_item(alias_: StringName) -> Dictionary:
	if _data.has_item(alias_):
		return _data.get_item(alias_)
		
	if Core.level != null:
		if Core.level.data.items.has_item(alias_): # Level specific items
			return Core.level.data.items.get_item(alias_)
	
	assert(false, "Item not found. (" + alias_ + ")")
	return {}
	
func get_item_value(alias_: StringName) -> ItemValue:
	if Core.level != null:
		if Core.level.data.items.has_item(alias_): # Level specific items
			return Core.level.data.items.get_item_value(alias_)
	
	if _data.has_item(alias_):
		return _data.get_item_value(alias_)
		
	assert(false, "Item not found. (" + alias_ + ")")
	return null

func get_item_unit(item_value_: ItemValue) -> ItemUnit:
	var path: String
			
	if item_value_.scene != null and item_value_.scene.is_path:
		path = item_value_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_value_.alias + ".tscn"

	var node: Node
	
	# If the node doesn't exist, just load it
	if Core.nodes.scenes.has(path):
		node = await Core.nodes.scenes[path].instantiate()
	else:
		node = await load(path).instantiate()
		
	if not node is ItemUnit:
		return null
		
	node.set_item_value(item_value_)
	
	return node

func get_level_item_unit(item_value_: ItemValue) -> ItemUnit:
	var path: String
			
	if item_value_.scene != null and item_value_.scene.is_path:
		path = item_value_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_value_.alias + ".tscn"

	var node: Node = await Core.nodes.get_node(
		path, 
		func(node_: Node, reset_type_: Core.ResetType) -> void:
			if reset_type_ == Core.ResetType.START and node_ is ItemUnit:
				node_.set_item_value(item_value_)
	)
	
	if node != null and not node is ItemUnit:
		Core.nodes.free_node(node)
		return null
	
	return node
