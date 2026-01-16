extends UnitActor
class_name InteractActor

var is_interacting: bool = false

var action_interact: StringName = &"interact"

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"interact", enabled)

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_interacting = false

func process(delta: float) -> void:
	super.process(delta)
	
	if not can_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return
	
	is_interacting = unit.actions.is_just_pressed(action_interact)
	
func get_actions() -> Array[StringName]:
	return [action_interact]
