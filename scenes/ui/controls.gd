extends BaseUI

@onready var _margin_container_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_margin_container.tscn")
@onready var _label_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_label.tscn")
@onready var _separator_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_separator.tscn")
@onready var _field_control: PackedScene = preload("res://addons/retrograde/scenes/ui/controls/ui_actions_field.tscn")

var _capture_input: bool = false
var _capture_action: StringName = &""

var _data: Dictionary
var _conflicts: Dictionary = {}
var _actions: Array[StringName] = []
var _filter_input_device: Core.InputDevice = Core.InputDevice.NONE
var _filter_conflicts: bool = false

var _scroll: bool = false
var _scroll_vertical: int = 0
var _focus_actions_field: UIActionsField = null

func _init() -> void:
	var file_: ControlsDataFile = ControlsDataFile.new("res://data/ui/controls.json")
	file_.load()
	_data = file_.data
	
	super._init(&"controls")

func _process(_delta: float) -> void:
	# We do this here instead of the pressed event becuase otherwise the 
	# scroll container state hasn't been updated yet.
	if _scroll:
		%ScrollContainer.set_v_scroll(_scroll_vertical)
		_scroll_vertical = 0
		_scroll = false

func _input(input_event_: InputEvent) -> void:
	if not _capture_input:
		super._input(input_event_)
		return

	if not input_event_.is_pressed():
		return

	if (input_event_ is InputEventKey or
		input_event_ is InputEventMouseButton or
		input_event_ is InputEventJoypadButton or
		input_event_ is InputEventJoypadMotion
	):
		var added_: bool = false
		
		var control_: UIActionsField = _get_actions_field(_capture_action)
		
		if control_ != null:
			var input_event_data_: Dictionary = Core.inputs._unserialize_input_event(input_event_)
			
			if control_.has_input_event(input_event_data_):
				Core.audio.play_sfx(&"ui/no")
			else:
				control_.add_input_event(input_event_data_)
				added_ = true
		
		_capture_input = false
		
		%ControlInput.visible = false
		%ControlManage.visible = true
		
		if control_ != null:
			control_.get_add_button().grab_focus()
		else:
			%UIButtonParent.grab_focus()
		
		if not added_:
			return
		
		var is_empty_: bool = _conflicts.is_empty()
		
		_update_conflicts()
		
		for action_: StringName in _conflicts:
			if not _actions.has(action_):
				_actions.push_back(action_)
		
		if _conflicts.is_empty():
			%UIButtonIgnoreConflicts.text = "BUTTON_DONE"
		else:
			%UIButtonIgnoreConflicts.text = "BUTTON_IGNORE_CONFLICTS"
		
		if is_empty_ and not _conflicts.is_empty():
			Core.audio.play_sfx(&"ui/conflicts")
			_scroll_vertical = %ScrollContainer.get_v_scroll()
			_focus_actions_field = control_
			_update_filter(_filter_input_device, true)
		elif _filter_conflicts:
			_filter_add_conflicts()
		else:
			_update_focus()
			
		_reset_input_animations()

func show_ui() -> void:
	super.show_ui()
	
	%ControlManage.visible = true
	%ControlInput.visible = false
	
	_add_fields()
	_update_conflicts()
	_update_filter(Core.InputDevice.NONE, false)

func hide_ui() -> void:
	super.hide_ui()
	
	_remove_fields()

func get_action_data() -> Dictionary:
	var data_: Dictionary = {}
	
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIActionsField:
			continue
		
		var action_: StringName = child_.get_action()
		var input_events_data_: Array[Dictionary] = child_.get_input_events_data()
		data_[action_] = input_events_data_
	
	return data_
	
func get_input_events_data(action_: StringName) -> Array[Dictionary]:
	var control_: UIActionsField = _get_actions_field(action_)
	
	if control_ != null:
		return control_.get_input_events_data()
	
	return []

func _get_input_events(action_: StringName) -> Array[Dictionary]:
	if _data.has(&"groups") and _data.groups.has(action_):
		for group_action_: StringName in _data.groups[action_]:
			if Core.inputs.has_action(group_action_):
				return Core.inputs.get_input_events_data(group_action_)
				
		return []
		
	return Core.inputs.get_input_events_data(action_)
	
func _set_input_events(action_: StringName, input_events_data_: Array[Dictionary]) -> void:
	if _data.has(&"groups") and _data.groups.has(action_):
		for group_action_: StringName in _data.groups[action_]:
			Core.inputs.set_input_events_data(group_action_, input_events_data_)
	else:
		Core.inputs.set_input_events_data(action_, input_events_data_)
	
func _get_actions_field(action_: StringName) -> UIActionsField:
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIActionsField:
			continue
		
		if action_ != child_.get_action():
			continue
		
		return child_
	
	return null

func capture_input(action_: StringName) -> void:
	%ControlManage.visible = false
	%ControlInput.visible = true
	_capture_input = true
	_capture_action = action_
	
func filter_input_device(input_device_: Core.InputDevice) -> void:
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIActionsField:
			continue
			
		child_.filter_input_device(input_device_)

func filter_conflicts(conflicts_: bool) -> void:
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIActionsField:
			child_.visible = true
			continue
			
		if not conflicts_:
			child_.visible = true
			child_.clear_conflicts()
			continue
			
		if _actions.has(child_.get_action()):
			child_.visible = true
			var input_events_data_: Array[Dictionary] = []
			
			if _conflicts.has(child_.get_action()):
				for input_event_data_: Dictionary in _conflicts[child_.get_action()]:
					input_events_data_.push_back(input_event_data_)
				
				child_.set_conflicts(input_events_data_)
			else:
				child_.clear_conflicts()
		else:
			child_.visible = false

	_hide_unused()
	_update_focus()

func _filter_add_conflicts() -> void:
	for child_: Node in %VBoxContainer.get_children():
		if not child_ is UIActionsField:
			continue
		
		if child_.visible or _conflicts.has(child_.get_action()):
			child_.visible = true
			
			var input_events_data_: Array[Dictionary] = []
			
			if _conflicts.has(child_.get_action()):
				for input_event_data_: Dictionary in _conflicts[child_.get_action()]:
					input_events_data_.push_back(input_event_data_)
			
			child_.set_conflicts(input_events_data_)
	
	_hide_unused()
	_update_focus()

func _reset_input_animations() -> void:
	for child_: Node in %VBoxContainer.get_children():
		if child_ is UIActionsField:
			child_.reset()

func _add_fields() -> void:
	for layout_: Dictionary in _data.layout:
		if %VBoxContainer.get_child_count() != 0:
			%VBoxContainer.add_child(_create_separator())
		
		if layout_.alias != &"":
			%VBoxContainer.add_child(_create_layout_title(layout_.alias))
		
		for action_: StringName in layout_.items:
			%VBoxContainer.add_child(_create_action_field(action_))

func _create_separator() -> UISeparator:
	var separator_control_: UISeparator = _separator_control.instantiate()
	separator_control_.style = &"section"
	return separator_control_
	
func _create_layout_title(alias_: StringName) -> UIMarginContainer:
	var margin_container_control_: UIMarginContainer = _margin_container_control.instantiate()
	margin_container_control_.style = &"title"
	
	var label_control_: UILabel = _label_control.instantiate()
	label_control_.style = &"title"
	label_control_.text = "TITLE:controls_" + alias_
	label_control_.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	margin_container_control_.add_child(label_control_)
	
	return margin_container_control_

func _create_action_field(action_: StringName) -> UIActionsField:
	var field_control_: UIActionsField = _field_control.instantiate()
	field_control_.set_action(action_)
	field_control_.set_input_events_data(_get_input_events(action_))
	field_control_.add_pressed.connect(_on_add_pressed)
	field_control_.remove_pressed.connect(_on_remove_pressed)
	
	return field_control_
			
func _remove_fields() -> void:
	for child_: Node in %VBoxContainer.get_children():
		if child_ is UIActionsField:
			child_.add_pressed.disconnect(_on_add_pressed)
			child_.remove_pressed.disconnect(_on_remove_pressed)
		child_.queue_free()
		
func _update_focus() -> void:
	var first_action_field_: UIActionsField = null
	var last_action_field_: UIActionsField = null
	
	for child_: Node in %VBoxContainer.get_children():
		if not child_.visible:
			if child_ is UIActionsField:
				child_.focus_neighbor_left = NodePath("")
				child_.focus_neighbor_top = NodePath("")
				child_.focus_neighbor_right = NodePath("")
				child_.focus_neighbor_bottom = NodePath("")
				child_.focus_next = NodePath("")
				child_.focus_previous = NodePath("")
				
			continue
		
		if not child_ is UIActionsField:
			continue
		
		if first_action_field_ == null:
			first_action_field_ = child_
			
		if last_action_field_ != null:
			# Previous field buttons down
			last_action_field_.get_add_button().focus_neighbor_bottom = child_.get_add_button().get_path()
			
			if last_action_field_.get_last_remove_button() != null:
				if child_.get_first_remove_button() != null:
					last_action_field_.get_last_remove_button().focus_neighbor_bottom = child_.get_first_remove_button().get_path()
				else:
					last_action_field_.get_last_remove_button().focus_neighbor_bottom = child_.get_add_button().get_path()
				
			# Current field buttons up
			child_.get_add_button().focus_neighbor_top = last_action_field_.get_add_button().get_path()
			
			if child_.get_first_remove_button() != null:
				if last_action_field_.get_last_remove_button() != null:
					child_.get_first_remove_button().focus_neighbor_top = last_action_field_.get_last_remove_button().get_path()
				else:
					child_.get_first_remove_button().focus_neighbor_top = last_action_field_.get_add_button().get_path()
					
		else:
			child_.get_add_button().focus_neighbor_top = %UIButtonIgnoreConflicts.get_path()
			
			if child_.get_first_remove_button() != null:
				child_.get_first_remove_button().focus_neighbor_top = %UIButtonIgnoreConflicts.get_path()
		
		# Add button left and right
		if child_.get_first_remove_button() != null:
			child_.get_add_button().focus_neighbor_left = child_.get_first_remove_button().get_path()
			child_.get_add_button().focus_neighbor_right = child_.get_first_remove_button().get_path()
		
		# Remove buttons left and right
		for remove_button_: UIButton in child_.get_remove_buttons():
			remove_button_.focus_neighbor_left = child_.get_add_button().get_path()
			remove_button_.focus_neighbor_right = child_.get_add_button().get_path()
			
		last_action_field_ = child_
	
	if last_action_field_ != null:
		pass
	
	if first_action_field_ == null:
		%UIButtonReset.focus_previous = %UIButtonJoypad.get_path()
		%UIButtonJoypad.focus_next = %UIButtonReset.get_path()
		
		%UIButtonAll.focus_neighbor_top = NodePath("")
		%UIButtonReset.focus_neighbor_top = NodePath("")
		%UIButtonConflicts.focus_neighbor_top = NodePath("")
		%UIButtonKeyboard.focus_neighbor_top = NodePath("")
		%UIButtonMouse.focus_neighbor_top = NodePath("")
		%UIButtonJoypad.focus_neighbor_top = NodePath("")
		
		%UIButtonIgnoreConflicts.focus_neighbor_bottom = NodePath("")
		%UIButtonReset.focus_neighbor_bottom = NodePath("")
		%UIButtonConflicts.focus_neighbor_bottom = NodePath("")
		%UIButtonKeyboard.focus_neighbor_bottom = NodePath("")
		%UIButtonMouse.focus_neighbor_bottom = NodePath("")
		%UIButtonJoypad.focus_neighbor_bottom = NodePath("")
		return
	
	first_action_field_.get_add_button().focus_neighbor_top = %UIButtonIgnoreConflicts.get_path()
	first_action_field_.get_add_button().focus_previous = %UIButtonJoypad.get_path()
	
	if first_action_field_.get_first_remove_button() != null:
		first_action_field_.get_first_remove_button().focus_neighbor_top = %UIButtonIgnoreConflicts.get_path()
	
	last_action_field_.get_add_button().focus_neighbor_bottom = %UIButtonParent.get_path()
	if last_action_field_.get_last_remove_button() != null:
		last_action_field_.get_last_remove_button().focus_neighbor_bottom = %UIButtonParent.get_path()
		%UIButtonReset.focus_previous = last_action_field_.get_last_remove_button().get_path()
	else:
		%UIButtonReset.focus_previous = last_action_field_.get_add_button().get_path()
	
	%UIButtonJoypad.focus_next = first_action_field_.get_add_button().get_path()
	
	# Buttons up
	%UIButtonReset.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	
	%UIButtonParent.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	
	%UIButtonAll.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	%UIButtonConflicts.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	%UIButtonKeyboard.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	%UIButtonMouse.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	%UIButtonJoypad.focus_neighbor_top = last_action_field_.get_add_button().get_path()
	
	# Buttons down
	%UIButtonReset.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
	
	%UIButtonIgnoreConflicts.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()

	%UIButtonAll.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
	%UIButtonConflicts.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
	%UIButtonKeyboard.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
	%UIButtonMouse.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
	%UIButtonJoypad.focus_neighbor_bottom = first_action_field_.get_add_button().get_path()
		
func _update_conflicts() -> void:
	var data_: Dictionary = get_action_data()
	
	var groups_: Array[Array] = []
	
	# Group actions that have the same input events
	for action_: StringName in data_:
		for input_event_data_: Dictionary in data_[action_]:
			var found_: bool = false
			
			# Add to existing group
			for group_: Array in groups_:
				if Core.dictionary_contains(input_event_data_, group_[0]):
					group_[1].append(action_)
					found_ = true
					break
			
			# Add to new group
			if not found_:
				groups_.append([input_event_data_, [action_]])
	
	var conflicts_: Dictionary = {}
	
	for group_: Array in groups_:
		if group_[1].size() < 2:
			continue
		
		for action_: StringName in group_[1]:
			if not conflicts_.has(action_):
				conflicts_[action_] = []
			
			conflicts_[action_].append(group_[0])
	
	_conflicts = conflicts_
	
func _update_filter(filter_input_device_: Core.InputDevice, filter_conflicts_: bool) -> void:
	_filter_input_device = filter_input_device_
	_filter_conflicts = filter_conflicts_

	if filter_input_device_ == Core.InputDevice.KEYBOARD:
		%UIButtonAll.button_pressed = false
		%UIButtonConflicts.button_pressed = false
		%UIButtonKeyboard.button_pressed = true
		%UIButtonMouse.button_pressed = false
		%UIButtonJoypad.button_pressed = false
	elif filter_input_device_ == Core.InputDevice.MOUSE:
		%UIButtonAll.button_pressed = false
		%UIButtonConflicts.button_pressed = false
		%UIButtonKeyboard.button_pressed = false
		%UIButtonMouse.button_pressed = true
		%UIButtonJoypad.button_pressed = false
	elif filter_input_device_ == Core.InputDevice.JOYPAD:
		%UIButtonAll.button_pressed = false
		%UIButtonConflicts.button_pressed = false
		%UIButtonKeyboard.button_pressed = false
		%UIButtonMouse.button_pressed = false
		%UIButtonJoypad.button_pressed = true
	else:
		%UIButtonAll.button_pressed = true
		%UIButtonConflicts.button_pressed = true
		%UIButtonKeyboard.button_pressed = false
		%UIButtonMouse.button_pressed = false
		%UIButtonJoypad.button_pressed = false
	
	if filter_conflicts_:
		%UIButtonConflicts.visible = false
		%UIButtonAll.visible = true
		
		%UIButtonReset.visible = false
		%UIButtonParent.visible = false
		%UIButtonIgnoreConflicts.visible = true
	else:
		if not _conflicts.is_empty() and filter_input_device_ == Core.InputDevice.NONE:
			%UIButtonConflicts.visible = true
			%UIButtonAll.visible = false
		else:
			%UIButtonConflicts.visible = false
			%UIButtonAll.visible = true
			
		%UIButtonIgnoreConflicts.visible = false
		%UIButtonReset.visible = true
		%UIButtonParent.visible = true
		
	filter_conflicts(filter_conflicts_)
	filter_input_device(filter_input_device_)
	
func _hide_unused() -> void:
	var prev_separator: UISeparator = null
	var prev_title: UIMarginContainer = null

	# Title - UIMarginContainer
	# Action - UIActionField
	# Separator - UISeparator
	# Title - UIMarginContainer
	# Action - UIActionField
	for child_: Node in %VBoxContainer.get_children():
		if not child_.visible:
			continue
		
		if child_ is UISeparator:
			if prev_title != null:
				prev_title.visible = false
				
			if prev_separator != null:
				prev_separator.visible = false
				
			prev_separator = child_
			continue

		if child_ is UIMarginContainer:
			prev_title = child_
			continue
			
		prev_separator = null
		prev_title = null
	
	if prev_title != null:
		prev_title.visible = false
		
	if prev_separator != null:
		prev_separator.visible = false

func _on_add_pressed(action_: StringName) -> void:
	capture_input(action_)
	
func _on_remove_pressed(action_: StringName, input_event_data_: Dictionary) -> void:
	Core.inputs.set_input_events_data(action_, get_input_events_data(action_))
	
	if _conflicts.is_empty():
		_update_focus()
		return
	
	_update_conflicts()
	_filter_add_conflicts()
		
	if _conflicts.is_empty():
		%UIButtonIgnoreConflicts.text = "BUTTON_DONE"
	else:
		%UIButtonIgnoreConflicts.text = "BUTTON_IGNORE_CONFLICTS"

func _on_ui_button_reset_pressed() -> void:
	Core.inputs.reset()
	
	_filter_conflicts = false
	
	_remove_fields()
	_add_fields()
	_update_conflicts()
	_update_filter(_filter_input_device, _filter_conflicts)

func _on_ui_button_all_pressed() -> void:
	if _filter_conflicts:
		_update_filter(Core.InputDevice.NONE, true)
	else:
		_update_filter(Core.InputDevice.NONE, false)

func _on_ui_button_conflicts_pressed() -> void:
	_actions = []
	for action_: StringName in _conflicts:
		_actions.push_back(action_)
	
	_update_filter(Core.InputDevice.NONE, true)

func _on_ui_button_keyboard_pressed() -> void:
	if %UIButtonKeyboard.button_pressed:
		_update_filter(Core.InputDevice.KEYBOARD, _filter_conflicts)
	else:
		_update_filter(Core.InputDevice.NONE, _filter_conflicts)

func _on_ui_button_mouse_pressed() -> void:
	if %UIButtonMouse.button_pressed:
		_update_filter(Core.InputDevice.MOUSE, _filter_conflicts)
	else:
		_update_filter(Core.InputDevice.NONE, _filter_conflicts)
	
func _on_ui_button_joypad_pressed() -> void:
	if %UIButtonJoypad.button_pressed:
		_update_filter(Core.InputDevice.JOYPAD, _filter_conflicts)
	else:
		_update_filter(Core.InputDevice.NONE, _filter_conflicts)

func _on_ui_button_parent_pressed() -> void:
	var data_: Dictionary = get_action_data()
	
	for action_: StringName in data_:
		Core.inputs.set_input_events_data(action_, data_[action_])
			
	Core.inputs.save()

func _on_ui_button_ignore_conflicts_pressed() -> void:
	_actions.clear()
	
	_update_filter(_filter_input_device, false)
	
	_scroll = true
	
	if _focus_actions_field != null:
		_focus_actions_field.get_add_button().grab_focus()
	else:
		%UIButtonParent.grab_focus()
