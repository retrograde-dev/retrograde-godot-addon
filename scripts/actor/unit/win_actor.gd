extends UnitActor
class_name WinActor

var is_win: bool = false
var is_in_win_area: bool = false
var _reason: StringName = &""

var win_cooldown_delta: float = 0.0
var _win_cooldown: CooldownTimer = null

var signal_can_win: bool = false
var signal_win_handled: bool = false

signal win_error(reason_: StringName, error_: Core.Error) 
signal win_before(reason_: StringName)
signal win_after(reason_: StringName)
signal win_complete(reason_: StringName)

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"win", enabled_)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_win = false
		is_in_win_area = false
		_reason = &""
		
		if reset_type_ == Core.ResetType.START:
			_win_cooldown = CooldownTimer.new(win_cooldown_delta)
			_add_areas()
		else:
			_win_cooldown.reset()
			
		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()
		
func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"Win", Core.Edge.NONE)

func _connect_events() -> void:
	var win_area: Area2D = unit.get_area_or_null(&"Win")
	
	if win_area != null:
		win_area.connect(&"body_entered", _on_win_body_entered)
		win_area.connect(&"body_exited", _on_win_body_exited)
		win_area.connect(&"area_entered", _on_win_area_entered)
		win_area.connect(&"area_exited", _on_win_area_exited)
	
func _disconnect_events() -> void:
	var win_area: Area2D = unit.get_area_or_null(&"Win")
	
	if win_area != null:
		win_area.disconnect(&"body_entered", _on_win_body_entered)
		win_area.disconnect(&"body_exited", _on_win_body_exited)
		win_area.disconnect(&"area_entered", _on_win_area_entered)
		win_area.disconnect(&"area_exited", _on_win_area_exited)
		
func _on_win_body_entered(_body: Node2D) -> void:
	is_in_win_area = true
	win()

func _on_win_body_exited(_body: Node2D) -> void:
	is_in_win_area = false
	
func _on_win_area_entered(_area: Area2D) -> void:
	is_in_win_area = true
	win()

func _on_win_area_exited(_area: Area2D) -> void:
	is_in_win_area = false

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
		
	if not can_unit_process():
		return
	
	if _win_cooldown.is_stopped:
		if Core.game.is_win or Core.game.is_lose or not is_win:
			return

	_win_cooldown.process(delta)
	
	if _win_cooldown.is_complete:
		Core.game.is_win = true
		_win_cooldown.stop()
		win_complete.emit(_reason)

func can_win() -> bool:
	return not is_win

func win(reason_: StringName = &"") -> bool:
	_reason = reason_
	
	if not can_win():
		win_error.emit(_reason, Core.Error.ACTOR_RESTRICTION)
		return false
	
	signal_can_win = true
	signal_win_handled = false
	
	win_before.emit(reason_)
	
	if signal_can_win == false:
		win_error.emit(reason_, Core.Error.GAME_RESTRICTION)
		return false
	
	if not signal_win_handled and not _win():
		win_error.emit(reason_, Core.Error.UNHANDLED)
		return false

	win_after.emit(reason_)
	return true
	
func _win() -> bool:
	if not _win_cooldown.start():
		return false
		
	is_win = true

	return true
