class_name BaseActor

var alias: StringName
var is_enabled: bool
var is_enabled_default: bool

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
	reset(Core.ResetType.START)
	is_started = true

func restart() -> void:
	reset(Core.ResetType.RESTART)

func stop() -> void:
	reset(Core.ResetType.STOP)
	is_started = false

func process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_process_skip()

func physics_process(_delta: float) -> void:
	# Needs to be called before can_process since it affects can_process
	_update_physics_process_skip()
		
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
