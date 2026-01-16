extends UnitActor
class_name HealthActor

var health: float = 100.0
var max_health: float = 100.0

var armor: float = 0
var max_armor: float = 100.0

var durability: float = 1.0

# Damage
var damage_cooldown_delta: float = 1.0
var _damage_cooldown: CooldownTimer

var group_damage: float = 0
var independent_damage: float = 0

#TODO: Revisit signals so not damage
signal damage_after(damage: float)

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"health", enabled)

func ready() -> void:
	super.ready()
	
	_damage_cooldown = CooldownTimer.new(damage_cooldown_delta, true)
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
		
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		health = max_health
		armor = 0.0
		
		group_damage = 0.0
		independent_damage = 0.0
		
		_damage_cooldown.reset()

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
	
	if not can_unit_process():
		return
		
	if is_unit_killed():
		return
		
	if Core.game.is_win or Core.game.is_lose:
		return

	_handle_damage(delta)
	
	if health == 0.0:
		kill_unit(&"health")

func _handle_damage(delta: float) -> void:
	if health == 0.0:
		return
		
	_damage_cooldown.process(delta)
		
	var current_damage: float = independent_damage

	if group_damage > 0.0 and _damage_cooldown.start():
		current_damage += group_damage
		
	if current_damage > 0.0:
		_damage_process(current_damage)
		
	group_damage = 0.0
	independent_damage = 0.0
	
func _damage_process(amount: float) -> void:
	assert(amount > 0.0, "No damage dealt.")
	
	if amount <= 0.0:
		return
	
	var apply_damage: float

	if unit.is_in_group("enemy") or unit.is_in_group("object"):
		apply_damage = Core.apply_difficulty_modifier_float(amount, true)
	else:
		apply_damage = Core.apply_difficulty_modifier_float(amount)

	apply_damage /= durability

	if armor > 0 and apply_damage > 0:
		apply_damage /= 2;
		armor = max(0.0, armor - apply_damage)

	health = max(0.0, health - apply_damage)
	
	damage_after.emit(apply_damage)
 
func damage(amount: float, independent: bool = false) -> void:
	if independent:
		independent_damage += amount
	else:
		group_damage += amount
		
func increase_health(amount: float) -> void:
	health = min(max_health, health + amount)

func decrease_health(amount: float) -> void:
	health = max(0.0, health - amount)

func is_full_health() -> bool:
	return health >= max_health
	
func increase_armor(amount: float) -> void:
	armor = min(max_armor, armor + amount)

func decrease_armor(amount: float) -> void:
	armor = max(0.0, armor - amount)
	
func is_full_armor() -> bool:
	return armor >= max_armor
