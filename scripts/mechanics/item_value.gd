class_name ItemValue

var alias: StringName
var type: Core.ItemType
var meta: Dictionary
var scene: SceneValue

func _init(
	alias_: StringName,
	type_: Core.ItemType,
	meta_: Dictionary = {},
	scene_: SceneValue = null
) -> void:
	alias = alias_
	type = type_
	meta = meta_
	scene = scene_

func is_equal(item_value_: ItemValue) -> bool:
	if item_value_ == null:
		return false
		
	if alias != item_value_.alias:
		return false
	
	if type != item_value_.type:
		return false
	
	# TODO: Decide if it makes sense to exclud certain known meta values (ex. count)
	if meta != item_value_.meta:
		return false
		
	if scene == null:
		if item_value_.scene != null:
			return false
	elif not scene.is_equal(item_value_.scene):
		return false
	
	return true

func duplicate() -> ItemValue:
	return ItemValue.new(alias, type, meta.duplicate(), scene.duplicate())
