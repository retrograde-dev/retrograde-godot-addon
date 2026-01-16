extends BaseUI

@onready var _label_control: PackedScene = preload("res://addons/retrograde/scenes/ui/component/ui_label.tscn")

var _data: Dictionary

func _init() -> void:
	var file_: CreditsDataFile = CreditsDataFile.new("res://data/ui/credits.json")
	file_.load()
	_data = file_.data
	
	super._init(&"credits")

func _ready() -> void:
	super._ready()
	
	for order_: Dictionary in _data.order:
		var label_control_: UILabel = _label_control.instantiate()
		label_control_.style = &"field"
		label_control_.text = "TITLE:credits_" + order_.alias
		label_control_.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		%GridContainer.add_child(label_control_)

		var vbox_container: VBoxContainer = VBoxContainer.new()
	
		for name_: StringName in order_.names:
			label_control_ = _label_control.instantiate()
			label_control_.style = &"value"
			label_control_.text = name_
			
			vbox_container.add_child(label_control_)
		
		%GridContainer.add_child(vbox_container)
		
