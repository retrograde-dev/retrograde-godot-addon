class_name LevelDoorValue

var alias: StringName
var area_alias: StringName
var unit_position: Vector2
var unit_mode: Core.UnitMode
var meta: Dictionary

func _init(
	alias_: StringName,
	area_alias_: StringName,
	unit_position_: Vector2,
	unit_mode_: Core.UnitMode = Core.UnitMode.NORMAL,
	meta_: Dictionary = {}
) -> void:	
	alias = alias_
	area_alias = area_alias_
	unit_position = unit_position_
	unit_mode = unit_mode_
	meta = meta_
