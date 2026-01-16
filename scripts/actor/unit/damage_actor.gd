extends UnitActor
class_name DamageActor

var is_in_damage_area: bool = false
var is_in_kill_area: bool = false

# Damage
var area_damage_amount: float = 10.0

var _damage_nodes: Dictionary = {}
var _handled_damage_nodes: Dictionary = {}

var signal_can_damage: bool = false
var signal_damage_handled: bool = false

signal damage_error(reason_: StringName, error_: Core.Error)
signal damage_before(reason_: StringName, damage_value_: DamageValue)
signal damage_after(reason_: StringName, damage_value_: DamageValue)

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"damage", enabled)
	unit_modes.push_back(Core.UnitMode.NORMAL)
	unit_modes.push_back(Core.UnitMode.CLIMBING)

# Damage area
func _on_damage_body_entered(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return

	if _damage_nodes.has(body_.get_instance_id()):
		return

	_damage_nodes[body_.get_instance_id()] = DamageValue.new(
		Core.DamageType.NONE,
		area_damage_amount
	)

	is_in_damage_area = true

func _on_damage_body_exited(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return

	_damage_nodes.erase(body_.get_instance_id())

	if _damage_nodes.is_empty():
		is_in_damage_area = false

func _on_damage_area_entered(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return

	if _damage_nodes.has(area_.get_instance_id()):
		return

	if area_ is Area2DAttack:
		if not area_.can_damage(unit):
			return

		_damage_nodes[area_.get_instance_id()] = area_.get_damage_value()

	is_in_damage_area = true

func _on_damage_area_exited(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return

	_damage_nodes.erase(area_.get_instance_id())
	_handled_damage_nodes.erase(area_.get_instance_id())

	if _damage_nodes.is_empty():
		is_in_damage_area = false

# Kill area
func _on_kill_body_entered(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return

	is_in_kill_area = true

func _on_kill_body_exited(body_: Node2D) -> void:
	if unit.is_ancestor_of(body_):
		return

	is_in_kill_area = false

func _on_kill_area_entered(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return

	is_in_kill_area = true

func _on_kill_area_exited(area_: Area2D) -> void:
	if unit.is_ancestor_of(area_):
		return

	is_in_kill_area = false

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)

	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		is_in_damage_area = false
		is_in_kill_area = false
		_damage_nodes.clear()

		if reset_type_ == Core.ResetType.START:
			_add_areas()

		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()

func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()

	if areas_ == null:
		return

	areas_.add_area(&"Damage", Core.Edge.NONE)
	areas_.add_area(&"Kill", Core.Edge.NONE)

func _connect_events() -> void:
	var damage_area_: Area2D = unit.get_area_or_null(&"Damage")
	if damage_area_ != null:
		damage_area_.connect(&"body_entered", _on_damage_body_entered)
		damage_area_.connect(&"body_exited", _on_damage_body_exited)
		damage_area_.connect(&"area_entered", _on_damage_area_entered)
		damage_area_.connect(&"area_exited", _on_damage_area_exited)

	var kill_area_: Area2D = unit.get_area_or_null(&"Kill")
	if kill_area_ != null:
		kill_area_.connect(&"body_entered", _on_kill_body_entered)
		kill_area_.connect(&"body_exited", _on_kill_body_exited)
		kill_area_.connect(&"area_entered", _on_kill_area_entered)
		kill_area_.connect(&"area_exited", _on_kill_area_exited)

func _disconnect_events() -> void:
	var damage_area_: Area2D = unit.get_area_or_null(&"Damage")
	if damage_area_ != null:
		damage_area_.disconnect(&"body_entered", _on_damage_body_entered)
		damage_area_.disconnect(&"body_exited", _on_damage_body_exited)
		damage_area_.disconnect(&"area_entered", _on_damage_area_entered)
		damage_area_.disconnect(&"area_exited", _on_damage_area_exited)

	var kill_area_: Area2D = unit.get_area_or_null(&"Kill")
	if kill_area_ != null:
		kill_area_.disconnect(&"body_entered", _on_kill_body_entered)
		kill_area_.disconnect(&"body_exited", _on_kill_body_exited)
		kill_area_.disconnect(&"area_entered", _on_kill_area_entered)
		kill_area_.disconnect(&"area_exited", _on_kill_area_exited)

func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return

	if not can_unit_process():
		return

	if is_in_damage_area:
		for instance_id_: int in _damage_nodes:
			if _handled_damage_nodes.has(instance_id_):
				continue

			var value: Variant = _damage_nodes[instance_id_]

			if value.movement and not unit.is_moving():
				continue

			match value.min_speed:
				Core.UnitSpeed.NORMAL:
					if unit.unit_speed == Core.UnitSpeed.SLOW:
						continue
				Core.UnitSpeed.FAST:
					if unit.unit_speed != Core.UnitSpeed.FAST:
						continue

			match value.max_speed:
				Core.UnitSpeed.SLOW:
					if unit.unit_speed != Core.UnitSpeed.SLOW:
						continue
				Core.UnitSpeed.NORMAL:
					if unit.unit_speed == Core.UnitSpeed.FAST:
						continue

			if value.independent:
				_handled_damage_nodes.set(instance_id_, true)

			signal_can_damage = true
			signal_damage_handled = false

			damage_before.emit(&"damage_area", value)

			if signal_can_damage == false:
				damage_error.emit(&"damage_area", Core.Error.GAME_RESTRICTION)
				continue

			if not signal_damage_handled and not _damage(value):
				damage_error.emit(&"damage_area", Core.Error.UNHANDLED)
				continue
			# TODO: Damage area alias, and way to specify health actor not to die if 0
			# so that the object doing the damage can handle the kill reason
			damage_after.emit(&"damage_area", value)

	if is_in_kill_area:
		# TODO: Kill area similar to damage area with alias to know how to kill
		kill_unit(&"kill_area")

func _damage(damage_value_: DamageValue) -> bool:
	damage_unit(damage_value_.damage, damage_value_.independent)
	return true
