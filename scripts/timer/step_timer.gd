class_name StepTimer

var current_step: int = 0
var current_delta: float = 0.0
var requires_update: bool = false

var is_active: bool = false
var is_complete: bool = false
var auto_stop: bool = false
var step_size: int
var step_delta: float

func _init(
	step_size_: int, 
	step_delta_: float = 0.125,
	auto_stop_: bool = false
) -> void:
	step_size = step_size_
	step_delta = step_delta_
	auto_stop = auto_stop_
	
func reset() -> void:
	current_step = 0
	current_delta = 0.0
	requires_update = false
	is_active = false
	is_complete = false
	
func process(delta: float) -> void:
	requires_update = false
	
	if is_complete:
		return
	
	if is_active and current_step >= step_size:
		is_active = false
		is_complete = true
		if auto_stop:
			stop()

	if is_active:
		current_delta += delta
		var step: int = ceili(current_delta / step_delta)
		if current_step != step:
			current_step = step
			requires_update = true

func start() -> bool:
	if is_active or is_complete:
		return false
	
	reset()
	is_active = true
	return true
	
func stop() -> void:
	is_active = false
	is_complete = false
