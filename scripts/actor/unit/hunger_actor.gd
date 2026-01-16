extends UnitActor
class_name HungerActor

var hunger: float = 100.0
var hunger_delta: float = 0.4
var max_hunger: float = 100.0

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"hunger", enabled)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		hunger = max_hunger

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
		
	# Prevent starving if not in game
	if Core.level == null or Core.level.level_mode != Core.LevelMode.GAME:
		return

	# Slowly drain hunger over time
	var amount: float = Core.apply_difficulty_modifier_float(hunger_delta * delta)
	hunger = max(0.0, hunger - amount)
	
	if hunger == 0.0:
		kill_unit(&"hunger")
		
func increase_hunger(amount: float) -> void:
	hunger = min(max_hunger, hunger + amount)

func decrease_hunger(amount: float) -> void:
	hunger = max(0.0, hunger - amount)

func is_full_hunger() -> bool:
	return hunger >= max_hunger
