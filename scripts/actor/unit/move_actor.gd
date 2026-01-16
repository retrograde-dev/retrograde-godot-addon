extends UnitActor
class_name MoveActor

#TODO: Update to max speeds with acceleration/deaccelertion
var slow_move_speed: float = 60.0
var normal_move_speed: float = 180.0
var fast_move_speed: float = 200.0

# When true, locked_direction_x will be disabled after normal x movement
var auto_reset_locked_direction_x: bool = false 

# When true, locked_direction_y will be disabled after normal y movement
var auto_reset_locked_direction_y: bool = false 

var normalize_move_speed: bool = false

# NONE: Nothing happens
# CROUCH: Move while crouched
# MOVE: Move and crouch when stopped
var move_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

var velocity: Vector2 = Vector2.ZERO

var action_move_left: StringName = &"move_left"
var action_move_right: StringName = &"move_right"
var action_move_up: StringName = &"move_up"
var action_move_down: StringName = &"move_down"
var action_move_slow: StringName = &"move_slow"
var action_move_fast: StringName = &"move_fast"

var move_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL

# When true, player won't face forward until moved
# TODO: Make support for y direction too, and make function the 
# same with crouch direction
var locked_direction_x: Core.UnitDirection = Core.UnitDirection.NONE
var locked_direction_y: Core.UnitDirection = Core.UnitDirection.NONE
var _internal_crouch_direction: Vector2 = Vector2.ZERO

signal unit_speed_changed(unit_speed_: Core.UnitSpeed, previous_unit_speed_: Core.UnitSpeed)
signal unit_stance_changed(unit_stance_: Core.UnitStance, previous_unit_stance_: Core.UnitStance)
signal unit_movement_changed(unit_movement_: Core.UnitMovement, previous_unit_movement_: Core.UnitMovement)
signal unit_direction_changed(unit_direction_: Core.UnitDirection, previous_unit_direction_: Core.UnitDirection)
signal unit_physics_changed(unit_physics_: Core.UnitPhysics, previous_unit_physics_: Core.UnitPhysics)

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"move", enabled)
	unit_modes.push_back(Core.UnitMode.NORMAL)
	unit_modes.push_back(Core.UnitMode.CLIMBING)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		move_speed = Core.UnitSpeed.NORMAL
		
		locked_direction_x = Core.UnitDirection.NONE
		locked_direction_y = Core.UnitDirection.NONE
		
		velocity = Vector2.ZERO

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)
	
	if not can_physics_process():
		return

	if not can_unit_process():
		return
	
	if can_unit_input():
		if unit.actions.is_pressed(action_move_slow, true):
			move_speed = Core.UnitSpeed.SLOW
		elif unit.actions.is_pressed(action_move_fast, true):
			move_speed = Core.UnitSpeed.FAST
		else:
			move_speed = Core.UnitSpeed.NORMAL
	
	_internal_crouch_direction.x = 0.0
	_internal_crouch_direction.y = 0.0
	
	unit.actors.move_process(delta_)

	unit.velocity = velocity
	velocity = Vector2.ZERO
	
	_update_unit_direction()
	_update_unit_movement()
	_update_unit_speed()
	_update_unit_stance()

	unit.move_and_slide()

func move_process(_delta: float) -> void:
	if is_unit_climbing():
		return
	
	var fall_actor: BaseActor = unit.get_actor_or_null(&"fall")
	var roam_actor: BaseActor = unit.get_actor_or_null(&"roam")
	var is_roaming: bool = roam_actor != null and roam_actor.is_roaming
	
	if fall_actor != null and fall_actor.is_crouch_falling:
		velocity.x = move_toward(unit.velocity.x, 0.0, normal_move_speed)
		return
	
	var direction: Vector2 = Vector2.ZERO
	
	if can_unit_input():
		direction = Vector2(
			sign(unit.actions.get_axis(action_move_left, action_move_right, true)),
			sign(unit.actions.get_axis(action_move_up, action_move_down, true)),
		)
		
	if normalize_move_speed:
		direction = direction.normalized()
	
	if direction.x == 0.0 and direction.y == 0.0:
		velocity.x = move_toward(unit.velocity.x, 0.0, normal_move_speed)
		if is_roaming:
			velocity.y = move_toward(unit.velocity.y, 0.0, normal_move_speed)
		return
		
	var velocity_: Vector2 = Vector2.ZERO
	
	if move_speed == Core.UnitSpeed.SLOW:
		velocity_.x = direction.x * slow_move_speed
		if is_roaming:
			velocity_.y = direction.y * slow_move_speed
	elif move_speed == Core.UnitSpeed.FAST:
		velocity_.x = direction.x * fast_move_speed
		if is_roaming:
			velocity_.y = direction.y * fast_move_speed
	else:
		velocity_.x = direction.x * normal_move_speed
		if is_roaming:
			velocity_.y = direction.y * normal_move_speed

	var crouch_actor: BaseActor = unit.get_actor_or_null(&"crouch")
		
	if crouch_actor != null and crouch_actor.is_crouching:	
		if fall_actor == null or not fall_actor.is_in_air:
			if move_crouch_behavior == Core.PlatformerBehavior.NONE:
				_internal_crouch_direction.x = direction.x
				velocity_.x = move_toward(unit.velocity.x, 0.0, normal_move_speed)
				if is_roaming:
					_internal_crouch_direction.y = direction.y
					velocity_.y = move_toward(unit.velocity.y, 0.0, normal_move_speed)
				return
				
	velocity.x = velocity_.x
	if is_roaming:
		velocity.y = velocity_.y
	

func _update_unit_direction() -> void:
	var previous_unit_direction_x: Core.UnitDirection = unit.unit_direction_x
	var previous_unit_direction_y: Core.UnitDirection = unit.unit_direction_y
	
	if _internal_crouch_direction.x > 0.0:
		if locked_direction_x != Core.UnitDirection.NONE:
			locked_direction_x = Core.UnitDirection.RIGHT
		unit.set_unit_direction_x(Core.UnitDirection.RIGHT)
	elif _internal_crouch_direction.x < 0.0:
		if locked_direction_x != Core.UnitDirection.NONE:
			locked_direction_x = Core.UnitDirection.LEFT
		unit.set_unit_direction_x(Core.UnitDirection.LEFT)
	elif locked_direction_x != Core.UnitDirection.NONE:
		unit.set_unit_direction_x(locked_direction_x)
	elif unit.velocity.x > 0.0:
		unit.set_unit_direction_x(Core.UnitDirection.RIGHT)
	elif unit.velocity.x < 0.0:
		unit.set_unit_direction_x(Core.UnitDirection.LEFT)
	else:
		unit.set_unit_direction_x(Core.UnitDirection.NONE)	
	
	if _internal_crouch_direction.y > 0.0:
		if locked_direction_y != Core.UnitDirection.NONE:
			locked_direction_y = Core.UnitDirection.DOWN
		unit.set_unit_direction_y(Core.UnitDirection.DOWN)
	elif _internal_crouch_direction.y < 0.0:
		if locked_direction_y != Core.UnitDirection.NONE:
			locked_direction_y = Core.UnitDirection.UP
		unit.set_unit_direction_y(Core.UnitDirection.UP)
	if locked_direction_y != Core.UnitDirection.NONE:
		unit.set_unit_direction_y(locked_direction_y)
	elif unit.velocity.y > 0.0:
		unit.set_unit_direction_y(Core.UnitDirection.DOWN)
	elif unit.velocity.y < 0.0:
		unit.set_unit_direction_y(Core.UnitDirection.UP)
	else:
		unit.set_unit_direction_y(Core.UnitDirection.NONE)

	if (previous_unit_direction_x != unit.unit_direction_x or 
		previous_unit_direction_y != unit.unit_direction_y 
	):
		unit_direction_changed.emit(unit.unit_direction, unit.previous_unit_direction)

	if auto_reset_locked_direction_x and unit.is_moving_x():
		locked_direction_x = Core.UnitDirection.NONE
		
	if auto_reset_locked_direction_y and unit.is_moving_y():
		locked_direction_y = Core.UnitDirection.NONE
	
func _update_unit_movement() -> void:
	var previous_unit_movement: Core.UnitMovement = unit.unit_movement
	
	if is_unit_climbing():
		unit.set_unit_movement(Core.UnitMovement.CLIMBING)
	elif is_unit_jumping():
		unit.set_unit_movement(Core.UnitMovement.JUMPING)
	elif is_unit_falling():
		unit.set_unit_movement(Core.UnitMovement.FALLING)
	elif unit.velocity.x == 0.0:
		unit.set_unit_movement(Core.UnitMovement.IDLE)
	else:
		unit.set_unit_movement(Core.UnitMovement.MOVING)

	if previous_unit_movement != unit.unit_movement:
		unit_movement_changed.emit(unit.unit_movement, unit.previous_unit_movement)

func _update_unit_speed() -> void:
	var previous_unit_speed: Core.UnitSpeed = unit.unit_speed
	
	var climb_actor: BaseActor = unit.get_actor_or_null(&"climb")
	if climb_actor != null and climb_actor.is_climbing:
		unit.set_unit_speed(climb_actor.climb_speed)
	else:
		unit.set_unit_speed(move_speed)
	
	if previous_unit_speed != unit.unit_speed:
		unit_speed_changed.emit(unit.unit_speed, unit.previous_unit_speed)

func _update_unit_stance() -> void:
	var previous_unit_stance: Core.UnitStance = unit.unit_stance

	var new_stance: Core.UnitStance = Core.UnitStance.NORMAL
	if _is_crouch_stance():
		new_stance = Core.UnitStance.CROUCH
	
	unit.set_unit_stance(new_stance)
	
	if previous_unit_stance != unit.unit_stance:
		unit_stance_changed.emit(unit.unit_stance, unit.previous_unit_stance)
		
func _is_crouch_stance() -> bool:
	var crouch_actor: BaseActor = unit.get_actor_or_null(&"crouch")
	var jump_actor: BaseActor = unit.get_actor_or_null(&"jump")
	var climb_actor: BaseActor = unit.get_actor_or_null(&"climb")
	var fall_actor: BaseActor = unit.get_actor_or_null(&"fall")
	
	if crouch_actor == null or not crouch_actor.is_crouching:
		return false
		
	if climb_actor != null and climb_actor.is_climbing:
		if climb_actor.climb_crouch_behavior != Core.PlatformerBehavior.NONE:
			return true
		
		return false
			
	if jump_actor != null and jump_actor.is_jumping:
		if jump_actor.is_crouch_jumping:
			return true
			
	if fall_actor != null and fall_actor.is_in_air:
		if fall_actor.is_crouch_falling:
			return true
		elif fall_actor.fall_crouch_behavior == Core.PlatformerBehavior.CROUCH:
			return true
		else:
			return false
	
	return true
	
func _update_unit_physics() -> void:
	var roam_actor: BaseActor = unit.get_actor_or_null(&"roam")
	var previous_unit_physics: Core.UnitPhysics = unit.unit_physics

	var new_physics: Core.UnitPhysics = Core.UnitPhysics.PLATFORM
	
	if roam_actor != null and roam_actor.is_roaming:
		new_physics = Core.UnitPhysics.PLANE
	
	unit.set_unit_physics(new_physics)
	
	if previous_unit_physics != unit.unit_physics:
		unit_physics_changed.emit(unit.unit_physics, unit.previous_unit_physics)

# TODO: Maybe rename this
func set_locked_direction_x(value_: Core.UnitDirection) -> void:
	locked_direction_x = value_
	
func set_locked_direction_y(value_: Core.UnitDirection) -> void:
	locked_direction_y = value_
	
func lock_direction_x() -> void:
	if unit.unit_direction_x != Core.UnitDirection.NONE:
		set_locked_direction_x(unit.unit_direction_x)
	else:
		set_locked_direction_x(unit.previous_unit_direction_x)
		
func unlock_direction_x() -> void:
	set_locked_direction_x(Core.UnitDirection.NONE)

func lock_direction_y() -> void:
	if unit.unit_direction_y != Core.UnitDirection.NONE:
		set_locked_direction_y(unit.unit_direction_y)
	else:
		set_locked_direction_y(unit.previous_unit_direction_y)
		
func unlock_direction_y() -> void:
	set_locked_direction_y(Core.UnitDirection.NONE)
	
func lock_direction() -> void:
	lock_direction_x()
	lock_direction_y()
		
func unlock_direction() -> void:
	unlock_direction_x()
	unlock_direction_y()

func apply_velocity(velocity_: Vector2) -> void:
	velocity += velocity_

func get_actions() -> Array[StringName]:
	return [
		action_move_left,
		action_move_right,
		action_move_up,
		action_move_down,
		action_move_slow,
		action_move_fast,
	]
