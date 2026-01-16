class_name AttackValue

var type: Core.AttackType
var alias: StringName
var meta: Dictionary
var node: Node = null

func _init(
	type_: Core.AttackType,
	alias_: StringName,
	meta_: Dictionary = {}
) -> void:
	type = type_
	alias = alias_
	meta = meta_
