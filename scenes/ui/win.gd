extends BaseUI

func _init() -> void:
	super._init(&"win")

func show_ui() -> void:
	super.show_ui()
	
	Core.audio.play_sfx(&"ui/win")

func update() -> void:
	super.update()
	
	if Core.ENABLE_PLAY_TIME:
		if Core.level != null:
			%UILabelTimeValue.text = Core.format_time(Core.level.get_play_time())
		else:
			%UILabelTimeValue.text = Core.format_time(0)
	else:
		%GridContainer.visible = false
	
	if Core.ENABLE_LEVEL_SELECT:
		%UIButtonLevelSelect.visible = Core.ui.has_ui(&"level_select")
		if Core.level != null and Core.level_select.has_next_level(Core.level.alias):
			%UIButtonNextLevel.visible = true
		else:
			%UIButtonNextLevel.visible = false
	else:
		%UIButtonLevelSelect.visible = false
		%UIButtonNextLevel.visible = false
	
	if Core.ENABLE_PLAY_AGAIN:
		%UIButtonPlayAgain.visible = true
		
		if not Core.ENABLE_GAME_DIFFICULTY:
			%UIButtonPlayAgainNormal.visible = false
			%UIButtonPlayAgainHard.visible = false
		elif Core.game_difficulty == Core.GameDifficulty.EASY:
			%UIButtonPlayAgainNormal.visible = true
			%UIButtonPlayAgainHard.visible = false
		elif Core.game_difficulty == Core.GameDifficulty.NORMAL:
			%UIButtonPlayAgainNormal.visible = false
			%UIButtonPlayAgainHard.visible = true
		else:
			%UIButtonPlayAgainNormal.visible = false
			%UIButtonPlayAgainHard.visible = false
	else:
		%UIButtonPlayAgain.visible = false
		%UIButtonPlayAgainNormal.visible = false
		%UIButtonPlayAgainHard.visible = false

func _on_ui_button_next_level_pressed() -> void:
	if not Core.level_select.has_next_level(Core.level.alias):
		return
		
	var level_: StringName = Core.level_select.get_next_level(Core.level.alias)
	if level_ != &"":
		Core.game.start_level(level_)

func _on_ui_button_play_again_pressed() -> void:
	Core.game.restart()

func _on_ui_button_play_again_normal_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.NORMAL
	Core.game.restart()

func _on_ui_button_play_again_hard_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.HARD
	Core.game.restart()
