class_name HelpHandler

var notices: Array[StringName] = []

func reset() -> void:
	notices = []

func issue_notice(name: StringName) -> bool:
	if notices.has(name):
		return false

	notices.push_back(name)

	#if Core.player !== null:
	#	Core.player.speech.say(name)

	return true
