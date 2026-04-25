extends BaseNode2D
class_name BaseObject

@export var alias: StringName = &"":
	get = get_alias,
	set = set_alias
	
func get_alias() -> StringName:
	return alias
func set_alias(value_: StringName) -> void:
	alias = value_
