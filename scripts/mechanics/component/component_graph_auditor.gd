class_name ComponentGraphAuditor

var _graph: ComponentGraph

func _init(graph_: ComponentGraph) -> void:
	_graph = graph_
	
func get_invalid_node_connections() -> Dictionary:
	var path_groups_: Array = find_circular_node_paths()
	var conflicting_coords_: Dictionary = {}
	
	for paths_: Array in path_groups_:
		for path_: Array in paths_:
			for value_: Dictionary in path_:
				if not conflicting_coords_.has(value_.start_coords):
					conflicting_coords_[value_.start_coords] = []
				
				if not conflicting_coords_[value_.start_coords].has(value_.start_edge):
					conflicting_coords_[value_.start_coords].push_back(value_.start_edge)	
				
				if not conflicting_coords_.has(value_.end_coords):
					conflicting_coords_[value_.end_coords] = []
				
				if not conflicting_coords_[value_.end_coords].has(value_.end_edge):
					conflicting_coords_[value_.end_coords].push_back(value_.end_edge)
	
	return conflicting_coords_

## Finds all paths that lead back to the same node.
## Returns Array[Array[Array[Vector2i]]]
func find_circular_node_paths() -> Array:
	var paths_: Array = []
	
	for node_coords_: Vector2i in _graph.get_nodes():
		var node_: ComponentNode = _graph.get_node(node_coords_)
		var component_: Component = _graph.get_component(node_coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()
		
		for edge_: Core.Edge in node_.get_connections():
			if orientation_.get_connection_type(edge_) == Core.ComponentType.INPUT:
				continue

			var path_: Array[Dictionary] = []
			var all_paths_: Array = []
		
			_find_all_paths_recursive(
				node_coords_, 
				edge_, 
				node_coords_, 
				edge_, 
				path_, 
				all_paths_
			)
				
			if not all_paths_.is_empty():
				paths_.push_back(all_paths_)
				
	return paths_

## Recursive depth first search to find all paths.
func _find_all_paths_recursive(
	current_coords_: Vector2i, 
	current_edge_: Core.Edge,
	end_coords_: Vector2i, 
	end_edge_: Core.Edge,
	path_: Array[Dictionary],
	all_paths_: Array
) -> void:
	path_.push_back({&"start_coords": current_coords_, &"start_edge": current_edge_})
		
	var current_node_: ComponentNode = _graph.nodes[current_coords_]
	var current_connection_: ComponentNodeConnection = current_node_.get_connection(current_edge_)
	var current_component_: Component = _graph.get_component(current_connection_.end_coords)
	var current_orientation_: ComponentOrientation = current_component_.get_orientation()
	
	# Dead end
	if not _graph.nodes.has(current_connection_.end_coords):
		path_.pop_back()
		return
	
	# Empty connection
	if (current_coords_ == current_connection_.end_coords and 
		current_connection_.path_coords.size() == 0
	):
		path_.pop_back()
		return
	
	# Output -> output
	if current_orientation_.get_connection_type(current_connection_.end_edge) == Core.ComponentType.OUTPUT:
		path_.pop_back()
		return
	
	# Path found
	if current_connection_.end_coords == end_coords_ and current_connection_.end_edge != end_edge_:
		path_.back().end_coords = current_connection_.end_coords
		path_.back().end_edge = current_connection_.end_edge
		all_paths_.append(path_.duplicate())
		path_.pop_back()
		return
	
	var next_node_: ComponentNode = _graph.nodes[current_connection_.end_coords]
	var next_component_: Component = _graph.get_component(current_connection_.end_coords)
	var next_orientation_: ComponentOrientation = next_component_.get_orientation()
	
	for next_edge_: Core.Edge in next_node_.get_connections():
		## Skip over inputs
		if (next_orientation_.get_connection_type(next_edge_) == Core.ComponentType.INPUT or 
			next_edge_ == current_connection_.end_edge
		):
			continue
		#
		var next_connection_: ComponentNodeConnection = next_node_.get_connection(next_edge_)
		#
		## Skip over connections that lead back to current connection
		if next_connection_.end_coords == current_connection_.end_coords:
			continue
#
		## Dead end
		if not _graph.nodes.has(next_connection_.end_coords):
			continue
			
		# Skip over paths that have already been handled
		if _has_path_connection(path_, current_connection_.end_coords, next_edge_):
			continue
		
		path_.back().end_coords = current_connection_.end_coords
		path_.back().end_edge = current_connection_.end_edge
		
		_find_all_paths_recursive(
			current_connection_.end_coords, 
			next_edge_, 
			end_coords_, 
			end_edge_,
			path_, 
			all_paths_
		)
		
	# Backtrack to find other routes.
	path_.pop_back()

func _has_path_connection(path_: Array[Dictionary], coords_: Vector2i, edge_: Core.Edge) -> bool:
	for value_: Dictionary in path_:
		if value_.start_coords == coords_ and value_.start_edge == edge_:
			return true
			
		if value_.has("end_coords"):
			if value_.end_coords == coords_ and value_.end_edge == edge_:
				return true
			
	return false


## Helper breadth first search function to find a path between two nodes.
## Can optionally ignore a coordinate to force a different route.
func get_path(
	start_coords_: Vector2i, 
	end_coords_: Vector2i, 
	ignore_nodes_: Array[Vector2i] = [],
	ignore_node_connections_: Dictionary = {}
) -> Array[Vector2i]:
	var queue_: Array[Vector2i] = [start_coords_]
	
	# This dictionary tracks how we reached each node, to reconstruct the path.
	var came_from_: Dictionary = {start_coords_: null}

	while not queue_.is_empty():
		var current_coords_: Vector2i = queue_.pop_front()

		if current_coords_ == end_coords_:
			# Path found! Reconstruct and return it.
			var path_: Array[Vector2i]
			var step_: Vector2i = end_coords_
			
			while true:
				path_.push_front(step_)
				if came_from_.has(step_):
					step_ = came_from_[step_]
				else:
					break
				
			return path_

		# If the node doesn't exist, skip it.
		if not _graph.nodes.has(current_coords_):
			continue

		var node_: ComponentNode = _graph.get_node(current_coords_)
		var component_: Component = _graph.get_component(current_coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()

		# Explore neighbors.
		for edge_: Core.Edge in node_.get_connections():
			if ignore_nodes_.has(current_coords_):
				continue
				
			# Skip over ignored connections.
			if (ignore_node_connections_.has(current_coords_) and 
				ignore_node_connections_[current_coords_].has(edge_)
			):
				continue
			
			# Skip over inputs
			if orientation_.get_connection_type(edge_) == Core.ComponentType.INPUT:
				continue
			
			var connection_: ComponentNodeConnection = node_.get_connection(edge_)
			
			# Skip over connections that lead back to current connection
			if connection_.end_coords == current_coords_:
				continue
			
			# Dead end
			if not _graph.nodes.has(connection_.end_coords):
				continue
			
			# Skip if we've already visited this neighbor.
			if not came_from_.has(connection_.end_coords):
				came_from_[connection_.end_coords] = current_coords_
				queue_.push_back(connection_.end_coords)

	# No path was found.
	return []

## Helper breadth first search function to determine if two nodes connect to eachother.
## Can optionally ignore a coordinate to force a different route.
func has_path(
	start_coords_: Vector2i, 
	end_coords_: Vector2i, 
	ignore_nodes_: Array[Vector2i] = [],
	ignore_node_connections_: Dictionary = {},
) -> bool:
	var queue_: Array[Vector2i] = [start_coords_]
	
	# This dictionary tracks how we reached each node, to reconstruct the path.
	var came_from_: Dictionary = {start_coords_: true}

	while not queue_.is_empty():
		var current_coords_: Vector2i = queue_.pop_front()

		if current_coords_ == end_coords_:
			return true

		# If the node doesn't exist, skip it.
		if not _graph.nodes.has(current_coords_):
			continue

		var node_: ComponentNode = _graph.get_node(current_coords_)
		var component_: Component = _graph.get_component(current_coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()

		# Explore neighbors.
		for edge_: Core.Edge in node_.get_connections():
			if ignore_nodes_.has(current_coords_):
				continue
				
			# Skip over ignored connections.
			if (ignore_node_connections_.has(current_coords_) and 
				ignore_node_connections_[current_coords_].has(edge_)
			):
				continue
			
			# Skip over inputs
			if orientation_.get_connection_type(edge_) == Core.ComponentType.INPUT:
				continue
			
			var connection_: ComponentNodeConnection = node_.get_connection(edge_)
			
			# Skip over connections that lead back to current connection
			if connection_.end_coords == current_coords_:
				continue
			
			# Dead end
			if not _graph.nodes.has(connection_.end_coords):
				continue
			
			# Skip if we've already visited this neighbor.
			if not came_from_.has(connection_.end_coords):
				came_from_[connection_.end_coords] = true
				queue_.push_back(connection_.end_coords)

	# No path was found.
	return false
