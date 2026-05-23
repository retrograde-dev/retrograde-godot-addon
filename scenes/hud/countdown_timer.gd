extends BaseHUD

var time_seconds: int = 0

signal timeout()

func _init() -> void:
	super._init(&"countdown_timer")

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART or 
		reset_type_ == Core.ResetType.REFRESH
	):
		_update()
		
func set_time(time_seconds_: int) -> void:
	time_seconds = time_seconds_
	_update()
	
func start_timer() -> void:
	%Timer.start()

func stop_timer() -> void:
	%Timer.stop()

func _update() -> void:
	if not Core.level or time_seconds == 0:
		%UILabel.text = "00:00"
	else:
		var play_time_: int = roundi(float(Core.level.playtime.get_playtime()) / 1_000_000)
		var remaining_seconds_: int = time_seconds - play_time_
		
		remaining_seconds_ = max(0, remaining_seconds_)
		
		var hours: int = floori(remaining_seconds_ / 3600.0)
		var minutes: int = floori((remaining_seconds_ % 3600) / 60.0)
		var seconds: int = remaining_seconds_ % 60
		
		if hours > 0:
			%UILabel.text = "%d:%02d:%02d" % [hours, minutes, seconds]
		else:
			%UILabel.text = "%2d:%02d" % [minutes, seconds]
			
		if remaining_seconds_ == 0:
			stop_timer()
			timeout.emit()
		
	%UILabel.position = Vector2(
		(256 - %UILabel.size.x) / 2,
		(64 - %UILabel.size.y) / 2
	)

func _on_timer_timeout() -> void:
	_update()

func get_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(256, 64))
