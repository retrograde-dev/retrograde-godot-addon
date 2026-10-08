class_name SpeechValue

var target: Node2D = null
var line: String
var delta: float
var style: Core.SpeechStyle = Core.SpeechStyle.TALK
var size: Core.SpeechSize = Core.SpeechSize.MEDIUM
var alignment: Core.Alignment = Core.Alignment.BOTTOM_CENTER
var orientation: Core.Orientation = Core.Orientation.VERTICAL
var attr: Dictionary

func _init(
	target_: Node2D,
	line_: String,
	delta_: float = 2.0,
	style_: Core.SpeechStyle = Core.SpeechStyle.TALK,
	size_: Core.SpeechSize = Core.SpeechSize.MEDIUM,
	alignment_: Core.Alignment = Core.Alignment.BOTTOM_CENTER,
	orientation_: Core.Orientation = Core.Orientation.VERTICAL,
	attr_: Dictionary = {},
) -> void:
	target = target_
	line = line_
	delta = delta_
	style = style_
	size = size_
	alignment = alignment_
	orientation = orientation_
	attr = attr_
