class_name DamageValue

var type: Core.DamageType
var damage: float
var independent: bool
var meta: Dictionary
var one_shot: bool = false
var movement: bool = false
var min_speed: Core.UnitSpeed = Core.UnitSpeed.SLOW
var max_speed: Core.UnitSpeed = Core.UnitSpeed.FAST
var groups: Array[StringName] = []
var node: Node = null

func _init(
	type_: Core.DamageType,
	damage_: float,
	independent_: bool = false,
	meta_: Dictionary = {}
) -> void:
	type = type_
	damage = damage_
	independent = independent_
	meta = meta_
