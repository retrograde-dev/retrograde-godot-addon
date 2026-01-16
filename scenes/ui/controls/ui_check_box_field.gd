extends HBoxContainer
class_name UICheckBoxField

@export_multiline var text: String:
	get: return %UILabel.text
	set(value):
		%UILabel.text = value

@export var value: float:
	get: return %UICheckBox.button_pressed
	set(value):
		%UICheckBox.set_pressed_no_signal(value)

signal toggled(toggled_on: bool)

func _on_ui_check_box_toggled(toggled_on: bool) -> void:
	toggled.emit(toggled_on)
