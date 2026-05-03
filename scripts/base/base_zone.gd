extends BaseNode2D
class_name BaseZone

@export var alias: StringName = &"":
	get = get_alias,
	set = set_alias

@export_group("Setup")
@export var initial_items: Array[ItemUnitResource] = []
@export var initial_entities: Array[EntityUnitResource] = []
@export var initial_players: Array[EntityUnitResource] = []
@export var initial_music: StringName = &""
@export var initial_ambiance: StringName = &""

var data: ZoneResource = null

var music: StringName:
	get = get_music,
	set = set_music
	
var ambiance: StringName:
	get = get_ambiance,
	set = set_ambiance
	
var items: ItemUnitSet = ItemUnitSet.new()
var entities: EntityUnitSet = EntityUnitSet.new()
var players: EntityUnitSet = EntityUnitSet.new()

signal door_opened(door_: DoorObject)
signal door_closed(door_: DoorObject)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		if Core.data.has_zone(Core.level.alias, alias):
			data = Core.data.get_zone(Core.level.alias, alias)
			
			# Remove items since handled by data
			for child_: Node in get_children():
				if child_ is ItemUnit:
					child_.parent.remove_child(child_)
				elif child_ is EntityUnit:
					child_.parent.remove_child(child_)
		else:
			data = ZoneResource.new()
			data.items = initial_items.duplicate(true)
			data.entities = initial_entities.duplicate(true)
			data.players = initial_players.duplicate(true)
			data.music = initial_music
			data.ambiance = initial_ambiance
			
			Core.data.set_zone(Core.level.alias, alias, data)
		
		if music != &"":
			Core.audio.play_music(music)
		else: 
			Core.audio.stop_music()
			
		if ambiance != &"":
			Core.audio.play_ambiance(ambiance)
		else: 
			Core.audio.stop_ambiance()
	elif reset_type_ == Core.ResetType.STOP:
		await items.depopulate_items()
		await entities.depopulate_entities()
		await players.depopulate_entities()
		
func children_reset(reset_type_: Core.ResetType) -> void:
	await super.children_reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		# Add any items in level to data.items
		for child_: Node in get_children():
			if child_ is ItemUnit:
				var item_unit_: ItemUnitResource = child_.export()
				initial_items.push_back(item_unit_.duplicate(true))
				data.items.push_back(item_unit_)
				
				Core.game.add_level_child(child_)
			elif child_ is EntityUnit:
				var entity_unit_: EntityUnitResource = child_.export()
				
				if Core.is_player(child_):
					initial_players.push_back(entity_unit_.duplicate(true))
					data.players.push_back(entity_unit_)
				else:
					initial_entities.push_back(entity_unit_.duplicate(true))
					data.entities.push_back(entity_unit_)
				
				Core.game.add_level_child(child_)
			elif child_ is DoorObject:
				child_.connect(&"door_opened", _on_door_opened)
				child_.connect(&"door_opened", _on_door_closed)
		
		items.set_items(data.items)
		entities.set_entities(data.entities)
		players.set_entities(data.players)
		
		await items.populate_items()
		await entities.populate_entities()
		await players.populate_entities()
	elif reset_type_ == Core.ResetType.STOP:
		for child: Node in get_children():
			if child is DoorObject:
				child.disconnect(&"door_opened", _on_door_opened)
				child.disconnect(&"door_opened", _on_door_closed)

func _on_door_opened(door_: DoorObject) -> void:
	door_opened.emit(door_)

func _on_door_closed(door_: DoorObject) -> void:
	door_closed.emit(door_)

func get_alias() -> StringName:
	return alias
func set_alias(value_: StringName) -> void:
	alias = value_

func get_music() -> StringName:
	return data.music
func set_music(value_: StringName) -> void:
	data.music = value_
	
func get_ambiance() -> StringName:
	return data.ambiance
func set_ambiance(value_: StringName) -> void:
	data.ambiance = value_
