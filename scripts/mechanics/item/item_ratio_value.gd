extends Resource
class_name ItemRatioValue

@export var types: Array[Core.ItemType] = []
@export var count: int = 0

@export var consume_ratios: Dictionary[Core.ConsumeType, int] = {}
@export var loot_ratios: Dictionary[Core.LootType, int] = {}
@export var spell_ratios: Dictionary[Core.SpellType, int] = {}
@export var trap_ratios: Dictionary[Core.TrapType, int] = {}

var _active: Array[Dictionary] = []
var _active_consume_ratios: Array[Core.ConsumeType] = []
var _active_loot_ratios: Array[Core.LootType] = []
var _active_spell_ratios: Array[Core.SpellType] = []
var _active_trap_ratios: Array[Core.TrapType] = []

func _init(
	types_: Array[Core.ItemType] = [],
	count_: int = 0
) -> void:
	types = types_
	count = count_
	
func reset() -> void:
	_active = []

func size() -> int:
	return count

func current_size() -> int:
	return _active.size()

func _handle_repeat() -> void:
	if _active.is_empty():
		_active = _create_ratio()

func get_items() -> Array[Dictionary]:
	return _create_ratio()

func get_next_item() -> Dictionary:
	_handle_repeat()
	
	return _active.pop_back()

func set_consume_ratio(
	consume_type_: Core.ConsumeType,
	count_: int
) -> void:
	if count_ == 0:
		consume_ratios.erase(consume_type_)
	else:
		consume_ratios.set(consume_type_, count)
	
func set_loot_ratio(
	loot_type_: Core.LootType,
	count_: int
) -> void:
	if count_ == 0:
		loot_ratios.erase(loot_type_)
	else:
		loot_ratios.set(loot_type_, count)
		
func set_spell_ratio(
	spell_type_: Core.SpellType,
	count_: int
) -> void:
	if count_ == 0:
		spell_ratios.erase(spell_type_)
	else:
		spell_ratios.set(spell_type_, count)
		
func set_trap_ratio(
	trap_type_: Core.TrapType,
	count_: int
) -> void:
	if count_ == 0:
		trap_ratios.erase(trap_type_)
	else:
		trap_ratios.set(trap_type_, count)

func _create_ratio() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	var current_count_: int = 0
	
	while true:
		var type_: Core.ItemType = types.pick_random()
		
		result.push_back({
			&"type": type_,
			&"subtype": _get_next_subtype(type_),
		})
		
		current_count_ += 1
		
		if current_count_ == count:
			break
	
	return result

func _get_next_subtype(type_: Core.ItemType) -> Variant:
	if type_ == Core.ItemType.CONSUME:
		if consume_ratios.is_empty():
			return null
			
		if _active_consume_ratios.is_empty():
			_active_consume_ratios = _create_consume_ratios()
			
		return _active_consume_ratios.pop_back()
	elif type_ == Core.ItemType.LOOT:
		if loot_ratios.is_empty():
			return null
			
		if _active_loot_ratios.is_empty():
			_active_loot_ratios = _create_loot_ratios()
	
		return _active_loot_ratios.pop_back()
	elif type_ == Core.ItemType.SPELL:
		if spell_ratios.is_empty():
			return null
			
		if _active_spell_ratios.is_empty():
			_active_spell_ratios = _create_spell_ratios()
	
		return _active_spell_ratios.pop_back()
	elif type_ == Core.ItemType.TRAP:
		if trap_ratios.is_empty():
			return null
			
		if _active_trap_ratios.is_empty():
			_active_trap_ratios = _create_trap_ratios()
	
		return _active_trap_ratios.pop_back()
		
	return null

func _create_consume_ratios() -> Array[Core.ConsumeType]:
	var result_: Array[Core.ConsumeType] = []
	
	for consume_type_: Core.ConsumeType in consume_ratios:
		var current_count_: int = 0
	
		while true:
			result_.push_back(consume_type_)
			
			current_count_ += 1
			
			if current_count_ == consume_ratios[consume_type_]:
				break
	
	result_.shuffle()
	return result_
	
func _create_loot_ratios() -> Array[Core.LootType]:
	var result_: Array[Core.LootType] = []
	
	for loot_type_: Core.LootType in loot_ratios:
		var current_count_: int = 0
	
		while true:
			result_.push_back(loot_type_)
			
			current_count_ += 1
			
			if current_count_ == loot_ratios[loot_type_]:
				break
		
	result_.shuffle()
	return result_

func _create_spell_ratios() -> Array[Core.SpellType]:
	var result_: Array[Core.SpellType] = []
	
	for spell_type_: Core.SpellType in spell_ratios:
		var current_count_: int = 0
	
		while true:
			result_.push_back(spell_type_)
			
			current_count_ += 1
			
			if current_count_ == spell_ratios[spell_type_]:
				break
		
	result_.shuffle()
	return result_

func _create_trap_ratios() -> Array[Core.TrapType]:
	var result_: Array[Core.TrapType] = []
	
	for trap_type_: Core.TrapType in trap_ratios:
		var current_count_: int = 0
	
		while true:
			result_.push_back(trap_type_)
			
			current_count_ += 1
			
			if current_count_ == trap_ratios[trap_type_]:
				break
		
	result_.shuffle()
	return result_
