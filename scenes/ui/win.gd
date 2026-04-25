extends BaseUI

func _init() -> void:
	super._init(&"win")

func show_ui() -> void:
	super.show_ui()
	
	Core.audio.play_sfx(&"ui/win")

func update() -> void:
	super.update()
	
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
		
		if not Core.ENABLE_GAME_DIFFICULTY or Core.data == null:
			%UIButtonPlayAgainNormal.visible = false
			%UIButtonPlayAgainHard.visible = false
		elif Core.data.difficulty == Core.GameDifficulty.EASY:
			%UIButtonPlayAgainNormal.visible = true
			%UIButtonPlayAgainHard.visible = false
		elif Core.data.difficulty == Core.GameDifficulty.NORMAL:
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
		
	var level_alias_: StringName = Core.level_select.get_next_level(Core.level.alias)
	if level_alias_ != &"":
		Core.data.level_alias = level_alias_
		Core.game.start()

func _on_ui_button_play_again_pressed() -> void:
	Core.game.restart()

func _on_ui_button_play_again_normal_pressed() -> void:
	Core.data.difficulty = Core.GameDifficulty.NORMAL
	Core.game.restart()

func _on_ui_button_play_again_hard_pressed() -> void:
	Core.data.difficulty = Core.GameDifficulty.HARD
	Core.game.restart()
