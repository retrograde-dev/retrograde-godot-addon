extends HBoxContainer
class_name UIActionsField

@onready var _input_event_control: PackedScene = preload("res://addons/retrograde/scenes/ui/controls/ui_input_event.tscn")

var action: StringName = &""
var data: Array[Dictionary] = []

signal add_pressed(action_: StringName)
signal remove_pressed(action_: StringName, input_event_data_: Dictionary)

func _ready() -> void:
	for input_event_data_: Dictionary in data:
		var input_event_control_: Node = _input_event_control.instantiate()
		input_event_control_.set_input_event_data(input_event_data_)
		input_event_control_.remove_pressed.connect(_on_remove_pressed)
		%VBoxContainer.add_child(input_event_control_)
		
	_sort_input_events()
	
func reset() -> void:
	for child_: Node in %VBoxContainer.get_children():
		if child_ is UIInputEvent:
			child_.reset()

func _on_remove_pressed(input_event_data_: Dictionary) -> void:
	var children_: Array[Node] = %VBoxContainer.get_children()
	
	for index_: int in children_.size():
		var child_: Node = children_[index_]
		
		if not child_ is UIInputEvent:
			continue
			
		if Core.dictionary_contains(child_.get_input_event_data(), input_event_data_):
			%VBoxContainer.remove_child(child_)
			_sort_input_events()
			
			if children_.size() == 1:
				%UIButtonAdd.grab_focus()
			elif index_ == children_.size() - 1:
				%VBoxContainer.get_children()[index_ - 1].get_remove_button().grab_focus()
			else:
				%VBoxContainer.get_children()[index_].get_remove_button().grab_focus()
			
			remove_pressed.emit(action, input_event_data_)
			break
	
func get_action() -> StringName:
	return action
	
func set_action(action_: StringName) -> void:
	action = action_
	%UILabel.text = "LABEL:action_" + action_
	
func get_input_events_data() -> Array[Dictionary]:
	return data
	
func set_input_events_data(input_events_data_: Array[Dictionary]) -> void:
	data = input_events_data_

	if is_node_ready():
		for input_event_data_: Dictionary in input_events_data_:
			var input_event_control_: Node = _input_event_control.instantiate()
			input_event_control_.set_input_event_data(input_event_data_)
			input_event_control_.remove_pressed.connect(_on_remove_pressed)
			%VBoxContainer.add_child(input_event_control_)
		_sort_input_events()

func has_input_event(input_event_data_: Dictionary) -> bool:
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIInputEvent:
			continue
			
		if Core.dictionary_contains(child_.get_input_event_data(), input_event_data_):
			return true
			
	return false

func add_input_event(input_event_data_: Dictionary) -> void:
	var input_event_control_: Node = _input_event_control.instantiate()
	input_event_control_.set_input_event_data(input_event_data_)
	input_event_control_.remove_pressed.connect(_on_remove_pressed)
	#input_event_control_.fade.fadeIn()
	%VBoxContainer.add_child(input_event_control_)
	_sort_input_events()
			
func _sort_input_events() -> void:
	var children_: Array[Node] = %VBoxContainer.get_children()
	
	children_.sort_custom(_sort_input_events_callback)
	
	var data_: Array[Dictionary] = []
	
	for i: int in children_.size():
		data_.push_back(children_[i].get_input_event_data())
		%VBoxContainer.move_child(children_[i], i)
		
	data = data_

func get_add_button() -> UIButton:
	return %UIButtonAdd

func get_remove_buttons() -> Array[UIButton]:
	var remove_buttons_: Array[UIButton] = []
	
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIInputEvent:
			continue
		
		remove_buttons_.push_back(child_.get_remove_button())

	return remove_buttons_

func get_first_remove_button() -> UIButton:
	if %VBoxContainer.get_children().size() == 0:
		return null
		
	return %VBoxContainer.get_children().front().get_remove_button()

func get_last_remove_button() -> UIButton:
	if %VBoxContainer.get_children().size() == 0:
		return null
		
	return %VBoxContainer.get_children().back().get_remove_button()

func _sort_input_events_callback(a: UIInputEvent, b: UIInputEvent) -> bool:
	if a.data.type == Core.InputType.KEY:
		if b.data.type == Core.InputType.KEY:
			if a.data.physical_keycode <= b.data.physical_keycode:
				return true
				
			return false
		else:
			return true
		
	if b.data.type == Core.InputType.KEY:
		return false
		
	if a.data.type == Core.InputType.MOUSE_BUTTON:
		if b.data.type == Core.InputType.MOUSE_BUTTON:
			if a.data.button_index <= b.data.button_index:
				return true
				
			return false
		else:
			return true
		
	if b.data.type == Core.InputType.MOUSE_BUTTON:
		return false
	
	if a.data.type == Core.InputType.JOYPAD_MOTION:
		if b.data.type == Core.InputType.JOYPAD_MOTION:
			if a.data.axis == b.data.axis:
				if a.data.axis_value <= b.data.axis_value:
					return true
				else:
					return false
				
			if a.data.axis <= b.data.axis:
				return true
				
			return false
		else:
			return true
		
	if b.data.type == Core.InputType.JOYPAD_MOTION:
		return false
		
	if a.data.button_index <= b.data.button_index:
		return true
			
	return false
	

func clear_conflicts() -> void:
	for child_: Node in %VBoxContainer.get_children():
		child_.set_conflict(false)
		
func set_conflicts(input_events_data_: Array[Dictionary]) -> void:
	for child_: Node in %VBoxContainer.get_children():
		var found_: bool = false
		
		for input_event_data_: Dictionary in input_events_data_:
			if Core.dictionary_contains(child_.get_input_event_data(), input_event_data_):
				child_.set_conflict(true)
				found_ = true
				break
		
		if not found_:
			child_.set_conflict(false)

func filter_input_device(input_device_: Core.InputDevice) -> void:
	if input_device_ == Core.InputDevice.NONE:
		for child_: Node in %VBoxContainer.get_children():
			child_.visible = true
	elif input_device_ == Core.InputDevice.KEYBOARD:
		for child_: Node in %VBoxContainer.get_children():
			if child_.data.type == Core.InputType.KEY:
				child_.visible = true
			else:
				child_.visible = false
	elif input_device_ == Core.InputDevice.MOUSE:
		for child_: Node in %VBoxContainer.get_children():
			if child_.data.type == Core.InputType.MOUSE_BUTTON:
				child_.visible = true
			else:
				child_.visible = false
	elif input_device_ == Core.InputDevice.JOYPAD:
		for child_: Node in %VBoxContainer.get_children():
			if (child_.data.type == Core.InputType.JOYPAD_BUTTON or 
				child_.data.type == Core.InputType.JOYPAD_MOTION
			):
				child_.visible = true
			else:
				child_.visible = false

func _on_ui_button_add_pressed() -> void:
	add_pressed.emit(action)
