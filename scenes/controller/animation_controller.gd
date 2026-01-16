extends BaseNode2D
class_name AnimationController

var play_value: PlayValue = null

var _texture_paths: Dictionary = {}

signal animation_started(
	sprite_: AnimatedSprite2D,
	play_value_: PlayValue, 
	animation_: StringName, 
	frame_: int
)
signal animation_frame(
	sprite_: AnimatedSprite2D,
	play_value_: PlayValue, 
	animation_: StringName, 
	frame_: int
)
signal animation_stopped(
	sprite_: AnimatedSprite2D,
	play_value_: PlayValue, 
	animation_: StringName, 
	frame_: int
)

func _ready() -> void:
	for child: Node in get_children():
		if child is AnimatedSprite2D:
			child.animation_finished.connect(_on_child_animation_finished.bind(child))
			child.frame_changed.connect(_on_child_frame_changed.bind(child))

func _on_child_animation_finished(sprite: AnimatedSprite2D) -> void:
	animation_stopped.emit(
		sprite, 
		play_value, 
		sprite.get_animation(), 
		sprite.get_frame()
	)
	
	var animation_name_: StringName = sprite.animation.split("_tf_")[0]
	
	if animation_name_ != sprite.animation:
		animation_started.emit(
			sprite,
			play_value, 
			animation_name_, 
			0
		)
		sprite.play(animation_name_)

func _on_child_frame_changed(sprite: AnimatedSprite2D) -> void:
	animation_frame.emit(
		sprite, 
		play_value, 
		sprite.get_animation(), 
		sprite.get_frame()
	)

func play(play_value_: PlayValue) -> void:
	if not is_enabled:
		return
		
	var animations_: Array[Dictionary] = _get_animations(
		play_value_.animation,
		play_value_.direction,
		play_value_.suffixes
	)
	
	for child: Node in get_children():
		if not child is AnimatedSprite2D:
			continue
			
		var empty: bool = true

		for animation_: Dictionary in animations_:
			if child.sprite_frames.has_animation(animation_.animation):
				var start_frame_: int = 0
				
				var transist: Array = _apply_transist(child, animation_.animation)

				if (child.is_playing() and 
					child.animation == transist[0] and 
					child.flip_h == animation_.flip_h and 
					child.flip_v == animation_.flip_v
				):				
					empty = false
					break;
					
				child.flip_h = animation_.flip_h
				child.flip_v = animation_.flip_v
				animation_stopped.emit(child, play_value, child.animation, child.frame)
				animation_started.emit(child, play_value_, transist[0], transist[1])
				child.play(transist[0])
				child.frame = transist[1]
				empty = false
				break
		
		if empty and child.sprite_frames.has_animation(&"empty"):
			child.play(&"empty")
			
	play_value = play_value_

func _apply_transist(sprite_: AnimatedSprite2D, animation_name_: StringName) -> Array:
	var transist_: Array = [animation_name_, 0]
	
	if play_value == null:
		return transist_

	if sprite_.sprite_frames.has_animation(
		animation_name_ + &"_tf_" + play_value.animation + &"_" + str(sprite_.frame)
	):
		transist_[0] = animation_name_ + &"_tf_" + play_value.animation + &"_" + str(sprite_.frame)
		return transist_
		
	var start_frame_: int = 0
	
	for i: int in sprite_.frame + 1:
		if sprite_.sprite_frames.has_animation(
			animation_name_ + &"_tf_" + play_value.animation + &"_lte_" + str(i)
		):
			transist_[0] = animation_name_ + &"_tf_" + play_value.animation + &"_lte_" + str(i)
			transist_[1] = sprite_.frame - start_frame_
			start_frame_ = i + 1
			return transist_
		
	if sprite_.sprite_frames.has_animation(
		animation_name_ + &"_tf_" + play_value.animation
	):
		transist_[0] = animation_name_ + &"_tf_" + play_value.animation
		transist_[1] = sprite_.frame
	
	return transist_

func _get_animations(
	animation_name_: StringName,
	unit_direction_: Core.UnitDirection,
	suffixes_: Array[StringName] = []
) -> Array[Dictionary]:
	var directions: Array = Core.PLAY_DIRECTIONS[unit_direction_]
	var add_animation_name_: bool = (animation_name_ != &"idle")
	
	var animation_names_: Array = []
	var animation_suffix_names_: Dictionary = {}
	
	for suffix_: StringName in suffixes_:
		animation_suffix_names_[suffix_] = []

	for direction: StringName in directions:
		var flip_h: bool = false
		var flip_v: bool = false
		
		if direction == &"x" or direction == &"xy":
			match unit_direction_:
				Core.UnitDirection.LEFT:
					flip_h = true
				Core.UnitDirection.LEFT_UP:
					flip_h = true
				Core.UnitDirection.LEFT_DOWN:
					flip_h = true
				Core.UnitDirection.UP_LEFT:
					flip_h = true
				Core.UnitDirection.DOWN_LEFT:
					flip_h = true
			
		if direction == &"y" or direction == &"xy":
			match unit_direction_:
				Core.UnitDirection.UP:
					flip_v = true
				Core.UnitDirection.UP_LEFT:
					flip_v = true
				Core.UnitDirection.UP_RIGHT:
					flip_v = true
				Core.UnitDirection.LEFT_UP:
					flip_v = true
				Core.UnitDirection.RIGHT_UP:
					flip_v = true
					
		if animation_name_ == direction:
			add_animation_name_ = false
			
			animation_names_.push_back({
				"animation": animation_name_,
				"flip_h": flip_h,
				"flip_v": flip_v,
			})
			
			for suffix_: StringName in suffixes_:
				animation_suffix_names_[suffix_].push_back({
					"animation": animation_name_ + &"_" + suffix_,
					"flip_h": flip_h,
					"flip_v": flip_v,
				})
		else:
			animation_names_.push_back({
				"animation": animation_name_ + &"_" + direction,
				"flip_h": flip_h,
				"flip_v": flip_v,
			})
			
			for suffix_:StringName in suffixes_:
				animation_suffix_names_[suffix_].push_back({
					"animation": animation_name_ + &"_" + direction + &"_" + suffix_,
					"flip_h": flip_h,
					"flip_v": flip_v,
				})
		
	if add_animation_name_:
		animation_names_.push_back({
			"animation": animation_name_,
			"flip_h": false,
			"flip_v": false,
		})
		
		for suffix_: StringName in suffixes_:
			animation_suffix_names_[suffix_].push_back({
				"animation": animation_name_ + &"_" + suffix_,
				"flip_h": false,
				"flip_v": false,
			})
	
	var result_animation_names: Array[Dictionary] = []
	
	for suffix_: StringName in suffixes_:
		result_animation_names.append_array(animation_suffix_names_[suffix_])
	
	result_animation_names.append_array(animation_names_)
		
	return result_animation_names

func set_texture_variant(variant_alias_: StringName) -> void:
	return
	
	for child: Node in get_children():
		if not child is AnimatedSprite2D:
			continue
		
		var path: String
		
		#var frames = child.sprite_frames
		#TODO Iterate over all frames of all aniamtoins and update texture....
		#TODO Do i just recreate all the animates again?
		# Get list of animations on ready, and populate variant versions of 
		# the animations Then when switch variant is called, it can switch to 
		# whatever animation is currently playing and set the frame to match
		
		#for animation_name_ in frames.animations_names:
			#frames.set_frame_texture(animation_name_, frame_index_, new_texture_)
		
		#if _texture_paths.has(child.get_instance_id()):
			#path = _texture_paths[child.get_instance_id()]
		#else:
			#path = frame.texture.resource_path
			#_texture_paths[child.get_instance_id()] = path
			#
		#if variant_alias_ == &"":
			#if frame.texture.resource_path != path:
				#frame.texture = load(path)
			#continue
			#
		#var variant_path = Core.add_suffix_to_path(path, variant_alias_)
		#
		#if FileAccess.file_exists(variant_path):
			#frame.texture = load(variant_path)
		#elif frame.texture.resource_path != path:
			#frame.texture = load(path)
