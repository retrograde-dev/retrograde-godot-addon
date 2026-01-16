extends BaseNode2D

@export var rect: Rect2 = Rect2()
@export var center_offset: float = 0.0
@export var edge_offset: float = 0.5
@export var edge_thickness: float = 0.5
@export var layer: Core.Layer = Core.Layer.NONE

var _center_rect: Rect2
var _up_rect: Rect2
var _down_rect: Rect2
var _left_rect: Rect2
var _right_rect: Rect2

signal body_entered(edge_: Core.Edge, body_: Node2D)
signal body_exited(edge_: Core.Edge, body_: Node2D)

signal area_entered(edge_: Core.Edge, area_: Area2D)
signal area_exited(edge_: Core.Edge, area_: Area2D)

func _ready() -> void:
	if layer == Core.Layer.NONE:
		return
	
	var layer_: int = Core.get_layer_number(layer)
	
	assert(layer_ > 0, "Layer not found. (" + str(layer) + ")")
	
	if layer_ <= 0:
		return
	
	%Area2DCenter.set_collision_layer_value(layer_, true)
	%Area2DCenter.set_collision_mask_value(layer_, true)
	
	%Area2DUp.set_collision_layer_value(layer_, true)
	%Area2DUp.set_collision_mask_value(layer_, true)
	
	%Area2DDown.set_collision_layer_value(layer_, true)
	%Area2DDown.set_collision_mask_value(layer_, true)
	
	%Area2DLeft.set_collision_layer_value(layer_, true)
	%Area2DLeft.set_collision_mask_value(layer_, true)
	
	%Area2DRight.set_collision_layer_value(layer_, true)
	%Area2DRight.set_collision_mask_value(layer_, true)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART 
	):
		_update_areas()
	elif reset_type_ == Core.ResetType.REFRESH:
		_update_areas()

func _update_areas() -> void:
	var rect_: Rect2 = rect
	
	if not rect_.has_area():
		rect_ = _get_parent_collision_rect()
		
		if not rect_.has_area():
			rect_ = Rect2(
				Vector2(-Core.TILE_SIZE / 2, -Core.TILE_SIZE / 2), 
				Vector2(Core.TILE_SIZE, Core.TILE_SIZE)
			)
	
	# Subtract a bit so it will actually be on the tile before triggering
	_center_rect = Rect2(
		rect_.position + Vector2(center_offset, center_offset),
		rect_.size - Vector2(center_offset * 2, center_offset * 2)
	)

	_set_area_shape(
		%Area2DCenter,
		_center_rect.size,
		_center_rect.position + (_center_rect.size * 0.5),
	)

	_set_area_shape(
		%Area2DLeft, 
		Vector2(
			rect_.position.x - edge_offset - edge_thickness * 0.5, 
			rect_.position.y + rect_.size.y * 0.5
		), 
		Vector2(edge_thickness, rect_.size.y)
	)
	
	_set_area_shape(
		%Area2DRight, 
		Vector2(
			rect_.position.x + rect_.size.x + edge_offset + edge_thickness * 0.5, 
			rect_.position.y + rect_.size.y * 0.5
		), 
		Vector2(edge_thickness, rect_.size.y)
	)

	_set_area_shape(
		%Area2DUp, 
		Vector2(
			rect_.position.x + rect_.size.x * 0.5, 
			rect_.position.y - edge_offset - edge_thickness * 0.5
		), 
		Vector2(rect_.size.x, edge_thickness)
	)
	
	_set_area_shape(
		%Area2DDown, 
		Vector2(
			rect_.position.x + rect_.size.x * 0.5, 
			rect_.position.y + rect_.size.y + edge_offset + edge_thickness * 0.5
		), 
		Vector2(rect_.size.x, edge_thickness)
	)
				
func _get_parent_collision_rect() -> Rect2:
	var parent: Node = get_parent()
	
	if parent is BaseCharacterBody2D:
		return parent.get_rect()
		
	if parent is CollisionObject2D:
		return Core.get_collision_rect(parent)
		
	if parent is BaseNode2D:
		var rect_: Rect2 = parent.get_rect()
		if rect_.has_area():
			return rect_
			
		var unit_: BaseUnit = Core.get_root_unit(self)
		if unit_ != null:
			return unit_.get_rect()
	
	return Rect2()

func _set_area_shape(area: Area2D, center: Vector2, size: Vector2) -> void:
	for child: Node in area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			child.shape.size = size
			child.position = center
			return

func get_rect() -> Rect2:
	return rect
	
func set_rect(rect_: Rect2) -> void:
	rect = rect_
	_update_areas()

func get_area_rect(edge_: Core.Edge) -> Rect2:
	if edge_ == Core.Edge.NONE:
		return _center_rect
	elif edge_ == Core.Edge.UP:
		return _up_rect
	elif edge_ == Core.Edge.DOWN:
		return _down_rect
	elif edge_ == Core.Edge.LEFT:
		return _left_rect
	elif edge_ == Core.Edge.RIGHT:
		return _right_rect
		
	return _center_rect
	
func get_collision_shape_2d(edge_: Core.Edge) -> CollisionShape2D:
	var area_: Area2D
	
	if edge_ == Core.Edge.UP:
		area_ = %Area2DUp
	elif edge_ == Core.Edge.DOWN:
		area_ = %Area2DDown
	elif edge_ == Core.Edge.LEFT:
		area_ = %Area2DLeft
	elif edge_ == Core.Edge.RIGHT:
		area_ = %Area2DRight
	else:
		area_ = %Area2DCenter
	
	for child_: Node in area_.get_children():
		if child_ is CollisionShape2D and child_.shape is RectangleShape2D:
			return child_
			
	return null

func _body_entered(edge_: Core.Edge, body_: Node2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(body_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not body_.get_parent().is_ancestor_of(self):
		return

	body_entered.emit(edge_, body_)

func _body_exited(edge_: Core.Edge, body_: Node2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(body_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not body_.get_parent().is_ancestor_of(self):
		return
		
	body_exited.emit(edge_, body_)

func _on_area_2d_center_body_entered(body: Node2D) -> void:
	_body_entered(Core.Edge.NONE, body)

func _on_area_2d_center_body_exited(body: Node2D) -> void:
	_body_exited(Core.Edge.NONE, body)

func _on_area_2d_up_body_entered(body: Node2D) -> void:
	_body_entered(Core.Edge.UP, body)

func _on_area_2d_up_body_exited(body: Node2D) -> void:
	_body_exited(Core.Edge.UP, body)

func _on_area_2d_down_body_entered(body: Node2D) -> void:
	_body_entered(Core.Edge.DOWN, body)

func _on_area_2d_down_body_exited(body: Node2D) -> void:
	_body_exited(Core.Edge.DOWN, body)

func _on_area_2d_left_body_entered(body: Node2D) -> void:
	_body_entered(Core.Edge.LEFT, body)

func _on_area_2d_left_body_exited(body: Node2D) -> void:
	_body_exited(Core.Edge.LEFT, body)

func _on_area_2d_right_body_entered(body: Node2D) -> void:
	_body_entered(Core.Edge.RIGHT, body)

func _on_area_2d_right_body_exited(body: Node2D) -> void:
	_body_exited(Core.Edge.RIGHT, body)

func _area_entered(edge_: Core.Edge, area_: Area2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(area_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not area_.get_parent().is_ancestor_of(self):
		return

	area_entered.emit(edge_, area_)

func _area_exited(edge_: Core.Edge, area_: Area2D) -> void:
	var unit_: BaseUnit = Core.get_root_unit(area_)
	
	if unit_ != null:
		if not unit_.is_ancestor_of(self):
			return
	elif not area_.get_parent().is_ancestor_of(self):
		return
		
	area_exited.emit(edge_, area_)

func _on_area_2d_center_area_entered(area_: Area2D) -> void:
	_area_entered(Core.Edge.RIGHT, area_)

func _on_area_2d_center_area_exited(area_: Area2D) -> void:
	_area_exited(Core.Edge.RIGHT, area_)

func _on_area_2d_up_area_entered(area_: Area2D) -> void:
	_area_entered(Core.Edge.RIGHT, area_)

func _on_area_2d_up_area_exited(area_: Area2D) -> void:
	_area_exited(Core.Edge.RIGHT, area_)

func _on_area_2d_down_area_entered(area_: Area2D) -> void:
	_area_entered(Core.Edge.RIGHT, area_)

func _on_area_2d_down_area_exited(area_: Area2D) -> void:
	_area_exited(Core.Edge.RIGHT, area_)

func _on_area_2d_left_area_entered(area_: Area2D) -> void:
	_area_entered(Core.Edge.RIGHT, area_)

func _on_area_2d_left_area_exited(area_: Area2D) -> void:
	_area_exited(Core.Edge.RIGHT, area_)

func _on_area_2d_right_area_entered(area_: Area2D) -> void:
	_area_entered(Core.Edge.RIGHT, area_)

func _on_area_2d_right_area_exited(area_: Area2D) -> void:
	_area_exited(Core.Edge.RIGHT, area_)
