class_name FadeTimer

var node: Node
var delta: float
var _default_alpha: float
var current_delta: float = 0.0
var is_active: bool = false
var is_complete: bool = false
	
func _init(node_: CanvasItem, delta_: float = 0.0) -> void:
	node = node_
	delta = delta_
	_default_alpha = node.modulate.a

func reset() -> void:
	node.modulate.a = _default_alpha
	current_delta = 0.0
	is_active = false
	is_complete = false

func process(delta_: float) -> void:
	if not is_active:
		return
		
	current_delta += delta_

	if current_delta > delta:
		complete()

func complete() -> void:
	if is_active and not is_complete:
		current_delta = delta
		is_active = false
		is_complete = true

func fadeIn() -> void:
	node.modulate.a = 0.0
	current_delta = 0.0
	is_active = false
	is_complete = false
	
func fadeOut() -> void:
	node.modulate.a = 1.0
	current_delta = 0.0
	is_active = false
	is_complete = false
