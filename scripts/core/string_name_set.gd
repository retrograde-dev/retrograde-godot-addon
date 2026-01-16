class_name StringNameSet

var names: Array[StringName]

signal updated(names_added_: Array[StringName], names_removed_: Array[StringName])

func _init(names_: Array[StringName] = []) -> void:
	names = names_
	
func _iter_init(iter_: Array) -> bool:
	iter_[0] = 0
	return iter_[0] < names.size()

func _iter_next(iter_: Array) -> bool:
	iter_[0] += 1
	return iter_[0] < names.size()

func _iter_get(iter_: Variant) -> StringName:
	return names[iter_] if iter_ < names.size() else &""
	
func has(name_: StringName) -> bool:
	return names.has(name_)
	
func add(name_: StringName) -> bool:
	if names.has(name_):
		return false
	
	names.push_back(name_)
	
	updated.emit([name_] as Array[StringName], [] as Array[StringName])
	return true

func add_all(names_: Array[StringName]) -> void:
	for name_: StringName in names_:
		add(name_)
	
func remove(name_: StringName) -> bool:
	for i: int in names.size():
		if names[i] == name_:
			names.remove_at(i)
			updated.emit([], name_)
			return true
			
	return false

func remove_all(names_: Array[StringName]) -> void:
	for i: int in range(names.size() - 1, -1, -1):
		if names_.has(names[i]):
			names.remove_at(i)
			
func replace(names_: Array[StringName]) -> void:
	if updated.get_connections().is_empty():
		names = names_
		return
	
	var added: Array[StringName] = []
	var removed: Array[StringName] = []
	
	for name: StringName in names:
		if not names_.has(name):
			removed.push_back(name)
			
	for name: StringName in names_:
		if not names.has(name):
			added.push_back(name)
	
	names = names_
	
	updated.emit(added, removed)

func clear() -> void:
	names = []
	updated.emit([] as Array[StringName], names)

func filter(method_: Callable) -> void:
	var names_: Array[StringName] = names.filter(method_)
	replace(names_)

func order(names_: Array[StringName]) -> void:
	var order_: Array[StringName] = []
	
	for name_: StringName in names_:
		if names.has(name_):
			order_.push_back(name_)

	for name_: StringName in names:
		if not order_.has(name_):
			order_.push_back(name_)
		
	names = order_
