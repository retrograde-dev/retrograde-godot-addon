class_name ComponentOrientation

var connections: Dictionary
var _edges: Array[Core.Edge] = []

func _init(connections_: Dictionary) -> void:
	connections = connections_

	var mixed_count_: int = 0
	
	for edge_: Core.Edge in connections:
		if not connections[edge_] is ComponentConnection:
			assert(true, "Invalid connection.")
			continue
			
		if connections[edge_].get_type() == Core.ComponentType.MIXED:
			mixed_count_ += 1
		_edges.push_back(edge_)
		
	if mixed_count_ > 0 and connections.size() > 2:
		assert(true, "Invalid connections. (Orientations with more than two connections cannot have a type of mixed.)")

func size() -> int:
	return connections.size()

func get_connections() -> Dictionary:
	return connections

func has_edge(edge_: Core.Edge) -> bool:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invalid edge.")
		return false

	return _edges.has(edge_)
	
func get_edges() -> Array[Core.Edge]:
	return _edges

func get_input_edges() -> Array[Core.Edge]:
	var edges_: Array[Core.Edge] = []

	for edge_: Core.Edge in connections:
		if connections[edge_].get_type() != Core.ComponentType.INPUT:
			continue

		edges_.push_back(edge_)

	return edges_

func get_output_edges() -> Array[Core.Edge]:
	var edges_: Array[Core.Edge] = []

	for edge_: Core.Edge in connections:
		if connections[edge_].get_type() != Core.ComponentType.OUTPUT:
			continue

		edges_.push_back(edge_)

	return edges_

func get_mixed_edges() -> Array[Core.Edge]:
	var edges_: Array[Core.Edge] = []

	for edge_: Core.Edge in connections:
		if connections[edge_].get_type() != Core.ComponentType.MIXED:
			continue

		edges_.push_back(edge_)

	return edges_

func is_input_edge(edge_: Core.Edge) -> bool:
	if not connections.has(edge_):
		return false

	return connections[edge_].get_type() == Core.ComponentType.INPUT

func is_output_edge(edge_: Core.Edge) -> bool:
	if not connections.has(edge_):
		return false

	return connections[edge_].get_type() == Core.ComponentType.OUTPUT

func is_mixed_edge(edge_: Core.Edge) -> bool:
	if not connections.has(edge_):
		return false

	return connections[edge_].get_type() == Core.ComponentType.MIXED

func is_edge_required(edge_: Core.Edge) -> bool:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invalid edge.")
		return false
	
	return connections[edge_].is_required()

func get_connection_type(edge_: Core.Edge) -> Core.ComponentType:
	return connections[edge_].get_type()

func modify(edge_: Core.Edge, input_level_: float) -> float:
	if not has_edge(edge_):
		assert(true, "Invalid edge.")
		return -1.0

	return connections[edge_].modify(input_level_)
