extends Node2D
class_name BaseEffect

var timer: StepTimer

func _init(steps: int, delta: float) -> void:
	timer = StepTimer.new(steps, delta)

func _process(delta: float) -> void:
	timer.process(delta)

	if timer.requires_update:
		update_sprites(timer.current_step)
	elif timer.is_complete:
		timer.stop()

func start() -> bool:
	return timer.start()

func stop() -> void:
	timer.stop()
	reset_sprites()

func update_sprites(_step: int) -> void:
	pass

func reset_sprites() -> void:
	pass
