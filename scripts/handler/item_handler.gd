class_name ItemHandler
	
func get_item_unit(item_: ItemResource) -> ItemUnit:
	var path: String
			
	if item_.scene != null and item_.scene.path != "":
		path = item_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_.alias + ".tscn"

	var node: Node
	
	# If the node doesn't exist, just load it
	if Core.nodes.scenes.has(path):
		node = await Core.nodes.scenes[path].instantiate()
	else:
		node = await load(path).instantiate()
		
	if not node is ItemUnit:
		return null
	
	return node

func get_level_item_unit(
	item_: ItemResource,
	reset_method_: Callable = Callable()
) -> ItemUnit:
	var path: String
			
	if item_.scene != null and item_.scene.path != "":
		path = item_.scene.path
	else:
		path = "res://scenes/unit/item/" + item_.alias + ".tscn"

	var node: Node = await Core.nodes.get_node(path, reset_method_)
	
	if not node is ItemUnit:
		Core.nodes.free_node(node)
		return null
	
	return node
