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
var current_items: Array[ItemUnitResource] = []
var current_entities: Array[EntityUnitResource] = []
var current_players: Array[EntityUnitResource] = []

var music: StringName:
	get = get_music,
	set = set_music
	
var ambiance: StringName:
	get = get_ambiance,
	set = set_ambiance
	
var items: ItemUnitSet = ItemUnitSet.new()
var entities: EntityUnitSet = EntityUnitSet.new()
var players: EntityUnitSet = EntityUnitSet.new()

var actions: ActionHandler
var actors: ActorHandler

signal door_opened(door_: DoorObject)
signal door_closed(door_: DoorObject)

func _ready() -> void:
	super._ready()
	
	if actors != null:
		actors.ready()

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		if reset_type_ == Core.ResetType.START:
			current_items = initial_items.duplicate(true)
			current_entities = initial_entities.duplicate(true)
			current_players = initial_players.duplicate(true)
			
		elif reset_type_ == Core.ResetType.RESTART:
			await items.depopulate_items()
			await entities.depopulate_entities()
			await players.depopulate_entities()
		
		if Core.data.has_zone(Core.level.alias, alias):
			data = Core.data.get_zone(Core.level.alias, alias)
			actors.import(data.actors)
			
			# Remove items since handled by data
			for child_: Node in get_children():
				if child_ is ItemUnit:
					child_.get_parent().remove_child(child_)
				elif child_ is EntityUnit:
					child_.get_parent().remove_child(child_)
		else:
			data = _init_zone_resource()
			data.items = current_items.duplicate(true)
			data.entities = current_entities.duplicate(true)
			data.players = current_players.duplicate(true)
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
		data.actors = actors.export()

func children_reset(reset_type_: Core.ResetType) -> void:
	await super.children_reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		# Add any items in level to data.items
		for child_: Node in get_children():
			if child_ is ItemUnit:
				var item_unit_: ItemUnitResource = child_.export()
				current_items.push_back(item_unit_.duplicate(true))
				data.items.push_back(item_unit_)
				
				Core.game.add_level_child(child_)
			elif child_ is EntityUnit:
				var entity_unit_: EntityUnitResource = child_.export()
				
				if Core.is_player(child_):
					current_players.push_back(entity_unit_.duplicate(true))
					data.players.push_back(entity_unit_)
				else:
					current_entities.push_back(entity_unit_.duplicate(true))
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
	
func start() -> void:
	await super.start()
	
	if actors != null:
		await actors.start()
		
	if actions != null:
		await actions.start()

func restart() -> void:
	await super.restart()
	
	if actors != null:
		await actors.restart()
		
	if actions != null:
		await actions.restart()
		
func refresh() -> void:
	await super.refresh()
	
	if actors != null:
		await actors.refresh()
		
	if actions != null:
		await actions.refresh()
	
func stop() -> void:
	if actions != null:
		await actions.stop()
		
	if actors != null:
		await actors.stop()
	
	await super.stop()
	
func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return

	if actions != null:
		actions.process(delta_)

	if actors != null:
		actors.process(delta_)
	
func _physics_process(delta_: float) -> void:
	super._physics_process(delta_)
	
	if actors == null or not is_running():
		return
		
	actors.physics_process(delta_)

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

func get_actions() -> ActionHandler:
	return actions

func get_actors() -> ActorHandler:
	return actors

func get_actor_or_null(actor_alias_: StringName) -> BaseActor:
	if actors == null:
		return null
		
	if not actors.has(actor_alias_):
		return null
	
	var actor: BaseActor = actors.use(actor_alias_)
	
	if not actor.is_enabled:
		return null
		
	return actor

func _init_zone_resource() -> ZoneResource:
	return ZoneResource.new()
