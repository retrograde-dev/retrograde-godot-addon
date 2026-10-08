extends Resource
class_name ItemProviderValue

@export var items: Array[ItemResource] = []
@export var behavior: ProviderBehavior = null

var _current_items: Array[ItemResource]
var _current_count: int

func _init(
	items_: Array[ItemResource] = [],
	behavior_: ProviderBehavior = null
) -> void:
	items = items_
	
	if behavior_ == null:
		# Get in order until empty
		behavior = ProviderBehavior.new(
			false, # Random
			true, # Remove
			false, # Repeat
		)
	else:
		behavior = behavior_
	
	if behavior.count > 0:
		assert(behavior.count <= items.size(), "Provider behavior count out of range.")

	_current_items = items.duplicate()
	_current_count = behavior.count

func reset() -> void:
	_current_items = items.duplicate()
	_current_count = behavior.count

func _handle_repeat() -> void:
	if not is_current_empty():
		return
		
	if behavior.repeat:
		reset()

func is_empty() -> bool:
	if behavior.repeat:
		return false

	return is_current_empty()

func is_current_empty() -> bool:
	if _current_count == 0 and behavior.count > 0:
		return true
	
	if _current_items.size() == 0:
		return true
		
	return false

func get_item() -> ItemResource:
	_handle_repeat()
	
	if _current_count == 0 and behavior.count > 0:
		return null
	
	if _current_items.size() == 0:
		return null
	
	var indexes_: Array[int] = range(_current_items.size())
	
	if behavior.count > 0:
		_current_count -= 1
		
	return _get_item_from_index(indexes_)
	 
func _get_item_from_index(indexes_: Array[int]) -> ItemResource:
	var index_: int = indexes_[0]
	
	if behavior.random:
		index_ = indexes_[randi_range(0, indexes_.size() - 1)]
		
	var item_: ItemResource = _current_items[index_]
	
	if behavior.remove:
		_current_items.remove_at(index_)
	
	return item_

func has_item_of_type(type_: Core.ItemType, subtype_: Variant) -> bool:
	if is_empty():
		return false
	
	_handle_repeat()
	
	var indexes_: Array[int] = _get_items_of_type_indexes(type_, subtype_)
	return indexes_.size() > 0

func get_item_of_type(type_: Core.ItemType, subtype_: Variant) -> ItemResource:
	_handle_repeat()
	
	var indexes_: Array[int] = _get_items_of_type_indexes(type_, subtype_)
	
	if indexes_.size() == 0:
		return null
	
	if behavior.count > 0:
		_current_count -= 1
	
	return _get_item_from_index(indexes_)

func _get_items_of_type_indexes(type_: Core.ItemType, subtype_: Variant) -> Array[int]:
	var indexes_: Array[int] = []
	
	for index_: int in _current_items.size():
		var item: ItemResource = _current_items[index_]
		
		if item.is_type(type_, subtype_):
			indexes_.push_back(index_)
			
	return indexes_
