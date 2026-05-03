extends UnitResource
class_name ItemUnitResource

@export var zone_item: ZoneItemResource = null
@export var meta: Dictionary = {}

var node: Node = null

func _init(
	zone_item_: ZoneItemResource = null,
	meta_: Dictionary = {}
) -> void:
	zone_item = zone_item_
	meta = meta_
