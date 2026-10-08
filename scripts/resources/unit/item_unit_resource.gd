extends UnitResource
class_name ItemUnitResource
	
@export var zone_item: ZoneItemResource = null

var node: Node = null

func _init(zone_item_: ZoneItemResource = null) -> void:
	zone_item = zone_item_
