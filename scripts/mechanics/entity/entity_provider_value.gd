extends Resource
class_name EntityProviderValue

@export var entities: Array[EntityResource] = []
@export var behavior: ProviderBehavior = null

var _current_entities: Array[EntityResource]
var _current_count: int

func _init(
	entities_: Array[EntityResource] = [],
	behavior_: ProviderBehavior = null
) -> void:
	entities = entities_
	
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
		assert(behavior.count <= entities.size(), "Provider behavior count out of range.")

	_current_entities = entities.duplicate()
	_current_count = behavior.count

func reset() -> void:
	_current_entities = entities.duplicate()
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
	
	if _current_entities.size() == 0:
		return true
		
	return false

func get_entity() -> EntityResource:
	_handle_repeat()
	
	if _current_count == 0 and behavior.count > 0:
		return null
	
	if _current_entities.size() == 0:
		return null
	
	var indexes_: Array[int] = range(_current_entities.size())
	
	if behavior.count > 0:
		_current_count -= 1
		
	return _get_entity_from_index(indexes_)
	 
func _get_entity_from_index(indexes_: Array[int]) -> EntityResource:
	var index_: int = indexes_[0]
	
	if behavior.random:
		index_ = indexes_[randi_range(0, indexes_.size() - 1)]
		
	var entity_: EntityResource = _current_entities[index_]
	
	if behavior.remove:
		_current_entities.remove_at(index_)
	
	return entity_
