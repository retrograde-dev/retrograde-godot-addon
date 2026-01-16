extends UnitActor
class_name ClimbActor

var slow_climbing_speed: float = 60.0
var normal_climbing_speed: float = 120.0
var fast_climbing_speed: float = 120.0

# NONE: Cannot jump off ladder
# JUMP: Jumps off ladder (handled by platformer jump actor)
var climb_jump_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Cannot crouch on ladder
# CROUCH: Crouch on ladder, but can't move
# MOVE: Crouch and move on ladder
# FALL: Let go of ladder
var climb_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Cannot move off ladder
# FALL: Can move off ladder (handled by platformer move actor)
var climb_off_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

# NONE: Climb up, down, and grab in air
# CLIMB: Climb up action also grabs in air
var climb_on_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.CLIMB

var is_climbing: bool = false
var is_climbing_start: bool = false
var _reason: StringName = &""
var _is_climb_active: bool = false

var is_in_climb_area: bool = false
var is_in_climb_up_area: bool = false
var is_in_climb_down_area: bool = false
var is_in_climb_left_area: bool = false
var is_in_climb_right_area: bool = false

var action_climb_on: StringName = &"climb_on"
var action_climb_off: StringName = &"climb_off"
var action_climb_up: StringName = &"climb_up"
var action_climb_down: StringName = &"climb_down"
var action_climb_left: StringName = &"climb_left"
var action_climb_right: StringName = &"climb_right"
var action_climb_slow: StringName = &"climb_slow"
var action_climb_fast: StringName = &"climb_fast"

var climb_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL

# Used to require release of up button before it can be used again to 
# prevent jumpyness at top of ladders
var _cancel_action_climb_up: bool = false

var signal_can_climb_on: bool = false
var signal_climb_on_handled: bool = false

var signal_can_climb_up: bool = false
var signal_climb_up_handled: bool = false

var signal_can_climb_down: bool = false
var signal_climb_down_handled: bool = false

var signal_can_climb_off: bool = false
var signal_climb_off_handled: bool = false

signal climb_on_error(reason_: StringName, error_: Core.Error) 
signal climb_on_before(reason_: StringName)
signal climb_on_after(reason_: StringName)

signal climb_up_error(reason_: StringName, error_: Core.Error) 
signal climb_up_before(reason_: StringName)
signal climb_up_after(reason_: StringName)

signal climb_down_error(reason_: StringName, error_: Core.Error) 
signal climb_down_before(reason_: StringName)
signal climb_down_after(reason_: StringName)

signal climb_off_error(reason_: StringName, error_: Core.Error) 
signal climb_off_before(reason_: StringName)
signal climb_off_after(reason_: StringName)

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"climb", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)
	unit_modes.push_back(Core.UnitMode.CLIMBING)

func _on_unit_mode_changed(unit_mode_: Core.UnitMode, _previous_unit_mode: Core.UnitMode) -> void:
	if unit_mode_ == Core.UnitMode.CLIMBING and unit_modes.has(Core.UnitMode.CLIMBING):
		climb_on(&"unit_mode")

func _on_climb_body_entered(_body: Node2D) -> void:
	is_in_climb_area = true

func _on_climb_body_exited(_body: Node2D) -> void:
	is_in_climb_area = false
	
func _on_climb_up_body_entered(_body: Node2D) -> void:
	is_in_climb_up_area = true

func _on_climb_up_body_exited(_body: Node2D) -> void:
	is_in_climb_up_area = false
	
func _on_climb_down_body_entered(_body: Node2D) -> void:
	is_in_climb_down_area = true

func _on_climb_down_body_exited(_body: Node2D) -> void:
	is_in_climb_down_area = false
	
func _on_climb_left_body_entered(_body: Node2D) -> void:
	is_in_climb_left_area = true

func _on_climb_left_body_exited(_body: Node2D) -> void:
	is_in_climb_left_area = false
	
func _on_climb_right_body_entered(_body: Node2D) -> void:
	is_in_climb_right_area = true

func _on_climb_right_body_exited(_body: Node2D) -> void:
	is_in_climb_right_area = false

func _on_climb_area_entered(_area: Area2D) -> void:
	is_in_climb_area = true

func _on_climb_area_exited(_area: Area2D) -> void:
	is_in_climb_area = false
	
func _on_climb_up_area_entered(_area: Area2D) -> void:
	is_in_climb_up_area = true

func _on_climb_up_area_exited(_area: Area2D) -> void:
	is_in_climb_up_area = false
	
func _on_climb_down_area_entered(_area: Area2D) -> void:
	is_in_climb_down_area = true

func _on_climb_down_area_exited(_area: Area2D) -> void:
	is_in_climb_down_area = false
	
func _on_climb_left_area_entered(_area: Area2D) -> void:
	is_in_climb_left_area = true

func _on_climb_left_area_exited(_area: Area2D) -> void:
	is_in_climb_left_area = false
	
func _on_climb_right_area_entered(_area: Area2D) -> void:
	is_in_climb_right_area = true

func _on_climb_right_area_exited(_area: Area2D) -> void:
	is_in_climb_right_area = false
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_climbing = false
		is_climbing_start = false
		
		is_in_climb_area = false
		is_in_climb_up_area = false
		is_in_climb_down_area = false
		is_in_climb_left_area = false
		is_in_climb_right_area = false

		climb_speed = Core.UnitSpeed.NORMAL
		
		_cancel_action_climb_up = false
		
		if reset_type_ == Core.ResetType.START:
			_add_areas()
			
		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()

func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"Climb", Core.Edge.NONE)
	areas_.add_area(&"ClimbUp", Core.Edge.NONE) # This is correct
	areas_.add_area(&"ClimbDown", Core.Edge.DOWN)
	areas_.add_area(&"ClimbLeft", Core.Edge.LEFT)
	areas_.add_area(&"ClimbRight", Core.Edge.RIGHT)

func _connect_events() -> void:
	unit.connect(&"unit_mode_changed", _on_unit_mode_changed)
	
	var climb_area: Area2D = unit.get_area_or_null(&"Climb")
	if climb_area != null:
		climb_area.connect(&"body_entered", _on_climb_body_entered)
		climb_area.connect(&"body_exited", _on_climb_body_exited)
		climb_area.connect(&"area_entered", _on_climb_area_entered)
		climb_area.connect(&"area_exited", _on_climb_area_exited)
	
	var climb_up_area: Area2D = unit.get_area_or_null(&"ClimbUp")
	if climb_up_area != null:
		climb_up_area.connect(&"body_entered", _on_climb_up_body_entered)
		climb_up_area.connect(&"body_exited", _on_climb_up_body_exited)
		climb_up_area.connect(&"area_entered", _on_climb_up_area_entered)
		climb_up_area.connect(&"area_exited", _on_climb_up_area_exited)
		
	var climb_down_area: Area2D = unit.get_area_or_null(&"ClimbDown")
	if climb_down_area != null:
		climb_down_area.connect(&"body_entered", _on_climb_down_body_entered)
		climb_down_area.connect(&"body_exited", _on_climb_down_body_exited)
		climb_down_area.connect(&"area_entered", _on_climb_down_area_entered)
		climb_down_area.connect(&"area_exited", _on_climb_down_area_exited)
		
	var climb_left_area: Area2D = unit.get_area_or_null(&"ClimbLeft")
	if climb_left_area != null:
		climb_left_area.connect(&"body_entered", _on_climb_left_body_entered)
		climb_left_area.connect(&"body_exited", _on_climb_left_body_exited)
		climb_left_area.connect(&"area_entered", _on_climb_left_area_entered)
		climb_left_area.connect(&"area_exited", _on_climb_left_area_exited)
		
	var climb_right_area: Area2D = unit.get_area_or_null(&"ClimbRight")
	if climb_right_area != null:
		climb_right_area.connect(&"body_entered", _on_climb_right_body_entered)
		climb_right_area.connect(&"body_exited", _on_climb_right_body_exited)
		climb_right_area.connect(&"area_entered", _on_climb_right_area_entered)
		climb_right_area.connect(&"area_exited", _on_climb_right_area_exited)

func _disconnect_events() -> void:
	unit.disconnect(&"unit_mode_changed", _on_unit_mode_changed)
	
	var climb_area: Area2D = unit.get_area_or_null(&"Climb")
	if climb_area != null:
		climb_area.disconnect(&"body_entered", _on_climb_body_entered)
		climb_area.disconnect(&"body_exited", _on_climb_body_exited)
		climb_area.disconnect(&"area_entered", _on_climb_area_entered)
		climb_area.disconnect(&"area_exited", _on_climb_area_exited)
	
	var climb_up_area: Area2D = unit.get_area_or_null(&"ClimbUp")
	if climb_up_area != null:
		climb_up_area.disconnect(&"body_entered", _on_climb_up_body_entered)
		climb_up_area.disconnect(&"body_exited", _on_climb_up_body_exited)
		climb_up_area.disconnect(&"area_entered", _on_climb_up_area_entered)
		climb_up_area.disconnect(&"area_exited", _on_climb_up_area_exited)
		
	var climb_down_area: Area2D = unit.get_area_or_null(&"ClimbDown")
	if climb_down_area != null:
		climb_down_area.disconnect(&"body_entered", _on_climb_down_body_entered)
		climb_down_area.disconnect(&"body_exited", _on_climb_down_body_exited)
		climb_down_area.disconnect(&"area_entered", _on_climb_down_area_entered)
		climb_down_area.disconnect(&"area_exited", _on_climb_down_area_exited)
		
	var climb_left_area: Area2D = unit.get_area_or_null(&"ClimbLeft")
	if climb_left_area != null:
		climb_left_area.disconnect(&"body_entered", _on_climb_left_body_entered)
		climb_left_area.disconnect(&"body_exited", _on_climb_left_body_exited)
		climb_left_area.disconnect(&"area_entered", _on_climb_left_area_entered)
		climb_left_area.disconnect(&"area_exited", _on_climb_left_area_exited)
		
	var climb_right_area: Area2D = unit.get_area_or_null(&"ClimbRight")
	if climb_right_area != null:
		climb_right_area.disconnect(&"body_entered", _on_climb_right_body_entered)
		climb_right_area.disconnect(&"body_exited", _on_climb_right_body_exited)
		climb_right_area.disconnect(&"area_entered", _on_climb_right_area_entered)
		climb_right_area.disconnect(&"area_exited", _on_climb_right_area_exited)

func interupt() -> void:
	_climb_off()

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)
	
	is_climbing_start = false
	
	if not can_physics_process():
		return
		
	if not can_unit_process():
		return
	
	if unit.unit_mode == Core.UnitMode.CLIMBING:
		return
	
	var can_input_: bool = can_unit_input()

	_process_climb(delta_, can_input_)

	if not can_input_:
		return
		
	if unit.actions.is_just_released(action_climb_up, true):
		_cancel_action_climb_up = false
	
	_action_climb_on()
	_action_climb_up()
	_action_climb_down()
	_action_climb_off()

func _process_climb(_delta: float, can_input_: bool) -> void:
	if can_input_:
		if unit.actions.is_pressed(action_climb_slow, true):
			climb_speed = Core.UnitSpeed.SLOW
		elif unit.actions.is_pressed(action_climb_fast, true):
			climb_speed = Core.UnitSpeed.FAST
		else:
			climb_speed = Core.UnitSpeed.NORMAL
			
	if not is_climbing:
		if _is_climb_active:
			# This shouldn't happen if properly handled
			_climb_off()
		return

	# Climbed off climbable area
	if not is_in_climb_area and not is_in_climb_up_area and not is_in_climb_down_area:
		climb_off(&"edge")
		
		if can_input_ and unit.actions.is_pressed(action_climb_up, true):
			_cancel_action_climb_up = true
			
		return
	
	if is_unit_crouching():
		if climb_crouch_behavior == Core.PlatformerBehavior.FALL:
			climb_off(&"crouch")
			return
	
	# At bottom of ladder that touches floor	
	if not is_in_climb_down_area and unit.is_on_floor():
		climb_off(&"floor")

func move_process(_delta: float) -> void:
	if not is_climbing:
		return
	
	# Can't move while crouching
	if is_unit_crouching() and climb_crouch_behavior == Core.PlatformerBehavior.CROUCH:
		return
		
	var move_actor: BaseActor = unit.get_actor_or_null(&"move")
	
	if move_actor == null:
		return
	
	var direction: Vector2 = Vector2.ZERO
	
	if can_unit_input():
		direction = Vector2(
			sign(unit.actions.get_axis(action_climb_left, action_climb_right, true)),
			sign(unit.actions.get_axis(action_climb_up, action_climb_down, true)),
		)
	
	if move_actor.normalize_move_speed:
		direction = direction.normalized()
	
	# Prevent moving left/right off ladder
	if unit.unit_mode == Core.UnitMode.CLIMBING or climb_off_behavior == Core.PlatformerBehavior.NONE:
		if is_in_climb_down_area:
			if not is_in_climb_left_area and direction.x < 0.0:
				direction.x = 0.0
			elif not is_in_climb_right_area and direction.x > 0.0:
				direction.x = 0.0
	
	var velocity_: Vector2 = Vector2.ZERO
	
	if climb_speed == Core.UnitSpeed.SLOW:
		velocity_.x = direction.x * slow_climbing_speed
		velocity_.y = direction.y * slow_climbing_speed
	elif climb_speed == Core.UnitSpeed.FAST:
		velocity_.x = direction.x * fast_climbing_speed
		velocity_.y = direction.y * fast_climbing_speed
	else:
		velocity_.x = direction.x * normal_climbing_speed
		velocity_.y = direction.y * normal_climbing_speed

	move_actor.apply_velocity(velocity_)

func _action_climb_on() -> void:
	if not unit.actions.is_just_pressed(action_climb_on, true):
		return
		
	climb_on(&"action")
	
func _action_climb_off() -> void:
	if not unit.actions.is_just_pressed(action_climb_off, true):
		return
		
	climb_off(&"action")
	
func _action_climb_up() -> void:
	if _cancel_action_climb_up and is_in_climb_down_area:
		return
		
	if not unit.actions.is_pressed(action_climb_up, true):
		return

	climb_up(&"action")

func _action_climb_down() -> void:
	if not unit.actions.is_pressed(action_climb_down, true):
		return
		
	climb_down(&"action")
	
func can_climb_on() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_area:
		return false
		
	return true

func can_climb_off() -> bool:
	if not is_climbing:
		return false
	
	return true

func can_climb_up() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_up_area:
		return false
	
	if is_in_climb_down_area:
		if climb_on_behavior == Core.PlatformerBehavior.NONE:
			return false
		else:
			var jump_actor: BaseActor = unit.get_actor_or_null(&"jump")
			
			if jump_actor != null and jump_actor.is_climb_jumping:
				return false
	
	return true
		
func can_climb_down() -> bool:
	if is_climbing:
		return false
		
	if not is_in_climb_down_area or is_in_climb_up_area:
		return false
		
	return true
	
func climb_on(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_climb_on():
		climb_on_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_climb_on = true
	signal_climb_on_handled = false
	
	climb_on_before.emit(reason_)
	
	if signal_can_climb_on == false:
		climb_on_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_climb_on_handled and not _climb_off():
		climb_on_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	_is_climb_active = true
	climb_on_after.emit(reason_)
	return true

func climb_off(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_climb_off():
		climb_off_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_climb_off = true
	signal_climb_off_handled = false
	
	climb_off_before.emit(reason_)
	
	if signal_can_climb_off == false:
		climb_off_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_climb_off_handled and not _climb_off():
		climb_off_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	_is_climb_active = false
	climb_off_after.emit(reason_)
	return true

func climb_up(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_climb_up():
		climb_up_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_climb_up = true
	signal_climb_up_handled = false
	
	climb_up_before.emit(reason_)
	
	if signal_can_climb_up == false:
		climb_up_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_climb_up_handled and not _climb_off():
		climb_up_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	_is_climb_active = true
	climb_up_after.emit(reason_)
	return true

func climb_down(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_climb_down():
		climb_down_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_climb_down = true
	signal_climb_down_handled = false
	
	climb_down_before.emit(reason_)
	
	if signal_can_climb_down == false:
		climb_down_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_climb_down_handled and not _climb_off():
		climb_down_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	_is_climb_active = true
	climb_down_after.emit(reason_)
	return true


func _climb_on() -> bool:
	var jump_actor_: BaseActor = unit.get_actor_or_null(&"jump")
	if jump_actor_ != null and jump_actor_.is_jumping:
		jump_actor_.interupt()
		
	is_climbing = true
	is_climbing_start = true
	
	return true

func _climb_off() -> bool:
	is_climbing = false;
	is_climbing_start = false
	_cancel_action_climb_up = false
	
	return true

func _climb_up() -> bool:
	if is_in_climb_up_area and unit.is_on_floor():
		_cancel_action_climb_up = false
		
	is_climbing = true
	is_climbing_start = true
	unit.position.y -= 1.0 # Not needed, but to make it similar to climb down
	
	return true
	
func _climb_down() -> bool:
	is_climbing = true
	is_climbing_start = true
	unit.position.y += 1.0 # Move down 1 so climb area will be in climbable area
	
	return true

func get_actions() -> Array[StringName]:
	return [
		action_climb_on,
		action_climb_off,
		action_climb_up,
		action_climb_down,
		action_climb_left,
		action_climb_right,
		action_climb_fast,
		action_climb_slow
	]
