extends BaseUI

@onready var _margin_container_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_margin_container.tscn")
@onready var _label_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_label.tscn")
@onready var _check_box_control: PackedScene = preload("res://addons/retrograde/scenes/ui/controls/ui_check_box_field.tscn")
@onready var _h_slider_control: PackedScene = preload("res://addons/retrograde/scenes/ui/controls/ui_h_slider_field.tscn")

var _data: Dictionary
var _fields: Dictionary = {}

func _init() -> void:
	if FileAccess.file_exists("res://data/ui/settings.json"):
		var file_: SettingsDataFile = SettingsDataFile.new("res://data/ui/settings.json")
		file_.load()
		_data = file_.data
	else:
		_data = {
			&"enabled": [],
			&"layout": [],
			&"settings": {}
		}
			
	super._init(&"settings")
	
func _ready() -> void:
	super._ready()
		
	for layout_: Dictionary in _data.layout:
		if layout_.alias != &"":
			%VBoxContainer.add_child(_create_layout_title(layout_.alias))
	
		for item_: StringName in layout_.items:
			if _data.settings[item_].type == &"h_slider":
				%VBoxContainer.add_child(_create_h_slider_control(item_, _data.settings[item_]))
			elif _data.settings[item_].type == &"check_box":
				%VBoxContainer.add_child(_create_check_box_control(item_, _data.settings[item_]))

func _create_layout_title(alias_: StringName) -> UIMarginContainer:
	var margin_container_control_: UIMarginContainer = _margin_container_control.instantiate()
	margin_container_control_.style = &"subtitle"
	
	var label_control_: UILabel = _label_control.instantiate()
	label_control_.style = &"subtitle"
	label_control_.text = "TITLE:settings_" + alias_
	label_control_.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	margin_container_control_.add_child(label_control_)
	
	return margin_container_control_
	
func _create_h_slider_control(alias_: StringName, settings_: Dictionary) -> UIHSliderField:
	var control_: UIHSliderField = _h_slider_control.instantiate()
	control_.text = "LABEL:settings_" + alias_
	
	if settings_.max_value > settings_.min_value:
		control_.min_value = settings_.min_value
		control_.max_value = settings_.max_value
		control_.step = settings_.step
	else:
		control_.max_value = settings_.min_value
		control_.min_value = settings_.min_value - (settings_.min_value - settings_.max_value)
		control_.step = settings_.step
		
	control_.value_changed.connect(_on_ui_h_slider_field_value_changed.bind(alias_))
	
	_fields.set(alias_, control_)
	
	_set_field_value(alias_, Core.settings.data.get(alias_, Core.settings.default_data[alias_]))
	
	return control_
	
func _create_check_box_control(alias_: StringName, _settings_: Dictionary) -> UICheckBoxField:
	var control_: UICheckBoxField = _check_box_control.instantiate()
	control_.text = "LABEL:settings_" + alias_
	
	control_.toggled.connect(_on_ui_check_box_field_toggled.bind(alias_))
	
	_fields.set(alias_, control_)
	
	_set_field_value(alias_, Core.settings.data.get(alias_, Core.settings.default_data[alias_]))
	
	return control_
	
func _set_field_value(alias_: StringName, value_: Variant) -> void:
	var settings_: Dictionary = _data.settings[alias_]
	
	if settings_.type == &"h_slider":
		if settings_.max_value > settings_.min_value:
			_fields[alias_].value = value_
		else:
			_fields[alias_].value = _fields[alias_].min_value + (settings_.min_value - value_)
	else:
		_fields[alias_].value = value_
		
func _get_field_value(alias_: StringName) -> Variant:
	var settings_: Dictionary = _data.settings[alias_]
	
	if settings_.type == &"h_slider":
		if settings_.max_value > settings_.min_value:
			return _fields[alias_].value
		else:
			return settings_.min_value - (_fields[alias_].value - _fields[alias_].min_value)
	else:
		return _fields[alias_].value

func _on_ui_h_slider_field_value_changed(value_: float, alias_: StringName) -> void:
	if alias_ == &"audio_master":
		Core.audio.set_volume(Core.AudioType.MASTER, value_)
	elif alias_ == &"audio_music":
		Core.audio.set_volume(Core.AudioType.MUSIC, value_)
	elif alias_ == &"audio_sfx":
		Core.audio.set_volume(Core.AudioType.SFX, value_)
	elif alias_ == &"audio_ambiance":
		Core.audio.set_volume(Core.AudioType.AMBIANCE, value_)
	else:
		Core[alias_] = _get_field_value(alias_)
		
	Core.settings.data[alias_] = value_

func _on_ui_check_box_field_toggled(toggled_on_: bool, alias_: StringName) -> void:
	Core[alias_] = toggled_on_
	Core.settings.data[alias_] = toggled_on_

func _on_ui_button_reset_pressed() -> void:
	for alias_: StringName in _fields:
		if alias_ == &"audio_master":
			Core.audio.set_volume(Core.AudioType.MASTER, Core.settings.default_data[alias_])
		elif alias_ == &"audio_music":
			Core.audio.set_volume(Core.AudioType.MUSIC, Core.settings.default_data[alias_])
		elif alias_ == &"audio_sfx":
			Core.audio.set_volume(Core.AudioType.SFX, Core.settings.default_data[alias_])
		elif alias_ == &"audio_ambiance":
			Core.audio.set_volume(Core.AudioType.AMBIANCE, Core.settings.default_data[alias_])
		else:
			Core[alias_] = Core.settings.default_data[alias_]
		
		_set_field_value(alias_, Core.settings.default_data[alias_])

func _on_ui_button_parent_pressed() -> void:
	Core.settings.save()
