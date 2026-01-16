extends HBoxContainer
class_name UIInputEvent

var data: Dictionary = {}
var fade: FadeTimer = FadeTimer.new(self, 0.5)

# There is probably a more sane way to do this

signal remove_pressed(input_event_data_: Dictionary)

func reset() -> void:
	if %UIAnimatedTextureRect.visible:
		%UIAnimatedTextureRect.reset()

func _process(delta_: float) -> void:
	fade.process(delta_)
	
func get_remove_button() -> UIButton:
	return %UIButtonRemove
	
func get_input_event_data() -> Dictionary:
	return data

func set_input_event_data(input_event_data_: Dictionary) -> void:
	data = input_event_data_

	%UILabel.text = data.text
	
	if Core.inputs.resources != null:
		var device_texture_: Texture2D = Core.inputs.resources.get_device_texture_from_input_type(data.type)
		if device_texture_ == null:
			%TextureRectType.visible = false
		else:
			%TextureRectType.texture = device_texture_
			%TextureRectType.visible = true
			
		var input_texture_animation_: TextureAnimation = Core.inputs.resources.get_input_texture_animation_from_input_events_data(data)
		if input_texture_animation_ == null:
			%UIAnimatedTextureRect.visible = false
		else:
			%UIAnimatedTextureRect.texture_animation = input_texture_animation_
			%UIAnimatedTextureRect.visible = true
	else:
			%TextureRectType.visible = false
			%UIAnimatedTextureRect.visible = false
			
func set_conflict(contflict_: bool) -> void:
	if contflict_:
		%UiPanelContainer.style = &"error"
	else:
		%UiPanelContainer.style = &""

func _on_ui_button_remove_pressed() -> void:
	remove_pressed.emit(get_input_event_data())
