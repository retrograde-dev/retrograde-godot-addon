class_name SceneValue

var is_path: bool = false
var path: StringName = &""

var is_tile_set_coords: bool = false
var tile_set_coords: Vector2i = Vector2i.ZERO

var is_scale: bool = false
var scale: Vector2 = Vector2.ZERO

func is_equal(scene_value_: SceneValue) -> bool:
	if scene_value_ == null:
		return false
	
	if is_path != scene_value_.is_path:
		return false
	
	if is_path and path != scene_value_.path:
		return false
	
	if is_tile_set_coords != scene_value_.is_tile_set_coords:
		return false
	
	if is_tile_set_coords and tile_set_coords != scene_value_.tile_set_coords:
		return false
	
	if is_scale != scene_value_.is_scale:
		return false
	
	if is_scale and scale != scene_value_.scale:
		return false
	
	return true

func duplicate() -> SceneValue:
	var scene_value_: SceneValue = SceneValue.new()
	
	scene_value_.is_path = is_path
	scene_value_.path = path
	scene_value_.is_tile_set_coords = is_tile_set_coords
	scene_value_.tile_set_coords = tile_set_coords
	scene_value_.is_scale = is_scale
	scene_value_.scale = scale
	
	return scene_value_
