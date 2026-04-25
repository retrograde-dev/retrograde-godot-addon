extends BaseUnit
class_name ItemUnit

@export var zone_item: ZoneItemResource = null
@export var meta: Dictionary = {}

var item: ItemResource:
	get = get_item

func get_item() -> ItemResource:
	if zone_item == null:
		return null
		
	return zone_item.item

func _init() -> void:
	super._init(Core.UnitType.ITEM)
	
	self.visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		for child: Node in get_children():
			if child is CollisionShape2D:
				child.disabled = false
	else:
		for child: Node in get_children():
			if child is CollisionShape2D:
				child.disabled = true
				
func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		_update_tile_set_coords()
		
func _update_tile_set_coords() -> void:
	if not item.scene.is_tile_set:
		return
	
	var item_tile_map_layer: Node = get_node_or_null("%Item")
	if item_tile_map_layer is TileMapLayer:
		if item_tile_map_layer.tile_set:
			item_tile_map_layer.set_cell(
				Vector2i(0, 0), 
				item.scene.tile_set_source_index,
				item.scene.tile_set_atlas_coords
			)
		else:
			push_warning("Item TileMapLayer does not have a TileSet set. (" + alias + ")")
	
func export(data_: Resource = null) -> Resource:
	if data_ == null:
		data_ = ItemUnitResource.new(
			zone_item.duplicate(true) as ZoneItemResource
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
	
	_update_tile_set_coords()
	
	super.import(data_)
