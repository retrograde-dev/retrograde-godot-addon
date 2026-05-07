extends BaseActor
class_name PauseActor

var is_paused: bool = false
var _toggle_mouse: bool = false

var action_pause: StringName = &"pause"

signal pause_toggled(is_paused: bool)

func _init(enabled_: bool = true) -> void:
	super._init(&"pause", enabled_)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		Core.game.get_tree().paused = false
		is_paused = false
		_toggle_mouse = false

func process(delta_: float) -> void:
	super.process(delta_)
	
	if not Core.game.actions.is_just_pressed(action_pause):
		return

	if not Core.game.actions.has(action_pause):
		return

	toggle_pause()
		
func pause() -> void:
	if !is_paused:
		toggle_pause()
		
func unpause() -> void:
	if is_paused:
		toggle_pause()
		
func toggle_pause() -> void:
	if is_paused:
		Core.game.get_tree().paused = false
		is_paused = false
		pause_toggled.emit(is_paused)

		if _toggle_mouse:
			Core.game.hide_mouse()

		Core.audio.normal_volume(Core.AudioType.MUSIC)
		Core.audio.normal_volume(Core.AudioType.AMBIANCE)

		Core.ui.hide_uis(Core.UIType.MENU)
	elif can_pause():
		Core.game.get_tree().paused = true
		is_paused = true
		pause_toggled.emit(is_paused)

		_toggle_mouse = Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE
		if _toggle_mouse:
			Core.game.show_mouse()

		Core.audio.quiet_volume(Core.AudioType.MUSIC)
		Core.audio.quiet_volume(Core.AudioType.AMBIANCE)

		Core.ui.show_ui(&"pause")

func can_pause() -> bool:
	if not Core.game.is_enabled:
		return false

	if Core.ui.has_visible_uis(Core.UIType.MENU):
		return false
		
	if Core.level == null:
		return false

	if Core.level.level_mode == Core.LevelMode.MENU:
		return false

	if Core.ui.is_ui_visible(&"win"):
		return false

	if Core.ui.is_ui_visible(&"lose"):
		return false

	return true

func get_actions() -> Array[StringName]:
	return [action_pause]
