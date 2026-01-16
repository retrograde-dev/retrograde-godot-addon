extends MarginContainer
class_name UIMarginContainer

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
		
	assert(Core.ui.has_margin_container(style), "Margin container style not found. (" + style + ")")
	
	if not Core.ui.has_margin_container(style):
		return
	
	var margin_container_: Dictionary = Core.ui.get_margin_container(style)

	if margin_container_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(margin_container_.theme))
	
	set_theme(ResourceLoader.load("res://resources/ui.tres"))
	set_theme_type_variation(margin_container_.theme_type_variation)
