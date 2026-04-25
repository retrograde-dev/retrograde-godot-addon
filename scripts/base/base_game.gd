extends Node
class_name BaseGame

@export var initial_level_alias: StringName = &""
@export var menu_level_alias: StringName = &""

@export_group("New Game")
@export var initial_party_alias: StringName = &""
@export var initial_parties: Dictionary[StringName, PartyResource] = {}
@export var initial_inventory: Dictionary[StringName, InventoryResource] = {}

var data: GameResource = null
var playtime: PlaytimeTimer = PlaytimeTimer.new()

var current_level: BaseLevel = null
var current_party: PartyValue = null
var current_cursor: BaseCursor = null

var is_paused: bool = false
var is_enabled: bool = true
var _toggle_mouse: bool = true

var _load_index: int = 0

var is_lose: bool = false
var _is_lose_handeld: bool = false
var is_win: bool = false
var _is_win_handeld: bool = false
var is_started: bool = false

signal pause_toggled(is_paused: bool)

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

	Core.settings = SettingsFile.new()
	Core.settings.load()

	Core.save = SaveHandler.new()

func _ready() -> void:
	Core.ui = get_node_or_null("%UI")
	Core.hud = get_node_or_null("%HUD")
	Core.camera = get_node_or_null("%Camera")
	
	Core.save.save_before.connect(_on_save_before)
	
	await menu()
	is_started = true

func start() -> void:
	start_load()
	Core.save.delete_save(0, Core.SaveType.RESTART)
	Core.save.delete_save(0, Core.SaveType.CHECKPOINT)
	await reset(Core.ResetType.START)
	end_load()
	
func load_last() -> void:
	start_load()
	
	var data_: GameResource = Core.save.load_last_game()
	if data_ != null:
		data = data_
		Core.data = data
		Core.state = data.state
	
	await reset(Core.ResetType.START)
	
	end_load()
	
func load(
	save_id_: int, 
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> void:
	start_load()

	data = Core.save.load_game(save_id_, save_type_)
	Core.data = data
	Core.state = data.state
	
	await reset(Core.ResetType.START)
	
	end_load()
	
func _on_save_before(save_id_: int, data_: GameResource, save_type_: Core.SaveType) -> void:
	pass
	
func save(
	save_id_: int, 
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> Error:
	#TODO: Save indicator?
	return Core.save.save_game(save_id_, data, save_type_)

func restart() -> void:
	start_load()
	
	if current_level == null or Core.level.level_mode != Core.LevelMode.GAME:
		await start()
	else:
		await reset(Core.ResetType.RESTART)
		
	end_load()

func refresh() -> void:
	await reset(Core.ResetType.REFRESH)

func stop() -> void:
	await reset(Core.ResetType.STOP)

	if Core.EXIT_DELAY > 0.0:
		await get_tree().create_timer(Core.EXIT_DELAY).timeout

	get_tree().quit()

func reset(reset_type_: Core.ResetType) -> void:
	if reset_type_ == Core.ResetType.START:
		_hide_mouse()
		
		await reset_party()
		await reset_level()
		await reset_game()

		Core.nodes.reset()
		Core.help.reset()
		Core.audio.reset()
		Core.speech.reset()
		
		Core.ui.hide_uis(Core.UIType.MENU)
		
		playtime.reset()
		playtime.start(data.playtime)

		await change_level(data.level_alias, Core.LevelMode.GAME)
	elif reset_type_ == Core.ResetType.RESTART:
		_hide_mouse()

		if Core.hud != null:
			await Core.hud.restart()

		if Core.ui != null:
			await Core.ui.restart()

		await reset_party()
		await reset_game()

		Core.nodes.free_all()
		Core.speech.reset()

		Core.ui.hide_uis(Core.UIType.MENU)
		Core.ui.hide_uis(Core.UIType.GAME)
		Core.hud.hide_huds()
		
		var data_: GameResource = Core.save.load_game(
			data.save_id,
			Core.SaveType.RESTART,
		)
		
		if data_ != null:
			data = data_
			
		playtime.reset()
		playtime.start(data.playtime)
		
		if current_level == null or data.level_alias != current_level.alias:
			await change_level(data.level_alias, Core.LevelMode.GAME)
		else:
			await current_level.restart()
	elif reset_type_ == Core.ResetType.REFRESH:
		if Core.hud != null:
			await Core.hud.refresh()

		if Core.ui != null:
			await Core.ui.refresh()
			
		if current_level != null:
			await current_level.refresh()

func menu() -> void:
	start_load()
	
	# Set up a default new game so menus can modify it
	data = GameResource.new()
	data.level_alias = initial_level_alias
	data.party_alias = initial_party_alias
	data.parties = initial_parties.duplicate(true)
	data.inventory = initial_inventory.duplicate(true)
	Core.data = data
	Core.state = data.state

	if is_started:
		await reset_party()
		await reset_level()
		await reset_game()

		Core.nodes.reset()
		Core.help.reset()
		Core.audio.reset()
		Core.speech.reset()

	if is_started:
		_show_mouse()
		Core.ui.hide_uis(Core.UIType.GAME)
		Core.hud.hide_huds()
	else:
		if Core.hud != null:
			await Core.hud.start()

		if Core.ui != null:
			await Core.ui.start()

	await change_level(menu_level_alias, Core.LevelMode.MENU)
	Core.ui.show_ui(&"menu")
	
	end_load()

func reset_game() -> void:
	reset_state()
	reset_win_lose()

func reset_party() -> void:
	if current_party != null:
		await current_party.stop()
		current_party = null
		Core.party = null

func reset_level() -> void:
	%Level.visible = false
	Core.ui.hide_uis(Core.UIType.GAME)
	Core.hud.hide_huds()

	if current_level != null:
		await current_level.stop()
		current_level.started.disconnect(_level_started)
		remove_level_child(current_level)
		current_level.queue_free()
		current_level = null
		Core.level = null
		Core.zone = null

func reset_cursor() -> void:
	if current_cursor != null:
		remove_level_child(current_cursor)
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

func add_level_child(node_: Node2D) -> void:
	if node_.get_parent():
		if node_.get_parent() != %Level:
			node_.reparent(%Level, true)
	else:
		%Level.add_child(node_)

func remove_level_child(node_: Node2D) -> void:
	%Level.remove_child.call_deferred(node_)

func get_level_alias() -> StringName:
	if Core.level == null:
		return &""

	return Core.level.alias

func get_zone_alias() -> StringName:
	if Core.level == null:
		return &""
		
	if Core.zone == null:
		return &""

	return Core.zone.alias

func change_level(
	level_alias_: StringName,
	level_mode_: Core.LevelMode = Core.LevelMode.GAME
) -> void:
	if current_level != null and current_level.alias == level_alias_:
		start_load()
		current_level.set_level_mode(level_mode_)
		await current_level.restart()
		#end_load() is handled by level restarted signal
		return
		
	start_load()
	
	await reset_level()

	var level_path_: String = "res://scenes/level/" + level_alias_ + ".tscn"

	var level_scene_: PackedScene = load(level_path_)

	assert(level_scene_ != null, "Level not found. (" + level_alias_ + ")")

	var level_: BaseLevel = await level_scene_.instantiate()

	add_level_child(level_)

	current_level = level_
	Core.level = level_
	level_.set_level_mode(level_mode_)

	level_.started.connect(_level_started)
	level_.restarted.connect(_level_restarted)

	await level_.start()

	%Level.visible = true
	
	#end_load() is handled by level started signal

func change_party(party_alias_: StringName) -> void:
	if current_party and current_party.alias != party_alias_:
		await current_party.restart()
		return
		
	await reset_party()
		
	current_party = PartyValue.new(party_alias_)
	Core.party = current_party
	
	await current_party.start()

func change_cursor(cursor_alias: StringName) -> void:
	if current_cursor and current_cursor.alias == cursor_alias:
		await current_cursor.restart()
		return

	await reset_cursor()

	var cursor_path: String = "res://scenes/cursor/" + cursor_alias + ".tscn"

	var cursor: BaseCursor = await load(cursor_path).instantiate()

	current_cursor = cursor
	Core.cursor = cursor

	add_level_child(cursor)

	await cursor.start()

func _level_started() -> void:
	Core.save.save_game(data.save_id, data, Core.SaveType.RESTART)
	end_load()
	
func _level_restarted() -> void:
	end_load()

func start_load() -> void:
	if _load_index == 0:
		Core.ui.show_ui(&"loading")
		
		if Core.camera != null:
			Core.camera.position_smoothing_enabled = false
		is_enabled = false
		
	_load_index += 1

func end_load() -> void:
	assert(_load_index > 0, "Load not started.")
	
	if _load_index == 0:
		return
	
	_load_index -= 1
	
	if _load_index == 0:
		if Core.camera != null:
			Core.camera.position_smoothing_enabled = true
		is_enabled = true
		Core.ui.hide_ui(&"loading")

func _process(delta_: float) -> void:
	_handle_pause()

	if not is_enabled:
		return

	playtime.process(delta_)
	if current_level != null:
		current_level.playtime.process(delta_)

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

func pause() -> void:
	if !is_paused:
		toggle_pause()
		
func unpause() -> void:
	if is_paused:
		toggle_pause()
		
func toggle_pause() -> void:
	if is_paused:
		get_tree().paused = false
		is_paused = false
		pause_toggled.emit(is_paused)

		if _toggle_mouse:
			_hide_mouse()

		Core.audio.normal_volume(Core.AudioType.MUSIC)
		Core.audio.normal_volume(Core.AudioType.AMBIANCE)

		Core.ui.hide_uis(Core.UIType.MENU)
	elif _can_pause():
		get_tree().paused = true
		is_paused = true
		pause_toggled.emit(is_paused)

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
