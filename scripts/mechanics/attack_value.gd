class_name AttackValue

var type: Core.AttackType
var alias: StringName
var attr: Dictionary
var node: Node = null

func _init(
	type_: Core.AttackType,
	alias_: StringName,
	attr_: Dictionary = {}
) -> void:
	type = type_
	alias = alias_
	attr = attr_
