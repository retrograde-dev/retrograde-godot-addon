extends Line2D
class_name LineTrailEffect

@export var size: int = 10

var is_started: bool = false
var is_paused: bool = false

func _ready() -> void:
	set_as_top_level(true)

func start() -> void:
	clear_points()
	visible = true
	is_started = true
	
func stop() -> void:
	visible = false
	is_started = false

func pause() -> void:
	is_paused = true

func unpause() -> void:
	clear_points()
	is_paused = false

func _physics_process(_delta: float) -> void:
	if not is_started or is_paused:
		return
		
	var point = get_parent().global_position
	if points.size() > 0 and point == points[points.size() - 1]:
		return
		
	add_point(point)
	if points.size() > size:
		remove_point(0)
