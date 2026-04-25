extends BaseCharacterBody2D
class_name BaseUnit

@export var alias: StringName = &"":
	get = get_alias,
	set = set_alias
	
var unit_type: Core.UnitType

var unit_state: UnitStateResource
var previous_unit_state: UnitStateResource

var unit_mode: Core.UnitMode:
	get = get_unit_mode,
	set = set_unit_mode
var previous_unit_mode: Core.UnitMode:
	get = get_previous_unit_mode

var unit_speed: Core.UnitSpeed:
	get = get_unit_speed,
	set = set_unit_speed
var previous_unit_speed: Core.UnitSpeed:
	get = get_previous_unit_speed

var unit_stance: Core.UnitStance:
	get = get_unit_stance,
	set = set_unit_stance
var previous_unit_stance: Core.UnitStance:
	get = get_previous_unit_stance

var unit_movement: Core.UnitMovement:
	get = get_unit_movement,
	set = set_unit_movement
var previous_unit_movement: Core.UnitMovement:
	get = get_previous_unit_movement

var unit_direction: Core.UnitDirection:
	get = get_unit_direction,
	set = set_unit_direction
var previous_unit_direction: Core.UnitDirection:
	get = get_previous_unit_direction

var unit_direction_x: Core.UnitDirection:
	get = get_unit_direction_x,
	set = set_unit_direction_x
var previous_unit_direction_x: Core.UnitDirection:
	get = get_previous_unit_direction_x

var unit_direction_y: Core.UnitDirection:
	get = get_unit_direction_y,
	set = set_unit_direction_y
var previous_unit_direction_y: Core.UnitDirection:
	get = get_previous_unit_direction_y

var unit_physics: Core.UnitPhysics:
	get = get_unit_physics,
	set = set_unit_physics
var previous_unit_physics: Core.UnitPhysics:
	get = get_previous_unit_physics

var actions: ActionHandler
var actors: ActorHandler
var areas: AreaController

var _timeout_cooldown: CooldownTimer = CooldownTimer.new()

signal unit_mode_changed(unit_mode_: Core.UnitMode, previous_unit_mode_: Core.UnitMode)
signal unit_speed_changed(unit_speed_: Core.UnitSpeed, previous_unit_speed_: Core.UnitSpeed)
signal unit_stance_changed(unit_stance_: Core.UnitStance, previous_unit_stance_: Core.UnitStance)
signal unit_movement_changed(unit_movement_: Core.UnitMovement, previous_unit_movement_: Core.UnitMovement)
signal unit_direction_changed(unit_direction_: Core.UnitDirection, previous_unit_direction_: Core.UnitDirection)
signal unit_direction_x_changed(unit_direction_x_: Core.UnitDirection, previous_unit_direction_x_: Core.UnitDirection)
signal unit_direction_y_changed(unit_direction_y_: Core.UnitDirection, previous_unit_direction_y_: Core.UnitDirection)
signal unit_physics_changed(unit_physics_: Core.UnitPhysics, previous_unit_physics_: Core.UnitPhysics)

func _init(unit_type_: Core.UnitType) -> void:
	unit_type = unit_type_

func _ready() -> void:
	super._ready()
	
	areas = get_node_or_null("%AreaController")
	
	if actors != null:
		actors.ready()

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		unit_state = UnitStateResource.new()
		previous_unit_state = UnitStateResource.new()

func start() -> void:
	await super.start()
	
	if actions != null:
		await actions.start()
	
	if actors != null:
		await actors.start()
	
func restart() -> void:
	await super.restart()
	
	if actions != null:
		actions.restart()
	
	if actors != null:
		actors.restart()
	
func stop() -> void:
	if actors != null:
		actors.stop()
		
	if actions != null:
		actions.stop()
		
	await super.stop()

func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return

	if actions != null:
		actions.process(delta_)

	if actors != null:
		actors.process(delta_)
	
func _physics_process(delta_: float) -> void:
	super._physics_process(delta_)
	
	if not _timeout_cooldown.is_stopped:
		_timeout_cooldown.process(delta_)
		
		if _timeout_cooldown.is_complete:
			_timeout_cooldown.stop()
			is_enabled = true
	
	if actors == null or not is_running():
		return
		
	actors.physics_process(delta_)
	
func get_alias() -> StringName:
	return alias
func set_alias(value_: StringName) -> void:
	alias = value_

func timeout(delta_: float) -> void:
	if not is_enabled:
		return

	if not _timeout_cooldown.is_stopped:
		_timeout_cooldown.stop()
	
	is_enabled = false
	_timeout_cooldown.delta = delta_
	_timeout_cooldown.start()

func is_moving() -> bool:
	return is_moving_x() or is_moving_y()
	
func is_moving_x() -> bool:
	return velocity.x != 0.0
	
func is_moving_y() -> bool:
	return velocity.y != 0.0

func get_unit_mode() -> Core.UnitMode:
	return unit_state.unit_mode
func set_unit_mode(unit_mode_: Core.UnitMode) -> void:
	if unit_state.unit_mode != unit_mode_:
		previous_unit_state.unit_mode = unit_mode
		unit_state.unit_mode = unit_mode_
		unit_mode_changed.emit(unit_mode_, previous_unit_mode)

func get_previous_unit_mode() -> Core.UnitMode:
	return previous_unit_state.unit_mode

func get_unit_speed() -> Core.UnitSpeed:
	return unit_state.unit_speed
func set_unit_speed(unit_speed_: Core.UnitSpeed) -> void:
	if unit_state.unit_speed != unit_speed_:
		previous_unit_state.unit_speed = unit_speed
		unit_state.unit_speed = unit_speed_
		unit_speed_changed.emit(unit_speed, previous_unit_speed)
		
func get_previous_unit_speed() -> Core.UnitSpeed:
	return previous_unit_state.unit_speed

func get_unit_stance() -> Core.UnitStance:
	return unit_state.unit_stance
func set_unit_stance(unit_stance_: Core.UnitStance) -> void:
	if unit_state.unit_stance != unit_stance_:
		previous_unit_state.unit_stance = unit_stance
		unit_state.unit_stance = unit_stance_
		unit_stance_changed.emit(unit_stance, previous_unit_stance)

func get_previous_unit_stance() -> Core.UnitStance:
	return previous_unit_state.unit_stance

func get_unit_movement() -> Core.UnitMovement:
	return unit_state.unit_movement
func set_unit_movement(unit_movement_: Core.UnitMovement) -> void:
	if unit_state.unit_movement != unit_movement_:
		previous_unit_state.unit_movement = unit_movement
		unit_state.unit_movement = unit_movement_
		unit_movement_changed.emit(unit_movement, previous_unit_movement)
		
func get_previous_unit_movement() -> Core.UnitMovement:
	return previous_unit_state.unit_movement
		
func get_unit_direction() -> Core.UnitDirection:
	return unit_state.unit_direction
func set_unit_direction(unit_direction_: Core.UnitDirection) -> void:
	if unit_state.unit_unit_direction != unit_direction_:
		var current_unit_direction_x_: Core.UnitDirection = unit_state.unit_direction_x
		var current_unit_direction_y_: Core.UnitDirection = unit_state.unit_direction_y
		
		previous_unit_state.unit_direction = unit_direction_
		unit_state.unit_direction = unit_direction_
		
		unit_direction_changed.emit(unit_direction, previous_unit_direction)
		
		if current_unit_direction_x_ != unit_state.unit_direction_x:
			unit_direction_x_changed.emit(unit_state.unit_direction_x, current_unit_direction_x_)
			
		if current_unit_direction_y_ != unit_state.unit_direction_y:
			unit_direction_y_changed.emit(unit_state.unit_direction_y, current_unit_direction_y_)
			
func set_unit_direction_from_vector2(unit_direction_: Vector2) -> void:
	var current_unit_direction_: Core.UnitDirection = unit_state.unit_direction
	var current_unit_direction_x_: Core.UnitDirection = unit_state.unit_direction_x
	var current_unit_direction_y_: Core.UnitDirection = unit_state.unit_direction_y
		
	if unit_direction_.x == 0.0:
		unit_state.unit_direction_x = Core.UnitDirection.NONE
	elif unit_direction_.x > 0:
		unit_state.unit_direction_x = Core.UnitDirection.RIGHT
	else:
		unit_state.unit_direction_x = Core.UnitDirection.LEFT
		
	if unit_direction_.y == 0.0:
		unit_state.unit_direction_y = Core.UnitDirection.NONE
	elif unit_direction_.y > 0:
		unit_state.unit_direction_y = Core.UnitDirection.DOWN
	else:
		unit_state.unit_direction_y = Core.UnitDirection.UP
		
	if current_unit_direction_ != unit_state.unit_direction:
		previous_unit_state.unit_direction = current_unit_direction_
		unit_direction_changed.emit(unit_state.unit_direction, current_unit_direction_)
		
	if current_unit_direction_x_ != unit_state.unit_direction_x:
		unit_direction_x_changed.emit(unit_state.unit_direction_x, current_unit_direction_x_)
		
	if current_unit_direction_y_ != unit_state.unit_direction_y:
		unit_direction_y_changed.emit(unit_state.unit_direction_y, current_unit_direction_y_)
	
func get_previous_unit_direction() -> Core.UnitDirection:
	return previous_unit_state.unit_direction
	
func get_unit_direction_x() -> Core.UnitDirection:
	return unit_state.unit_direction_x
func set_unit_direction_x(unit_direction_x_: Core.UnitDirection) -> void:
	if unit_direction_x != unit_direction_x_:
		var current_unit_direction_: Core.UnitDirection = unit_state.unit_direction
		
		previous_unit_direction_x = unit_direction_x
		unit_direction_x = unit_direction_x_

		unit_direction_changed.emit(unit_state.unit_direction, current_unit_direction_)
		unit_direction_x_changed.emit(unit_direction_x, previous_unit_direction_x)

func get_previous_unit_direction_x() -> Core.UnitDirection:
	return previous_unit_state.unit_direction_x
	
func get_unit_direction_y() -> Core.UnitDirection:
	return unit_state.unit_direction_y
func set_unit_direction_y(unit_direction_y_: Core.UnitDirection) -> void:
	if unit_state.unit_direction_y != unit_direction_y_:
		var current_unit_direction_: Core.UnitDirection = unit_state.unit_direction
		
		previous_unit_state.unit_direction_y = unit_direction_y
		unit_state.unit_direction_y = unit_direction_y_
		
		unit_direction_changed.emit(unit_state.unit_direction, current_unit_direction_)
		unit_direction_y_changed.emit(unit_direction_y, previous_unit_direction_y)

func get_previous_unit_direction_y() -> Core.UnitDirection:
	return previous_unit_state.unit_direction_y
	
func get_unit_physics() -> Core.UnitPhysics:
	return unit_state.unit_physics
func set_unit_physics(unit_physics_: Core.UnitPhysics) -> void:
	if unit_state.unit_physics != unit_physics_:
		previous_unit_state.unit_physics = unit_physics
		unit_state.unit_physics = unit_physics_
		unit_physics_changed.emit(unit_physics, previous_unit_physics)

func get_previous_unit_physics() -> Core.UnitPhysics:
	return previous_unit_state.unit_physics

func get_actions() -> ActionHandler:
	return actions

func get_actors() -> ActorHandler:
	return actors

func get_actor_or_null(actor_alias_: StringName) -> BaseActor:
	if actors == null:
		return null
		
	if not actors.has(actor_alias_):
		return null
	
	var actor: BaseActor = actors.use(actor_alias_)
	
	if not actor.is_enabled:
		return null
		
	return actor

func get_areas() -> AreaController:
	return areas

func get_area_or_null(area_name_: StringName) -> Area2D:
	var area: Area2D = get_node_or_null("%Area2D" + area_name_)
	if area != null:
		return area

	var areas_: AreaController = get_areas()
	if areas_ != null:
		return areas_.get_area(area_name_)

	return null
	
func export(data_: Resource = null) -> Resource:
	if data_ == null:
		data_ = UnitResource.new()
	else:
		assert(data_ is UnitResource, "Invalid resource.")
	
	super.export(data_)
	
	if unit_state == null:
		data_.unit_state = UnitStateResource.new()
	else:
		data_.unit_state = unit_state.duplicate(true) as UnitStateResource
		
	if previous_unit_state == null:
		data_.previous_unit_state = UnitStateResource.new()
	else:
		data_.previous_unit_state = previous_unit_state.duplicate(true) as UnitStateResource
	
	if actors != null:
		data_.actors = actors.export()
	
	return data_
	
func import(data_: Resource) -> void:
	assert(data_ is UnitResource, "Invalid resource.")
	
	super.import(data_)
	
	if data_.unit_state != null:
		unit_state = data_.unit_state.duplicate(true) as UnitStateResource
	else:
		unit_state = UnitStateResource.new()
		
	if data_.previous_unit_state != null:
		previous_unit_state = data_.previous_unit_state.duplicate(true) as UnitStateResource
	else:
		previous_unit_state = UnitStateResource.new()
	
	if actors != null:
		actors.import(data_.actors)
