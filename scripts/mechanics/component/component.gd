class_name Component

var graph: ComponentGraph = null

var node: Node
var type: Core.ComponentType
var orientations: Array[ComponentOrientation]
var orientation_index: int = 0
var _connections: Dictionary = {}

var _input_levels: Dictionary = {}
var _input_updated: bool = true
var _output_updated: bool = true
var _current_total_input_level: float = -1.0
var _current_total_output_level: float = -1.0

var _validation: Core.Validation = Core.Validation.NONE
var _connection_validations: Dictionary = {}

var modifier: ComponentModifier

signal edge_connected(edge_: Core.Edge)
signal edge_disconnected(edge_: Core.Edge)
signal orientated(orientation_: ComponentOrientation)
signal input_level_changed(input_level_: float)
signal output_level_changed(output_level_: float)
signal graph_changed(graph: ComponentGraph)
signal validation_changed(edge_: Core.Edge, validation_: Core.Validation)

func _init(
	node_: Node,
	type_: Core.ComponentType,
	orientations_: Array[ComponentOrientation],
	modifier_: ComponentModifier = null
) -> void:
	node = node_
	type = type_
	orientations = orientations_
	modifier = modifier_
	
	if modifier == null:
		if type == Core.ComponentType.OUTPUT:
			modifier = ComponentModifier.new(
				0.0, 
				1.0,
				func(input_level_: float, input_modifier_: float, output_modifier_: float) -> float:
					return input_modifier_ + input_level_ + output_modifier_
			)
		elif type == Core.ComponentType.INPUT:
			modifier = ComponentModifier.new(
				1.0, 
				0.0,
				func(input_level_: float, input_modifier_: float, output_modifier_: float) -> float:
					if is_equal_approx(input_level_, input_modifier_):
						return 1.0

					return -1.0
			)

func reset() -> void:
	orientation_index = 0
	
	if modifier != null:
		modifier.reset()
		
	_connections = {}
	reset_input_levels()
	_input_updated = true
	_output_updated = true
	_current_total_input_level = -1.0
	_current_total_output_level = -1.0
	
	reset_validation()

func reset_validation() -> void:
	_validation = Core.Validation.NONE
	_connection_validations = {}

func get_graph() -> ComponentGraph:
	return graph
	
func set_graph(graph_: ComponentGraph) -> void:
	if graph != graph_:
		graph = graph_
		graph_changed.emit(graph)

func get_type() -> Core.ComponentType:
	return type

func get_edges() -> Array[Core.Edge]:
	return get_orientation().get_edges()

func has_edge(edge_: Core.Edge = Core.Edge.NONE) -> bool:
	return get_orientation().has_edge(edge_)

func get_orientation() -> ComponentOrientation:
	return orientations[orientation_index]

func get_orientation_index() -> int:
	return orientation_index

func set_orientation(orientation_index_: int) -> void:
	if orientation_index == orientation_index_:
		return
		
	orientation_index = orientation_index_
	reset_input_levels()
	
	for edge_: Core.Edge in _connections.keys():
		if not get_orientation().has_edge(edge_):
			if _connections.has(edge_):
				_connections.erase(edge_)
				edge_disconnected.emit(edge_)
			
	orientated.emit(get_orientation())
	
func get_orientations() -> Array[ComponentOrientation]:
	return orientations

func orientate() -> void:
	var orientation_index_: int = orientation_index + 1
	
	if orientation_index_ == orientations.size():
		orientation_index_ = 0
		
	set_orientation(orientation_index_)

func get_modifier() -> ComponentModifier:
	return modifier

func get_connections() -> Array[Core.Edge]:
	var edges_: Array[Core.Edge] = []
	
	for edge_: Core.Edge in _connections.keys():
		edges_.push_back(edge_)
	
	return edges_

func set_connections(edges_: Array[Core.Edge]) -> void:
	for edge_: Core.Edge in edges_:
		connect_edge(edge_)
		
	for edge_: Core.Edge in _connections:
		if not edges_.has(edge_):
			disconnect_edge(edge_)
	
func connect_edge(edge_: Core.Edge) -> void:
	if not has_edge(edge_):
		assert(true, "Edge not found.")
		return
	
	if not _connections.has(edge_):
		_connections[edge_] = true
		edge_connected.emit(edge_)
	
func disconnect_edge(edge_: Core.Edge) -> void:
	if not has_edge(edge_):
		assert(true, "Edge not found.")
		return
	
	if _connections.has(edge_):
		_connections.erase(edge_)
		edge_disconnected.emit(edge_)

func is_edge_connected(edge_: Core.Edge) -> bool:
	return _connections.has(edge_)

func is_fully_connected() -> bool:
	return _connections.size() == get_orientation().size()

func get_input_level(edge_: Core.Edge) -> float:
	if type == Core.ComponentType.OUTPUT:
		assert(true, "Can't get input level on output types.")
		return -1.0
	if edge_ == Core.Edge.NONE:
		assert(true, "Invalid edge.")
		return -1.0
	
	var orientation_: ComponentOrientation = get_orientation()
	
	if not orientation_.has_edge(edge_):
		return -1.0
	
	if orientation_.is_output_edge(edge_):
		return -1.0
			
	if orientation_.is_mixed_edge(edge_):
		if not _input_levels.has(edge_):
			return -1.0
	elif not _input_levels.has(edge_):
		return 0.0
		
		
	if _input_levels[edge_] <= 0.0:
		return 0.0
		
	return max(0.0, orientation_.modify(edge_, _input_levels[edge_]))

func reset_input_levels(edge_: Core.Edge = Core.Edge.NONE) -> void:
	if edge_ == Core.Edge.NONE:
		if _input_levels.size():
			_input_levels = {}
			_input_updated = true
	elif _input_levels.has(edge_):
		_input_levels.erase(edge_)
		_input_updated = true

func set_input_level(edge_: Core.Edge, input_level_: float, reset_: bool = false) -> void:
	if type == Core.ComponentType.OUTPUT:
		assert(true, "Can't set input level on output types.")
		return
	
	var update_total_: bool = false
	
	if not _input_levels.has(edge_) or _input_levels[edge_] != input_level_:
		update_total_ = true
	elif reset_ and _input_levels.size() > 1:
		update_total_ = true
		
	if reset_:
		_input_levels = {}
		
	_input_levels[edge_] = input_level_
	
	# We only want to call emit for input and output level changed events if 
	# value has actually changed
	if update_total_:
		if input_level_changed.has_connections():
			var total_input_level_: float = _get_total_input_level_internal()

			if total_input_level_ != _current_total_input_level:
				_current_total_input_level = total_input_level_
				input_level_changed.emit(_current_total_input_level)
				
			_input_updated = false
		else:
			_input_updated = true
			
		if output_level_changed.has_connections():
			var total_output_level_: float = _get_total_output_level_internal()
			if total_output_level_ != _current_total_output_level:
				_current_total_output_level = total_output_level_
				output_level_changed.emit(_current_total_output_level)
			
			_output_updated = false
		else:
			_output_updated = true
	
func get_total_input_level() -> float:
	if type == Core.ComponentType.OUTPUT:
		assert(true, "Can't get input level on output types.")
		return 0.0
	
	if _input_updated:
		_input_updated = false
		_current_total_input_level = _get_total_input_level_internal()
		
	return _current_total_input_level

func _get_total_input_level_internal() -> float:
	var total_input_level_: float = 0.0
	
	for current_edge_: Core.Edge in Core.Edge.values():
		if current_edge_ == Core.Edge.NONE:
			continue
			
		var input_level_: float = get_input_level(current_edge_)
		
		if input_level_ < 0.0:
			continue
		
		total_input_level_ += input_level_
	
	if modifier != null:
		total_input_level_ = modifier.modify(total_input_level_)
		
		if total_input_level_ < 0.0:
			return -1.0
		
	return total_input_level_

func get_output_level(edge_: Core.Edge) -> float:
	if type == Core.ComponentType.INPUT:
		assert(true, "Can't get output level on input types.")
		return 0.0
	
	var total_input_level: float
	var orientation_: ComponentOrientation = get_orientation()
	
	if type == Core.ComponentType.OUTPUT:
		total_input_level = max(0.0, modifier.modify(0.0))
	else:
		if orientation_.is_input_edge(edge_):
			return -1.0
			
		if orientation_.is_mixed_edge(edge_) and _input_levels.has(edge_):
			return -1.0
		
		total_input_level = get_total_input_level()
		
		if total_input_level < 0.0:
			return -1.0
	
	var output_connection_size: int = get_output_connection_size(true)
	
	var output_level_: float = total_input_level / output_connection_size
	
	return max(0.0, orientation_.modify(edge_, output_level_))

func get_total_output_level() -> float:
	if type == Core.ComponentType.INPUT:
		assert(true, "Can't get output level on input types.")
		return 0.0
	
	if _output_updated:
		_output_updated = false
		_current_total_output_level = _get_total_output_level_internal()
		
	return _current_total_output_level

func _get_total_output_level_internal() -> float:
	var orientation_: ComponentOrientation = get_orientation()
	var output_level_: float = 0.0
	
	for current_edge_: Core.Edge in orientation_.get_output_edges():
		var current_output_level_: float = get_output_level(current_edge_)
		if current_output_level_ > 0.0:
			output_level_ += current_output_level_
	
	for current_edge_: Core.Edge in orientation_.get_mixed_edges():
		var current_output_level_: float = get_output_level(current_edge_)
		if current_output_level_ > 0.0:
			output_level_ += current_output_level_
		
	return output_level_

func get_validation() -> Core.Validation:
	return _validation
	
func set_validation(validation_: Core.Validation) -> void:
	if _validation != validation_:
		_validation = validation_
		validation_changed.emit(Core.Edge.NONE, validation_)

func get_connection_validation(edge_: Core.Edge) -> Core.Validation:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invalid edge.")
		return Core.Validation.NONE
	
	if _connection_validations.has(edge_):
		return _connection_validations[edge_]
		
	return Core.Validation.NONE
	
func set_connection_validation(
	edge_: Core.Edge, 
	validation_: Core.Validation,
) -> void:
	if edge_ == Core.Edge.NONE:
		assert(true, "Invalid edge.")
		return
	
	if (not _connection_validations.has(edge_) or 
		_connection_validations[edge_] != validation_
	):
		_connection_validations[edge_] = validation_
		validation_changed.emit(edge_, validation_)

func is_valid() -> bool:
	if _validation == Core.Validation.IGNORE:
		return true
	
	if (_validation == Core.Validation.ERROR or
		_validation == Core.Validation.WARNING
	):
		return false
	
	for edge_: Core.Edge in _connection_validations:
		if (_connection_validations[edge_] == Core.Validation.ERROR or
			_connection_validations[edge_] == Core.Validation.WARNING
		):
			return false

	return true

func has_all_input_levels() -> bool:
	if get_input_connection_size() != _input_levels.size():
		return false
	
	# If there are mixed connections that could still be inputs
	if get_output_connection_size(true) != get_output_connection_size(false):
		return false
	
	return true

func get_input_connection_size(include_mixed_: bool = false) -> int:
	var orientation_: ComponentOrientation = get_orientation()
	
	var size_: int = orientation_.get_input_edges().size()
	
	if not include_mixed_:
		return size_
	
	for edge_: Core.Edge in orientation_.get_mixed_edges():
		if _input_levels.has(edge_):
			size_ += 1
		
	return size_
	
func get_output_connection_size(include_mixed_: bool = false) -> int:
	var orientation_: ComponentOrientation = get_orientation()
	
	if include_mixed_:
		return orientation_.size() - get_input_connection_size(true)
		
	return orientation_.get_output_edges().size()

func can_connect_edge(edge_: Core.Edge) -> bool:
	if graph == null:
		assert(true, "Graph not set.")
		return false
	
	return graph.can_connect_edge(graph.get_coords(self), edge_)

func can_connect_adjacent_edge(edge_: Core.Edge) -> bool:
	if graph == null:
		assert(true, "Graph not set.")
		return false
	
	return graph.can_connect_adjacent_edge(graph.get_coords(self), edge_)

func get_coords() -> Vector2i:
	if graph == null:
		assert(true, "Graph not set.")
		return Vector2i.ZERO
	
	return graph.get_coords(self)
