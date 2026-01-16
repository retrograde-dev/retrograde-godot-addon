extends BaseNode2D
class_name FieldController

@onready var area_2d_boxes: Array[Area2D] = [
	%Area2DSpeed,
	%Area2DMove,
]

@export var rect: Rect2 = Rect2()

var _fields: Dictionary

var is_in_field_center_area: bool:
	get:
		return not _fields[&"center"].is_empty()
		
var is_in_field_left_area: bool:
	get:
		return not _fields[&"left"].is_empty()
		
var is_in_field_right_area: bool:
	get:
		return not _fields[&"right"].is_empty()
		
var is_in_field_up_area: bool:
	get:
		return not _fields[&"up"].is_empty()
		
var is_in_field_down_area: bool:
	get:
		return not _fields[&"down"].is_empty()
		
var is_in_field_move_area: bool:
	get:
		return not _fields[&"move"].is_empty()

var is_in_field_speed_area: bool:
	get:
		return not _fields[&"speed"].is_empty()

signal field_entered(filed_value_: FieldValue)
signal field_exited(filed_value_: FieldValue)

func _ready() -> void:
	#%Area2DMove.set_collision_layer_value(Core.get_layer_number(Core.Layer.FIELD_MOVE), true)
	#%Area2DMove.set_collision_mask_value(Core.get_layer_number(Core.Layer.FIELD_MOVE), true)
	#
	#%Area2DSpeed.set_collision_layer_value(Core.get_layer_number(Core.Layer.FIELD_SPEED), true)
	#%Area2DSpeed.set_collision_mask_value(Core.get_layer_number(Core.Layer.FIELD_SPEED), true)
	pass

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART 
	):
		_fields = {
			&"center": {},
			&"left": {},
			&"right": {},
			&"up": {},
			&"down": {},
			&"move": {},
			&"speed": {},
		}
		
		%BoundsField.reset(reset_type_)
		_update_areas()
	elif reset_type_ == Core.ResetType.REFRESH:
		%BoundsField.reset(reset_type_)
		_update_areas()

func get_rect() -> Rect2:
	return rect
	
func set_rect(rect_: Rect2) -> void:
	rect = rect_
	%BoundsField.set_rect(rect_)
	_update_areas()

func _update_areas() -> void:
	var rect_: Rect2 = %BoundsField.get_area_rect(Core.Edge.NONE)
	
	for area_2d: Area2D in area_2d_boxes:
		for child: Node in area_2d.get_children():
			if child is CollisionShape2D and child.shape is RectangleShape2D:
				child.shape.size = rect_.size
				child.position = rect_.position + (rect_.size * 0.5)

func _on_bounds_body_entered(edge_: int, body: Node2D) -> void:
	if edge_ == Core.Edge.NONE:
		_field_entered(&"center", body)
	elif edge_ == Core.Edge.UP:
		_field_entered(&"up", body)
	elif edge_ == Core.Edge.DOWN:
		_field_entered(&"down", body)
	elif edge_ == Core.Edge.LEFT:
		_field_entered(&"left", body)
	elif edge_ == Core.Edge.RIGHT:
		_field_entered(&"right", body)

func _on_bounds_body_exited(edge_: int, body: Node2D) -> void:
	if edge_ == Core.Edge.NONE:
		_field_exited(&"center", body)
	elif edge_ == Core.Edge.UP:
		_field_exited(&"up", body)
	elif edge_ == Core.Edge.DOWN:
		_field_exited(&"down", body)
	elif edge_ == Core.Edge.LEFT:
		_field_exited(&"left", body)
	elif edge_ == Core.Edge.RIGHT:
		_field_exited(&"right", body)

func _on_area_2d_move_body_entered(body: Node2D) -> void:
	_field_entered(&"move", body)

func _on_area_2d_move_body_exited(body: Node2D) -> void:
	_field_exited(&"move", body)

func _on_area_2d_speed_body_entered(body: Node2D) -> void:
	_field_entered(&"speed", body)

func _on_area_2d_speed_body_exited(body: Node2D) -> void:
	_field_exited(&"speed", body)
	
func _field_entered(alias_: StringName, body_: Node2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(body_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not body_.get_parent().is_ancestor_of(self):
		return
		
	var field_value_: FieldValue
	
	if alias_ == &"move":
		field_value_ = _get_move_field_value(alias_, body_)
	elif alias_ == &"speed":
		field_value_ = _get_speed_field_value(alias_, body_)
	else:
		field_value_ = _get_field_field_value(alias_, body_)
	
	_fields[alias_][body_.get_instance_id()] = field_value_

	field_entered.emit(field_value_)

func _field_exited(alias_: StringName, body_: Node2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(body_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not body_.get_parent().is_ancestor_of(self):
		return
		
	var field_value_: FieldValue = null
	
	if _fields[alias_].has(body_.get_instance_id()):
		field_value_ = _fields[alias_][body_.get_instance_id()]
		_fields[alias_].erase(body_.get_instance_id())
		
	field_exited.emit(field_value_)

func _get_field_field_value(alias_: StringName, _body: Node2D) -> FieldValue:
	var field_value_: FieldValue = FieldValue.new(Core.FieldType.BOUNDS)
	
	match alias_:
		&"left":
			field_value_.direction_x = Core.UnitDirection.LEFT
		&"right":
			field_value_.direction_x = Core.UnitDirection.RIGHT
		&"up":
			field_value_.direction_y = Core.UnitDirection.UP
		&"down":
			field_value_.direction_y = Core.UnitDirection.DOWN
	
	return field_value_

func _get_move_field_value(_alias: StringName, body_: Node2D) -> FieldValue:
	var field_value_: FieldValue
	
	if body_ is TileMapLayer:
		field_value_ = _get_field_values(Core.FieldType.MOVE, body_)
	else: 
		field_value_ = FieldValue.new(Core.FieldType.MOVE)
	
	return field_value_

func _get_speed_field_value(_alias: StringName, body_: Node2D) -> FieldValue:
	var field_value_: FieldValue
	
	if body_ is TileMapLayer:
		field_value_ = _get_field_values(Core.FieldType.SPEED, body_)
	else: 
		field_value_ = FieldValue.new(Core.FieldType.SPEED)
	
	return field_value_

func _get_field_values(field_type_: Core.FieldType, tile_map_layer_: TileMapLayer) -> FieldValue:
	var field_value_: FieldValue = FieldValue.new(field_type_)
	
	var rect_: Rect2 = %BoundsField.get_area_rect(Core.Edge.NONE)
	
	var local_rect_: Rect2 = Rect2(
		tile_map_layer_.to_local(to_global(rect_.position)),
		rect_.size
	)
	
	var start_: Vector2i = tile_map_layer_.local_to_map(local_rect_.position)
	var end_: Vector2i = tile_map_layer_.local_to_map(local_rect_.position + local_rect_.size)
	
	for y: int in range(start_.y, end_.y + 1):
		for x: int in range(start_.x, end_.x + 1):
			var coords_: Vector2i = Vector2i(x, y)

			if not _has_tile_physics_layer(field_type_, tile_map_layer_, coords_):
				continue
				
			var data: TileData = tile_map_layer_.get_cell_tile_data(coords_)
			
			if data == null:
				continue
				
			var direction_x: int = data.get_custom_data("direction_x")
			match direction_x:
				-1:
					field_value_.direction_x = Core.UnitDirection.LEFT
				1:
					field_value_.direction_x = Core.UnitDirection.RIGHT
				_:
					field_value_.direction_x = Core.UnitDirection.NONE
					
			var direction_y: int = data.get_custom_data("direction_y")
			match direction_y:
				-1:
					field_value_.direction_y = Core.UnitDirection.UP
				1:
					field_value_.direction_y = Core.UnitDirection.DOWN
				_:
					field_value_.direction_y = Core.UnitDirection.NONE
					
			var speed: int = data.get_custom_data("speed")
			match speed:
				-1:
					field_value_.speed = Core.UnitSpeed.SLOW
				1:
					field_value_.speed = Core.UnitSpeed.FAST
				_:
					field_value_.speed = Core.UnitSpeed.NORMAL

			break
	
	return field_value_

func _has_tile_physics_layer(
	field_type_: Core.FieldType,
	tile_map_layer_: TileMapLayer, 
	coords_: Vector2i,
) -> bool:
	var source_id_: int = tile_map_layer_.get_cell_source_id(coords_)
	if source_id_ == -1:
		return false

	var atlas_coords_: Vector2i = tile_map_layer_.get_cell_atlas_coords(coords_)
	
	var tile_data_: TileSetSource = tile_map_layer_.tile_set.get_source(source_id_).get_tile_data(atlas_coords_, 0)
	if tile_data_ == null:
		return false
		
	var layer_id: int = Core.get_field_layer_id(Core.get_field_layer(field_type_))
	
	if tile_data_.get_collision_polygons_count(layer_id) > 0:
		return true

	#for i in tile_data_.get_collision_polygons_count(layer_id):
		#var shape_ = tile_data_.get_collision_shape(i)
		#
		#if not shape_:
			#continue
			#
		#match field_type_:
			#Core.FieldType.MOVE:
				#if shape_.physics_layer == Core.FIELD_MOVE_LAYER_NUMBER:
					#return true
			#Core.FieldType.SPEED:
				#if shape_.physics_layer == Core.FIELD_SPEED_LAYER_NUMBER:
					#return true
			#_:
				#if shape_.physics_layer == Core.FIELD_LAYER_NUMBER:
					#return true

	return false
