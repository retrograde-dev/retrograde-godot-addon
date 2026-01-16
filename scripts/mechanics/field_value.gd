class_name FieldValue

var type: Core.FieldType = Core.FieldType.NONE
var direction_x: Core.UnitDirection = Core.UnitDirection.NONE
var direction_y: Core.UnitDirection = Core.UnitDirection.NONE
var speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL

func _init(type_: Core.FieldType) -> void:
	type = type_
