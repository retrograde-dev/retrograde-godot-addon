extends HBoxContainer
class_name UIHSliderField

@export_multiline var text: String:
	get: return %UILabel.text
	set(value):
		%UILabel.text = value

@export var min_value: float:
	get: return %UIHSlider.min_value
	set(value):
		%UIHSlider.min_value = value

@export var max_value: float:
	get: return %UIHSlider.max_value
	set(value):
		%UIHSlider.max_value = value
		
@export var step: float:
	get: return %UIHSlider.minstep
	set(value):
		%UIHSlider.step = value
		
@export var value: float:
	get: return %UIHSlider.value
	set(value):
		%UIHSlider.value = value

signal value_changed(value: float)

func _on_ui_h_slider_value_changed(value_: float) -> void:
	value_changed.emit(value_)
