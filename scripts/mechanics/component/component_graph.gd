class_name ComponentGraph

var components: Dictionary = {}
var nodes: Dictionary = {}
var auditor: ComponentGraphAuditor

func _init() -> void:
	auditor = ComponentGraphAuditor.new(self)

## Rebuild all nodes
func update() -> void:
	_update_nodes()
	_update_connections()

## Update only the nodes affected by changes to the coordinates
func update_coords(coords_: Vector2i) -> bool:
	var update_connections_: bool = false
	var update_orientation_: bool = false
	
	if components.has(coords_): # A component was added or orientated
		var component_: Component = get_component(coords_)
			
		if _is_node(coords_):
			if nodes.has(coords_):
				var node_: ComponentNode = nodes[coords_]
				var edges_: Array[Core.Edge] = component_.get_edges()
				var edge_diff_: Dictionary = node_.get_edge_diff(edges_)
				
				for edge_: Core.Edge in edge_diff_.removed:
					var connection_: ComponentNodeConnection = node_.get_connection(edge_)
					if nodes.has(connection_.end_coords):
						# Connects to itself on a different edge
						if connection_.end_coords == coords_ and connection_.path_coords.size() > 0:
							# Add end edge to added so it updates
							edge_diff_.added.push_back(connection_.end_edge)
						else:
							nodes[connection_.end_coords].disconnect_coords(coords_)
					
				node_.clear_edges(edges_)
				
				for edge_: Core.Edge in edge_diff_.added:
					_update_node_edge(coords_, edge_, true)
				
				if edge_diff_.removed.size() > 0 or edge_diff_.added.size() > 0:
					update_connections_ = true
				
				# Alawys update in case orientation change doesn't effect connections.
				update_orientation_ = true
			else:
				_update_node(coords_, true)
				update_connections_ = true
		else:
			# Connect or disconnect adjacent coords as needed
			var component_edges_: Array[Core.Edge] = component_.get_edges()

			for edge_: Core.Edge in Core.Edge.values():
				if edge_ == Core.Edge.NONE:
					continue
				
				var adjacent_coords_: Vector2i = coords_ + Core.get_edge_direction(edge_)
				
				var adjacent_component_: Component = get_component(adjacent_coords_)
				
				if adjacent_component_ == null:
					continue
					
				# Adjacent item doesn't have connection to this edge
				if not adjacent_component_.has_edge(Core.get_opposing_edge(edge_)):
					continue
				
				update_connections_ = true
					
				if nodes.has(adjacent_coords_):
					if component_edges_.has(edge_):
						_update_node_edge(adjacent_coords_, Core.get_opposing_edge(edge_), true)
					else:
						nodes[adjacent_coords_].disconnect_coords(coords_)
						
					continue
				
				for node_coords_: Vector2i in nodes:
					var node_: ComponentNode = nodes[node_coords_]
					
					var adjacent_edges_: Array[Core.Edge] = node_.get_connection_edges(adjacent_coords_)
					if adjacent_edges_.size() == 0:
						continue
					
					# If the updated component has this edge then the adjacent
					# node needs to update 
					if component_edges_.has(edge_):
						for adjacent_edge_: Core.Edge in adjacent_edges_:
							_update_node_edge(node_.coords, adjacent_edge_, true)
					else:
						node_.disconnect_coords(coords_)
	elif nodes.has(coords_): # A node was removed
		var node_: ComponentNode = nodes[coords_]
		
		for edge_: Core.Edge in node_.connections:
			var connection_: ComponentNodeConnection = node_.get_connection(edge_)
			if (connection_.end_coords != coords_ and 
				nodes.has(connection_.end_coords)
			):
				nodes[connection_.end_coords].disconnect_coords(coords_)
		
		nodes.erase(coords_)
		update_connections_ = true
	else: # An in between component was removed
		var found_: int = 0
		
		for node_coords_: Vector2i in nodes:
			var node_: ComponentNode = nodes[node_coords_]
				
			if node_.disconnect_coords(coords_):
				update_connections_ = true
				found_ += 1
			
			# Will only ever be two map nodes affected
			if found_ == 2:
				break;
				
		if found_ == 0:
			for edge_: Core.Edge in Core.Edge.values():
				if edge_ == Core.Edge.NONE:
					continue
				
				var adjacent_coords_: Vector2i = coords_ + Core.get_edge_direction(edge_)

				var adjacent_component_: Component = get_component(adjacent_coords_)
				
				if adjacent_component_ == null:
					continue
					
				update_connections_ = true
				break
	
	if update_connections_:
		_update_connection(coords_)
	
	return update_connections_ or update_orientation_

func run() -> void:
	var visited_: Array[Vector2i] = []
	var node_visited_: Array[Vector2i] = []
	var delay_stack_: Array[Vector2i] = []
	
	var invalid_connections_: Dictionary = auditor.get_invalid_node_connections()
	
	var stack_: Array[Vector2i] = get_coords_set_from_type(Core.ComponentType.OUTPUT)
	
	while stack_.size() > 0:
		var current_coords_: Vector2i = stack_.pop_back()
		
		if node_visited_.has(current_coords_):
			continue
		
		visited_.push_back(current_coords_)
		node_visited_.push_back(current_coords_)
		
		var current_component_: Component = get_component(current_coords_)
		var current_node_: ComponentNode = get_node(current_coords_)
		var current_orientation_: ComponentOrientation = current_component_.get_orientation()
		
		for current_edge_: Core.Edge in current_orientation_.get_edges():
			var current_connection_: ComponentNodeConnection = current_node_.get_connection(current_edge_)
			
			if _handle_input_connection_validation(
				current_coords_,
				current_edge_,
				visited_,
				node_visited_,
				invalid_connections_,
			):
				continue
				
			if _handle_output_connection_validation(
				current_coords_,
				current_edge_,
				visited_,
				node_visited_,
				invalid_connections_,
			):
				continue
			
			# Add component to delay stack for future processing
			if (has_node(current_connection_.end_coords) and
				not delay_stack_.has(current_connection_.end_coords) and 
				not node_visited_.has(current_connection_.end_coords) and 
				not stack_.has(current_connection_.end_coords)
			):
				get_component(current_connection_.end_coords).reset_input_levels()
				delay_stack_.push_back(current_connection_.end_coords)
			
			_handle_input_level_validation(
				current_coords_,
				current_edge_,
				visited_,
			)
			
		_handle_component_validation(
			current_coords_,
		)
		
		if stack_.size() == 0 and delay_stack_.size() > 0:
			_update_run_stack(
				stack_,
				delay_stack_,
				node_visited_,
				invalid_connections_,
			)
	
	# Any remaining nodes are unused and can be ignored.
	for coords_: Vector2i in nodes:
		if visited_.has(coords_):
			continue
			
		visited_.push_back(coords_)
		
		var component_: Component = get_component(coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()
		for edge_: Core.Edge in orientation_.get_edges():
			var connection_: ComponentNodeConnection = nodes[coords_].get_connection(edge_)
			
			if orientation_.is_input_edge(edge_) or orientation_.is_mixed_edge(edge_):
				component_.set_input_level(edge_, 0.0)
			
			#if connection_.end_coords != coords_ or connection_.path_coords.size() > 0:
			if (invalid_connections_.has(coords_) and 
				invalid_connections_[coords_].has(edge_)
			):
				component_.set_connection_validation(
					edge_,
					Core.Validation.WARNING
				)
			elif connection_.end_coords != coords_ and node_visited_.has(connection_.end_coords):
				component_.set_connection_validation(
					edge_,
					Core.Validation.ERROR
				)
			else:
				component_.set_connection_validation(
					edge_,
					Core.Validation.NONE
				)
		
		component_.set_validation(Core.Validation.IGNORE)
			

func _update_run_stack(
	stack_: Array[Vector2i],
	delay_stack_: Array[Vector2i],
	node_visited_: Array[Vector2i],
	invalid_connections_: Dictionary,
) -> void:
	if delay_stack_.size() == 1:
		stack_.push_back(delay_stack_.pop_back())
		return
	
	var remaining_stack_: Array[Vector2i] = []
	
	# Nodes with all inputs set can continue
	for index_: int in range(delay_stack_.size() - 1, -1, -1):
		var component_: Component = get_component(delay_stack_[index_])
		if component_.has_all_input_levels():
			stack_.push_back(delay_stack_[index_])
			delay_stack_.remove_at(index_)

	if stack_.size() > 0:
		return
		
	if delay_stack_.size() == 0:
		return
	
	if delay_stack_.size() == 1:
		stack_.push_back(delay_stack_.pop_back())
		return
		
	# Prioritize nodes that don't connected to others in the delay stack
	for i: int in delay_stack_.size():
		var has_path: bool = false
		
		for j: int in delay_stack_.size():
			if i == j:
				continue;
				
			has_path = auditor.has_path(
				delay_stack_[i], 
				delay_stack_[j], 
				node_visited_,
				invalid_connections_,
			)
			
			if has_path:
				break
		
		if not has_path:
			stack_.push_back(delay_stack_[i])
			delay_stack_.remove_at(i)
			return
	
	# Just pull a random one
	stack_.push_back(delay_stack_.pop_back())

func _handle_input_connection_validation(
	coords_: Vector2i,
	edge_: Core.Edge,
	visited_: Array[Vector2i],
	node_visited_: Array[Vector2i],
	invalid_connections_: Dictionary,
) -> bool:
	var component_: Component = get_component(coords_)
	var orientation_: ComponentOrientation = component_.get_orientation()
	
	if orientation_.is_output_edge(edge_):
		return false
		
	if orientation_.is_mixed_edge(edge_) and component_.get_input_level(edge_) < 0.0:
		return false
		
	var node_: ComponentNode = get_node(coords_)
	var connection_: ComponentNodeConnection = node_.get_connection(edge_)
	
	var validation_: Core.Validation = Core.Validation.NONE
	var update_connection_path_: bool = false
	var update_input_level_: bool = false
	
	if not has_node(connection_.end_coords):
		# Bad connection (dead end)
		validation_ = Core.Validation.ERROR
		update_connection_path_ = true
		update_input_level_ = true
	elif connection_.end_coords == coords_:
		# Bad connection (connects to itself, or no connection)
		if connection_.path_coords.size() > 0: 
			# Connects to itself
			validation_ = Core.Validation.ERROR
		elif orientation_.is_edge_required(connection_.edge):
			# No connection and required
			validation_ = Core.Validation.ERROR

		update_input_level_ = true
	elif (invalid_connections_.has(coords_) and 
		invalid_connections_[coords_].has(edge_)
	):
		# Bad connection (circular connection)
		validation_ = Core.Validation.WARNING
		update_input_level_ = true
	elif not node_visited_.has(connection_.end_coords):
		# Input from output that hasn't been processed which means comes 
		# from dead node
		validation_ = Core.Validation.ERROR
		update_input_level_ = true
	elif component_.get_input_level(edge_) <= 0.0:
		validation_ = Core.Validation.ERROR
	else:
		validation_ = Core.Validation.SUCCESS
	
	if update_input_level_:
		component_.set_input_level(connection_.edge, 0.0)
	
	component_.set_connection_validation(
		connection_.edge,
		validation_
	)
	
	if update_connection_path_:
		_handle_connection_path_validation(
			connection_.path_coords,
			validation_,
			visited_
		)
		
	return true

func _handle_output_connection_validation(
	coords_: Vector2i,
	edge_: Core.Edge,
	visited_: Array[Vector2i],
	node_visited_: Array[Vector2i],
	invalid_connections_: Dictionary,
) -> bool:
	var component_: Component = get_component(coords_)
	var orientation_: ComponentOrientation = component_.get_orientation()
	
	if orientation_.is_input_edge(edge_):
		return false
		
	if orientation_.is_mixed_edge(edge_) and component_.get_input_level(edge_) >= 0.0:
		return false
		
	var node_: ComponentNode = get_node(coords_)
	var connection_: ComponentNodeConnection = node_.get_connection(edge_)
	
	var validation_: Core.Validation = Core.Validation.NONE
	var update_connection_path_: bool = false
	
	if not has_node(connection_.end_coords):
		# Bad connection (dead end)
		validation_ = Core.Validation.ERROR
		update_connection_path_ = true
	elif connection_.end_coords == coords_:
		# Bad connection (connects to itself, or no connection)
		if connection_.path_coords.size() > 0:
			# Connects to itself
			validation_ = Core.Validation.ERROR
			update_connection_path_ = true
		elif orientation_.is_edge_required(edge_) and component_.get_type() != Core.ComponentType.OUTPUT:
			# No connection and required
			validation_ = Core.Validation.ERROR
	elif (invalid_connections_.has(coords_) and 
		invalid_connections_[coords_].has(edge_)
	):
		# Bad connection (circular connection)
		validation_ = Core.Validation.WARNING
		update_connection_path_ = true
	else:
		# Bad connection (output -> output)
		var next_component_: Component = get_component(connection_.end_coords)
		var next_orientation_: ComponentOrientation = next_component_.get_orientation()
		var next_connection_type_: Core.ComponentType = next_orientation_.get_connection_type(connection_.end_edge)
		if next_connection_type_ == Core.ComponentType.OUTPUT:
			validation_ = Core.Validation.ERROR
			if not node_visited_.has(connection_.end_coords):
				update_connection_path_ = true
		else:
			return false
	
	component_.set_connection_validation(
		edge_,
		validation_
	)
	
	if update_connection_path_:
		_handle_connection_path_validation(
			connection_.path_coords,
			validation_,
			visited_,
		)
		
	return true

func _handle_input_level_validation(
	coords_: Vector2i,
	edge_: Core.Edge,
	visited_: Array[Vector2i],
) -> void:
	var component_: Component = get_component(coords_)
	var node_: ComponentNode = get_node(coords_)
	var connection_: ComponentNodeConnection = node_.get_connection(edge_)
	
	assert(has_node(connection_.end_coords), "Invalid node.")
	
	var next_component_: Component = get_component(connection_.end_coords)

	var output_level_: float = component_.get_output_level(edge_)

	output_level_ = _get_node_connection_output_level(connection_, output_level_)

	next_component_.set_input_level(connection_.end_edge, output_level_)
	
	var validation_: Core.Validation
	
	if output_level_ <= 0.0:
		validation_ = Core.Validation.ERROR
	else:
		validation_ = Core.Validation.SUCCESS
	
	component_.set_connection_validation(
		edge_, 
		validation_
	)
	_handle_connection_path_validation(
		connection_.path_coords,
		validation_,
		visited_
	)
	
func _handle_component_validation(
	coords_: Vector2i,
) -> void:
	var component_: Component = get_component(coords_)
	
	if component_.get_type() == Core.ComponentType.INPUT:
		if component_.get_total_input_level() <= 0.0:
			component_.set_validation(Core.Validation.ERROR)
			return
	elif component_.get_type() == Core.ComponentType.OUTPUT:
		if component_.get_total_output_level() <= 0.0:
			component_.set_validation(Core.Validation.ERROR)
			return
			
	var handled_: bool = false
	
	for edge_: Core.Edge in Core.Edge.values():
		if edge_ == Core.Edge.NONE:
			continue
		
		var validation_: Core.Validation = component_.get_connection_validation(edge_)
		
		if (validation_ == Core.Validation.ERROR or
			validation_ == Core.Validation.WARNING
		):
			component_.set_validation(Core.Validation.ERROR)
			handled_ = true
			break
			
	if not handled_:
		component_.set_validation(Core.Validation.SUCCESS)

func _handle_connection_path_validation(
	path_coords_: Array[Vector2i], 
	validation_: Core.Validation,
	visited_: Array[Vector2i],
) -> void:
	for coords_: Vector2i in path_coords_:
		if visited_.has(coords_):
			continue
		
		visited_.push_back(coords_)
		
		var component_: Component = get_component(coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()
		for edge_: Core.Edge in orientation_.get_edges():
			component_.set_connection_validation(edge_, validation_)

func _get_node_connection_output_level(
	connection_: ComponentNodeConnection, 
	output_level_: float
) -> float:
	var input_edge_: Core.Edge = Core.get_opposing_edge(connection_.edge)
	
	for coords_: Vector2i in connection_.path_coords:
		var component_: Component = get_component(coords_)
		var orientation_: ComponentOrientation = component_.get_orientation()
		
		component_.set_input_level(
			input_edge_, 
			output_level_,
			true
		)
		
		for edge_: Core.Edge in orientation_.get_edges():
			if edge_ == input_edge_:
				continue
			
			output_level_ = component_.get_output_level(edge_)

			input_edge_ = Core.get_opposing_edge(edge_)
			break
	
	return output_level_

func has_node(coords_: Vector2i) -> bool:
	return nodes.has(coords_)
	
func get_node(coords_: Vector2i) -> ComponentNode:
	if nodes.has(coords_):
		return nodes[coords_]
		
	return null
	
func get_nodes() -> Dictionary:
	return nodes

func has_component(coords_: Vector2i) -> bool:
	return components.has(coords_)

func get_component(coords_: Vector2i) -> Component:
	if components.has(coords_):
		return components[coords_]
		
	return null
	
func add_component(coords_: Vector2i, component_: Component) -> void:
	components[coords_] = component_
	component_.set_graph(self)

func remove_component(coords_: Vector2i) -> void:
	if components.has(coords_):
		components[coords_].set_graph(null)
		components.erase(coords_)

func get_coords(component_: Component) -> Vector2i:
	for coords_: Vector2i in components:
		if components[coords_] == component_:
			return coords_
	
	assert(true, "Component not found.")
	return Vector2i.ZERO
	
func get_coords_set_from_nodes() -> Array[Vector2i]:
	return nodes.keys()

func get_coords_set_from_type(compontnet_type_: Core.ComponentType) -> Array[Vector2i]:
	var component_coords_: Array[Vector2i] = []
	
	for coords_: Vector2i in components:
		if components[coords_].get_type() == compontnet_type_:
			component_coords_.push_back(coords_)
	
	return component_coords_

func can_connect_edge(coords_: Vector2i, edge_: Core.Edge) -> bool:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invlaid edge.")
		return false
	
	var component_: Component = get_component(coords_)
	
	if component_ == null:
		return false
		
	if not component_.has_edge(edge_):
		return false
		
	return can_connect_adjacent_edge(coords_, edge_)
		
func can_connect_adjacent_edge(coords_: Vector2i, edge_: Core.Edge) -> bool:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invlaid edge.")
		return false
	
	var adjacent_coords_: Vector2i = coords_ + Core.get_edge_direction(edge_)
	
	if not has_component(adjacent_coords_):
		return false
	
	var adjacent_component_: Component = get_component(adjacent_coords_)
	
	if not adjacent_component_.has_edge(Core.get_opposing_edge(edge_)):
		return false

	return true

func _is_node(coords_: Vector2i) -> bool:
	if not has_component(coords_):
		return false
		
	var component_: Component = get_component(coords_)
		
	match component_.get_type():
		Core.ComponentType.MIXED:
			var orientation_: ComponentOrientation = component_.get_orientation()
			if orientation_.size() != 2:
				return true
			
			var connections_: Dictionary = orientation_.get_connections()
			for edge_: Core.Edge in connections_:
				if connections_[edge_].get_type() != Core.ComponentType.MIXED:
					return true
					
			return false
		Core.ComponentType.OUTPUT:
			return true
		Core.ComponentType.INPUT:
			return true
			
	return false

func _update_nodes() -> void:
	nodes = {}

	for coords_: Vector2i in components:
		if not _is_node(coords_):
			continue
		
		_update_node(coords_, true)

func _update_node(coords_: Vector2i, force_: bool = false) -> void:
		if not nodes.has(coords_):
			nodes[coords_] = ComponentNode.new(coords_)
		
		var component_: Component = get_component(coords_)
		
		var edges_: Array[Core.Edge] = component_.get_edges()
		
		nodes[coords_].clear_edges(edges_)
		
		for edge_: Core.Edge in edges_:
			_update_node_edge(coords_, edge_, force_)

func _update_node_edge(
	coords_: Vector2i, 
	edge_: Core.Edge,
	force_: bool = false,
) -> void:
	# Edge node already set, only regenerate if force
	if not force_ and nodes[coords_].has_connection(edge_):
		return
	
	var next_: ComponentNodeConnection = _find_next_node(coords_, edge_)
	nodes[coords_].set_connection(next_)
	
	#if coords_ != next_.end_coords and _is_node(next_.end_coords):
		#if not nodes.has(next_.end_coords):
			#nodes[next_.end_coords] = ComponentNode.new(next_.end_coords)
		#
		#if force_ or not nodes[next_.end_coords].has_connection(next_.edge):
			#var path_coords = next_.path_coords.duplicate()
			#path_coords.reverse()
			#nodes[next_.end_coords].set_connection(
				#ComponentNodeConnection.new(next_.edge, coords_, path_coords)
			#)

func _find_next_node(coords_: Vector2i, edge_: Core.Edge) -> ComponentNodeConnection:
	var current_: ComponentNodeConnection = ComponentNodeConnection.new(
		edge_, 
		Core.get_opposing_edge(edge_), 
		coords_, 
		[]
	)
	var next_: ComponentNodeConnection = null
	
	while true:
		next_ = _get_next_component(
			current_.edge,
			current_.end_coords, 
			current_.path_coords,
		)
		
		if next_ == null:
			if current_.path_coords.size() > 0:
				current_.end_coords = current_.path_coords.back()
			break
		
		current_ = next_
		
		if _is_node(next_.end_coords):
			break
	
	current_.edge = edge_
	
	return current_


func _get_next_component(edge_: Core.Edge, coords_: Vector2i, path_coords_: Array) -> ComponentNodeConnection:
	var current_component_: Component = get_component(coords_)
	
	if current_component_ == null:
		assert(true, "Component not found.")
		return null
	
	var next_coords_: Vector2i = coords_ + Core.get_edge_direction(edge_)
	var opposing_edge_: Core.Edge = Core.get_opposing_edge(edge_)
	
	var next_component_: Component = get_component(next_coords_)

	if next_component_ == null or not next_component_.has_edge(opposing_edge_):
		return null
	
	# Next node found
	if _is_node(next_coords_):
		return ComponentNodeConnection.new(
			edge_,
			opposing_edge_,
			next_coords_, 
			path_coords_
		)
	
	var next_edge_: Core.Edge
	
	# Should only have two edges
	for current_edge_: Core.Edge in next_component_.get_edges():
		if current_edge_ == opposing_edge_:
			continue
		
		next_edge_ = current_edge_
		break
		
	path_coords_.push_back(next_coords_)
	
	return _get_next_component(next_edge_, next_coords_, path_coords_)
	

func _update_connections() -> void:
	for coords_: Vector2i in components:
		var component_: Component = get_component(coords_)
		for edge_: Core.Edge in component_.get_edges():
			if can_connect_edge(coords_, edge_):
				component_.connect_edge(edge_)
			else:
				component_.disconnect_edge(edge_)

func _update_connection(coords_: Vector2i, edge_: Core.Edge = Core.Edge.NONE) -> void:
	var component_: Component = get_component(coords_)
	
	if edge_ == Core.Edge.NONE:
		for current_edge_: Core.Edge in Core.Edge.values():
			if current_edge_ == Core.Edge.NONE:
				continue
			
			if component_ != null and component_.has_edge(current_edge_):
				if can_connect_edge(coords_, current_edge_):
					component_.connect_edge(current_edge_)
				else:
					component_.disconnect_edge(current_edge_)
				
			_update_connection(
				coords_ + Core.get_edge_direction(current_edge_),
				Core.get_opposing_edge(current_edge_)
			)
	elif component_ != null:
		if can_connect_edge(coords_, edge_):
			component_.connect_edge(edge_)
		elif component_.has_edge(edge_):
			component_.disconnect_edge(edge_)
