extends UnitActor
class_name WeaponsActor

var uses: int = 1

var weapons: WeaponsController = null

var use_action_enabled: bool = true
var use_action_enabled_default: bool = true
var signal_can_use: bool = false
var signal_use_handled: bool = false

var action_use: StringName = &"weapon_use_"

signal use_error(use_index_: int, error_: Core.Error)
signal use_before(use_index_: int)
signal use_after(use_index_: int)
signal use_complete(use_index_: int)

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"weapons", enabled_)

func ready() -> void:
	super.ready()
	
	weapons = unit.get_node_or_null("%WeaponsController")
	if weapons != null:
		weapons.use_error.connect(_on_use_error)
		weapons.use_after.connect(_on_use_after)
		weapons.use_complete.connect(_on_use_complete)

func _on_use_error(use_index_: int, error_: Core.Error) -> void:
	use_error.emit(use_index_, error_)
	
func _on_use_after(use_index_: int) -> void:
	use_after.emit(use_index_)

func _on_use_complete(use_index_: int) -> void:
	use_complete.emit(use_index_)
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		use_action_enabled = use_action_enabled_default

func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
	
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return
		
	for index_: int in uses:
		_action_use_weapon(index_)

func _action_use_weapon(use_index_: int) -> void:
	if not use_action_enabled:
		return
	
	var action_: StringName = action_use + str(use_index_ + 1)
	
	if not unit.actions.is_just_pressed(action_):
		return
	
	if not unit.actions.has(action_):
		use_error.emit(use_index_, Core.Error.UNIT_RESTRICTION)
		return

	use_weapon(use_index_)

func can_use_weapon(use_index_: int) -> bool:
	if weapons == null:
		return false
		
	return weapons.can_use(use_index_)
	
func get_weapon_attack(use_index_: int) -> AttackValue:
	return weapons.get_use(use_index_)

func use_weapon(use_index_: int) -> void:
	if not can_use_weapon(use_index_):
		use_error.emit(use_index_, Core.Error.ACTOR_RESTRICTION)
		return
	
	signal_can_use = true
	signal_use_handled = false
	
	use_before.emit(use_index_)
	
	if signal_can_use == false:
		use_error.emit(use_index_, Core.Error.GAME_RESTRICTION)
		return
	
	if not signal_use_handled:
		if not _use_weapon(use_index_):
			use_error.emit(use_index_, Core.Error.UNHANDLED)
			return

func _use_weapon(use_index_: int) -> bool:
	return weapons.use(use_index_)

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = []
	
	for index_: int in uses:
		actions_.push_back(action_use + str(index_ + 1))
		
	return actions_
