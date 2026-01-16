class_name SpeechHandler

var _queue: Array[SpeechValue] = []
var _queue_delta: float = 0.0

func reset() -> void:
	_queue.clear()
	_queue_delta = 0.0

func process(delta_: float) -> void:
	if _queue.size() == 0:
		return
		
	_queue_delta -= delta_
	if _queue_delta <= 0.0:
		_queue.pop_front()
		if _queue.size() != 0:
			_queue_delta = _queue[0].delta
			say(_queue[0], false)

func say(line_: SpeechValue, queue_: bool = false) -> void:
	if queue_:
		_queue.push_back(line_)
		if _queue.size() == 1:
			_queue_delta = line_.delta
			say(line_)
		return
	
	if line_.target is BaseUnit:
		var speech_actor: BaseActor = line_.target.get_actor_or_null(&"speech")
		
		if speech_actor != null:
			if (speech_actor.say(line_)):
				return

	#TODO: Fallback or general overlay system?
	
func is_saying(target_: Node2D) -> bool:
	if target_ is BaseUnit:
		var speech_actor: BaseActor = target_.get_actor_or_null(&"speech")
		
		if speech_actor != null:
			return speech_actor.is_saying
			
	return false
		
