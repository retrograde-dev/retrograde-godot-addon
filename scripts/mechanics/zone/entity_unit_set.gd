class_name EntityUnitSet

var entities: Array[EntityUnitResource] = []:
	get = get_entities,
	set = set_entities

signal add_entity_before(entity_: EntityUnitResource)
signal add_entity_after(entity_: EntityUnitResource)

signal remove_entity_before(entity_: EntityUnitResource)
signal remove_entity_after(entity_: EntityUnitResource)

func populate_entities() -> void:
	for entity_: EntityUnitResource in entities:
		await populate_entity(entity_)
			
func populate_chunk_entities(rect_: Rect2) -> void:
	# TODO: For open world chunk loading
	pass

func depopulate_entities() -> void:
	for entity_: EntityUnitResource in entities:
		await depopulate_entity(entity_)

func depopulate_chunk_entities(rect_: Rect2) -> void:
	# TODO: For open world chunk loading
	pass

func populate_entity(entity_: EntityUnitResource) -> void:
	assert(Core.level != null, "Level is null.")
	
	if Core.level == null:
		return
	
	assert(Core.zone != null, "Level zone is null.")
	
	if Core.zone == null:
		return
	
	if entity_.node != null:
		return
		
	entity_.node = await Core.entities.get_level_entity_unit(
		entity_.zone_entity.entity,
		func(node_: Node, reset_type_: Core.ResetType) -> void:
			node_.import(entity_)
	)

func depopulate_entity(entity_: EntityUnitResource) -> void:
	assert(Core.level != null, "Level is null.")
	
	if Core.level == null:
		return
	
	assert(Core.zone != null, "Level zone is null.")
	
	if Core.zone == null:
		return
		
	if entity_.node != null:
		await Core.nodes.free_node(entity_.node)
		entity_.node = null

func get_entities() -> Array[EntityUnitResource]:
	return entities
	
func set_entities(value_: Array[EntityUnitResource]) -> void:
	entities = value_

func get_entities_from_meta(meta: Dictionary) -> Array[EntityUnitResource]:
	var entities_: Array[EntityUnitResource] = []

	for entity_: EntityUnitResource in entities:
		if Core.dictionary_contains(entity_.meta, meta):
			entities_.push_back(entity_)

	return entities_
	
func get_entity_from_zone_entity(zone_entity_: ZoneEntityResource) -> EntityUnitResource:
	for index_: int in entities.size():
		if entities[index_].zone_entity == zone_entity_:
			return entities[index_]
	
	return null
	
func get_entity_from_entity_alias(entity_alias_: StringName) -> EntityUnitResource:
	for entity_: EntityUnitResource in entities:
		if entity_.zone_entity.entity.alias == entity_alias_:
			return entity_
		
	return null

func get_entity_from_unit_alias(unit_alias_: StringName) -> EntityUnitResource:
	for entity_: EntityUnitResource in entities:
		if entity_.node != null and entity_.node.alias == unit_alias_:
			return entity_
		
	return null

func has_entity(entity_: EntityUnitResource) -> bool:
	for index_: int in entities.size():
		if entities[index_] == entity_:
			return true
			
	return false

func add_entity(entity_: EntityUnitResource) -> void:
	add_entity_before.emit(entity_)

	entities.push_back(entity_)

	await populate_entity(entity_)

	add_entity_after.emit(entity_)

func remove_entity(entity_: EntityUnitResource) -> void:
	for index_: int in entities.size():
		if entities[index_] != entity_:
			continue
			
		remove_entity_before.emit(entities[index_])
		await depopulate_entity(entities[index_])

		var removed_entity_: EntityUnitResource = entities[index_]

		entities.remove_at(index_)

		removed_entity_.node = null
		remove_entity_after.emit(removed_entity_)
		break

func remove_entities() -> void:
	for index_: int in range(entities.size() - 1, -1, -1):
		remove_entity_before.emit(entities[index_])
		await depopulate_entity(entities[index_])

		var removed_entity_: EntityUnitResource = entities[index_]

		entities.remove_at(index_)

		removed_entity_.node = null
		remove_entity_after.emit(removed_entity_)
