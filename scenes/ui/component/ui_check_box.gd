extends CheckBox
class_name UICheckBox

@export_category("Visual")
@export var style: StringName = &"":
	set(value):
		style = value
		if is_node_ready():
			_update_style()

func _ready() -> void:
	_update_style()

func _update_style() -> void:
	if style == &"":
		set_theme(null)
		set_theme_type_variation(&"")
		return
		
	assert(Core.ui.has_check_box(style), "Check box style not found. (" + style + ")")
	 
	if not Core.ui.has_check_box(style):
		return
		
	var check_box_: Dictionary = Core.ui.get_check_box(style)

	if check_box_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(check_box_.theme))
		
	set_theme_type_variation(check_box_.theme_type_variation)
