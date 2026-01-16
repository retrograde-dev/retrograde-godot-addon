extends BaseNode2D
class_name BaseLevel

var alias: StringName
var level_type: Core.LevelType
var level_mode: Core.LevelMode = Core.LevelMode.GAME

var _start_time: int = 0
var _stop_time: int = 0
var _pause_delta: float = 0.0
var auto_start_play_time: bool = true
var auto_stop_play_time: bool = true

var area: BaseArea
var items: LevelItemSet
var locks: LevelLockSet
var doors: LevelDoorSet

var data: LevelData

func _init(alias_: StringName, level_type_: Core.LevelType = Core.LevelType.PLATFORMER) -> void:
	alias = alias_
	level_type = level_type_
	
	data = LevelData.new(alias_)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		if auto_start_play_time:
			_start_time = Time.get_ticks_msec()
		else:
			_start_time = 0
		_stop_time = 0
		_pause_delta = 0.0
		
		reset_camera()
		reset_area()
		reset_level()
	
		items = LevelItemSet.new(self)
		locks = LevelLockSet.new(self)
		doors = LevelDoorSet.new(self)
		
		if data.level.data.has(&"player"):
			await Core.game.change_player(data.level.data.player.alias)
			
			if data.level.data.player.has(&"items"):
				for item_: Dictionary in data.level.data.player.items:
					var item_value_: ItemValue = null
					
					if Core.items.has_item(item_.alias):
						item_value_ = Core.items.get_item_value(item_.alias)
				
					if item_value_ != null:
						item_value_ = item_value_.duplicate()
						item_value_.meta.count = item_.count if item_.has("count") else 1
						Core.player.items.add_item(item_value_)
			
			await change_player_area(
				data.level.data.area.alias,
				data.level.data.player.position,
				data.level.data.player.mode,
				data.level.data.player.physics,
			)
		
		
		reset_huds()

func reset_level() -> void:
	Core.game.reset_cursor()

func reset_huds() -> void:
	Core.hud.hide_huds()
	
func reset_camera() -> void:
	if Core.camera == null:
		return

	if level_mode == Core.LevelMode.MENU:
		Core.camera.zoom.x = Core.MENU_CAMERA_ZOOM
		Core.camera.zoom.y = Core.MENU_CAMERA_ZOOM
		Core.camera.target_offset = Core.MENU_CAMERA_TARGET_OFFSET
	else:
		Core.camera.zoom.x = Core.LEVEL_CAMERA_ZOOM
		Core.camera.zoom.y = Core.LEVEL_CAMERA_ZOOM
		Core.camera.target_offset = Core.LEVEL_CAMERA_TARGET_OFFSET

	Core.camera.target_offset_rotation_enabled = true
	Core.camera.limit_smoothed = true
	Core.camera.position_smoothing_enabled = true
	Core.camera.enabled = true
	Core.camera.make_current()

func reset_area() -> void:
	if area != null:
		if area is BaseArea:
			area.door_opened.disconnect(_on_door_opened)
			
		items.depopulate_area_items(area.alias)
		Core.nodes.clear_node(area)
		area = null
		
func _process(delta: float) -> void:
	super._process(delta)

	if not is_running():
		return

	if auto_stop_play_time and _stop_time == 0:
		if Core.game.is_lose or Core.game.is_win:
			_stop_time = Time.get_ticks_msec()

	if Core.game.is_paused and _start_time != 0 and _stop_time == 0:
		_pause_delta += delta

func set_level_type(level_type_: Core.LevelType) -> void:
	level_type = level_type_

func set_level_mode(level_mode_: Core.LevelMode) -> void:
	level_mode = level_mode_

func get_play_time() -> int:
	if _start_time == 0:
		return 0

	if _stop_time == 0:
		return Time.get_ticks_msec() - _start_time - round(_pause_delta)

	return _stop_time - _start_time - round(_pause_delta)
	
func start_play_time() -> void:
	_start_time = Time.get_ticks_msec()

func stop_play_time() -> void:
	_stop_time = Time.get_ticks_msec()

func set_play_time(time_miliseconds_: int) -> void:
	_stop_time = time_miliseconds_ + _start_time + round(_pause_delta)

func change_player_area(
	area_alias_: String, 
	unit_position_: Vector2 = Vector2.ZERO,
	unit_mode_: Core.UnitMode = Core.UnitMode.NONE,
	unit_physics_: Core.UnitPhysics = Core.UnitPhysics.PLATFORM
) -> void:
	assert(Core.player != null, "Player not set.")
	
	if Core.player == null:
		return
		
	Core.game.start_load()
	
	reset_area()
	
	# Disable player
	Core.player.timeout(Core.MIN_COLLISION_WAIT_DELTA)
	Core.player.position = unit_position_
	
	var area_: Dictionary = data.areas.get_area(area_alias_)
	
	var scene: String
	
	if area_.has("scene"):
		scene = area_.scene
	else:
		scene = "res://scenes/level/" + alias + "/area/" + area_.alias + ".tscn"
	
	var node: BaseArea = await Core.nodes.get_node(scene)
	
	area = node
	
	area.alias = area_.alias
	area.position = Vector2.ZERO
	
	if area is BaseArea:
		area.door_opened.connect(_on_door_opened)
	
	items.populate_area_items(area_.alias)
	
	if area_.has("music") and area_.music != null:
		Core.audio.play_music(area_.music)
	else: 
		Core.audio.stop_music()
		
	if area_.has("ambiance") and area_.ambiance != null:
		Core.audio.play_ambiance(area_.ambiance)
	else: 
		Core.audio.stop_ambiance()
	
	# TODO: These are pretty game specific, either normalize or allow 
	# override of this type of thing
	#Core.game.is_outside = area_.has("outside") and area_.outside
	#Core.game.is_lightning = area_.has("lightning") and area_.lightning
	
	Core.player.set_unit_mode(unit_mode_)
	
	Core.player.set_unit_physics(unit_physics_)
	
	Core.camera.set_target(Core.player)
	
	Core.game.end_load()

func change_player_area_zoom(
	area_name_: String, 
	unit_position_: Vector2 = Core.DEAD_ZONE,
	unit_mode_: Core.UnitMode = Core.UnitMode.NONE,
	unit_physics_: Core.UnitPhysics = Core.UnitPhysics.PLATFORM
) -> void:
	# TODO: add effect that pauses engine, zooms in 
	# player camera, then switches area
	change_player_area(area_name_, unit_position_, unit_mode_, unit_physics_)

func add_mode(mode_: StringName, add_to_children: bool = false) -> void:
	super.add_mode(mode_)
	
	if add_to_children:
		if area != null:
			area.add_mode(mode_)
	
func remove_mode(mode_: StringName, remove_from_children: bool = false) -> void:
	super.remove_mode(mode_)
			
	if remove_from_children:
		if area != null:
			area.remove_mode(mode_)

func _on_door_opened(door_alias_: StringName, _door_type: Core.DoorType) -> void:
	if door_alias_ == &"":
		return

	var door: LevelDoorValue = doors.get_door(door_alias_)
	if door == null:
		return
		
	change_player_area(door.area_alias, door.unit_position, door.unit_mode)
