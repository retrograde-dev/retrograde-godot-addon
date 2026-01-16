extends UnitActor
class_name RoamActor

var is_roaming: bool:
	get:
		return _is_roaming()
	set(value):
		# Will get updated from events still
		is_in_roam_area = value

var is_in_roam_area: bool = false

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	super._init(unit_, &"roam", enabled_)

func _on_roam_body_entered(_body: Node2D) -> void:
	is_in_roam_area = true

func _on_roam_body_exited(_body: Node2D) -> void:
	is_in_roam_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		if unit.unit_physics == Core.UnitPhysics.PLANE:
			is_in_roam_area = true
		else:
			is_in_roam_area = false
		
		if reset_type_ == Core.ResetType.START:
			_add_areas()

		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()

func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"Roam", Core.Edge.NONE)
	
func _connect_events() -> void:
	unit.connect(&"unit_physics_changed", _on_unit_physics_changed)
	
	var roam_area_: Area2D = unit.get_area_or_null(&"Roam")
	if roam_area_ != null:
		roam_area_.connect(&"body_entered", _on_roam_body_entered)
		roam_area_.connect(&"body_exited", _on_roam_body_exited)
	
func _disconnect_events() -> void:
	unit.disconnect(&"unit_physics_changed", _on_unit_physics_changed)
	
	var roam_area_: Area2D = unit.get_area_or_null(&"Roam")
	if roam_area_ != null:
		roam_area_.disconnect(&"body_entered", _on_roam_body_entered)
		roam_area_.disconnect(&"body_exited", _on_roam_body_exited)

func _on_unit_physics_changed(
	unit_physics_: Core.UnitPhysics, 
	_previous_unit_physics: Core.UnitPhysics
) -> void:
	is_in_roam_area = (unit_physics_ == Core.UnitPhysics.PLANE)

func _is_roaming() -> bool:
	if not is_in_roam_area:
		return false
	
	var climb_actor: BaseActor = unit.get_actor_or_null(&"climb")
	var fall_actor: BaseActor = unit.get_actor_or_null(&"fall")
	
	if climb_actor != null and climb_actor.is_climbing:
		return false
	
	if fall_actor != null and fall_actor.is_in_air:
		return false
	
	return true
