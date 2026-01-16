extends BaseUI

func _init() -> void:
	super._init(&"difficulty")

func update() -> void:
	super.update()
	

func _on_ui_button_easy_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.EASY

func _on_ui_button_normal_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.NORMAL

func _on_ui_button_hard_pressed() -> void:
	Core.game_difficulty = Core.GameDifficulty.HARD
