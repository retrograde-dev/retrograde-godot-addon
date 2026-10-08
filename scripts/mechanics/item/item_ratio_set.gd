extends Resource
class_name ItemRatioSet

@export var ratios: Array[ItemRatioValue] = []

var _active: Array[Dictionary] = []

func reset() -> void:
	_active = []
	
func size() -> int:
	var count_: int = 0
	
	for item_ratio_value_: ItemRatioValue in ratios:
		count_ += item_ratio_value_.size()
	
	return count_
	
func current_size() -> int:
	return _active.size()
	
func add_ratio(item_ratio_value_: ItemRatioValue) -> void:
	ratios.push_back(item_ratio_value_)

func _handle_repeat() -> void:
	if _active.is_empty():
		_active = _create_ratio()

func get_item_types() -> Array[Dictionary]:
	return _create_ratio()
	
func get_next_item_type() -> Dictionary:
	_handle_repeat()
	
	return _active.pop_back()

func _create_ratio() -> Array[Dictionary]:
	var result_: Array[Dictionary] = []
	
	for item_ratio_value_: ItemRatioValue in ratios:
		result_ += item_ratio_value_.get_items()
		
	result_.shuffle()
	return result_
