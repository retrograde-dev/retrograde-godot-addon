extends Resource
class_name ItemStackResource

@export_range(0, 9999, 1, "or_greater", "hide_control") var stack_size: int = 0
@export var item_mode: Core.ItemMode = Core.ItemMode.SINGLE
@export var merge_infinite: bool = false
@export var add_infinite: bool = false
@export var remove_empty: bool = true
