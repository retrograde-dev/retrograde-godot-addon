extends Label
class_name UILabel

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
		
	assert(Core.ui.has_label(style), "Label style not found. (" + style + ")")
	
	if not Core.ui.has_label(style):
		return

	var label_: Dictionary = Core.ui.get_label(style)

	if label_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(label_.theme))
		
	set_theme_type_variation(label_.theme_type_variation)
