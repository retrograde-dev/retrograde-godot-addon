extends BaseUnit
class_name ProjectileUnit

var is_dead: bool = false
var death_cooldown_delta: float = 0.0
var death_cooldown: CooldownTimer
var death_handled: bool = false

var is_colliding: bool = false

# Wait a bit of time before testing for collision to ensure checking at new position
var _current_collision_delta: float = 0.0
var collision_delta: float = 0.125

var projectile_type: Core.ProjectileType
var lifespan_delta: float
var _current_lifespan: float

var hide_on_complete_death: bool = false

func _init(
	alias_: StringName, 
	projectile_type_: Core.ProjectileType,
	lifespan_delta_: float,
) -> void:
	super._init(alias_, Core.UnitType.PROJECTILE)
	
	projectile_type = projectile_type_
	lifespan_delta = lifespan_delta_
	
	death_cooldown_delta = max(Core.MIN_COLLISION_WAIT_DELTA, death_cooldown_delta)
	
	death_cooldown = CooldownTimer.new(death_cooldown_delta)
	death_cooldown.add_step(&"hide", Core.MIN_COLLISION_WAIT_DELTA)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_dead = false
		death_handled = false
		collision_layer = 0
		is_colliding = false
		_current_collision_delta = 0.0
		_current_lifespan = 0.0
		
		death_cooldown.reset()
		
		var attack_area_: Area2D = get_node_or_null("%Area2DAttack")
		if attack_area_ != null:
			attack_area_.monitoring = true
			attack_area_.monitorable = true

func _ready() -> void:
	var attack_area_: Area2D = get_node_or_null("%Area2DAttack")
	if attack_area_ != null:
		attack_area_.connect("body_entered", _on_attack_body_entered)
	
func _on_attack_body_entered(body_: Node2D) -> void:
	if not is_running():
		return
		
	var attack_area_: Area2D = get_node_or_null("%Area2DAttack")
	if attack_area_ != null and attack_area_ is Area2DAttack:
		if attack_area_.can_damage(body_):
			attack_area_.monitoring = false
			attack_area_.monitorable = false
			is_dead = true
	elif Core.is_enemies(self, body_):
		if attack_area_ != null:
			attack_area_.monitoring = false
			attack_area_.monitorable = false
		is_dead = true

func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
		
	_handle_lifespan(delta_)

	_handle_death(delta_)
	
func _physics_process(delta_: float) -> void:
	super._physics_process(delta_)
	
	if not is_running():
		return
	
	_handle_collision(delta_)

func _handle_lifespan(delta_: float) -> void:
	if not is_dead:
		_current_lifespan += delta_
		if _current_lifespan > lifespan_delta:
			is_dead = true
		
func _handle_collision(delta_: float) -> void:
	if _current_collision_delta > collision_delta:
		is_colliding = get_slide_collision_count() > 0
		if is_colliding:
			is_dead = true
	else:
		_current_collision_delta += delta_

func _handle_death(delta_: float) -> void:
	if not is_dead or death_handled:
		return

	death_cooldown.process(delta_)

	if death_cooldown.start():
		_start_death()
	elif death_cooldown.is_on_step(&"hide"):
		if not hide_on_complete_death:
			modes.add(&"hide")
	elif death_cooldown.is_complete:
		death_handled = true
		death_cooldown.stop()
		_complete_death()

func _start_death() -> void:
	pass
	
func _complete_death() -> void:
	if hide_on_complete_death:
		# To trigger signal
		modes.add(&"hide")
	
	Core.nodes.free_node(self)

func start() -> void:
	super.start()
	Core.clear_groups(self)
	_current_collision_delta = 0.0
	is_enabled = true
	is_colliding = false
	
func stop() -> void:
	super.stop()
	velocity = Vector2.ZERO
