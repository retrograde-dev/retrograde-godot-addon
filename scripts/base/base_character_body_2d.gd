extends CharacterBody2D
class_name BaseCharacterBody2D

var is_enabled: bool = true
var is_started: bool = false
var is_ready: bool = false
var modes: StringNameSet = StringNameSet.new()
var alignment: Core.Alignment = Core.Alignment.TOP_LEFT

var scale_default: Vector2 = Vector2.ONE
var velocity_default: Vector2 = Vector2.ZERO

signal reseted(reset_type_: Core.ResetType)
signal started()
signal stopped()
signal refreshed()
signal restarted()

func _ready() -> void:
	scale_default = scale
	velocity_default = velocity

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		scale = scale_default
		velocity = velocity_default

		is_started = false
		is_ready = false
		modes.filter(func(mode: StringName) -> bool: return Core.GLOBAL_MODES.has(mode))

	reseted.emit(reset_type_)

func start() -> void:
	await reset(Core.ResetType.START)

	is_started = true

	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.start()

	process_mode = Node.PROCESS_MODE_INHERIT

	started.emit()

func restart() -> void:
	await reset(Core.ResetType.RESTART)

	is_started = true

	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.restart()

	process_mode = Node.PROCESS_MODE_INHERIT

	restarted.emit()

func refresh() -> void:
	await reset(Core.ResetType.REFRESH)

	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.refresh()

	refreshed.emit()

func stop() -> void:
	await reset(Core.ResetType.STOP)

	is_started = false
	is_ready = false

	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.stop()

	process_mode = Node.PROCESS_MODE_DISABLED

	stopped.emit()

func _process(_delta: float) -> void:
	# We redundantly check is_ready here so overriding wont allow calling
	# it after already being ready
	if not is_ready:
		_handle_ready()

func _physics_process(_delta: float) -> void:
	pass

func _handle_ready() -> void:
	if is_ready:
		return

	if not is_started:
		return

	if position == Core.DEAD_ZONE:
		return

	is_ready = true
	ready()

func ready() -> void:
	pass

func is_running() -> bool:
	if not Core.game.is_enabled:
		return false

	if not is_enabled or not is_started or not is_ready:
		return false

	return true

func add_mode(mode_: StringName, add_to_children: bool = false) -> void:
	modes.add(mode_)

	if add_to_children:
		for child: Node in get_children():
			if child is BaseNode2D or child is BaseCharacterBody2D:
				child.add_mode(mode_)

func remove_mode(mode_: StringName, remove_from_children: bool = false) -> void:
	modes.remove(mode_)

	if remove_from_children:
		for child: Node in get_children():
			if child is BaseNode2D or child is BaseCharacterBody2D:
				child.remove_mode(mode_)

func get_align_position(alignment_: Core.Alignment) -> Vector2:
	return position - Core.get_align_offset(get_scale_rect(), alignment_)

func get_align_global_position(alignment_: Core.Alignment) -> Vector2:
	return global_position - Core.get_align_offset(get_scale_rect(), alignment_)

func get_align_offset(alignment_: Core.Alignment) -> Vector2:
	return Core.get_align_offset(get_scale_rect(), alignment_)

func get_rect() -> Rect2:
	var bounds_area: Area2D = get_node_or_null("%Area2DRect")

	if bounds_area != null:
		return Core.get_collision_rect(bounds_area)

	return Core.get_collision_rect(self)

func get_scale_rect() -> Rect2:
	var rect_: Rect2 = get_rect()

	rect_.size *= scale

	return rect_

func get_position_rect() -> Rect2:
	var rect_: Rect2 = get_scale_rect()
	var position_: Vector2 = get_align_global_position(Core.Alignment.TOP_LEFT)
	rect_.position += position_
	return rect_

func export(data_: Resource = null) -> Resource:
	if data_ == null:
		data_ = CharacterBody2DResource.new()
	else:
		assert(data_ is CharacterBody2DResource, "Invalid resource.")
	
	data_.is_enabled = is_enabled
	data_.modes = modes.names.duplicate()
	data_.position = global_position
	data_.scale = scale
	data_.velocity = velocity
	data_.rotation = rotation
	data_.visible = visible
	
	return data_
	
func import(data_: Resource) -> void:
	assert(data_ is CharacterBody2DResource, "Invalid resource.")
	
	is_enabled = data_.is_enabled
	modes.names = data_.modes.duplicate()
	global_position = data_.position
	scale = data_.scale
	velocity = data_.velocity
	rotation = data_.rotation
	visible = data_.visible
