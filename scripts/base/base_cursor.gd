extends BaseCharacterBody2D
class_name BaseCursor

var alias: StringName

var _half_screen_size: Vector2
var _offset: Vector2 = Vector2.ZERO

# No reason to poll screen size every time
const UPDATE_VIEWPORT_COOLDOWN_DELTA: float = 1.0
var _update_viewport_cooldown: float = 0.0

func _init(alias_: StringName) -> void:
	alias = alias_
	
func _ready() -> void:
	super._ready()
	
	_update_half_screen_size()
	position = _get_center_position()

func _process(delta: float) -> void:
	if not is_running():
		return
		
	_update_viewport_cooldown += delta
	if _update_viewport_cooldown > UPDATE_VIEWPORT_COOLDOWN_DELTA:
		_update_viewport_cooldown = 0.0
		_update_half_screen_size()
	
	var joystick_motion: Vector2 = Vector2(
		Input.get_action_strength(&"cursor_right") - Input.get_action_strength(&"cursor_left"),
		Input.get_action_strength(&"cursor_down") - Input.get_action_strength(&"cursor_up")
	)
	if joystick_motion.length() > 0:
		if Input.is_action_pressed(&"cursor_slow"):
			_offset += joystick_motion.normalized() * Core.joypad_speed_slow * delta
		elif Input.is_action_pressed(&"cursor_fast"):
			_offset += joystick_motion.normalized() * Core.joypad_speed_fast * delta
		else:
			_offset += joystick_motion.normalized() * Core.joypad_speed_normal * delta
	
	_offset = _offset.clamp(-_half_screen_size, _half_screen_size)
	if Core.camera != null:
		position = _get_center_position() + _offset
	else:
		position = _offset

func _input(event: InputEvent) -> void:
	if not Core.game.is_enabled:
		return
		
	if event is InputEventMouseMotion:
		_offset += event.relative * Core.mouse_speed
		
func _get_center_position() -> Vector2:
	if Core.camera != null:
		return Core.camera.get_screen_center_position()
	else:
		return Vector2.ZERO

func _update_half_screen_size() -> void:
	if Core.camera == null:
		_half_screen_size = Vector2(0, 0)

	_half_screen_size = Vector2(Core.camera.get_viewport().size) / Core.camera.zoom / 2.0 
	_half_screen_size -= Vector2(Core.MOUSE_CURSOR_SIZE / 2.0, Core.MOUSE_CURSOR_SIZE / 2.0)
	
