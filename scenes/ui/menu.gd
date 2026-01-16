extends BaseUI

@onready var sprite_title: AnimatedSprite2D = $MarginContainer/AnimatedSprite2DTitle

func _init() -> void:
	super._init(&"menu")

func _ready() -> void:
	super._ready()
	_update_title_position()
	_update_locale()

func update() -> void:
	super.update()
	
	%UIButtonSettings.visible = Core.ui.has_ui(&"settings")
	%UIButtonControls.visible = Core.ui.has_ui(&"controls")
	%UIButtonCredits.visible = Core.ui.has_ui(&"credits")
	%UIButtonToggleLocale.visible = Core.LOCALES.size() > 1

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_title_position()
		
func _update_title_position() -> void:
	if not sprite_title:
		return
		
	var available_space_: Vector2 = get_viewport().get_visible_rect().size
	
	sprite_title.position = Vector2(round(available_space_.x / 2), 32.0)
		
func _update_locale() -> void:
	sprite_title.play(Core.locale)
	
	if Core.LOCALES.size() <= 1:
		return
	
	for index_: int in Core.LOCALES.size():
		if Core.LOCALES[index_] == Core.locale:
			var next_index_: int = (index_ + 1) % Core.LOCALES.size()
			%UIButtonToggleLocale.text = "BUTTON_LOCALE:" + Core.LOCALES[next_index_]
			break
		
func _on_button_toggle_locale_pressed() -> void:
	for index_: int in Core.LOCALES.size():
		if Core.LOCALES[index_] == Core.locale:
			var next_index_: int = (index_ + 1) % Core.LOCALES.size()
			Core.locale = Core.LOCALES[next_index_]
			TranslationServer.set_locale(Core.locale)
			break
		
	_update_locale()
	
	Core.settings.save()
