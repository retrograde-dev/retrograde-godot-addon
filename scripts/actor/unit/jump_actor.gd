extends UnitActor
class_name JumpActor

var jump_speed: float = 450

var air_time_delay: float = 0.1 # Delay from start of fall to when jump is no longer available

# NONE: Cannot jump while crouched
# CROUCH: Can jump while crouched
# JUMP: Can jump, but will be uncrouched
var jump_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

var is_jumping: bool = false
var is_jumping_start: bool = false
var is_crouch_jumping: bool = false
var is_climb_jumping: bool = false
var _reason: StringName = &""
var _is_jump_active: bool = false

var signal_can_jump: bool = false
var signal_jump_handled: bool = false

signal jump_error(reason_: StringName, error_: Core.Error) 
signal jump_before(reason_: StringName)
signal jump_after(reason_: StringName)
signal jump_complete(reason_: StringName)

var action_jump: StringName = &"jump"

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"jump", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_jumping = false
		is_jumping_start = false
		is_crouch_jumping = false
		is_climb_jumping = false
		_reason = &""

func interupt() -> void:
	is_jumping = false
	is_jumping_start = false
	is_crouch_jumping = false
	is_climb_jumping = false

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)

	is_jumping_start = false
	if is_crouch_jumping and not is_unit_crouching():
		is_crouch_jumping = false

	if not can_physics_process():
		return
	
	if not can_unit_process():
		return
		
			
	_process_jump(delta_)
		
	if not can_unit_input():
		return
	
	_action_jump(delta_)

func _process_jump(_delta: float) -> void:
	var fall_actor: BaseActor = unit.get_actor_or_null(&"fall")
	
	if fall_actor == null:
		return

	if not is_jumping and _is_jump_active:
		is_crouch_jumping = false
		is_climb_jumping = false
		_is_jump_active = false
		jump_complete.emit(_reason)
	elif is_jumping and not fall_actor.is_in_air:
		is_jumping = false
		is_crouch_jumping = false
		is_climb_jumping = false
		_is_jump_active = false
		jump_complete.emit(_reason)

func _action_jump(_delta: float) -> void:
	if not unit.actions.is_just_pressed(action_jump):
		return
		
	if not unit.actions.has(action_jump):
		jump_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	jump(&"action")

func can_jump() -> bool:
	if is_jumping:
		return false
	
	var climb_actor: BaseActor = unit.get_actor_or_null(&"climb")
	
	if climb_actor != null and climb_actor.is_climbing:
		if climb_actor.climb_jump_behavior != Core.PlatformerBehavior.JUMP:
			return false

		climb_actor.interupt()
		is_climb_jumping = true
		return true

	var fall_actor: BaseActor = unit.get_actor_or_null(&"fall")
	
	if fall_actor != null and fall_actor.is_in_air:
		if fall_actor.air_time >= air_time_delay:
			return false

	var crouch_actor: BaseActor = unit.get_actor_or_null(&"crouch")
	
	if crouch_actor != null and crouch_actor.is_crouching:
		if jump_crouch_behavior == Core.PlatformerBehavior.NONE:
			return false

	return true

func jump(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_jump():
		jump_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_jump = true
	signal_jump_handled = false
	
	jump_before.emit(reason_)
	
	if signal_can_jump == false:
		jump_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_jump_handled and not _jump():
		jump_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	_is_jump_active = true
	jump_after.emit(reason_)
	return true

func _jump() -> bool:
	if is_jumping:
		return false
		
	is_jumping = true
	is_jumping_start = true
	if jump_crouch_behavior == Core.PlatformerBehavior.CROUCH and is_unit_crouching():
		is_crouch_jumping = true
		
	return true
	
func get_actions() -> Array[StringName]:
	return [action_jump]

func move_process(_delta: float) -> void:
	if is_jumping_start:
		var move_actor: BaseActor = unit.get_actor_or_null(&"move")
		
		if move_actor != null:
			move_actor.apply_velocity(Vector2(0.0, -jump_speed))
