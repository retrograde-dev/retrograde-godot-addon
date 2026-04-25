class_name EntityHandler
	
func get_entity_unit(entity_: EntityResource) -> EntityUnit:
	var path: String
			
	if entity_.scene != null and entity_.scene.path != "":
		path = entity_.scene.path
	else:
		path = "res://scenes/unit/entity/" + entity_.alias + ".tscn"

	var node: Node
	
	# If the node doesn't exist, just load it
	if Core.nodes.scenes.has(path):
		node = await Core.nodes.scenes[path].instantiate()
	else:
		node = await load(path).instantiate()
		
	if not node is EntityUnit:
		return null
	
	return node

func get_level_entity_unit(
	entity_: EntityResource,
	reset_method_: Callable = Callable()
) -> EntityUnit:
	var path: String
			
	if entity_.scene != null and entity_.scene.path != "":
		path = entity_.scene.path
	else:
		path = "res://scenes/unit/entity/" + entity_.alias + ".tscn"

	var node: Node = await Core.nodes.get_node(path, reset_method_)
	
	if not node is EntityUnit:
		Core.nodes.free_node(node)
		return null
	
	return node
