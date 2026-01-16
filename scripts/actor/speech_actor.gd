extends BaseActor
class_name SpeechActor

var unit: BaseCharacterBody2D
var _timer: CooldownTimer = CooldownTimer.new(0.0)

var is_saying: bool = false

func _init(unit_: BaseCharacterBody2D, enabled_: bool = true) -> void:
	super._init(&"speech", enabled_)
	unit = unit_

func process(delta_: float) -> void:
	super.process(delta_)
	
	if not can_process():
		return
		
	_timer.process(delta_)
	
	if _timer.is_complete:
		_timer.stop()
		is_saying = false
		
		var speech_: BaseSpeech = unit.get_node_or_null("%Speech")
		
		if speech_ != null:
			speech_.visible = false

func say(line_: SpeechValue) -> bool:
	var speech_: BaseSpeech = unit.get_node_or_null("%Speech")
	
	if speech_ == null:
		return false
	
	speech_.set_line(line_.line)
	speech_.set_style(line_.style)
	speech_.set_size(line_.size)
	speech_.set_alignment(line_.alignment)
	speech_.set_orientation(line_.orientation)
	speech_.refresh()
	speech_.visible = true
	
	_timer.stop()
	_timer.delta = line_.delta
	_timer.start()
	is_saying = true
	return true
