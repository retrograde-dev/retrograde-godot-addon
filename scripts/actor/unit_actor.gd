extends BaseActor
class_name UnitActor

var unit: BaseUnit

var unit_modes: Array[Core.UnitMode] = []

func _init(
	unit_: BaseUnit, 
	alias_: StringName,
	enabled_: bool = true
) -> void:
	super._init(alias_, enabled_)
	
	unit = unit_
	
func get_actions() -> Array[StringName]:
	return []
	
func move_process(_delta: float) -> void:
	pass
	
func can_unit_process() -> bool:
	if not unit.is_enabled:
		return false

	if not unit_modes.is_empty() and not unit_modes.has(unit.unit_mode):
		return false

	return true

func can_unit_input() -> bool:
	if unit.actions == null:
		return false
	
	# TODO: Replace this temporary solution of preventing character input on menu
	# such that an interactive level menu could be created
	if Core.level != null and Core.level.level_mode == Core.LevelMode.MENU:
		return false
	
	if is_unit_killed():
		return false
		
	return true

func is_unit_killed() -> bool:
	var life_actor_: BaseActor = unit.get_actor_or_null(&"life")
	
	if life_actor_ == null:
		return false
	
	return life_actor_.is_killed
	
func kill_unit(reason_: StringName = &"") -> void:
	var life_actor_: BaseActor = unit.get_actor_or_null(&"life")
	
	if life_actor_ == null:
		return
	
	life_actor_.kill(reason_)
	
func revive_unit() -> void:
	var life_actor_: BaseActor = unit.get_actor_or_null(&"life")
	
	if life_actor_ == null:
		return
	
	life_actor_.revive()
	
func damage_unit(damage: float, independent: bool = false) -> void:
	var health_actor_: BaseActor = unit.get_actor_or_null(&"health")
	
	if health_actor_ == null:
		return
	
	health_actor_.damage(damage, independent)
	
func set_unit_health(health: float) -> void:
	var health_actor_: BaseActor = unit.get_actor_or_null(&"health")
	
	if health_actor_ == null:
		return
	
	health_actor_.health = health

func is_unit_climbing() -> bool:
	var climb_actor_: BaseActor = unit.get_actor_or_null(&"climb")

	if climb_actor_ == null:
		return false

	return climb_actor_.is_climbing

func is_unit_crouching() -> bool:
	var crouch_actor_: BaseActor = unit.get_actor_or_null(&"crouch")

	if crouch_actor_ == null:
		return false

	return crouch_actor_.is_crouching

func is_unit_jumping() -> bool:
	var jump_actor_: BaseActor = unit.get_actor_or_null(&"jump")

	if jump_actor_ == null:
		return false

	return jump_actor_.is_jumping

func is_unit_in_air() -> bool:
	var fall_actor_: BaseActor = unit.get_actor_or_null(&"fall")
	
	if fall_actor_ == null:
		return false
		
	return fall_actor_.is_in_air

func is_unit_rising() -> bool:
	var fall_actor_: BaseActor = unit.get_actor_or_null(&"fall")
	
	if fall_actor_ == null:
		return false
		
	return fall_actor_.is_rising

func is_unit_falling() -> bool:
	var fall_actor_: BaseActor = unit.get_actor_or_null(&"fall")

	if fall_actor_ == null:
		return false

	return fall_actor_.is_falling

func is_unit_interacting() -> bool:
	var interact_actor_: BaseActor = unit.get_actor_or_null(&"interact")

	if interact_actor_ == null:
		return false

	return interact_actor_.is_interacting

func lose(reason_: StringName = &"") -> bool:
	var lose_actor_: BaseActor = unit.get_actor_or_null(&"lose")
	
	if lose_actor_ == null:
		return false
		
	return lose_actor_.lose(reason_)

func win(reason_: StringName = &"") -> bool:
	var win_actor_: BaseActor = unit.get_actor_or_null(&"win")
	
	if win_actor_ == null:
		return false
		
	return win_actor_.win(reason_)
