extends TextureRect
class_name UIAnimatedTextureRect

var _texture_animation: TextureAnimation = null
var texture_animation: TextureAnimation:
	get:
		return get_texture_animation()
	set(value):
		set_texture_animation(value)

func _ready() -> void:
	if _texture_animation == null:
		process_mode = Node.PROCESS_MODE_DISABLED

func reset() -> void:
	_texture_animation.reset()

func get_texture_animation() -> TextureAnimation:
	return _texture_animation
	
func set_texture_animation(texture_animation_: TextureAnimation) -> void:
	_texture_animation = texture_animation_
	
	if _texture_animation == null:
		process_mode = Node.PROCESS_MODE_DISABLED
		texture = null
	else:
		texture = _texture_animation.atlas
		
		# No need to process animation if only one frame
		if _texture_animation.frame_count == Vector2i.ONE:
			process_mode = Node.PROCESS_MODE_DISABLED
		else:
			process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta: float) -> void:
	if texture_animation == null or visible == false:
		return
	
	texture_animation.process(delta)
