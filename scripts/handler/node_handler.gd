class_name NodeHandler

var nodes: Dictionary
var scenes: Dictionary
var _thread: Thread
var _cancel_thread: bool = false
var is_loading: bool = false
var _current_loading_path: String
var _queue: Array = []
var _in_use: Array = []

signal load_started
signal load_stopped

func _init() -> void:
	_thread = Thread.new()

func reset() -> void:
	if _thread.is_started():
		_cancel_thread = true

	for path: String in nodes:
		for node: Node in nodes[path]:
			Core.game.remove_level_child(node)
	
	nodes.clear()
	
	is_loading = false
	_current_loading_path = ""
	
	_queue = []
	_in_use = []
	
func load_node(path: String, count: int = 1) -> void:
	if is_loading:
		_queue.push_back({
			&"path": path,
			&"count": count,
		})
		return
		
	is_loading = true
	_current_loading_path = path
	_thread.start(_threaded_load.bind(path, count))
	load_started.emit()

func _is_loading_node(path: String) -> bool:
	if _current_loading_path == path:
		return true
		
	for value: Dictionary in _queue:
		if value.path == path:
			return true
			
	return false
	
func get_node(path_: String, reset_method_: Callable = Callable()) -> Node:
	var node_: Node = _get_free_node(path_)
	
	if node_ != null:
		_in_use.push_back(node_.get_instance_id())
		
		if node_ is BaseNode2D or node_ is BaseCharacterBody2D:
			if not reset_method_.is_null():
				reset_method_.call(node_, Core.ResetType.RESTART)
			node_.restart()
		
		return node_
	
	var node_instance_: Node
	
	# If the node doesn't exist, just load it
	if scenes.has(path_):
		node_instance_ = await scenes[path_].instantiate()
	else:
		node_instance_ = await load(path_).instantiate()
	
	if not nodes.has(path_):
		nodes[path_] = []
		
	nodes[path_].push_back(node_instance_)
	
	node_instance_.position = Core.DEAD_ZONE
	
	Core.game.add_level_child(node_instance_)
	
	_in_use.push_back(node_instance_.get_instance_id())
	
	if node_instance_ is BaseNode2D or node_instance_ is BaseCharacterBody2D:
		if not reset_method_.is_null():
			reset_method_.call(node_instance_, Core.ResetType.START)
		node_instance_.start()
	
	return node_instance_

func _get_free_node(path: String) -> Node:
	if not nodes.has(path):
		return null
	
	for node: Node in nodes[path]:
		if not _in_use.has(node.get_instance_id()):
			return node
			
	return null
	
func clear_node(node: Node) -> void:
	free_node(node)
	_remove_node(node)
	
func _remove_node(node_: Node) -> void:
	var path_: String = node_.scene_file_path
	
	if nodes.has(path_):
		for index_: int in nodes[path_].size():
			if nodes[path_][index_] == node_:
				Core.game.remove_level_child(nodes[path_][index_])
				nodes[path_].remove_at(index_)
				break

func free_node(node: Node, reset_method_: Callable = Callable()) -> void:
	if _in_use.has(node.get_instance_id()):
		_in_use.erase(node.get_instance_id())
		
		if node is BaseNode2D or node is BaseCharacterBody2D:
			if not reset_method_.is_null():
				reset_method_.call(node, Core.ResetType.STOP)
			await node.stop()
		
		node.position = Core.DEAD_ZONE

func free_nodes(nodes_: Array[Node], reset_method_: Callable = Callable()) -> void:
	for node: Node in nodes_:
		await free_node(node, reset_method_)
		
func free_all(reset_method_: Callable = Callable()) -> void:
	for path: String in nodes:
		for node: Node in nodes[path]:
			if node is BaseNode2D or node is BaseCharacterBody2D:
				if not reset_method_.is_null():
					reset_method_.call(node, Core.ResetType.STOP)
				await node.stop()
				
			node.position = Core.DEAD_ZONE
	
	_in_use = []

func _threaded_load(path: String, count: int) -> Dictionary:
	var node: Resource = load(path)
	var loaded_nodes: Array[Node] = []
	
	for i: int in count:
		var node_instance: Node = await node.instantiate()
		# Ensure off screen
		node_instance.position = Core.DEAD_ZONE
		loaded_nodes.push_back(node_instance)
	
	_theaded_load_complete.call_deferred()
	
	return {
		&"path": path,
		&"scene": node,
		&"nodes": loaded_nodes
	}

func _theaded_load_complete() -> void:
	var value: Variant = _thread.wait_to_finish()
	
	if _cancel_thread:
		_queue = []
		is_loading = false
		_current_loading_path = ""
		load_stopped.emit()
		return

	if not nodes.has(value.path):
		nodes[value.path] = []

	if not scenes.has(value.path):
		scenes[value.path] = value.scene

	for node: Node in value.nodes:
		nodes[value.path].push_back(node)
		Core.game.add_level_child(node)
	
	if _queue.size():
		var queue_value: Dictionary = _queue.pop_front()

		_current_loading_path = queue_value.path
		_thread = Thread.new()
		_thread.start(_threaded_load.bind(queue_value.path, queue_value.count))
	else:
		is_loading = false
		_current_loading_path = ""
		load_stopped.emit()
