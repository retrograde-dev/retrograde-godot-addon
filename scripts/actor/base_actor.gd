@abstract
class_name BaseActor

var alias: StringName

var is_enabled: bool:
	set = _set_is_enabled
	
var is_enabled_default: bool:
	set = _set_is_enabled_default

var is_started: bool = false

var current_process_skip: int = -1
var process_skip: int = 0 # For actors that don't need to be run every time
var process_skip_offset: int = 0

var current_physics_process_skip: int = -1
var physics_process_skip: int = 0 # For actors that don't need to be run every time
var physics_process_skip_offset: int = 0

func _init(alias_: StringName, enabled_: bool = true) -> void:
	alias = alias_
	is_enabled = enabled_
	is_enabled_default = enabled_
	
func ready() -> void:
	pass

func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		is_enabled = is_enabled_default
		is_started = false
		current_process_skip = -1
		
		assert(process_skip >= process_skip_offset, "Invalid process skip offset for current proccess skip.")

func start() -> void:
	await reset(Core.ResetType.START)
	is_started = true

func restart() -> void:
	await reset(Core.ResetType.RESTART)
	
func refresh() -> void:
	await reset(Core.ResetType.REFRESH)

func stop() -> void:
	await reset(Core.ResetType.STOP)
	is_started = false

func get_actions() -> Array[StringName]:
	return []
	
func process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_process_skip()

func physics_process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_physics_process_skip()

func _set_is_enabled(value_: bool) -> void:
	is_enabled = value_

func _set_is_enabled_default(value_: bool) -> void:
	is_enabled_default = value_

func _update_process_skip() -> void:
	current_process_skip += 1
	
	if current_process_skip >= process_skip:
		current_process_skip = 0
		
func _update_physics_process_skip() -> void:
	current_physics_process_skip += 1
	
	if current_physics_process_skip >= physics_process_skip:
		current_physics_process_skip = 0
	
func can_process() -> bool:
	if current_process_skip != process_skip_offset:
		return false
		
	if not is_enabled:
		return false

	return true
	
func can_physics_process() -> bool:
	if current_physics_process_skip != physics_process_skip_offset:
		return false
		
	if not is_enabled:
		return false

	return true

func export() -> Dictionary[StringName, Variant]:
	return {
		&"is_enabled": is_enabled,
		&"is_enabled_default": is_enabled_default,
		&"is_started": is_started,
		&"current_process_skip": current_process_skip,
		&"process_skip": process_skip,
		&"process_skip_offset": process_skip_offset,
		&"current_physics_process_skip": current_physics_process_skip,
		&"physics_process_skip": physics_process_skip,
		&"physics_process_skip_offset": physics_process_skip_offset,
	}
	
func import(data_: Dictionary[StringName, Variant]) -> void:
	is_enabled = data_.get(&"is_enabled", is_enabled)
	is_enabled_default = data_.get(&"is_enabled_default", is_enabled_default)
	is_started = data_.get(&"is_started", is_started)
	current_process_skip = data_.get(&"current_process_skip", current_process_skip)
	process_skip = data_.get(&"process_skip", process_skip)
	process_skip_offset = data_.get(&"process_skip_offset", process_skip_offset)
	current_physics_process_skip = data_.get(&"current_physics_process_skip", current_physics_process_skip)
	physics_process_skip = data_.get(&"physics_process_skip", physics_process_skip)
	physics_process_skip_offset = data_.get(&"physics_process_skip_offset", physics_process_skip_offset)
	
