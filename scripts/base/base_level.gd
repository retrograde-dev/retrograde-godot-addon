extends BaseNode2D
class_name BaseLevel

@export var alias: StringName = &"":
	get = get_alias,
	set = set_alias

var level_type: Core.LevelType = Core.LevelType.PLATFORMER:
	get = get_level_type,
	set = set_level_type
	
var level_mode: Core.LevelMode = Core.LevelMode.GAME:
	get = get_level_mode,
	set = set_level_mode

@export_group("Setup")
@export var initial_zone_alias: StringName = &""
@export var initial_locks: Dictionary[StringName, LockResource] = {}

@export_subgroup("Parties")
@export var override_parties: bool = false
@export var initial_party_alias: StringName = &""
@export var initial_parties: Dictionary[StringName, PartyResource] = {}

@export_subgroup("Inventory")
@export var override_inventory: bool = false
@export var initial_inventory: Dictionary[StringName, InventoryResource] = {}

var data: LevelResource = null
var playtime: PlaytimeTimer = PlaytimeTimer.new()
var auto_start_playtime: bool = true
var auto_stop_playtime: bool = true

var current_zone: BaseZone
var locks: LevelLockSet = LevelLockSet.new()

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		playtime.reset()
		
		if Core.data.has_level(alias):
			data = Core.data.get_level(alias)
			
			if auto_start_playtime:
				playtime.start(data.playtime)
		else:
			data = LevelResource.new()
			data.zone_alias = initial_zone_alias
			data.locks = initial_locks.duplicate(true)
			
			data.override_parties = override_parties
			data.party_alias = initial_party_alias
			data.parties = initial_parties.duplicate(true)
			
			data.override_inventory = override_inventory
			data.inventory = initial_inventory.duplicate(true)
			
			Core.data.set_level(alias, data)
			
			if auto_start_playtime:
				playtime.start()
			
		if data.override_parties:
			Core.parties = data.parties
		else:
			Core.parties = Core.data.parties
			
		if data.override_inventory:
			Core.inventory = data.inventory
		else:
			Core.inventory = Core.data.inventory
		
		await reset_camera()
		await reset_level()
		
		await change_zone(data.zone_alias)
		
		if data.override_parties:
			await Core.game.change_party(data.party_alias)
		else:
			await Core.game.change_party(Core.data.party_alias)
		
		await reset_huds()

func reset_level() -> void:
	await Core.game.reset_cursor()

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

func reset_zone() -> void:
	if current_zone != null:
		Core.nodes.clear_node(current_zone)
		current_zone = null
		Core.zone = null
		
func _process(delta: float) -> void:
	super._process(delta)

	if not is_running():
		return

	if auto_stop_playtime and playtime.is_running():
		if Core.game.is_lose or Core.game.is_win:
			playtime.stop()

func get_alias() -> StringName:
	return alias
func set_alias(value_: StringName) -> void:
	alias = value_

func get_level_type() -> Core.LevelType:
	return level_type
func set_level_type(value_: Core.LevelType) -> void:
	level_type = value_

func get_level_mode() -> Core.LevelMode:
	return level_mode
func set_level_mode(value_: Core.LevelMode) -> void:
	level_mode = value_

func change_zone(zone_alias_: String) -> void:
	if current_zone != null and current_zone.alias == zone_alias_:
		Core.game.start_load()
		await current_zone.restart()
		Core.game.end_load()
		return
		
	Core.game.start_load()
	
	await reset_zone()
	
	var zone_path_: String = "res://scenes/level/" + alias + "/zone/" + zone_alias_ + ".tscn"
	
	var zone_: BaseZone = await Core.nodes.get_node(
		zone_path_,
		func(node_: Node2D, rest_type_: Core.ResetType):
			current_zone = node_
			Core.zone = current_zone
			data.zone_alias = current_zone.alias
	)
	
	Core.game.end_load()

func add_mode(mode_: StringName, add_to_children: bool = false) -> void:
	super.add_mode(mode_)
	
	if add_to_children:
		if current_zone != null:
			current_zone.add_mode(mode_)
	
func remove_mode(mode_: StringName, remove_from_children: bool = false) -> void:
	super.remove_mode(mode_)
			
	if remove_from_children:
		if current_zone != null:
			current_zone.remove_mode(mode_)
