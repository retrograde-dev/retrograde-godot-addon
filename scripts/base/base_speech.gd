extends BaseNode2D
class_name BaseSpeech

var speech_line: String = ""
var speech_alignment: Core.Alignment = Core.Alignment.BOTTOM_CENTER
var speech_orientation: Core.Orientation = Core.Orientation.VERTICAL
var speech_style: Core.SpeechStyle = Core.SpeechStyle.TALK
var speech_size: Core.SpeechSize = Core.SpeechSize.MEDIUM

var _refresh_bubble_required: bool = true
var _refresh_line_required: bool = true

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or 
		reset_type_ == Core.ResetType.RESTART
	):
		speech_line = ""
		speech_alignment = Core.Alignment.BOTTOM_CENTER
		speech_orientation = Core.Orientation.VERTICAL
		speech_style = Core.SpeechStyle.TALK
		speech_size = Core.SpeechSize.MEDIUM
		_refresh_bubble_required = true
		_refresh_line_required = true
	elif reset_type_ == Core.ResetType.REFRESH:
		refresh_lines()
		refresh_bubble()

func set_line(speech_line_: String) -> void:
	speech_line = speech_line_
	_refresh_line_required = true
	
func set_alignment(speech_alignment_: Core.Alignment) -> void:
	if speech_alignment != speech_alignment_:
		speech_alignment = speech_alignment_
		_refresh_bubble_required = true
		
func set_orientation(speech_orientation_: Core.Orientation) -> void:
	if speech_orientation != speech_orientation_:
		speech_orientation = speech_orientation_
		_refresh_bubble_required = true
	
func set_style(speech_style_: Core.SpeechStyle) -> void:
	if speech_style != speech_style_:
		speech_style = speech_style_
		_refresh_bubble_required = true
	
func set_size(speech_size_: Core.SpeechSize) -> void:
	if speech_size != speech_size_:
		speech_size = speech_size_
		_refresh_bubble_required = true

func _process(delta_: float) -> void:
	super._process(delta_)
	
	if not is_running():
		return
		
	if _refresh_bubble_required:
		refresh_bubble()
		
	if _refresh_line_required:
		refresh_lines()

func refresh_bubble() -> void:
	_refresh_bubble_required = false
	
func refresh_lines() -> void:
	_refresh_line_required = false
