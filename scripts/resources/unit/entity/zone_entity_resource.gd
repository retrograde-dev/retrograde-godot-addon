extends Resource
class_name ZoneEntityResource

@export_storage var id: StringName = &"":
	get = get_id,
	set = set_id
	
@export var entity: EntityResource = null
@export_range(-1, 9999, 1, "or_greater", "hide_control") var count: int = 1
@export var attr: Dictionary = {}

func _init(
	entity_: EntityResource = null,
	count_: int = 1,
	attr_: Dictionary = {}
) -> void:
	entity = entity_
	count = count_
	attr = attr_
	
func get_id() -> StringName:
	if id == &"":
		id = Core.create_id(&"entity_")
	return id
func set_id(id_: StringName) -> void:
	id = id_
