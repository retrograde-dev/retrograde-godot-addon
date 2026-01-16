class_name ComponentModifier

var input_modifier: float
var output_modifier: float
var modifier_method: Callable

var input_modifier_default: float
var output_modifier_default: float

func _init(
	input_modifier_: float = 0.0,
	output_modifier_: float = 0.0,
	modifier_method_: Callable = Callable()
) -> void:
	input_modifier = input_modifier_
	output_modifier = output_modifier_
	modifier_method = modifier_method_
	
	input_modifier_default = input_modifier
	output_modifier_default = output_modifier
	
func reset() -> void:
	input_modifier = input_modifier_default
	output_modifier = output_modifier_default

func get_input_modifier() -> float:
	return input_modifier

func set_input_modifier(input_modifier_: float) -> void:
	input_modifier = input_modifier_

func get_output_modifier() -> float:
	return output_modifier

func set_output_modifier(output_modifier_: float) -> void:
	output_modifier = output_modifier_

func modify(input_level_: float) -> float:
	if modifier_method.is_null():
		if is_equal_approx(input_level_, 0.0):
			return 0.0
			
		return input_modifier + input_level_ + output_modifier

	return modifier_method.call(input_level_, input_modifier, output_modifier)
