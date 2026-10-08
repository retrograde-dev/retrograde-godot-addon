extends BaseUnit
class_name ItemUnit

@export var zone_item: ZoneItemResource = null

var item: ItemResource:
	get = get_item

func get_item() -> ItemResource:
	if zone_item == null:
		return null
		
	return zone_item.item
	
var attr: Dictionary = {}:
	get = get_attr,
	set = set_attr

func get_attr() -> Dictionary:
	return zone_item.attr
func set_attr(value_: Dictionary) -> void:
	zone_item.attr = value_
	
func _init() -> void:
	super._init(Core.UnitType.ITEM)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		await _reset_attr()
		
func _reset_attr() -> void:
	if (not item.scene.attr.has(&"tile_set_source_index") and
		not item.scene.attr.has(&"tile_set_atlas_coords")
	):
		return
	
	var tile_map_layer: Node = get_node_or_null("%Item")
	if tile_map_layer is TileMapLayer:
		if tile_map_layer.tile_set:
			tile_map_layer.set_cell(
				Vector2i(0, 0), 
				item.scene.attr.get(&"tile_set_source_index", 0),
				item.scene.attr.get(&"tile_set_atlas_coords", Vector2i(0, 0)),
			)
		else:
			push_warning("Item TileMapLayer does not have a TileSet set. (" + alias + ")")
	
func export(data_: Resource = null) -> Resource:
	if data_ == null:
		data_ = ItemUnitResource.new(
			zone_item.duplicate(true) as ZoneItemResource,
		)
	else:
		assert(data_ is ItemUnitResource, "Invalid resource.")
		
		data_.zone_item = zone_item.duplicate(true) as ZoneItemResource
	
	data_.node = self
	
	super.export(data_)
	
	return data_
	
func import(data_: Resource) -> void:
	assert(data_ is ItemUnitResource, "Invalid resource.")
	
	zone_item = data_.zone_item.duplicate(true) as ZoneItemResource
	
	super.import(data_)
