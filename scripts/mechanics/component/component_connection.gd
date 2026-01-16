class_name ComponentConnection

var type: Core.ComponentType
var required: bool
var modifier: ComponentModifier

func _init(
	type_: Core.ComponentType = Core.ComponentType.MIXED,
	required_: bool = true, 
	modifier_: ComponentModifier = null,
) -> void:
	type = type_
	required = required_
	modifier = modifier_

func get_type() -> Core.ComponentType:
	return type

func is_required() -> int:
	return required
	
func modify(input_level_: float) -> float:
	if modifier == null:
		return input_level_
		
	return modifier.modify(input_level_)
