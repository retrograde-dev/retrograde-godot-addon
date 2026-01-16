extends StringNameSet
class_name ActionHandler

var unit: BaseUnit

var _press: StringNameSet = StringNameSet.new()
var _pressed: Array[StringName] = []
var _released: Array[StringName] = []

var _press_queue: Array[StringName] = []
var _pressed_queue: Array[StringName] = []
var _release_queue: Array[StringName] = []

func _init(unit_: BaseUnit) -> void:
	unit = unit_

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		_press.clear()
		_pressed.clear()
		_released.clear()

		_press_queue.clear()
		_pressed_queue.clear()
		_release_queue.clear()

		clear()
		add_all(unit.actors.get_actions())
	elif reset_type_ == Core.ResetType.STOP:
		if unit.actors != null:
			remove_all(unit.actors.get_actions())

func start() -> void:
	reset(Core.ResetType.START)

func restart() -> void:
	reset(Core.ResetType.RESTART)

func stop() -> void:
	reset(Core.ResetType.STOP)

func process(_delta: float) -> void:
	_press.remove_all(_release_queue)
	_press.add_all(_press_queue)
	_pressed = _pressed_queue.duplicate()
	_pressed.append_array(_press_queue)
	_released = _release_queue

	_press_queue.clear()
	_release_queue = _pressed_queue
	_pressed_queue = []

func press(action_: StringName, has_: bool = false) -> void:
	if not has_ or has(action_):
		_press_queue.push_back(action_)

func release(action_: StringName, has_: bool = false) -> void:
	if not has_ or has(action_):
		_release_queue.push_back(action_)

func just_pressed(action_: StringName, has_: bool = false) -> void:
	if not has_ or has(action_):
		_pressed_queue.push_back(action_)

func is_just_pressed(action_: StringName, has_: bool = false) -> bool:
	if has_ and not has(action_):
		return false

	if _pressed.has(action_):
		return true

	if not unit.is_in_group(&"input"):
		return false

	return Input.is_action_just_pressed(action_)

func is_just_released(action_: StringName, has_: bool = false) -> bool:
	if has_ and not has(action_):
		return false

	if _released.has(action_):
		return true

	if not unit.is_in_group(&"input"):
		return false

	return Input.is_action_just_released(action_)

func is_pressed(action_: StringName, has_: bool = false) -> bool:
	if has_ and not has(action_):
		return false

	if _press.has(action_):
		return true

	if not unit.is_in_group(&"input"):
		return false
	
	if Core.inputs.has_action(action_):
		return Input.is_action_pressed(action_)
		
	return false

func get_axis(negative_action_: StringName, positive_action_: StringName, has_: bool = false) -> float:
	if not has_:
		return _get_press_axis(negative_action_, positive_action_)

	if not has(negative_action_):
		if not has(positive_action_):
			return 0.0

		if _press.has(negative_action_):
			return -1.0

		if not unit.is_in_group(&"input"):
			return 0.0

		return Input.get_action_strength(negative_action_)
	elif not has(positive_action_):
		if _press.has(positive_action_):
			return 1.0

		if not unit.is_in_group(&"input"):
			return 0.0

		return -Input.get_action_strength(positive_action_)

	return _get_press_axis(negative_action_, positive_action_)

func _get_press_axis(negative_action_: StringName, positive_action_: StringName) -> float:
	var result: float = 0.0

	if unit.is_in_group(&"input"):
		result += Input.get_axis(negative_action_, positive_action_)

	if _press.has(positive_action_):
		if not _press.has(negative_action_):
			result += 1.0
	elif _press.has(negative_action_):
		result += -1.0

	return sign(result)
