extends Node2D
class_name StepVFX

var timer: StepTimer

func _init(steps: int, delta: float) -> void:
	timer = StepTimer.new(steps, delta)

func _process(delta: float) -> void:
	timer.process(delta)

	if timer.requires_update:
		update(timer.current_step)
	elif timer.is_complete:
		timer.stop()

func start() -> bool:
	return timer.start()

func stop() -> void:
	timer.stop()
	reset()

func update(_step: int) -> void:
	pass

func reset() -> void:
	pass
