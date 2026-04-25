extends UnitActor
class_name CollisionActor

var is_colliding: bool = false

var collision_mode: Core.CollisionMode = Core.CollisionMode.NONE
var collision_damage_amount: float = 10.0

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"collision", enabled)
	unit_modes.push_back(Core.UnitMode.NORMAL)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_colliding = false

func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
	
	if not can_unit_process():
		return
		
	if collision_mode == Core.CollisionMode.NONE:
		return
		
	is_colliding = unit.get_slide_collision_count() > 0
	if not is_colliding:
		return

	if collision_mode == Core.CollisionMode.DAMAGE:
		damage_unit(collision_damage_amount)
		return
		
	kill_unit(&"collision")
	
func export() -> Dictionary[StringName, Variant]:
	var data: Dictionary[StringName, Variant] = super.export()
	
	data.merge({
		&"collision_mode": collision_mode,
		&"collision_damage_amount": collision_damage_amount,
	})
	
	return data
	
func import(data: Dictionary[StringName, Variant]) -> void:
	super.import(data)
	
	collision_mode = data.get(&"collision_mode", collision_mode)
	collision_damage_amount = data.get(&"collision_damage_amount", collision_damage_amount)
