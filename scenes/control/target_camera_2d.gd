extends Camera2D
class_name TargetCamera2D

@export var target: NodePath
@export var target_offset: Vector2 = Vector2.ZERO
@export var target_offset_rotation_enabled: bool = false

func set_target(node: Node2D) -> void:
	target = node.get_path()
	
	var _limit_smoothed: bool = limit_smoothed
	var _position_smoothing_enabled: bool = position_smoothing_enabled
	
	limit_smoothed = false
	position_smoothing_enabled = false
	
	global_position = _get_target_position(node)

	limit_smoothed = _limit_smoothed
	position_smoothing_enabled = _position_smoothing_enabled

func _physics_process(_delta: float) -> void:
	if target.is_empty():
		return
		
	var target_node: Node = get_node_or_null(target)
	
	if target_node == null:
		return
	
	var new_position: Vector2 = _get_target_position(target_node)
	var distance: float = global_position.distance_to(new_position)
	
	if distance > 64:
		global_position = global_position.move_toward(new_position, distance / 6)
	else:
		global_position = new_position

func _get_target_position(node: Node) -> Vector2:
	var new_position: Vector2 = node.global_position
	
	if target_offset_rotation_enabled:
		new_position += target_offset.rotated(node.rotation)
	else:
		new_position += target_offset
	
	return new_position
