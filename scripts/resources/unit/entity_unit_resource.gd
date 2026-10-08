extends UnitResource
class_name EntityUnitResource

@export var zone_entity: ZoneEntityResource = null

var node: Node = null

func _init(zone_entity_: ZoneEntityResource = null) -> void:
	zone_entity = zone_entity_
