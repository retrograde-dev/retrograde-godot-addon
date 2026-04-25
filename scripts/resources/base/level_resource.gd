extends Resource
class_name LevelResource

@export_group("Meta")
@export var playtime: int = 0

@export_group("Level")
@export var zone_alias: StringName = &""
@export var locks: Dictionary[StringName, LockResource] = {}

@export_subgroup("Parties")
@export var override_parties: bool = false
@export var party_alias: StringName = &""
@export var parties: Dictionary[StringName, PartyResource] = {}

@export_subgroup("Inventory")
@export var override_inventory: bool = false
@export var inventory: Dictionary[StringName, InventoryResource] = {}

@export_group("Zones")
@export var zones: Dictionary[StringName, ZoneResource] = {}

func has_zone(zone_alias_: StringName) -> bool:
	return zones.has(zone_alias_)
	
func get_zone(zone_alias_: StringName) -> ZoneResource:
	return zones.get(zone_alias_)

func set_zone(zone_alias_: StringName, zone_: ZoneResource) -> void:
	zones.set(zone_alias_, zone_)
