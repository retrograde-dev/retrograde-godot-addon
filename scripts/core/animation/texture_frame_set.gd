class_name AnimationFrameSet

var frames: Array[AnimationFrameValue]

func _init(frames_: Array[AnimationFrameValue] = []) -> void:
	frames = frames_
	
func add_frame(frame_: AnimationFrameValue) -> void:
	frames.push_back(frame_)
	
func size() -> int:
	return frames.size()
