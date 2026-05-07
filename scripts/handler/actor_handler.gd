class_name ActorHandler

var _actors: Dictionary = {}
var _current: int = 0
var _count: int = 0
var _process_order: StringNameSet = StringNameSet.new()
var _physics_process_order: StringNameSet = StringNameSet.new()
	
func _iter_init(_arg: Array) -> bool:
	_current = 0
	_count = _actors.size()
	return (_current < _count)

func _iter_next(_arg: Array) -> bool:
	_current += 1
	return (_current < _count)

func _iter_get(_arg: Variant) -> BaseActor:
	return _actors[_actors.keys()[_current]]
	
func ready() -> void:
	for key: StringName in _actors:
		_actors[key].ready()
	
func reset(reset_type_: Core.ResetType) -> void:
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		for key: StringName in _actors:
			_actors[key].alias = key

func start() -> void:
	await reset(Core.ResetType.START)
	
	for key: StringName in _actors:
		await _actors[key].start()

func restart() -> void:
	await reset(Core.ResetType.RESTART)
	
	for key: StringName in _actors:
		await _actors[key].restart()
		
func refresh() -> void:
	await reset(Core.ResetType.REFRESH)
	
	for key: StringName in _actors:
		await _actors[key].refresh()
		
func stop() -> void:
	await reset(Core.ResetType.STOP)
	
	for key: StringName in _actors:
		await _actors[key].stop()

func process(delta_: float) -> void:
	for key: StringName in _process_order:
		_actors[key].process(delta_)
	
func physics_process(delta_: float) -> void:
	for key: StringName in _physics_process_order:
		_actors[key].physics_process(delta_)

func move_process(delta_: float) -> void:
	for key: StringName in _physics_process_order:
		if _actors[key] is UnitActor:
			_actors[key].move_process(delta_)

func has(alias_: StringName) -> bool:
	return _actors.has(alias_)
	
func use(alias_: StringName) -> BaseActor:
	return _actors.get(alias_)
	
func remove(alias_: StringName) -> void:
	if not _actors.has(alias_):
		return
		
	_actors.erase(alias_)

func add(alias_: StringName, actor_: BaseActor) -> void:
	remove(alias_)
	
	_actors[alias_] = actor_
	
	actor_.alias = alias_
	
	if not _process_order.has(actor_.alias):
		_process_order.add(actor_.alias)
		
	if not _physics_process_order.has(actor_.alias):
		_physics_process_order.add(actor_.alias)
	
func add_all(actors_: Dictionary) -> void:
	for key: StringName in actors_:
		add(key, actors_[key])

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = []
	
	for key: StringName in _actors:
		for action_: StringName in _actors[key].get_actions():
			if not actions_.has(action_):
				actions_.push_back(action_)
			
	return actions_

func set_order(actor_aliases_: Array[StringName]) -> void:
	set_process_order(actor_aliases_)
	set_physics_process_order(actor_aliases_)

func set_process_order(actor_aliases_: Array[StringName]) -> void:
	_process_order.order(actor_aliases_)
	
func set_physics_process_order(actor_aliases_: Array[StringName]) -> void:
	_physics_process_order.order(actor_aliases_)

func export() -> Dictionary[StringName, Dictionary]:
	var actors_: Dictionary[StringName, Dictionary] = {}
	
	for key: StringName in _actors:
		actors_[key] = _actors[key].export()
		
	return actors_
	
func import(data_: Dictionary[StringName, Dictionary]) -> void:
	for key: StringName in data_:
		if _actors.has(key):
			_actors[key].import(data_[key])
