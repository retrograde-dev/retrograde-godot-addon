extends Resource
class_name PartyResource

@export var units: Array[PartyUnitResource] = []
@export_range(0, 99, 1, "or_greater", "hide_control") var leader: int = 0:
	get = get_leader,
	set = set_leader
@export_range(0, 99, 1, "or_greater", "hide_control") var active: int = 0:
	get = get_active,
	set = set_active

func get_leader_unit() -> PartyUnitResource:
	if leader > units.size():
		assert(leader < units.size(), "Leader is out of range.")
		return null
		
	return units[leader]

func get_leader() -> int:
	return leader
	
func set_leader(leader_: int) -> void:
	assert(leader_ >= 0 and leader_ < units.size(), "Leader is out of range.")
	
	leader = leader_
	
func get_active() -> int:
	return active
	
func set_active(active_: int) -> void:
	assert(active_ >= 0 and active_ < units.size(), "Active is out of range.")
	active = active_
	
func set_leader_from_unit_alias(unti_alias_: StringName) -> void:
	for index_: int in units.size():
		if units[index_].unit_alias == unti_alias_:
			set_leader(index_)
			return
			
	assert(true, "Unit not found.")
