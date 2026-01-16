class_name PlayValue

var animation: StringName
var direction: Core.UnitDirection
var suffixes: Array[StringName] = []

func _init(
	animation_: StringName, 
	direction_: Core.UnitDirection = Core.UnitDirection.NONE,
	suffixes_: Array[StringName] = [],
) -> void:
	animation = animation_
	direction = direction_
	suffixes = suffixes_

func is_equals(play_value_: PlayValue) -> bool:
	if animation != play_value_.animation:
		return false
		
	if direction != play_value_.direction:
		return false
		
	if suffixes.size() != play_value_.suffixes.size():
		return false
		
	for index_: int in suffixes.size():
		if suffixes[index_] != play_value_.suffixes[index_]:
			return false
			
	return true
