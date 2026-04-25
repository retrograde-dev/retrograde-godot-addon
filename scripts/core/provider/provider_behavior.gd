class_name ProviderBehavior

var random: bool
var remove: bool
var repeat: bool
var count: int
	
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
