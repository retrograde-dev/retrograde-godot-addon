class_name TextureAnimation

var texture: Texture2D
var frame_count: Vector2i
var frame_orientation: Core.Orientation
var frame_set: AnimationFrameSet
var autoplay: bool = false
var loop: bool = false
	
var atlas: AtlasTexture = AtlasTexture.new()

var _playing: bool = false
var _current_frame: int = 0
var _current_duration: float = 0.0

func _init(
	texture_: Texture2D,
	frame_count_: Vector2i,
	frame_orientation_: Core.Orientation,
	frame_set_: AnimationFrameSet,
	autoplay_: bool = false,
	loop_: bool = false,
) -> void:
	texture = texture_
	frame_count = frame_count_
	frame_orientation = frame_orientation_
	frame_set = frame_set_
	autoplay = autoplay_
	loop = loop_
	atlas.atlas = texture
	_set_frame(0)
	
	if autoplay_:
		play()

func process(delta_: float) -> void:
	if not _playing:
		return
		
	_current_duration += delta_
	
	var update_frame_: bool = false
	
	while true:
		if _current_duration > frame_set.frames[_current_frame].duration:
			_current_duration -= frame_set.frames[_current_frame].duration
			_current_frame += 1
			update_frame_ = true
			
			if _current_frame >= frame_set.size():
				if loop:
					_current_frame = 0
				else:
					stop()
					_current_frame = 0
					_current_duration = 0.0
					_set_frame(frame_set.size() - 1)
					return
		else:
			break

	if update_frame_:
		_set_frame(_current_frame)
	
func reset() -> void:
	if autoplay:
		play()
	else:
		stop()
	_current_frame = 0
	_current_duration = 0.0
	
func play() -> void:
	_playing = true
	
func stop() -> void:
	_playing = false
	
func _set_frame(frame_index_: int) -> void:
	if texture == null:
		texture = null
		return
	
	assert(
		frame_index_ >= 0 or frame_index_ < frame_set.size(), 
		"Invalid atlas frame index. (" + str(frame_index_) + ")"
	)
	
	if frame_index_ < 0 or frame_index_ >= frame_set.size():
		texture = null
		return
	
	var index_: int = frame_set.frames[frame_index_].index
	
	var width_: int = floori(float(texture.get_width()) / frame_count.x)
	var height_: int = floori(float(texture.get_height()) / frame_count.y)
	var col: int
	var row: int
	
	if frame_orientation == Core.Orientation.HORIZONTAL:
		col = index_ % frame_count.x
		row = floori(float(index_) / frame_count.x)
	else:
		row = index_ % frame_count.y
		col = floori(float(index_) / frame_count.y)
	
	atlas.region = Rect2(
		col * width_,
		row * height_,
		width_,
		height_
	)
