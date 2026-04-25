class_name UnitSet

var units: Array[BaseUnit]

signal updated(units_added_: Array[BaseUnit], units_removed_: Array[BaseUnit])

func _init(units_: Array[BaseUnit] = []) -> void:
	units = units_
	
func _iter_init(iter_: Array) -> bool:
	iter_[0] = 0
	return iter_[0] < units.size()

func _iter_next(iter_: Array) -> bool:
	iter_[0] += 1
	return iter_[0] < units.size()

func _iter_get(iter_: Variant) -> BaseUnit:
	return units[iter_] if iter_ < units.size() else &""

func get_unit_from_alias(unit_alias_: String) -> BaseUnit:
	for unit_: BaseUnit in units:
		if unit_.alias == unit_alias_:
			return unit_;
			
	return null

func has_unit(unit_: BaseUnit) -> bool:
	return units.has(unit_)

func has_units(units_: Array[BaseUnit]) -> bool:
	for unit_: BaseUnit in units_:
		if not has_unit(unit_):
			return false
			
	return true

func add_unit(unit_: BaseUnit) -> bool:
	if units.has(unit_):
		return false
	
	units.push_back(unit_)
	
	updated.emit([unit_] as Array[BaseUnit], [] as Array[BaseUnit])
	return true

func add_units(units_: Array[BaseUnit]) -> void:
	for unit_: BaseUnit in units_:
		add_unit(unit_)
	
func remove_unit(unit_: BaseUnit) -> bool:
	for index_: int in units.size():
		if units[index_] == unit_:
			units.remove_at(index_)
			updated.emit([], [unit_] as Array[BaseUnit])
			return true
			
	return false

func remove_units(units_: Array[BaseUnit]) -> void:
	for index_: int in range(units.size() - 1, -1, -1):
		if units_.has(units[index_]):
			units.remove_at(index_)

func remove_unit_from_alias(unit_alias_: StringName) -> void:
	for index_: int in units.size():
		if units[index_].alias == unit_alias_:
			units.remove_at(index_)
			break
		
func replace_units(units_: Array[BaseUnit]) -> void:
	if updated.get_connections().is_empty():
		units = units_
		return
	
	var added: Array[BaseUnit] = []
	var removed: Array[BaseUnit] = []
	
	for unit: BaseUnit in units:
		if not units_.has(unit):
			removed.push_back(unit)
			
	for unit: BaseUnit in units_:
		if not units.has(unit):
			added.push_back(unit)
	
	units = units_
	
	updated.emit(added, removed)

func clear() -> void:
	units.clear()
	updated.emit([] as Array[BaseUnit], units)

func filter(method_: Callable) -> void:
	var units_: Array[BaseUnit] = units.filter(method_)
	replace_units(units_)

func order(units_: Array[BaseUnit]) -> void:
	var order_: Array[BaseUnit] = []
	
	for unit_: BaseUnit in units_:
		if units.has(unit_):
			order_.push_back(unit_)

	for unit_: BaseUnit in units:
		if not order_.has(unit_):
			order_.push_back(unit_)
		
	units = order_
	
func order_from_aliases(unit_aliases_: Array[StringName]) -> void:
	var order_: Array[BaseUnit] = []
	
	for unit_alias_: StringName in unit_aliases_:
		for index_: int in units.size():
			if units[index_].alias == unit_alias_:
				order_.push_back(units[index_])

	for unit_: BaseUnit in units:
		if not order_.has(unit_):
			order_.push_back(unit_)
		
	units = order_
