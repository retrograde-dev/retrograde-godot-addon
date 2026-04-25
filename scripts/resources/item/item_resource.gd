extends Resource
class_name ItemResource

@export var alias: StringName = &""
@export var item_type: Core.ItemType = Core.ItemType.NONE
@export var meta: Dictionary = {}
@export var scene: ItemSceneResource = null

@export_group("Item Types")
@export var component_item_type: Array[Core.ComponentType] = []
@export var consume_item_type: Array[Core.ConsumeType] = []
@export var loot_item_type: Array[Core.LootType] = []
@export var spell_item_type: Array[Core.SpellType] = []
@export var trap_item_type: Array[Core.TrapType] = []
@export var tool_item_type: Array[Core.ToolType] = []

@export_group("Inventory")
@export var can_pick_up: bool = true
@export var can_drop: bool = true
@export var can_discard: bool = true
@export_range(1, 9999, 1, "or_greater", "hide_control") var max_stacks: int = 1
@export_range(0.0, 1000.0, 1.0, "or_greater", "hide_control") var weight: float = 1.0

@export_group("Stacking")
@export var inventory_stack: ItemStackResource = null
@export var zone_stack: ItemStackResource = null

func _init() -> void:
	inventory_stack = ItemStackResource.new()
	zone_stack = ItemStackResource.new()
