extends UnitActor
class_name LoseActor

var is_lose: bool = false
var is_in_lose_area: bool = false
var _reason: StringName = &""

var lose_cooldown_delta: float = 0.0
var _lose_cooldown: CooldownTimer = null

var signal_can_lose: bool = false
var signal_lose_handled: bool = false

signal lose_error(reason_: StringName, error_: Core.Error) 
signal lose_before(reason_: StringName)
signal lose_after(reason_: StringName)
signal lose_complete(reason_: StringName)

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"lose", enabled)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_lose = false
		is_in_lose_area = false
		_reason = &""
		
		if reset_type_ == Core.ResetType.START:
			_lose_cooldown = CooldownTimer.new(lose_cooldown_delta)
			_add_areas()
		else:
			_lose_cooldown.reset()
			
		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()
		
func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"lose", Core.Edge.NONE)

func _connect_events() -> void:
	var lose_area: Area2D = unit.get_area_or_null(&"lose")
	
	if lose_area != null:
		lose_area.connect(&"body_entered", _on_lose_body_entered)
		lose_area.connect(&"body_exited", _on_lose_body_exited)
		lose_area.connect(&"area_entered", _on_lose_area_entered)
		lose_area.connect(&"area_exited", _on_lose_area_exited)
	
func _disconnect_events() -> void:
	var lose_area: Area2D = unit.get_area_or_null(&"lose")
	
	if lose_area != null:
		lose_area.disconnect(&"body_entered", _on_lose_body_entered)
		lose_area.disconnect(&"body_exited", _on_lose_body_exited)
		lose_area.disconnect(&"area_entered", _on_lose_area_entered)
		lose_area.disconnect(&"area_exited", _on_lose_area_exited)
		
func _on_lose_body_entered(_body: Node2D) -> void:
	is_in_lose_area = true
	lose()

func _on_lose_body_exited(_body: Node2D) -> void:
	is_in_lose_area = false
	
func _on_lose_area_entered(_area: Area2D) -> void:
	is_in_lose_area = true
	lose()

func _on_lose_area_exited(_area: Area2D) -> void:
	is_in_lose_area = false

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
	
	if not can_unit_process():
		return
	
	if _lose_cooldown.is_stopped:
		if Core.game.is_win or Core.game.is_lose or not is_lose:
			return

	_lose_cooldown.process(delta)

	if _lose_cooldown.is_complete:
		Core.game.is_lose = true
		_lose_cooldown.stop()
		lose_complete.emit(_reason)

func can_lose() -> bool:
	return not is_lose

func lose(reason_: StringName = &"") -> bool:
	_reason = reason_
	
	if not can_lose():
		lose_error.emit(_reason, Core.Error.ACTOR_RESTRICTION)
		return false
	
	signal_can_lose = true
	signal_lose_handled = false
	
	lose_before.emit(reason_)
	
	if signal_can_lose == false:
		lose_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_lose_handled and not _lose():
		lose_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	lose_after.emit(reason_)
	return true
	
func _lose() -> bool:
	if not _lose_cooldown.start():
		return false
		
	is_lose = true

	return true
