extends BaseCanvasLayer
class_name UIController

var _data: Dictionary

func _init() -> void:
	if FileAccess.file_exists("res://data/ui.json"):
		var _file: UIDataFile = UIDataFile.new("res://data/ui.json")
		_file.load()
		_data = _file.data
	else:
		_data = {
			&"enabled": [],
			&"uis": []
		}
	
func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if reset_type_ == Core.ResetType.START:
		for ui_: StringName in _data.enabled:
			assert(_data.uis.has(ui_), "UI not found. (" + ui_ + ")")
			
			if not _data.uis.has(ui_):
				continue
			
			var ui_resource_: Resource = load(_data.uis[ui_])
			
			assert(ui_resource_ != null, "UI not found. (" + ui_ + ": " + _data.uis[ui_] + ")")
			
			var ui_node_: BaseUI = ui_resource_.instantiate()

			ui_node_.visible = false
				
			add_child(ui_node_)

func has_button(alias_: StringName) -> bool:
	return _data.buttons.has(alias_)
	
func get_button(alias_: StringName) -> Dictionary:
	return _data.buttons[alias_]
	
func has_check_box(alias_: StringName) -> bool:
	return _data.check_boxes.has(alias_)
	
func get_check_box(alias_: StringName) -> Dictionary:
	return _data.check_boxes[alias_]
	
func has_h_slider(alias_: StringName) -> bool:
	return _data.h_sliders.has(alias_)
	
func get_h_slider(alias_: StringName) -> Dictionary:
	return _data.h_sliders[alias_]
	
func has_label(alias_: StringName) -> bool:
	return _data.labels.has(alias_)
	
func get_label(alias_: StringName) -> Dictionary:
	return _data.labels[alias_]

func has_separator(alias_: StringName) -> bool:
	return _data.separators.has(alias_)
	
func get_separator(alias_: StringName) -> Dictionary:
	return _data.separators[alias_]

func has_margin_container(alias_: StringName) -> bool:
	return _data.margin_containers.has(alias_)
	
func get_margin_container(alias_: StringName) -> Dictionary:
	return _data.margin_containers[alias_]
	
func has_panel_container(alias_: StringName) -> bool:
	return _data.panel_containers.has(alias_)
	
func get_panel_container(alias_: StringName) -> Dictionary:
	return _data.panel_containers[alias_]

func has_ui(alias_: StringName) -> bool:
	for child: Node in get_children():
		if child is BaseUI and child.alias == alias_:
			return true
		
	return false

func get_ui(alias_: StringName) -> BaseUI:
	for child: Node in get_children():
		if child is BaseUI and child.alias == alias_:
			return child
		
	return null
	
func has_visible_uis(ui_type: Core.UIType) -> bool:
	for child: Node in get_children():
		if child is BaseUI and child.ui_type == ui_type and child.visible:
			return true
		
	return false

func is_ui_visible(alias_: StringName) -> bool:
	var ui: BaseUI = get_ui(alias_)
	
	if ui != null and ui.visible == true:
		return true
		
	return false

func hide_uis(ui_type: Core.UIType) -> void:
	for child: Node in get_children():
		if child is BaseUI and child.ui_type == ui_type:
			child.hide_ui()

func hide_ui(alias_: StringName) -> void:
	var ui: BaseUI = get_ui(alias_)
	
	if ui != null:
		ui.hide_ui()
			
func show_ui(alias_: StringName) -> void:
	var ui: BaseUI = get_ui(alias_)
	
	if ui != null:
		ui.show_ui()
	
func prepare_ui_alias(alias_: StringName, from_alias_: StringName) -> StringName:
	if alias_ != &"parent":
		if alias_ == &"difficulty":
			if not Core.ENABLE_GAME_DIFFICULTY or not has_ui(&"difficulty"):
				alias_ = &"level_select"
	
		if alias_ == &"level_select":
			if not Core.ENABLE_LEVEL_SELECT or not has_ui(&"level_select"):
				alias_ = &"start"
			
		return alias_
		
	if Core.game.is_paused:
		return &"pause"
		
	if (from_alias_ == &"level_select" and 
		Core.ENABLE_GAME_DIFFICULTY and
		has_ui(&"difficulty")
	):
		return &"difficulty"
		
	return &"menu"
		
func prepare_ui(alias_: StringName, from_alias_: StringName) -> void:
	if alias_ == &"menu":
		if Core.game.current_level != null and Core.game.current_level.level_mode != Core.LevelMode.MENU:
			Core.game.menu()
	if alias_ == &"settings" and from_alias_ == &"pause":
		Core.audio.normal_volume(Core.AudioType.MUSIC)
		Core.audio.normal_volume(Core.AudioType.AMBIANCE)
	elif alias_ == &"pause"	and from_alias_ == &"settings":
		Core.audio.quiet_volume(Core.AudioType.MUSIC)
		Core.audio.quiet_volume(Core.AudioType.AMBIANCE)
