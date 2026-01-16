class_name ComponentNode

var coords: Vector2i

var connections: Dictionary = {}

func _init(coords_: Vector2i) -> void:
	coords = coords_

func has_connection(edge_: Core.Edge) -> bool:
	return connections.has(edge_)

func get_connection(edge_: Core.Edge) -> ComponentNodeConnection:
	return connections[edge_]
		
func set_connection(connection_: ComponentNodeConnection) -> void:
	connections[connection_.edge] = connection_

func get_connections() -> Dictionary:
	return connections

func get_connection_edges(coords_: Vector2i) -> Array[Core.Edge]:
	var edges_: Array[Core.Edge] = []
	
	for edge_: Core.Edge in connections:
		if connections[edge_].end_coords == coords_:
			# No connections.
			if connections[edge_].path_coords.size() == 0:
				continue
				
			edges_.push_back(edge_)
			continue

		if connections[edge_].path_coords.has(coords_):
			edges_.push_back(edge_)

	return edges_

func has_path_coords(coords_: Vector2i) -> bool:
	if coords == coords_:
		return false
		
	for edge_: Core.Edge in connections:
		if connections[edge_].end_coords == coords_:
			# No connections.
			if connections[edge_].path_coords.size() == 0:
				return false
				
			return true

		if connections[edge_].path_coords.has(coords_):
			return true

	return false

func clear_edges(keep_edges_: Array[Core.Edge]) -> void:
	var current_edges_: Array = connections.keys()

	for edge_: Core.Edge in current_edges_:
		if not keep_edges_.has(edge_):
			connections.erase(edge_)

func get_edge_diff(edges_: Array[Core.Edge]) -> Dictionary:
	var added_edges_: Array[Core.Edge] = []
	var removed_edges_: Array[Core.Edge] = []

	for edge_: Core.Edge in edges_:
		if not connections.has(edge_):
			added_edges_.push_back(edge_)

	for edge_: Core.Edge in connections:
		if not edges_.has(edge_):
			removed_edges_.push_back(edge_)

	return {&"added": added_edges_, &"removed": removed_edges_}

func disconnect_coords(coords_: Vector2i) -> bool:
	# Can't disconnect itself
	if coords_ == coords:
		return false
	
	var disconnected_: bool = false
	
	for edge_: Core.Edge in connections:
		# If connection removed was its end node
		if connections[edge_].end_coords == coords_:
			if connections[edge_].path_coords.back() == connections[edge_].end_coords:
				# Not a node connection so just remove a path coords
				connections[edge_].path_coords.pop_back()
			
			if connections[edge_].path_coords.size() > 0:
				connections[edge_].end_coords = connections[edge_].path_coords.back()
			else:
				connections[edge_].end_coords = coords

			return true

		# If connection removed was part of the path coords
		var index: int = connections[edge_].path_coords.find(coords_)
		if index >= 0:
			connections[edge_].path_coords = connections[edge_].path_coords.slice(0, index)
		
			if connections[edge_].path_coords.size() > 0:
				# Still has remaining path coords so set end to last
				connections[edge_].end_coords = connections[edge_].path_coords.back()
			else:
				# No remaining path coords so set to itself
				connections[edge_].end_coords = coords
			disconnected_ = true

	return disconnected_
