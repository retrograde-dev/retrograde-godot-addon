extends ItemUnit
class_name ComponentUnit

var component: Component

func _init(
	alias_: StringName,
	component_: Component,
	item_meta_: Dictionary = {},
	item_scene_: SceneValue = null
) -> void:
	super._init(alias_, Core.ItemType.COMPONENT, item_meta_, item_scene_)
	
	component = component_

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		component.reset()
		
	super.reset(reset_type_)


func set_item_meta(item_meta_: Dictionary) -> void:
	super.set_item_meta(item_meta_)

	if item_meta_.has("orientation"):
		component.set_orientation(item_meta_.orientation)
		
	if item_meta_.has("input_modifier"):
		if component.get_type() == Core.ComponentType.OUTPUT:
			component.get_modifier().set_input_modifier(item_meta_.input_modifier)
		else:
			assert(true, "Output components cannot have input modifiers.")
	
	if item_meta_.has("output_modifier"):
		if component.get_type() == Core.ComponentType.INPUT:
			component.get_modifier().set_output_modifier(item_meta_.output_modifier)
		else:
			assert(true, "Input components cannot have output modifiers.")

func orientate() -> void:
	component.orientate()
