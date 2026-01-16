class_name WeaponAttack

var alias: StringName
var delta: float

func _init(
	alias_: StringName,
	delta_: float = 0.0,
) -> void:
	alias = alias_
	delta = delta_
