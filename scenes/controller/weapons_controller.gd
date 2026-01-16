extends BaseNode2D
class_name WeaponsController

var uses: Array[AttackValue] = []

var signal_can_use: bool = false

signal use_error(use_index_: int, error_: Core.Error)
signal use_before(use_index_: int)
signal use_after(use_index_: int)
signal use_complete(use_index_: int)

func _ready() -> void:
	var parent: Node = get_parent()
	if parent is BaseUnit:
		parent.unit_mode_changed.connect(_on_unit_mode_changed)
		parent.unit_speed_changed.connect(_on_unit_speed_changed)
		parent.unit_stance_changed.connect(_on_unit_stance_changed)
		parent.unit_movement_changed.connect(_on_unit_movement_changed)
		parent.unit_direction_x_changed.connect(_on_unit_direction_x_changed)
		parent.unit_direction_y_changed.connect(_on_unit_direction_y_changed)
		
	#TODO: Some way of making it easy to add and remove weapons from controller
	#and automatically setup signals
	for child: Node in get_children():
		if child is WeaponUnit:
			child.attack_error.connect(_on_attack_error)
			child.attack_before.connect(_on_attack_before)
			child.attack_after.connect(_on_attack_after)
			child.attack_complete.connect(_on_attack_complete)
		
		
func _on_unit_mode_changed(unit_mode_: Core.UnitMode, _previous_unit_mode: Core.UnitMode) -> void:
	set_unit_mode(unit_mode_)
	
func _on_unit_speed_changed(unit_speed_: Core.UnitSpeed, _previous_unit_speed: Core.UnitSpeed) -> void:
	set_unit_speed(unit_speed_)
	
func _on_unit_stance_changed(unit_stance_: Core.UnitStance, _previous_unit_stance: Core.UnitStance) -> void:
	set_unit_stance(unit_stance_)
	
func _on_unit_movement_changed(unit_movement_: Core.UnitMovement, _previous_unit_movement: Core.UnitMovement) -> void:
	set_unit_movement(unit_movement_)
	
func _on_unit_direction_x_changed(unit_direction_x_: Core.UnitDirection, _previous_unit_direction_x: Core.UnitDirection) -> void:
	set_unit_direction_x(unit_direction_x_)
	
func _on_unit_direction_y_changed(unit_direction_y_: Core.UnitDirection, _previous_unit_direction_y: Core.UnitDirection) -> void:
	set_unit_direction_y(unit_direction_y_)

func _on_attack_error(_weapon: WeaponUnit, attack_: AttackValue, error_: Core.Error) -> void:
	if attack_.meta.has("weapon_controller_use_index"):
		use_error.emit(attack_.meta.weapon_controller_use_index, error_)
	
func _on_attack_before(weapon_: WeaponUnit, attack_: AttackValue) -> void:
	if attack_.meta.has("weapon_controller_use_index"):
		signal_can_use = true
		
		use_before.emit(attack_.meta.weapon_controller_use_index)
		
		if not signal_can_use:
			weapon_.signal_can_attack = false
			
	
func _on_attack_after(_weapon: WeaponUnit, attack_: AttackValue) -> void:
	if attack_.meta.has("weapon_controller_use_index"):
		use_after.emit(attack_.meta.weapon_controller_use_index)
	
func _on_attack_complete(_weapon: WeaponUnit, attack_: AttackValue) -> void:
	if attack_.meta.has("weapon_controller_use_index"):
		use_complete.emit(attack_.meta.weapon_controller_use_index)

func play(animation_name_: StringName) -> void:
	for child: Node in get_children():
		if child is BaseUnit:
			child.play(animation_name_)


func use(use_index_: int) -> bool:
	if not can_use(use_index_):
		return false
	
	var attack: AttackValue = uses[use_index_]
	
	if attack == null:
		return false
		
	match attack.type:
		Core.AttackType.WEAPON:
			for child: Node in get_children():
				if child is WeaponUnit and child.alias == attack.alias:
					child.attack_from_attack_value(
						attack, 
						{"weapon_controller_use_index": use_index_}
					)
					return true
	
	return false
	
func can_use(use_index_: int) -> bool:
	assert(use_index_ >= 0, "Invalid use_index_ value. (" + str(use_index_) + ")")
	
	if use_index_ < 0:
		return false
	
	if use_index_ >= uses.size():
		return false
		
	if uses[use_index_] == null:
		return false
		
	return true
	
func get_use(use_index_: int) -> AttackValue:
	assert(use_index_ >= 0, "Invalid use_index_ value. (" + str(use_index_) + ")")
	
	if use_index_ < 0:
		return null
		
	if use_index_ >= uses.size():
		return null
	
	return uses[use_index_]

func set_use(use_index_: int, attack_: AttackValue) -> void:
	while use_index_ >= uses.size():
		uses.push_back(null)
		
	uses[use_index_] = attack_

		
func set_unit_mode(unit_mode_: Core.UnitMode) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_mode(unit_mode_)

func set_unit_speed(unit_speed_: Core.UnitSpeed) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_speed(unit_speed_)
		
func set_unit_stance(unit_stance_: Core.UnitStance) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_stance(unit_stance_)
		
func set_unit_movement(unit_movement_: Core.UnitMovement) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_movement(unit_movement_)
	
func set_unit_direction_x(unit_direction_x_: Core.UnitDirection) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_direction_x(unit_direction_x_)
		
func set_unit_direction_y(unit_direction_y_: Core.UnitDirection) -> void:
	for child: Node in get_children():
		if child is WeaponUnit:
			child.set_unit_direction_y(unit_direction_y_)
