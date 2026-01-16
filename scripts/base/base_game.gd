extends Node
class_name BaseGame

var _level_alias: StringName = &""
var current_level: BaseLevel = null
var current_player: PlayerUnit = null
var current_cursor: BaseCursor = null

var is_paused: bool = false
var is_enabled: bool = true
var _toggle_mouse: bool = true

var is_lose: bool = false
var _is_lose_handeld: bool = false
var is_win: bool = false
var _is_win_handeld: bool = false
var is_started: bool = false

func _init() -> void:
	Core.nodes = NodeHandler.new()
	Core.game = self

	Core.inputs = InputHandler.new()
	Core.inputs.load()

	Core.items = ItemHandler.new()

	if Core.ENABLE_LEVEL_SELECT:
		Core.level_select = LevelSelectHandler.new()

	Core.help = HelpHandler.new()
	Core.audio = AudioHandler.new()
	Core.speech = SpeechHandler.new()
	Core.states = {}

	Core.settings = SettingsFile.new()
	Core.settings.load()

	Core.save = SaveFile.new()
	Core.save.load()

func _ready() -> void:
	Core.ui = get_node_or_null("%UI")
	Core.hud = get_node_or_null("%HUD")
	Core.camera = get_node_or_null("%Camera")

	await menu()
	is_started = true

func start() -> void:
	await start_level(Core.START_LEVEL)

func start_level(level_alias_: StringName) -> void:
	_level_alias = level_alias_
	await reset(Core.ResetType.START)

func restart() -> void:
	await reset(Core.ResetType.RESTART)

func refresh() -> void:
	await reset(Core.ResetType.REFRESH)

func stop() -> void:
	await reset(Core.ResetType.STOP)

	if Core.EXIT_DELAY > 0.0:
		await get_tree().create_timer(Core.EXIT_DELAY).timeout

	get_tree().quit()

func reset(reset_type_: Core.ResetType) -> void:
	if current_level == null and reset_type_ == Core.ResetType.RESTART:
		reset_type_ = Core.ResetType.START

	if reset_type_ == Core.ResetType.START:
		if _level_alias == &"":
			_level_alias = Core.START_LEVEL

		level(_level_alias)
	elif reset_type_ == Core.ResetType.RESTART:
		Core.ui.show_ui(&"loading")

		if Core.hud != null:
			await Core.hud.restart()

		if Core.ui != null:
			await Core.ui.restart()

		reset_player()
		reset_game()

		Core.nodes.free_all()
		Core.states.clear()
		Core.speech.reset()

		start_load()

		_hide_mouse()

		Core.ui.hide_uis(Core.UIType.MENU)
		Core.ui.hide_uis(Core.UIType.GAME)
		Core.hud.hide_huds()

		await current_level.restart()
	elif reset_type_ == Core.ResetType.REFRESH:
		if Core.hud != null:
			await Core.hud.restart()

		if Core.ui != null:
			await Core.ui.restart()

func menu() -> void:
	Core.ui.show_ui(&"loading")

	if is_started:
		reset_level()
		reset_player()
		reset_game()

		Core.nodes.reset()
		Core.help.reset()
		Core.audio.reset()
		Core.states.clear()
		Core.speech.reset()

	start_load()

	if is_started:
		_show_mouse()
		Core.ui.hide_uis(Core.UIType.GAME)
		Core.hud.hide_huds()
	else:
		if Core.hud != null:
			await Core.hud.start()

		if Core.ui != null:
			await Core.ui.start()

	await change_level(Core.MENU_LEVEL, Core.LevelMode.MENU)
	Core.ui.show_ui(&"menu")

func level(level_alias_: StringName) -> void:
	Core.ui.show_ui(&"loading")

	reset_level()
	reset_player()
	reset_game()

	Core.nodes.reset()
	Core.help.reset()
	Core.audio.reset()
	if level_alias_ == Core.START_LEVEL:
		Core.states.clear()
	Core.speech.reset()

	start_load()
	_hide_mouse()
	Core.ui.hide_uis(Core.UIType.MENU)

	await change_level(level_alias_, Core.LevelMode.GAME)

func reset_game() -> void:
	reset_state()
	reset_win_lose()

func reset_player() -> void:
	reset_cursor()

	if current_player != null:
		current_player.queue_free()
		current_player = null

	Core.player = null

func reset_level() -> void:
	%Level.visible = false
	Core.ui.hide_uis(Core.UIType.GAME)
	Core.hud.hide_huds()

	if current_level != null:
		current_level.started.disconnect(_level_started)
		%Level.remove_child(current_level)
		current_level.queue_free()
		current_level = null
		Core.level = null

func reset_cursor() -> void:
	if current_cursor != null:
		%Level.remove_child(current_cursor)
		current_cursor.queue_free()
		current_cursor = null
		Core.cursor = null

func reset_state() -> void:
	is_paused = false
	Engine.time_scale = 1
	is_enabled = true

	if Core.camera != null:
		Core.camera.position_smoothing_enabled = true

func reset_win_lose() -> void:
	is_lose = false
	_is_lose_handeld = false
	is_win = false
	_is_win_handeld = false

func add_mode(mode_: StringName) -> void:
	if Core.level != null:
		Core.level.add_mode(mode_, true)

	if Core.player != null:
		Core.player.add_mode(mode_, true)

	if Core.cursor != null:
		Core.cursor.add_mode(mode_, true)

	for child_: Node in Core.hud.get_children():
		if child_ is BaseHUD:
			child_.add_mode(mode_, true)

func remove_mode(mode_: StringName) -> void:
	if Core.level != null:
		Core.level.remove_mode(mode_, true)

	if Core.player != null:
		Core.player.remove_mode(mode_, true)

	if Core.cursor != null:
		Core.player.remove_mode(mode_, true)

	for child_: Node in Core.hud.get_children():
		if child_ is BaseHUD:
			child_.remove_mode(mode_, true)

func add_level_child(node: Node2D) -> void:
	%Level.add_child(node)

func remove_level_child(node: Node2D) -> void:
	%Level.remove_child.call_deferred(node)

func get_level_alias() -> StringName:
	if Core.level != null:
		return Core.level.alias

	return &""

func get_level_area_alias() -> StringName:
	if Core.level != null and Core.level.area != null:
			return Core.level.area.alias

	return &""

func change_level(
	level_alias_: StringName,
	level_mode_: Core.LevelMode = Core.LevelMode.GAME
) -> void:
	if current_level == null or current_level.alias != level_alias_:
		reset_level()

		var level_path_: String = "res://scenes/level/" + level_alias_ + ".tscn"

		var level_resource_: Resource = load(level_path_)

		assert(level_resource_ != null, "Level not found. (" + level_alias_ + ")")

		var level_: BaseLevel = await level_resource_.instantiate()

		%Level.add_child(level_)

		current_level = level_
		Core.level = level_
		level_.set_level_mode(level_mode_)

		level_.started.connect(_level_started)

		await level_.start()

		%Level.visible = true
	else:
		start_load()
		current_level.set_level_mode(level_mode_)
		await current_level.restart()

func change_player(player_alias_: StringName) -> void:
	if current_player and current_player.alias == player_alias_:
		current_player.restart()
		return

	reset_player()

	var player_path_: String = "res://scenes/unit/player/" + player_alias_ + ".tscn"

	var player_resource_: Resource = load(player_path_)

	assert(player_resource_ != null, "Player not found. (" + player_alias_ + ")")

	if player_resource_ == null:
		return

	var player_: PlayerUnit = await player_resource_.instantiate()

	%Level.add_child(player_)
	current_player = player_
	Core.player = player_

	player_.start()

func set_player_position(position: Vector2i) -> void:
	assert(current_player != null, "Player is not loaded.")

	if current_player == null:
		return

	current_player.position = position

func change_cursor(cursor_alias: StringName) -> void:
	if current_cursor and current_cursor.alias == cursor_alias:
		current_cursor.restart()
		return

	reset_cursor()

	var cursor_path: String = "res://scenes/cursor/" + cursor_alias + ".tscn"

	var cursor: BaseCursor = await load(cursor_path).instantiate()

	current_cursor = cursor
	Core.cursor = cursor

	%Level.add_child(cursor)

	cursor.start()

func _level_started() -> void:
	end_load()
	Core.ui.hide_ui(&"loading")

func start_load() -> void:
	if Core.camera != null:
		Core.camera.position_smoothing_enabled = false
	is_enabled = false
	#Engine.time_scale = 0

func end_load() -> void:
	if Core.camera != null:
		Core.camera.position_smoothing_enabled = true
	#Engine.time_scale = 1
	is_enabled = true

func _process(delta_: float) -> void:
	_handle_pause()

	if not is_enabled:
		return

	Core.speech.process(delta_)

	if is_lose and not _is_lose_handeld:
		_is_lose_handeld = true
		_show_mouse()
		Core.ui.show_ui(&"lose")

	if is_win and not _is_win_handeld:
		_is_win_handeld = true
		_show_mouse()
		Core.ui.show_ui(&"win")

func _physics_process(_delta: float) -> void:
	pass

func _handle_pause() -> void:
	if current_level == null:
		return

	if not InputMap.has_action(&"pause"):
		return

	if Input.is_action_just_pressed(&"pause"):
		toggle_pause()

func toggle_pause() -> void:
	if is_paused:
		Engine.time_scale = 1

		if _toggle_mouse:
			_hide_mouse()

		is_paused = false
		is_enabled = true

		Core.audio.normal_volume(Core.AudioType.MUSIC)
		Core.audio.normal_volume(Core.AudioType.AMBIANCE)

		Core.ui.hide_uis(Core.UIType.MENU)
	elif _can_pause():
		Engine.time_scale = 0
		is_enabled = false
		is_paused = true

		if _toggle_mouse:
			_show_mouse()

		Core.audio.quiet_volume(Core.AudioType.MUSIC)
		Core.audio.quiet_volume(Core.AudioType.AMBIANCE)

		Core.ui.show_ui(&"pause")

func _can_pause() -> bool:
	if not is_enabled:
		return false

	if Core.ui.has_visible_uis(Core.UIType.MENU):
		return false

	if current_level != null and current_level.level_mode == Core.LevelMode.MENU:
		return false

	if Core.ui.is_ui_visible(&"win"):
		return false

	if Core.ui.is_ui_visible(&"lose"):
		return false

	return true

func _hide_mouse() -> void:
	if not is_paused:
		_toggle_mouse = true

	if Core.ENABLE_MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		if Core.cursor:
			Core.cursor.visible = true

func _show_mouse() -> void:
	if not is_paused:
		_toggle_mouse = false

	if Core.ENABLE_MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		if Core.cursor:
			Core.cursor.visible = false

func _input(event_: InputEvent) -> void:
	if Core.inputs == null:
		if event_ is InputEventJoypadButton or event_ is InputEventJoypadMotion:
			Core.last_input_device = Core.InputDevice.JOYPAD
			Core.last_joypad_device = event_.device
		elif event_ is InputEventKey:
			Core.last_input_device = Core.InputDevice.KEYBOARD
		elif event_ is InputEventMouseButton or event_ is InputEventMouseMotion:
			Core.last_input_device = Core.InputDevice.MOUSE
	else:
		Core.inputs.update(event_)
