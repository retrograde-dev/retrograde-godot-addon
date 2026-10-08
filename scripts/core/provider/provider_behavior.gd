extends Resource
class_name ProviderBehavior

@export var random: bool = false
@export var remove: bool = false
@export var repeat: bool = false
@export var count: int = 0
	
func _init(
	random_: bool = false,
	remove_: bool = false,
	repeat_: bool = false,
	count_: int = 0,
) -> void:
	random = random_
	remove = remove_
	repeat = repeat_
	count = count_
