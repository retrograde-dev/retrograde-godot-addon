extends BaseUI

func _init() -> void:
	super._init(&"pause")

func update() -> void:
	super.update()
	
	%UIButtonSettings.visible = Core.ui.has_ui(&"settings")
	%UIButtonControls.visible = Core.ui.has_ui(&"controls")
	
	if Core.ENABLE_PLAY_TIME:
		if Core.level != null:
			%UILabelTimeValue.text = Core.format_time(Core.level.get_play_time())
		else:
			%UILabelTimeValue.text = Core.format_time(0)
	else:
		%GridContainer.visible = false
	
	if (Core.ENABLE_LEVEL_SELECT and 
		Core.ENABLE_LEVEL_SKIP and
		Core.level and
		Core.level_select.has_next_level(Core.level.alias)
	):
		%UIButtonSkipLevel.visible = true
	else:
		%UIButtonSkipLevel.visible = false
	
func _on_ui_button_continue_pressed() -> void:
	hide_ui()
	Core.game.toggle_pause()


func _on_ui_button_restart_pressed() -> void:
	hide_ui()
	Core.game.restart()

func _on_ui_button_skip_level_pressed() -> void:
	if not Core.level_select.has_next_level(Core.level.alias):
		return
		
	var level_: StringName = Core.level_select.get_next_level(Core.level.alias)
	if level_ != &"":
		Core.game.start_level(level_)
