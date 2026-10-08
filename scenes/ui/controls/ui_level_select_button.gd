extends UIButton
class_name UILevelSelectButton

func _update_style() -> void:
	super._update_style()

	var button_: Dictionary = Core.ui.get_button(style)
	
	if button_.texture.get(&"completed", null):
		%TextureRectCompleted.texture = ResourceLoader.load(button_.texture.completed)

func update() -> void:
	var level_: StringName = goto_ui_alias.substr(6)

	var level: String = str(goto_ui_alias.substr(6))
	if (Core.state.has(&"level_select") and 
		Core.state.level_select.has(level_) and
		Core.state.level_select[level_].get(&"win", false)
	):
		%TextureRectCompleted.visible = true
	else:
		%TextureRectCompleted.visible = false
