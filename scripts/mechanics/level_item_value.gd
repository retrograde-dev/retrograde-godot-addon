class_name LevelItemValue

var item: ItemValue
var area_alias: StringName
var position: Vector2
var meta: Dictionary

var _visible: bool = true
var visible: bool:
	get:
		return _visible
	set(value):
		_visible = value
		
		if node != null:
			node.visible = value
		
var node: Node = null

func _init(
	item_: ItemValue,
	area_alias_: StringName,
	position_: Vector2,
	meta_: Dictionary = {}
) -> void:	
	item = item_
	area_alias = area_alias_
	position = position_
	meta = meta_
