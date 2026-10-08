extends Camera2D
class_name TargetCamera2D

@export var target: Node2D = null:
	get= get_target,
	set = set_target
	
@export var target_offset: Vector2 = Vector2.ZERO:
	get = get_target_offset,
	set = set_target_offset
	
@export var target_offset_rotation_enabled: bool = false

var _is_shaking: bool = false
var _shake_fade_delta: float = 0.0
var _current_shake_offset: float = 0.0

var _current_target_offset: Vector2 = Vector2.ZERO

func get_target() -> Node2D:
	return target
	
func set_target(node_: Node2D) -> void:
	target = node_
	
	if target is EntityUnit:
		_current_target_offset = target.zone_entity.entity.camera_offset
	else:
		_current_target_offset = target_offset
	
	var _limit_smoothed: bool = limit_smoothed
	var _position_smoothing_enabled: bool = position_smoothing_enabled
	
	limit_smoothed = false
	position_smoothing_enabled = false
	
	global_position = _get_target_position(node_)

	limit_smoothed = _limit_smoothed
	position_smoothing_enabled = _position_smoothing_enabled

func get_target_offset() -> Vector2:
	return target_offset
func set_target_offset(offset_: Vector2) -> void:
	target_offset = offset_

func shake(max_shake_offset_: float = 10.0, shake_fade_delta_: float = 10.0) -> void:
	if not _is_shaking:
		_current_shake_offset = max_shake_offset_
		_shake_fade_delta = shake_fade_delta_
		_is_shaking = true

func _process(delta_: float) -> void:
	if _is_shaking:
		if _current_shake_offset > 0.2:
			_current_shake_offset = lerpf(_current_shake_offset, 0.0, _shake_fade_delta * delta_)
			offset = Vector2(
				randf_range(-_current_shake_offset, _current_shake_offset),
				randf_range(-_current_shake_offset, _current_shake_offset),
			)
		else:
			offset = Vector2.ZERO
			_is_shaking = false

func _physics_process(_delta: float) -> void:
	if target == null:
		return
	
	var new_position: Vector2 = _get_target_position(target)
	var distance: float = global_position.distance_to(new_position)
	
	if distance > 64:
		global_position = global_position.move_toward(new_position, distance / 6)
	else:
		global_position = new_position

func _get_target_position(node: Node) -> Vector2:
	var new_position: Vector2 = node.global_position
	
	if target_offset_rotation_enabled:
		new_position += _current_target_offset.rotated(node.rotation)
	else:
		new_position += _current_target_offset
	
	return new_position
