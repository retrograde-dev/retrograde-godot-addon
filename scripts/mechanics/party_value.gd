class_name PartyValue

var alias: StringName
var _party: PartyResource

func _init(alias_: StringName) -> void:
	alias = alias_
	_party = Core.parties.get(alias_, null)

func start() -> void:
	_set_party_inventories()
	
	var unit_: PartyUnitResource = _party.get_leader_unit()
	
	assert(unit_ != null, "Leader not found.")
	
	if unit_ == null:
		return
	
	var entity_unit_: EntityUnitResource = Core.zone.players.get_entity_from_unit_alias(unit_.unit_alias)
	
	if entity_unit_ == null:
		return
		
	Core.player = entity_unit_.node
	Core.player.add_to_group(&"input")
		
	if Core.camera != null:
		Core.camera.set_target(Core.player)

func restart() -> void:
	pass
	
func refresh() -> void:
	pass
	
func stop() -> void:
	pass

func select_next_unit() -> void:
	pass
	
func select_previous_unit() -> void:
	pass
	
func select_unit(index_: int) -> void:
	pass

func set_leader(leader_: int) -> void:
	assert(leader_ >= 0 and leader_ < _party.units.size(), "Leader is out of range.")
	
	if leader_ < 0 or leader_ >= _party.units.size():
		return
		
	_party.leader = leader_
	
func set_leader_from_unit_alias(unit_alias_: StringName) -> void:	
	for index_: int in _party.units.size():
		if _party.units[index_].unit_alias == unit_alias_:
			set_leader(index_)
			break
			
	assert(true, "Unit not found. (" + unit_alias_ + ")")

func _set_party_inventories() -> void:
	for unit_: PartyUnitResource in _party.units:
		if unit_.inventory_alias == &"":
			continue
			
		var entity_unit_: EntityUnitResource = Core.zone.players.get_entity_from_unit_alias(unit_.unit_alias)
		
		if entity_unit_ == null:
			continue
		
		entity_unit_.node.items.inventory_alias = unit_.inventory_alias
	
#func reset_player() -> void:
	#if current_player != null:
		#await current_player.stop()
		#remove_level_child(current_player)
		#current_player.queue_free()
		#current_player = null
		#Core.player = null
#func change_player(player_alias_: StringName) -> void:
	#if current_player and current_player.alias == player_alias_:
		#await current_player.restart()
		#return
#
	#await reset_player()
#
	#var player_path_: String = "res://scenes/unit/player/" + player_alias_ + ".tscn"
#
	#var player_resource_: Resource = load(player_path_)
#
	#assert(player_resource_ != null, "Player not found. (" + player_alias_ + ")")
#
	#if player_resource_ == null:
		#return
#
	#var player_: EntityUnit = await player_resource_.instantiate()
#
	#add_level_child(player_)
	#current_player = player_
	#Core.player = player_
#
	#await player_.start()
