extends CanvasLayer
class_name BaseCanvasLayer

var is_enabled: bool = true
var is_started: bool = false
var is_ready: bool = false
var modes: StringNameSet = StringNameSet.new()

var scale_default: Vector2 = Vector2.ONE

signal reseted(reset_type_: Core.ResetType)
signal started()
signal stopped()
signal refreshed()
signal restarted()

func _ready() -> void:
	scale_default = scale
	
func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		scale = scale_default
		
		is_started = false
		is_ready = false
		modes.filter(func(mode: StringName) -> bool: return Core.GLOBAL_MODES.has(mode))

	reseted.emit(reset_type_)
	
func start() -> void:
	reset(Core.ResetType.START)
	
	is_started = true
		
	for child: Node in get_children(): 
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.start()
			
	started.emit()

func restart() -> void:	
	reset(Core.ResetType.RESTART)
	
	is_started = true
	
	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.restart()
		
	restarted.emit()
	
func refresh() -> void:
	reset(Core.ResetType.REFRESH)
	
	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.refresh()
	
	refreshed.emit()

func stop() -> void:
	reset(Core.ResetType.STOP)
	
	is_started = false
	is_ready = false
	
	for child: Node in get_children():
		if child is BaseNode2D or child is BaseCharacterBody2D:
			await child.stop()
			
	stopped.emit()

func _process(_delta: float) -> void:
	# We redundantly check is_ready here so overriding wont allow calling
	# it after alrady being ready
	if not is_ready:
		_handle_ready()

func _handle_ready() -> void:
	if is_ready:
		return
	
	if Engine.is_editor_hint():
		return
	
	if not Core.game.is_enabled:
		return

	if not is_started:
		return

	is_ready = true
	ready()

func ready() -> void:
	pass

func is_running() -> bool:
	if not Core.game.is_enabled:
		return false

	if not is_enabled or not is_started or not is_ready:
		return false

	return true

func add_mode(mode_: StringName, add_to_children: bool = false) -> void:
	modes.add(mode_)
	
	if add_to_children:
		for child: Node in get_children():
			if child is BaseNode2D or child is BaseCharacterBody2D:
				child.add_mode(mode_)
	
func remove_mode(mode_: StringName, remove_from_children: bool = false) -> void:
	modes.remove(mode_)
	
	if remove_from_children:
		for child: Node in get_children():
			if child is BaseNode2D or child is BaseCharacterBody2D:
				child.remove_mode(mode_)
