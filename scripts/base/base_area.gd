extends BaseNode2D
class_name BaseArea

var alias: StringName

signal door_opened(door_alias_: StringName, door_type_: Core.DoorType)
signal door_closed(door_alias_: StringName, door_type_: Core.DoorType)

func _init(alias_: StringName) -> void:
	alias = alias_

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		for child: Node in get_children():
			if child is DoorObject:
				child.connect(&"door_opened", _on_door_opened)
				child.connect(&"door_opened", _on_door_closed)
	elif reset_type_ == Core.ResetType.STOP:
		for child: Node in get_children():
			if child is DoorObject:
				child.disconnect(&"door_opened", _on_door_opened)
				child.disconnect(&"door_opened", _on_door_closed)
	
	reset_area(reset_type_)

func reset_area(_reset_type: Core.ResetType) -> void:
	pass
	
func _on_door_opened(door_alias_: StringName, door_type_: Core.DoorType) -> void:
	door_opened.emit(door_alias_, door_type_)

func _on_door_closed(door_alias_: StringName, door_type_: Core.DoorType) -> void:
	door_closed.emit(door_alias_, door_type_)
