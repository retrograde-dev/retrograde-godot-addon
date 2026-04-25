extends UnitActor
class_name ItemsActor

var can_select: bool = true
var inventory_alias: StringName = &""
var inventory: InventoryResource:
	get = get_inventory
	
func get_inventory() -> InventoryResource:
	if inventory_alias != &"":
		if not Core.inventory.has(inventory_alias):
			Core.inventory.set(inventory_alias, InventoryResource.new())
			
		return Core.inventory.get(inventory_alias)
	
	if inventory == null:
		inventory = InventoryResource.new()
		
	return inventory

var items: Array[InventoryItemResource]:
	get():
		return inventory.items
	set(value):
		inventory.items = value
		
var slots: int:
	get():
		return inventory.slots
	set(value):
		inventory.slots = value
	
var selected_slot: int:
	get():
		return inventory.selected_slot
	set(value):
		inventory.selected_slot = value
		
var item_types: Array[Core.ItemType] = []
var unit_alignment: Core.Alignment = Core.Alignment.CENTER_CENTER
var item_alignment: Core.Alignment = Core.Alignment.CENTER_CENTER

var drop: DropItemActor
var use: UseItemActor
var pick_up: PickUpItemActor
var swap: SwapItemActor

var is_in_item_area: bool = false
var item_area_items: Array[ItemUnit] = [] # Items within the units item area
var item_position_mode: Core.ItemPositionMode = Core.ItemPositionMode.ENTITY

var select_action_slots: int = 10

var action_next: StringName = &"item_next"
var action_previous: StringName = &"item_previous"
var action_select: StringName = &"item_select_"

func _init(unit_: BaseUnit, enabled_: bool = true) -> void:
	drop = DropItemActor.new(self, unit_, enabled_)
	pick_up = PickUpItemActor.new(self, unit_, enabled_)
	swap = SwapItemActor.new(self, unit_, enabled_)
	use = UseItemActor.new(self, unit_, enabled_)
	
	super._init(unit_, &"items", enabled_)

func reset(reset_type_: Core.ResetType) -> void:
	await super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_in_item_area = false
		item_area_items.clear()
		
		inventory = null
			
		if reset_type_ == Core.ResetType.START:
			_add_areas()
			
		_connect_events()
	elif reset_type_ == Core.ResetType.STOP:
		_disconnect_events()
		
	drop.reset(reset_type_)
	pick_up.reset(reset_type_)
	swap.reset(reset_type_)
	use.reset(reset_type_)
	
func _set_is_enabled(value_: bool) -> void:
	super._set_is_enabled(value_)
	
	drop.is_enabled = value_
	pick_up.is_enabled = value_
	swap.is_enabled = value_
	use.is_enabled = value_

func _set_is_enabled_default(value_: bool) -> void:
	super._set_is_enabled_default(value_)
	
	drop.is_enabled_default = value_
	pick_up.is_enabled_default = value_
	swap.is_enabled_default = value_
	use.is_enabled_default = value_

func _add_areas() -> void:
	var areas_: AreaController = unit.get_areas()
	
	if areas_ == null:
		return
		
	areas_.add_area(&"Item", Core.Edge.NONE)

func _connect_events() -> void:
	var item_area_: Area2D = unit.get_area_or_null(&"Item")
	if item_area_ != null:
		item_area_.connect(&"body_entered", _on_item_body_entered)
		item_area_.connect(&"body_exited", _on_item_body_exited)
	
func _disconnect_events() -> void:
	var item_area_: Area2D = unit.get_area_or_null(&"Item")
	if item_area_ != null:
		item_area_.disconnect(&"body_entered", _on_item_body_entered)
		item_area_.disconnect(&"body_exited", _on_item_body_exited)
	
func process(delta_: float) -> void:
	super.process(delta_)
	
	_process_items(delta_)
	
	use.process(delta_)
	drop.process(delta_)
	swap.process(delta_)
	pick_up.process(delta_)
	
func _process_items(delta_: float) -> void:
	if not can_process():
		return
		
	if not can_unit_process():
		return
		
	if not can_unit_input():
		return
		
	if Core.game.is_win or Core.game.is_lose:
		return
	
	_action_move_selection_next()
	_action_move_selection_previous()
	
	for i: int in select_action_slots:
		_action_select_item(i)

func physics_process(delta_: float) -> void:
	super.physics_process(delta_)

	use.physics_process(delta_)
	drop.physics_process(delta_)
	swap.physics_process(delta_)
	pick_up.physics_process(delta_)

func _on_item_body_entered(body: Node2D) -> void:
	if not body is ItemUnit:
		return
	
	item_area_items.push_back(body)
	is_in_item_area = true

func _on_item_body_exited(body: Node2D) -> void:
	if not body is ItemUnit:
		return
	
	for i: int in item_area_items.size():
		if item_area_items[i] == body:
			item_area_items.remove_at(i)
			break
	
	is_in_item_area = item_area_items.size() > 0

func _action_move_selection_next() -> void:
	if not can_select:
		return

	if not unit.actions.is_just_pressed(action_next, true):
		return
	
	if unit.actions.is_just_pressed(action_previous, true):
		return
		
	move_selection_next()
	
func _action_move_selection_previous() -> void:
	if not can_select:
		return

	if not unit.actions.is_just_pressed(action_previous, true):
		return
	
	if unit.actions.is_just_pressed(action_next, true):
		return
		
	move_selection_previous()

func _action_select_item(slot_: int) -> void:
	if not can_select:
		return
	
	if not unit.actions.is_just_pressed(action_select + str(slot_ + 1), true):
		return
		
	select_item(slot_)
	
func get_item_area_items() -> Array[ItemUnitResource]:
	var items_: Array[ItemUnitResource] = []
	
	if not is_in_item_area:
		return items_
	
	if Core.level == null:
		return items_
	
	for item_: ItemUnitResource in Core.zone.items.get_items():
		if not item_area_items.has(item_.node):
			continue

		if not item_.node.visible:
			continue

		if item_types.size() > 0 and not item_types.has(item_.zone_item.item.item_type):
			continue

		if not item_.node is ItemUnit:
			continue

		if item_position_mode == Core.ItemPositionMode.TILE:
			var unit_position_: Vector2 = ((unit.get_align_global_position(unit_alignment) + drop.drop_offset) / Core.TILE_SIZE).floor()
			var item_position_: Vector2 = (item_.node.get_align_global_position(item_alignment) / Core.TILE_SIZE).floor()
			
			if unit_position_ != item_position_:
				continue
			
		items_.push_back(item_)
		
	return items_
	
func move_selection_next() -> void:
	inventory.move_selection_next()
		
func move_selection_previous() -> void:
	inventory.move_selection_previous()
		
func select_item(slot_: int) -> void:
	inventory.select_item(slot_)
	
func select_item_of_type(type_: Core.ItemType) -> bool:
	return inventory.select_item_of_type(type_)
	
func is_selected_item_of_type(type_: Core.ItemType) -> bool:
	return inventory.is_selected_item_of_type(type_)

func get_slot(inventory_item_: InventoryItemResource) -> int:
	return inventory.get_slot(inventory_item_)
	
func get_item(slot_: int) -> InventoryItemResource:
	return inventory.get_item(slot_)
	
func get_selected_item() -> InventoryItemResource:
	return inventory.get_selected_item()
	
func get_selected_item_type() -> Core.ItemType:
	return inventory.get_selected_item_type()

func get_items_from_alias(alias_: StringName) -> Array[InventoryItemResource]:
	return inventory.get_items_from_alias(alias_)
	
func get_items_from_meta(meta_: Dictionary) -> Array[InventoryItemResource]:
	return inventory.get_items_from_meta(meta_)
	
func get_items_from_type(type_: Core.ItemType) -> Array[InventoryItemResource]:
	return inventory.get_items_from_type(type_)

func can_add_item(
	inventory_item_: InventoryItemResource, 
	merge_: bool = false,
	unselected_: bool = false
) -> bool:
	return inventory.can_add_item(inventory_item_, merge_, unselected_)
	
func add_item(
	inventory_item_: InventoryItemResource, 
	merge_: bool = false,
	unselected_: bool = false,
) -> bool:
	return inventory.add_item(inventory_item_, merge_, unselected_)

func replace_item(slot_: int, inventory_item_: InventoryItemResource) -> void:
	inventory.replace_item(slot_, inventory_item_)
	
func replace_selected_item(inventory_item_: InventoryItemResource) -> void:
	inventory.replace_selected_item(inventory_item_)
	
func remove_item(slot_: int) -> void:
	inventory.remove_item(slot_)
	
func remove_selected_item() -> void:
	inventory.remove_selected_item()

func is_empty() -> bool:
	return inventory.is_empty()

func is_slot_empty(slot_: int) -> bool:
	return inventory.is_slot_empty(slot_)

func is_selected_slot_empty() -> bool:
	return inventory.is_selected_slot_empty()
	
func has_empty() -> bool:
	return inventory.has_empty()

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_next,
		action_previous,
	]
	
	for i: int in select_action_slots:
		actions_.push_back(action_select + str(i + 1))
		
	for action_: StringName in drop.get_actions():
		actions_.push_back(action_)
		
	for action_: StringName in pick_up.get_actions():
		actions_.push_back(action_)
		
	for action_: StringName in swap.get_actions():
		actions_.push_back(action_)
		
	for action_: StringName in use.get_actions():
		actions_.push_back(action_)
		
	return actions_
