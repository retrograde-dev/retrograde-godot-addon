extends Resource
class_name GameResource

@export_group("Meta")
@export var save_id: int = 0
@export var name: StringName = &""
@export var created: float = 0.0
@export var last_played: float = 0.0
@export var playtime: int = 0

@export_group("Settings")
@export var difficulty: Core.GameDifficulty = Core.GameDifficulty.NORMAL
@export var help: Core.ContentLevel = Core.ContentLevel.MINIMAL
@export var gore: Core.ContentLevel = Core.ContentLevel.FULL
@export var language: Core.ContentLevel = Core.ContentLevel.FULL
@export var sexuality: Core.ContentLevel = Core.ContentLevel.FULL

@export_group("Game")
@export var inventory: Dictionary[StringName, InventoryResource] = {}
@export var state: Dictionary = {}

@export_group("Levels")
@export var level_alias = &""
@export var levels: Dictionary[StringName, LevelResource] = {}

@export_group("Parties")
@export var party_alias: StringName = &""
@export var parties: Dictionary[StringName, PartyResource] = {}

func _init() -> void:
	created = Time.get_unix_time_from_system()

func has_level(level_alias_: StringName) -> bool:
	return levels.has(level_alias_)
	
func get_level(level_alias_: StringName) -> LevelResource:
	return levels.get(level_alias_)

func set_level(level_alias_: StringName, level_: LevelResource) -> void:
	levels.set(level_alias_, level_)
	
func has_zone(level_alias_: StringName, zone_alias_: StringName) -> bool:
	if not has_level(level_alias_):
		return false
	
	if not levels[level_alias_].has_zone(zone_alias_):
		return false
	
	return true
	
func get_zone(level_alias_: StringName, zone_alias_: StringName) -> ZoneResource:
	return levels[level_alias_].zones.get(zone_alias_)

func set_zone(level_alias_: StringName, zone_alias_: StringName, zone_: ZoneResource) -> void:
	levels[level_alias_].zones.set(zone_alias_, zone_)
