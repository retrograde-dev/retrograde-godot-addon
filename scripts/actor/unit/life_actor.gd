extends UnitActor
class_name LifeActor

var is_killed: bool = false
var _reason: StringName = &""

var lose_on_kill: bool = false
var health_on_revive: float = 0.0

var kill_cooldown_delta: float = 0.0
var _kill_cooldown: CooldownTimer

var revive_cooldown_delta: float = 0.0
var _revive_cooldown: CooldownTimer

var kill_action_enabled: bool = true
var kill_action_enabled_default: bool = true
var signal_can_kill: bool = false
var signal_kill_handled: bool = false

var revive_action_enabled: bool = true
var revive_action_enabled_default: bool = true
var signal_can_revive: bool = false
var signal_revive_handled: bool = false

signal kill_error(reason_: StringName, error_: Core.Error) 
signal kill_before(reason_: StringName)
signal kill_after(reason_: StringName)
signal kill_hide(reason_: StringName)
signal kill_complete(reason_: StringName)

signal revive_error(reason_: StringName, error_: Core.Error) 
signal revive_before(reason_: StringName)
signal revive_after(reason_: StringName)
signal revive_show(reason_: StringName)
signal revive_complete(reason_: StringName)

var action_kill: StringName = &"life_kill"
var action_revive: StringName = &"life_revive"

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"kill", enabled)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
		
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_killed = false
		_reason = &""
		
		if reset_type_ == Core.ResetType.START:
			_kill_cooldown = CooldownTimer.new(kill_cooldown_delta)
			_kill_cooldown.add_step(&"hide", 0.0)
			
			_revive_cooldown = CooldownTimer.new(revive_cooldown_delta)
			_revive_cooldown.add_step(&"show", 0.0)
		else:
			_kill_cooldown.reset()
			_revive_cooldown.reset()
			
		kill_action_enabled = kill_action_enabled_default
	
		revive_action_enabled = revive_action_enabled_default

func process(delta_: float) -> void:
	super.process(delta_)

	if not can_process():
		return
		
	if not can_unit_process():
		return

		
	_process_kill(delta_)
	_process_revive(delta_)
		
	if not can_unit_input():
		return
	
	_action_kill(delta_)
	_action_revive(delta_)

func _process_kill(delta_: float) -> void:
	if not is_killed or _kill_cooldown.is_stopped:
		return
	
	_kill_cooldown.process(delta_)

	if _kill_cooldown.is_on_step(&"hide"):
		kill_hide.emit(_reason)
	elif _kill_cooldown.is_complete:
		_kill_cooldown.stop()
		kill_complete.emit(_reason)
		
		if lose_on_kill:
			lose(_reason)
	
func _process_revive(delta_: float) -> void:
	if is_killed or _revive_cooldown.is_stopped:
		return
		
	_revive_cooldown.process(delta_)

	if _revive_cooldown.is_on_step(&"show"):
		revive_show.emit(_reason)
	elif _revive_cooldown.is_complete:
		_revive_cooldown.stop()
		revive_complete.emit(_reason)
	
func _action_kill(_delta: float) -> void:
	if not kill_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_kill):
		return
		
	if not unit.actions.has(action_kill):
		kill_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	kill(&"action")
	
func _action_revive(_delta: float) -> void:
	if not revive_action_enabled:
		return
		
	if not unit.actions.is_just_pressed(action_revive):
		return
		
	if not unit.actions.has(action_revive):
		revive_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	revive(&"action")
	
func can_kill() -> bool:
	return not is_killed
	
func can_revive() -> bool:
	return is_killed
	
func kill(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_kill():
		kill_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_kill = true
	signal_kill_handled = false
	
	kill_before.emit(reason_)
	
	if signal_can_kill == false:
		kill_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_kill_handled and not _kill():
		kill_error.emit(reason_, Core.Error.UNHANDLED)
		return false
			
	kill_after.emit(reason_)
	return true

func revive(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_revive():
		revive_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_revive = true
	signal_revive_handled = false
	
	revive_before.emit(reason_)
	
	if signal_can_revive == false:
		revive_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
		
	if not signal_revive_handled and not _revive():
		revive_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	revive_after.emit(reason_)
	return true
	
func _kill() -> bool:
	if not _kill_cooldown.start():
		return false
	
	is_killed = true
	
	return true
	
func _revive() -> bool:
	if not _revive_cooldown.start():
		return false
		
	is_killed = false
	
	if health_on_revive != 0.0:
		set_unit_health(health_on_revive)
	
	return true

func get_actions() -> Array[StringName]:
	return [action_kill]
