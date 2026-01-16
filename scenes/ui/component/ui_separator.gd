extends Control
class_name UISeparator

@export_category("Visual")
@export var style: StringName = &"":
	set(value):
		style = value
		_update_style()
		
func _ready() -> void:
	_update_style()
	
func _update_style() -> void:
	if style == &"":
		visible = true
		custom_minimum_size.x = 0
		custom_minimum_size.y = 0
		return
	
	assert(Core.ui.has_separator(style), "Separator style not found. (" + style + ")")
	
	if not Core.ui.has_separator(style):
		return

	var separator_: Dictionary = Core.ui.get_separator(style)
	
	visible = separator_.visible
	custom_minimum_size = separator_.size
