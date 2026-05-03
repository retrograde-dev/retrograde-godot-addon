extends UnitResource
class_name EntityUnitResource

@export var zone_entity: ZoneEntityResource = null
@export var meta: Dictionary = {}

var node: Node = null

func _init(
	zone_entity_: ZoneEntityResource = null,
	meta_: Dictionary = {}
) -> void:
	zone_entity = zone_entity_
	meta = meta_
