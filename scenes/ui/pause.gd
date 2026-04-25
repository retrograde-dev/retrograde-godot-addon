extends BaseUI

func _init() -> void:
	super._init(&"pause")

func update() -> void:
	super.update()
	
	%UIButtonSettings.visible = Core.ui.has_ui(&"settings")
	%UIButtonControls.visible = Core.ui.has_ui(&"controls")
	
	if Core.ENABLE_GAME_PLAYTIME and Core.level != null:
		%UILabelGamePlaytimeValue.text = Core.game.playtime.get_formatted_playtime()
		%UILabelGamePlaytimeField.visible = true
		%UILabelGamePlaytimeValue.visible = true
	else:
		%UILabelGamePlaytimeField.visible = false
		%UILabelGamePlaytimeValue.visible = false
		
	if Core.ENABLE_LEVEL_PLAYTIME and Core.level != null:
		%UILabelLevelPlaytimeValue.text = Core.level.playtime.get_formatted_playtime()
		%UILabelLevelPlaytimeField.visible = true
		%UILabelLevelPlaytimeValue.visible = true
	else:
		%UILabelLevelPlaytimeField.visible = false
		%UILabelLevelPlaytimeValue.visible = false
		
	if %UILabelGamePlaytimeField.visible or %UILabelLevelPlaytimeField.visible:
		%GridContainer.visible = true
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
		
	var level_alias_: StringName = Core.level_select.get_next_level(Core.level.alias)
	if level_alias_ != &"":
		Core.data.level_alias = level_alias_
		Core.game.start()
