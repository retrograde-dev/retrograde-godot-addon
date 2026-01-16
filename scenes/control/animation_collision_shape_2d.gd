extends CollisionShape2D
class_name AnimationCollisionShape2D

@export var animation: StringName = &""
@export var frame: int = -1
@export var rects: Array[Rect2] = []

func process_frame(
	animation_: StringName, 
	frame_: int = 0, 
	flip_h_: bool = false,
	flip_v_: bool = false,
) -> void:
	if animation_ != animation:
		set_disabled(true)
		return
		
	if frame != -1 and frame != frame_:
		set_disabled(true)
		return
	
	if rects.is_empty():
		set_disabled(false)
		return
		
	if frame == -1:
		if frame_ >= rects.size():
			set_disabled(true)
			return
			
		set_disabled(false)
		_update_shape(rects[frame_], flip_h_, flip_v_)
		return
	else:
		set_disabled(false)
		_update_shape(rects[0], flip_h_, flip_v_)

func _update_shape(
	rect_: Rect2,
	flip_h_: bool, 
	flip_v_: bool
) -> void:
	var flip_: Vector2 = Vector2(
		-1.0 if flip_h_ else 1.0, 
		-1.0 if flip_v_ else 1.0
	)
	
	set_position(rect_.position * flip_)
		
	if shape is RectangleShape2D:
		shape.size = rect_.size
	elif shape is CapsuleShape2D:
		shape.radius = rect_.size.x
		shape.height = rect_.size.y
	elif shape is CircleShape2D:
		shape.radius = rect_.size.x
