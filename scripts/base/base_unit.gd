extends BaseCharacterBody2D
class_name BaseUnit

var alias: StringName
var unit_type: Core.UnitType

var unit_mode: Core.UnitMode = Core.UnitMode.NONE
var previous_unit_mode: Core.UnitMode = Core.UnitMode.NONE

var unit_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL
var previous_unit_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL

var unit_stance: Core.UnitStance = Core.UnitStance.NORMAL
var previous_unit_stance: Core.UnitStance = Core.UnitStance.NORMAL

var unit_movement: Core.UnitMovement = Core.UnitMovement.IDLE
var previous_unit_movement: Core.UnitMovement = Core.UnitMovement.IDLE

var unit_direction_x: Core.UnitDirection = Core.UnitDirection.NONE
var previous_unit_direction_x: Core.UnitDirection = Core.UnitDirection.NONE

var unit_direction_y: Core.UnitDirection = Core.UnitDirection.NONE
var previous_unit_direction_y: Core.UnitDirection = Core.UnitDirection.NONE

var unit_direction: Core.UnitDirection:
	get:
		if unit_direction_y == Core.UnitDirection.UP:
			if unit_direction_x == Core.UnitDirection.LEFT:
				return Core.UnitDirection.UP_LEFT
			elif unit_direction_x == Core.UnitDirection.RIGHT:
				return Core.UnitDirection.UP_RIGHT
			else:
				return Core.UnitDirection.UP
		elif unit_direction_y == Core.UnitDirection.DOWN:
			if unit_direction_x == Core.UnitDirection.LEFT:
				return Core.UnitDirection.DOWN_LEFT
			elif unit_direction_x == Core.UnitDirection.RIGHT:
				return Core.UnitDirection.DOWN_RIGHT
			else:
				return Core.UnitDirection.DOWN
			
		return unit_direction_x

var previous_unit_direction: Core.UnitDirection:
	get:
		if previous_unit_direction_y == Core.UnitDirection.UP:
			if previous_unit_direction_x == Core.UnitDirection.LEFT:
				return Core.UnitDirection.UP_LEFT
			elif previous_unit_direction_x == Core.UnitDirection.RIGHT:
				return Core.UnitDirection.UP_RIGHT
			else:
				return Core.UnitDirection.UP
		elif previous_unit_direction_y == Core.UnitDirection.DOWN:
			if previous_unit_direction_x == Core.UnitDirection.LEFT:
				return Core.UnitDirection.DOWN_LEFT
			elif previous_unit_direction_x == Core.UnitDirection.RIGHT:
				return Core.UnitDirection.DOWN_RIGHT
			else:
				return Core.UnitDirection.DOWN
			
		return previous_unit_direction_x

var unit_physics: Core.UnitPhysics = Core.UnitPhysics.PLATFORM
var previous_unit_physics: Core.UnitPhysics = Core.UnitPhysics.PLATFORM

var actions: ActionHandler
var actors: ActorHandler
var areas: AreaController

var _timeout_cooldown: CooldownTimer = CooldownTimer.new()

signal unit_mode_changed(unit_mode_: Core.UnitMode, previous_unit_mode_: Core.UnitMode)
signal unit_speed_changed(unit_speed_: Core.UnitSpeed, previous_unit_speed_: Core.UnitSpeed)
signal unit_stance_changed(unit_stance_: Core.UnitStance, previous_unit_stance_: Core.UnitStance)
signal unit_movement_changed(unit_movement_: Core.UnitMovement, previous_unit_movement_: Core.UnitMovement)
signal unit_direction_x_changed(unit_direction_x_: Core.UnitDirection, previous_unit_direction_x_: Core.UnitDirection)
signal unit_direction_y_changed(unit_direction_y_: Core.UnitDirection, previous_unit_direction_y_: Core.UnitDirection)
signal unit_physics_changed(unit_physics_: Core.UnitPhysics, previous_unit_physics_: Core.UnitPhysics)

func _init(alias_: StringName, unit_type_: Core.UnitType) -> void:
	alias = alias_
	unit_type = unit_type_

func _ready() -> void:
	super._ready()
	
	areas = get_node_or_null("%AreaController")
	
	if actors != null:
		actors.ready()

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		unit_mode = Core.UnitMode.NONE
		previous_unit_mode = Core.UnitMode.NONE
		
		unit_speed = Core.UnitSpeed.NORMAL
		previous_unit_speed = Core.UnitSpeed.NORMAL
		
		unit_stance = Core.UnitStance.NORMAL
		previous_unit_stance = Core.UnitStance.NORMAL
		
		unit_movement = Core.UnitMovement.IDLE
		previous_unit_movement = Core.UnitMovement.IDLE
		
		unit_direction_x = Core.UnitDirection.NONE
		previous_unit_direction_x = Core.UnitDirection.NONE
		
		unit_direction_y = Core.UnitDirection.NONE
		previous_unit_direction_y = Core.UnitDirection.NONE
		
		unit_physics = Core.UnitPhysics.PLATFORM
		previous_unit_physics = Core.UnitPhysics.PLATFORM

func start() -> void:
	if actions != null:
		actions.start()
	
	if actors != null:
		actors.start()
	
	super.start()
	
func restart() -> void:
	if actions != null:
		actions.restart()
	
	if actors != null:
		actors.restart()
	
	super.restart()
	
func stop() -> void:
	super.stop()

	if actors != null:
		actors.stop()
		
	if actions != null:
		actions.stop()

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
		
func set_unit_mode(unit_mode_: Core.UnitMode) -> void:
	if unit_mode != unit_mode_:
		previous_unit_mode = unit_mode
		unit_mode = unit_mode_
		unit_mode_changed.emit(unit_mode_, previous_unit_mode)

func set_unit_speed(unit_speed_: Core.UnitSpeed) -> void:
	if unit_speed != unit_speed_:
		previous_unit_speed = unit_speed
		unit_speed = unit_speed_
		unit_speed_changed.emit(unit_speed, previous_unit_speed)
		
func set_unit_stance(unit_stance_: Core.UnitStance) -> void:
	if unit_stance != unit_stance_:
		previous_unit_stance = unit_stance
		unit_stance = unit_stance_
		unit_stance_changed.emit(unit_stance, previous_unit_stance)
		
func set_unit_movement(unit_movement_: Core.UnitMovement) -> void:
	if unit_movement != unit_movement_:
		previous_unit_movement = unit_movement
		unit_movement = unit_movement_
		unit_movement_changed.emit(unit_movement, previous_unit_movement)
		
func set_unit_direction(unit_direction_: Vector2) -> void:
	if unit_direction_.x == 0.0:
		set_unit_direction_x(Core.UnitDirection.NONE)
	elif unit_direction_.x > 0:
		set_unit_direction_x(Core.UnitDirection.RIGHT)
	else:
		set_unit_direction_x(Core.UnitDirection.LEFT)
		
	if unit_direction_.y == 0.0:
		set_unit_direction_y(Core.UnitDirection.NONE)
	elif unit_direction_.y > 0:
		set_unit_direction_y(Core.UnitDirection.DOWN)
	else:
		set_unit_direction_y(Core.UnitDirection.UP)
	
func set_unit_direction_x(unit_direction_x_: Core.UnitDirection) -> void:
	if unit_direction_x != unit_direction_x_:
		previous_unit_direction_x = unit_direction_x
		unit_direction_x = unit_direction_x_
		unit_direction_x_changed.emit(unit_direction_x, previous_unit_direction_x)
		
func set_unit_direction_y(unit_direction_y_: Core.UnitDirection) -> void:
	if unit_direction_y != unit_direction_y_:
		previous_unit_direction_y = unit_direction_y
		unit_direction_y = unit_direction_y_
		unit_direction_y_changed.emit(unit_direction_y, previous_unit_direction_y)

func set_unit_physics(unit_physics_: Core.UnitPhysics) -> void:
	if unit_physics != unit_physics_:
		previous_unit_physics = unit_physics
		unit_physics = unit_physics_
		unit_physics_changed.emit(unit_physics, previous_unit_physics)

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
