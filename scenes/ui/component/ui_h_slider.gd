extends HSlider
class_name UIHSlider

@export_category("Visual")
@export var style: StringName = &"":
	set(value):
		style = value
		if is_node_ready():
			_update_style()

var _last_wheel_time: float = 0.0
var _wheel_debounce_delta: float = 0.05

func _ready() -> void:
	_update_style()

func _update_style() -> void:
	if style == &"":
		set_theme(null)
		set_theme_type_variation(&"")
		return
		
	assert(Core.ui.has_h_slider(style), "HSlider style not found. (" + style + ")")
	 
	if not Core.ui.has_h_slider(style):
		return
	
	var h_slider_: Dictionary = Core.ui.get_h_slider(style)

	if h_slider_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(h_slider_.theme))
		
	set_theme_type_variation(h_slider_.theme_type_variation)

func _gui_input(event_: InputEvent) -> void:
	if event_ is InputEventMouseButton:
		if event_.button_index == MOUSE_BUTTON_WHEEL_UP:
			accept_event()
			
			# To prevent multiple ticks
			var time_: float = Time.get_ticks_msec() / 1000.0
			
			if time_ - _last_wheel_time < _wheel_debounce_delta:
				return
				
			_last_wheel_time = time_
			
			value += step
		if event_.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event()
			
			# To prevent multiple ticks
			var time_: float = Time.get_ticks_msec() / 1000.0
			
			if time_ - _last_wheel_time < _wheel_debounce_delta:
				return
				
			_last_wheel_time = time_
			
			value -= step
