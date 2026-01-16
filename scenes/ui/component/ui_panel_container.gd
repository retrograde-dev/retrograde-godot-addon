extends PanelContainer
class_name UIPanelContainer

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
		add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		return
		
	assert(Core.ui.has_panel_container(style), "Panel container style not found. (" + style + ")")
	
	if not Core.ui.has_panel_container(style):
		return

	var panel_container_: Dictionary = Core.ui.get_panel_container(style)

	remove_theme_stylebox_override("panel")
	
	if panel_container_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(panel_container_.theme))
		
	set_theme_type_variation(panel_container_.theme_type_variation)
