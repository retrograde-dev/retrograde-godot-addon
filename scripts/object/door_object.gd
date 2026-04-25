extends BaseObject
class_name DoorObject

@export var door_type: Core.DoorType = Core.DoorType.NONE
@export var door_side: Core.DoorSide = Core.DoorSide.NONE
@export var lock_alias: StringName = &""
@export var teleport: TeleportResource = null

var timer: StepTimer
var animation_alias: StringName = &""

var is_on_left_side: bool = false
var is_on_right_side: bool = false
var is_in_vicinity: bool = false
var is_opened: bool

var _is_open_left: bool = false

var is_closed: int:
	get:
		return not is_opened
	set(value): 
		is_opened = not value

signal door_opened(door_: DoorObject)
signal door_closed(door_: DoorObject)

func _init(step_size_: int, step_delta_: float) -> void:
	timer = StepTimer.new(step_size_, step_delta_)

func _ready() -> void:
	super._ready()
	
	var left_side_area: Area2D = get_node_or_null("%Area2DLeftSide")
	var right_side_area: Area2D = get_node_or_null("%Area2DRightSide")
	var vicinity_area: Area2D = get_node_or_null("%Area2DVicinity")
	
	if left_side_area != null:
		left_side_area.connect(&"body_entered", _on_left_side_body_entered)
		left_side_area.connect(&"body_exited", _on_left_side_body_exited)

	if right_side_area != null:
		right_side_area.connect(&"body_entered", _on_right_side_body_entered)
		right_side_area.connect(&"body_exited", _on_right_side_body_exited)
	
	if vicinity_area != null:
		vicinity_area.connect(&"body_entered", _on_vicinity_body_entered)
		vicinity_area.connect(&"body_exited", _on_vicinity_body_exited)

	_reset_door()
	
func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_on_left_side = false
		is_on_right_side = false
		is_in_vicinity = false
		is_opened = false
		timer.reset()
		
		_reset_door()
	
func _on_left_side_body_entered(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_on_left_side = true

func _on_left_side_body_exited(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_on_left_side = false

func _on_right_side_body_entered(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_on_right_side = true

func _on_right_side_body_exited(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_on_right_side = false

func _on_vicinity_body_entered(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_in_vicinity = true

func _on_vicinity_body_exited(body_: Node2D) -> void:
	if Core.is_player(body_):
		is_in_vicinity = false

func _process(delta: float) -> void:
	super._process(delta)
		
	if not is_running():
		return
	
	timer.process(delta)
	
	if _start_open_door_animation():
		timer.start()
		is_opened = true
	elif _start_close_door_animation():
		timer.start()
		is_opened = false
	elif timer.requires_update:
		_update_door_animation(timer.current_step)
	elif timer.is_complete:
		timer.stop()
		
		if is_opened:
			door_opened.emit(self)
		else:
			door_closed.emit(self)
	
func _start_open_door_animation() -> bool:
	if timer.is_active or timer.is_complete or is_opened:
		return false
			
	if door_type == Core.DoorType.ROOM:
		if not is_on_left_side and not is_on_right_side:
			return false
	elif not is_in_vicinity:
		return false
		
	if Core.player == null or not Core.player.interact.is_interacting:
		return false
		
	if not _can_open_door():
		return false
	
	if door_type == Core.DoorType.ROOM:
		if is_on_left_side:
			_is_open_left = true
			animation_alias = &"open_door_left"
		else:
			_is_open_left = false
			animation_alias = &"open_door_right"
	else:
		animation_alias = &"open_door"
	
	return true
	
func _start_close_door_animation() -> bool:
	if timer.is_active or timer.is_complete or not is_opened:
		return false
		
	if is_in_vicinity:
		return false

	if not _can_close_door():
		return false
	
	if door_type == Core.DoorType.ROOM:
		if _is_open_left:
			animation_alias = &"close_door_left"
		else:
			animation_alias = &"close_door_right"
	else:
		animation_alias = &"close_door"
		
	return true
	
func _update_door_animation(step: int) -> void:
	if door_type == Core.DoorType.ROOM:
		match animation_alias:
			&"open_door_left":
				_open_door_left(step)
			&"open_door_right":
				_open_door_right(step)
			&"close_door_left":
				_close_door_left(step)
			&"close_door_right":
				_close_door_right(step)
	else:
		match animation_alias:
			&"open_door":
				_open_door(step)
			&"close_door":
				_close_door(step)
	
func _can_open_door() -> bool:
	var lock_: LockResource = Core.level.locks.get_lock(lock_alias)
	
	if lock_ == null:
		return true
	
	if lock_.type == Core.LockType.NONE:
		return true
	
	var lock_state_: Core.LockState = lock_.try_unlock()
	
	if lock_.type == Core.LockType.OBSTRUCTION:
		_obstruction_action(lock_state_)
	elif lock_.type == Core.LockType.KEY:
		_key_action(lock_state_)
	elif lock_.type == Core.LockType.PASSCODE:
		_passcode_action(lock_state_)
	elif lock_.type == Core.LockType.TERMINAL:
		_terminal_action(lock_state_)
	
	return lock_.unlocked
	
func _can_close_door() -> bool:
	return true

func _reset_door() -> void:
	pass

func _open_door_left(_step: int) -> void:
	pass
		
func _close_door_left(_step: int) -> void:
	pass
	
func _open_door_right(_step: int) -> void:
	pass

func _close_door_right(_step: int) -> void:
	pass

func _open_door(_step: int) -> void:
	pass
	
func _close_door(_step: int) -> void:
	pass
	
func _obstruction_action(_lock_state: Core.LockState) -> void:
	pass

func _key_action(_lock_state: Core.LockState) -> void:
	pass

func _passcode_action(_lock_state: Core.LockState) -> void:
	pass

func _terminal_action(_lock_state: Core.LockState) -> void:
	pass
