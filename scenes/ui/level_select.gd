extends BaseUI

@onready var _margin_container_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_margin_container.tscn")
@onready var _label_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_label.tscn")
@onready var _level_select_button: PackedScene = preload("res://addons/retrograde/scenes/ui/controls/ui_level_select_button.tscn")

func _init() -> void:
	super._init(&"level_select")
	
func _ready() -> void:
	for layout_: Dictionary in Core.level_select.get_layout():
		if layout_.alias != &"":
			%VBoxContainer.add_child(_create_layout_title(layout_.alias))
	
		var grid_: GridContainer = GridContainer.new()
		grid_.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
		if layout_.levels.size() < Core.UI_LEVEL_SELECT_COLUMNS:
			grid_.columns = layout_.levels.size()
		else:
			grid_.columns = Core.UI_LEVEL_SELECT_COLUMNS
			
		%VBoxContainer.add_child(grid_)
			
		for level_alias_: StringName in layout_.levels:
			var button_: Node = _level_select_button.instantiate()
			button_.goto_ui_alias = &"start:" + level_alias_
			grid_.add_child(button_)
			button_.text = "LEVEL:" + level_alias_

func _create_layout_title(alias_: StringName) -> UIMarginContainer:
	var margin_container_control_: UIMarginContainer = _margin_container_control.instantiate()
	margin_container_control_.style = &"subtitle"
	
	var label_control_: UILabel = _label_control.instantiate()
	label_control_.style = &"subtitle"
	label_control_.text = "TITLE:level_select_" + alias_
	label_control_.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	margin_container_control_.add_child(label_control_)
	
	return margin_container_control_
		
func update() -> void:
	super.update()
	
	if Core.level != null and Core.level.level_mode == Core.LevelMode.GAME:
		%UIButtonParent.text = "BUTTON_MENU"
	else:
		%UIButtonParent.text = "BUTTON_BACK"
	
	for grid_: Node in %VBoxContainer.get_children():
		if not grid_ is GridContainer:
			continue
			
		for button_: Node in grid_.get_children():
			if not button_ is UIButton:
				continue
				
			button_.update()
