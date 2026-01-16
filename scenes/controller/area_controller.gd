extends BaseNode2D
class_name AreaController

#@export_category("Directional Areas")
#@export var area_up: bool = false
#@export var area_down: bool = false
#@export var area_left: bool = false
#@export var area_right: bool = false
#@export var area_center: bool = false

var _areas: Dictionary = {}
var _queue_areas: Dictionary = {}

func get_area(area_name_: StringName) -> Area2D:
	var area: Area2D = get_node_or_null("%Area2D" + area_name_)
	if area != null:
		return area
		
	if _queue_areas.has(area_name_):
		_add_area_internal(area_name_, _queue_areas[area_name_])
		_queue_areas.erase(area_name_)
		
	if _areas.has(area_name_):
		return _areas[area_name_].area
		
	return null
	
func add_area(area_name_: StringName, edge_: Core.Edge) -> void:
	_queue_areas[area_name_] = edge_

func _add_area_internal(area_name_: StringName, edge_: Core.Edge) -> void:
	var area_: Area2D 
	
	if _areas.has(area_name_):
		area_ = _areas[area_name_].area
		
		for child: Node in area_.get_children():
			if child is CollisionShape2D:
				area_.remove_child(child)
				break
	else:
		area_ = Area2D.new()
		add_child(area_)
		
	area_.add_child(%Bounds.get_collision_shape_2d(edge_))
		
	_areas[area_name_] = {
		&"edge": edge_,
		&"area": area_
	}

func remove_area(area_name_: StringName) -> void:
	if _areas.has(area_name_):
		remove_child(_areas[area_name_].area)
		_areas.erase(area_name_)
	
	if _queue_areas.has(area_name_):
		_queue_areas.erase(area_name_)
	
