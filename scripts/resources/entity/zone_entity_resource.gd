extends Resource
class_name ZoneEntityResource

@export var entity: EntityResource = null
@export_range(-1, 9999, 1, "or_greater", "hide_control") var count: int = 1
@export var meta: Dictionary = {}

func _init(
	entity_: EntityResource = null,
	count_: int = 1,
	meta_: Dictionary = {}
) -> void:
	entity = entity_
	count = count_
	meta = meta_
