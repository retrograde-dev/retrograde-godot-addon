extends ItemUnit
class_name ComponentUnit

var component: Component

func _init(
	component_: Component,
	item_attr_: Dictionary = {},
	item_scene_: SceneResource = null
) -> void:
	super._init()
	
	component = component_

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		component.reset()
		
	await super.reset(reset_type_)


func set_item_attr(item_attr_: Dictionary) -> void:
	super.set_item_attr(item_attr_)

	#TODO: Refactor this out into @export and add component_resource
	if item_attr_.has("orientation"):
		component.set_orientation(item_attr_.orientation)
		
	if item_attr_.has("input_modifier"):
		if component.get_type() == Core.ComponentType.OUTPUT:
			component.get_modifier().set_input_modifier(item_attr_.input_modifier)
		else:
			assert(true, "Output components cannot have input modifiers.")
	
	if item_attr_.has("output_modifier"):
		if component.get_type() == Core.ComponentType.INPUT:
			component.get_modifier().set_output_modifier(item_attr_.output_modifier)
		else:
			assert(true, "Input components cannot have output modifiers.")

func orientate() -> void:
	component.orientate()
