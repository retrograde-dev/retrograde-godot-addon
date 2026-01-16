extends BaseUI

func _init() -> void:
	super._init(&"lose")

func show_ui() -> void:
	super.show_ui()
	
	Core.audio.play_sfx(&"ui/lose")
	
func update() -> void:
	super.update()
	
	if Core.ENABLE_PLAY_TIME:
		if Core.level != null:
			%UILabelTimeValue.text = Core.format_time(Core.level.get_play_time())
		else:
			%UILabelTimeValue.text = Core.format_time(0)
	else:
		%GridContainer.visible = false
		
	if Core.ENABLE_LEVEL_SELECT and Core.ui.has_ui(&"level_select"):
		%UIButtonLevelSelect.visible = true
	else:
		%UIButtonLevelSelect.visible = false
		
	if not Core.ENABLE_GAME_DIFFICULTY:
		%UIButtonTryAgainEasy.visible = false
		%UIButtonTryAgainNormal.visible = false
	elif Core.game_difficulty == Core.GameDifficulty.EASY:
		%UIButtonTryAgainEasy.visible = false
		%UIButtonTryAgainNormal.visible = false
	elif Core.game_difficulty == Core.GameDifficulty.NORMAL:
		%UIButtonTryAgainEasy.visible = true
		%UIButtonTryAgainNormal.visible = false
	else:
		%UIButtonTryAgainEasy.visible = false
		%UIButtonTryAgainNormal.visible = true

func _on_ui_button_try_again_pressed() -> void:
	Core.game.restart()

func _on_ui_button_try_again_easy_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.EASY
	Core.game.restart()

func _on_ui_button_try_again_normal_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.NORMAL
	Core.game.restart()
