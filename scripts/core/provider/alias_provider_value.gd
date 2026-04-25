class_name AliasProviderValue

var aliases: Array[StringName]
var behavior: ProviderBehavior
var _current_aliases: Array[StringName]
var _current_count: int

func _init(
	aliases_: Array[StringName],
	behavior_: ProviderBehavior = null
) -> void:
	aliases = aliases_
	
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
		assert(behavior.count <= aliases.size(), "Provider behavior count out of range.")

	_current_aliases = aliases.duplicate()
	_current_count = behavior.count

func reset() -> void:
	_current_aliases = aliases.duplicate()
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
	
	if _current_aliases.size() == 0:
		return true
		
	return false

func get_alias(
) -> StringName:
	_handle_repeat()
	
	if _current_count == 0 and behavior.count > 0:
		return &""
	
	if _current_aliases.size() == 0:
		return &""
	
	var indexes_: Array[int] = range(_current_aliases.size())
	
	if behavior.count > 0:
		_current_count -= 1
		
	return _get_alias_from_index(indexes_)
	 
func _get_alias_from_index(indexes_: Array[int]) -> StringName:
	var index_: int = indexes_[0]
	
	if behavior.random:
		index_ = indexes_[randi_range(0, indexes_.size() - 1)]
		
	var alias_: StringName = _current_aliases[index_]
	
	if behavior.remove:
		_current_aliases.remove_at(index_)
	
	return alias_
