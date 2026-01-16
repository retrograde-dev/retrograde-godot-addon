extends BaseNode2D

@export var slot: int = 1:
	set(value):
		slot = value
		if get_node_or_null("%UILabelSlot") != null:
			%UILabelSlot.text = str(value)
			
var item: ItemValue = null
var selected: bool = false
var show_slot_label: bool = true

var _item_unit: ItemUnit = null

func _ready() -> void:
	%UILabelSlot.text = str(slot)
	%UILabelSlot.visible = show_slot_label

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART or 
		reset_type_ == Core.ResetType.REFRESH
	):
		_update()
	
func _update() -> void:
	var item_type_: Core.ItemType = Core.ItemType.NONE
	
	var parent: Node = get_parent()
	var item_size_: Vector2 = parent.item_size
	var item_scale_: Vector2 = parent.item_scale
	var label_offset_: Vector2 = parent.item_label_offset
	
	%UILabelSlot.visible = show_slot_label
	%UILabelSlot.position = label_offset_
		
	if item == null:
		%UILabelCount.visible = false
	else:
		%UILabelCount.visible = item.meta.can_stack
	
	if item == null:
		%UILabelCount.text = ""
	elif not item.meta.has("count"):
		%UILabelCount.text = "0"
	elif item.meta.count == -1:
		%UILabelCount.text = "--"
	else:
		%UILabelCount.text = str(item.meta.count)
		
	%UILabelCount.position = item_size_ - label_offset_ - %UILabelCount.size
	
	if item == null:
		if _item_unit != null:
			_item_unit.visible = false
	elif Core.level != null:
		if _item_unit != null:
			if _item_unit.alias == item.alias:
				_item_unit.visible = true
			else:
				await _update_item_unit()
		else:
			await _update_item_unit()

		item_type_ = item.type
		
		_item_unit.scale = item_scale_
		
		var size_: Vector2 = _item_unit.get_scale_rect().size

		_item_unit.position.x = (item_size_.x - size_.x) / 2
		# TODO: Take into consideration item alignment
		_item_unit.position.y = ((item_size_.y - size_.y) / 2)
	else:
		if _item_unit != null:
			_item_unit.visible = false

	var x_coord_: int
	var y_coord_: int
	
	if selected:
		x_coord_ = 2
	else:
		x_coord_ = 0
	
	match item_type_:
		Core.ItemType.NONE:
			y_coord_ = 0
		Core.ItemType.FOOD:
			y_coord_ = 1
		Core.ItemType.HEALTH:
			y_coord_ = 4
		Core.ItemType.HEALTH_FOOD:
			y_coord_ = 3
		_:
			y_coord_ = 2

	%ItemUnder.set_cell(Vector2i(0, 0), %ItemUnder.tile_set.get_source_id(0), Vector2i(x_coord_, y_coord_))
	%ItemOver.set_cell(Vector2i(0, 0), %ItemOver.tile_set.get_source_id(0), Vector2i(x_coord_ + 1, y_coord_))

func _update_item_unit() -> void:
	var node: ItemUnit = await Core.items.get_item_unit(item)
	
	node.collision_layer = 0
	node.collision_mask = 0
	node.z_as_relative = true
	node.z_index = 0
	node.scale = get_parent().item_scale
	
	%ItemUnder.add_sibling(node)
	
	if _item_unit != null:
		_item_unit.queue_free()
	
	_item_unit = node
	
	node.start()
