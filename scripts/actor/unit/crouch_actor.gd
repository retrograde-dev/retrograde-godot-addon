extends UnitActor
class_name CrouchActor

#var slow_crouch_speed: float = 60.0
#var normal_crouch_speed: float = 60.0
#var fast_crouch_speed: float = 200.0

var is_crouch_toggle: bool = false

var is_crouching: bool = false
var is_crouching_start: bool = false
var _reason: StringName = &""
var _is_crouch_active: bool = false

var signal_can_crouch: bool = false
var signal_crouch_handled: bool = false

var signal_can_uncrouch: bool = false
var signal_uncrouch_handled: bool = false

signal crouch_error(reason_: StringName, error_: Core.Error) 
signal crouch_before(reason_: StringName)
signal crouch_after(reason_: StringName)

signal uncrouch_error(reason_: StringName, error_: Core.Error) 
signal uncrouch_before(reason_: StringName)
signal uncrouch_after(reason_: StringName)

var action_crouch: StringName = &"crouch"

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"crouch", enabled_)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_crouching = false

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)

	is_crouching_start = false

	if not can_physics_process():
		return
	
	if not can_unit_process():
		return
		
	_process_crouch(delta_)
		
	if not can_unit_input():
		return
	
	if is_crouching:
		_action_uncrouch(delta_)
	else:
		_action_crouch(delta_)
	
func _process_crouch(_delta: float) -> void:
	if not is_crouching and _is_crouch_active:
		uncrouch(_reason)

func _action_crouch(_delta: float) -> void:
	if is_crouch_toggle:
		if not unit.actions.is_just_pressed(action_crouch, true):
			return
		
		if is_crouching:
			return
	elif unit.actions.is_pressed(action_crouch, true):
		if is_crouching:
			return
	elif is_crouching:
		return
		
	if not unit.actions.has(action_crouch):
		crouch_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return

	crouch(&"action")
	
func _action_uncrouch(_delta: float) -> void:
	if is_crouch_toggle:
		if not unit.actions.is_just_pressed(action_crouch):
			return
		
		if not is_crouching:
			return
	elif unit.actions.is_pressed(action_crouch):
		return
	elif not is_crouching or _reason != &"action":
		return
		
	if not unit.actions.has(action_crouch):
		crouch_error.emit(&"action", Core.Error.UNIT_RESTRICTION)
		return
		
	uncrouch(&"action")

func can_crouch() -> bool:
	if _is_crouch_active:
		return false
		
	return true
	
func can_uncrouch() -> bool:
	if not _is_crouch_active:
		return false
		
	return true
	
func crouch(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_crouch():
		crouch_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_crouch = true
	signal_crouch_handled = false
	
	crouch_before.emit(reason_)
	
	if signal_can_crouch == false:
		crouch_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_crouch_handled and not _crouch():
		crouch_error.emit(reason_, Core.Error.UNHANDLED)
		return false
			
	_is_crouch_active = true
	crouch_after.emit(reason_)
	return true

func uncrouch(reason_: StringName = &"") -> bool:
	_reason = reason_
		
	if not can_uncrouch():
		uncrouch_error.emit(reason_, Core.Error.ACTOR_RESTRICTION)
		return false
		
	signal_can_uncrouch = true
	signal_uncrouch_handled = false
	
	uncrouch_before.emit(reason_)
	
	if signal_can_uncrouch == false:
		uncrouch_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_uncrouch_handled and not _uncrouch():
		uncrouch_error.emit(reason_, Core.Error.UNHANDLED)
		return false
			
	_is_crouch_active = false
	uncrouch_after.emit(reason_)
	return true
	
func _crouch() -> bool:
	is_crouching = true
	is_crouching_start = true
	
	return true

func _uncrouch() -> bool:
	is_crouching = false
	is_crouching_start = false
	
	return true
	
func get_actions() -> Array[StringName]:
	return [action_crouch]
