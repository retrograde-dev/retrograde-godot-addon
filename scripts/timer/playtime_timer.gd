class_name PlaytimeTimer

var start_time: int = 0
var stop_time: int = 0
var pause_delta: float = 0.0
var is_paused: bool = false

func reset() -> void:
	start_time = 0
	stop_time = 0
	pause_delta = 0.0
	
func is_running() -> bool:
	return start_time != 0 and stop_time == 0
	
func start(start_time_usec_: int = 0) -> void:
	start_time = Time.get_ticks_usec() - start_time_usec_
	stop_time = 0
	pause_delta = 0.0
	
func stop() -> void:
	stop_time = Time.get_ticks_usec()
	
func pause() -> void:
	is_paused = true
	
func unpause() -> void:
	is_paused = false
	
func toggle_pause() -> void:
	is_paused = !is_paused

func process(delta_: float) -> void:
	if stop_time != 0:
		return
		
	if is_paused or Core.game.is_paused:
		pause_delta += delta_
	
func get_playtime() -> int:
	if stop_time != 0:
		return Time.get_ticks_usec() - start_time - int(pause_delta * 1_000_000)
		
	return stop_time - start_time - int(pause_delta * 1_000_000)

func set_playtime(time_usec_: int) -> void:
	if stop_time != 0:
		start_time = stop_time - time_usec_
	else:
		start_time = Time.get_ticks_usec() - time_usec_
		
	pause_delta = 0.0
	
func get_formatted_playtime() -> String:
	return Core.format_time(get_playtime())
