extends UnitActor
class_name FallActor

var fall_acceleration: float = 1960.0
var max_fall_speed: float = 1960.0

var is_in_air: bool = false
var is_rising: bool = false
var is_falling: bool = false

var is_crouch_falling: bool = false
var is_crouch_falling_start: bool = false

var air_time: float = 0.0
var rise_time: float = 0.0
var fall_time: float = 0.0

var _previous_y: float = Core.DEAD_ZONE.y

# NONE: Nothing happens
# CROUCH: Crouches in air
# FALL: Crouches and falls straight down
var fall_crouch_behavior: Core.PlatformerBehavior = Core.PlatformerBehavior.NONE

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"fall", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_in_air = false
		is_rising = false
		is_falling = false
		
		air_time = 0.0
		rise_time = 0.0
		fall_time = 0.0
		
		_previous_y = Core.DEAD_ZONE.y

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)

	is_crouch_falling_start = false
	if is_crouch_falling and not is_unit_crouching():
		is_crouch_falling = false
	
	if not can_physics_process():
		return
	
	if not can_unit_process():
		return
		
	var jump_actor: BaseActor = unit.get_actor_or_null(&"jump")
	
	if is_unit_climbing():
		if is_in_air:
			is_in_air = false 
			is_falling = false
			is_rising = false 
			is_crouch_falling = false
	elif jump_actor != null and jump_actor.is_jumping_start:
		if not is_in_air:
			is_in_air = true
			air_time = 0.0
			rise_time = 0.0
			fall_time = 0.0
	elif unit.is_on_floor():
		if is_in_air:
			is_in_air = false 
			is_falling = false
			is_rising = false 
			is_crouch_falling = false
	elif not is_in_air:
		is_in_air = true
		air_time = 0.0
		rise_time = 0.0
		fall_time = 0.0
	
	if is_in_air:
		if jump_actor == null or not jump_actor.is_jumping_start:
			if (not is_crouch_falling and 
				(jump_actor == null or not jump_actor.is_crouch_jumping) and
				fall_crouch_behavior == Core.PlatformerBehavior.FALL and 
				is_unit_crouching()
			):
				is_crouch_falling = true
				is_crouch_falling_start = true
		
		air_time += delta_
		
		if jump_actor != null and jump_actor.is_jumping_start:
			is_rising = true
			is_falling = false
			rise_time += delta_
		elif _previous_y > unit.global_position.y:
			is_rising = true
			is_falling = false
			rise_time += delta_
		else:
			is_rising = false
			is_falling = true
			fall_time += delta_
	
	_previous_y = unit.global_position.y

func move_process(delta_: float) -> void:
	if not is_in_air:
		return
		
	var move_actor: BaseActor = unit.get_actor_or_null(&"move")
	
	if move_actor == null:
		return
		
	var jump_actor: BaseActor = unit.get_actor_or_null(&"jump")
	
	if jump_actor == null or not jump_actor.is_jumping_start:
		if is_crouch_falling_start:
			# Cancel up move and apply normal fall acceleration
			move_actor.apply_velocity(Vector2(0.0, fall_acceleration * delta_))
		else:
			var velocity_y: float = min(max_fall_speed, unit.velocity.y + (fall_acceleration * delta_))
			move_actor.apply_velocity(Vector2(0.0, velocity_y))

func export() -> Dictionary[StringName, Variant]:
	var data: Dictionary[StringName, Variant] = super.export()
	
	data.merge({
		&"fall_acceleration": fall_acceleration,
		&"max_fall_speed": max_fall_speed,
		&"is_in_air": is_in_air,
		&"is_rising": is_rising,
		&"is_falling": is_falling,
		&"is_crouch_falling": is_crouch_falling,
		&"is_crouch_falling_start": is_crouch_falling_start,
		&"air_time": air_time,
		&"rise_time": rise_time,
		&"fall_time": fall_time,
		&"_previous_y": _previous_y,
	})
	
	return data
	
func import(data: Dictionary[StringName, Variant]) -> void:
	super.import(data)
	
	fall_acceleration = data.get(&"fall_acceleration", fall_acceleration)
	max_fall_speed = data.get(&"max_fall_speed", max_fall_speed)
	is_in_air = data.get(&"is_in_air", is_in_air)
	is_rising = data.get(&"is_rising", is_rising)
	is_falling = data.get(&"is_falling", is_falling)
	is_crouch_falling = data.get(&"is_crouch_falling", is_crouch_falling)
	is_crouch_falling_start = data.get(&"is_crouch_falling_start", is_crouch_falling_start)
	air_time = data.get(&"air_time", air_time)
	rise_time = data.get(&"rise_time", rise_time)
	fall_time = data.get(&"fall_time", fall_time)
	_previous_y = data.get(&"_previous_y", _previous_y)
