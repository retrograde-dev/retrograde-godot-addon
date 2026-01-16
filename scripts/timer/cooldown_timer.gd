class_name CooldownTimer

var delta: float
var current_delta: float = 0.0
var is_active: bool = false
var is_complete: bool = false
var auto_stop: bool = false
var steps: Array[Dictionary] = []

var is_stopped: bool:
	get:
		return not is_active and not is_complete

func _init(delta_: float = 0.0, auto_stop_: bool = false) -> void:
	delta = delta_
	auto_stop = auto_stop_

func reset() -> void:
	reset_steps()

	current_delta = 0.0
	is_active = false
	is_complete = false
	
func reset_steps() -> void:
	for step: Dictionary in steps:
		step.is_active = false
		step.is_complete = false

func add_step(alias_: StringName, delta_: float) -> void:
	steps.push_back({
		"alias": alias_,
		"delta": delta_,
		"is_active": false,
		"is_complete": false,
	})
	
func set_step_delta(alias_: StringName, delta_: float) -> void:
	for step: Dictionary in steps:
		if step.alias == alias_:
			step.delta = delta_
			break

func process(delta_: float) -> void:
	if not is_active:
		if is_complete:
			reset_steps()
		return

	current_delta += delta_

	for step: Dictionary in steps:
		if step.is_complete:
			continue
		elif step.is_active:
			step.is_active = false
			step.is_complete = true
		elif current_delta >= step.delta:
			step.is_active = true

	if current_delta > delta:
		complete()

func complete() -> void:
	if is_active and not is_complete:
		current_delta = delta
		is_active = false
		is_complete = true
		if auto_stop:
			stop()

func is_before_step(alias_: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step: Dictionary in steps:
		if step.alias == alias_:
			return not step.is_active and not step.is_complete

	return false

func is_on_step(alias_: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step: Dictionary in steps:
		if step.alias == alias_:
			return step.is_active

	return false

func is_after_step(alias_: StringName) -> bool:
	if not is_active and not is_complete:
		return false

	for step: Dictionary in steps:
		if step.alias == alias_:
			return step.is_complete

	return false

func start() -> bool:
	if is_active or is_complete:
		return false

	reset()
	is_active = true

	return true

func stop() -> void:
	reset_steps()
		
	is_active = false
	is_complete = false
