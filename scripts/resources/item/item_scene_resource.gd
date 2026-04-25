extends Resource
class_name ItemSceneResource

@export_file("*.tscn") var path: String = ""

@export var is_tile_set: bool = false
@export var tile_set_source_index: int = 0
@export var tile_set_atlas_coords: Vector2i = Vector2i.ZERO
