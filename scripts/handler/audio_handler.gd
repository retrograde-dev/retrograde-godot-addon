class_name AudioHandler

var _data: Dictionary
var sfx: Dictionary = {}
var music: Dictionary = {}
var ambiance: Dictionary = {}
var dialogue: Dictionary = {}
var last: Dictionary = {}

var _current_volume: Dictionary = {
	Core.AudioType.MASTER: 0.5,
	Core.AudioType.MUSIC: 0.5,
	Core.AudioType.SFX: 0.5,
	Core.AudioType.AMBIANCE: 0.5,
	Core.AudioType.DIALOGUE: 0.5,
}

func _init() -> void:
	var sfx_file: AudioDataFile = AudioDataFile.new("res://data/audio/sfx.json")
	sfx_file.load()
	
	var music_file: AudioDataFile = AudioDataFile.new("res://data/audio/music.json")
	music_file.load()

	_data[Core.AudioType.MUSIC] = music_file.data
	_data[Core.AudioType.SFX] = sfx_file.data
	_data[Core.AudioType.AMBIANCE] = {}
	_data[Core.AudioType.DIALOGUE] = {}

func reset() -> void:
	reset_state()
	reset_audio()

func reset_state() -> void:
	stop_music()
	last.clear()

func reset_audio() -> void:
	reset_sfx()
	reset_music()
	reset_ambiance()
	reset_dialogue()

func reset_sfx() -> void:
	var ui_sfx_: Dictionary = {}
	
	for name: StringName in sfx:
		if name.begins_with(&"ui/"):
			ui_sfx_.set(name, sfx[name])
		else:
			Core.game.remove_level_child(sfx[name])
		
	sfx = ui_sfx_

func reset_music() -> void:
	for name: StringName in music:
		Core.game.remove_level_child(music[name])
	music = {}

func reset_ambiance() -> void:
	for name: StringName in ambiance:
		Core.game.remove_level_child(ambiance[name])
	ambiance = {}
	
func reset_dialogue() -> void:
	for name: StringName in dialogue:
		Core.game.remove_level_child(dialogue[name])
	dialogue = {}

func play_music(name: StringName, fade_time: float = 0.0) -> void:
	_play(Core.AudioType.MUSIC, name, &"", fade_time)

# Stop all music but name if specified
func stop_music(name: StringName = &"", fade_time: float = 0.0) -> void:
	_stop(Core.AudioType.MUSIC, name, fade_time)

func load_music(name: StringName) -> void:
	_load(Core.AudioType.MUSIC, name)

func unload_music(name: StringName) -> void:
	_unload(Core.AudioType.MUSIC, name)

func play_sfx(name: StringName) -> void:
	var count: int = 1
	var rand: bool = false
	var suffix: StringName = &""

	if _data[Core.AudioType.SFX].has(name):
		var data_: Dictionary = _data[Core.AudioType.SFX].get(name)
		count = data_.count
		rand = data_.rand

	if count == 0:
		return

	var last_name_: String = _get_last_name(Core.AudioType.SFX, name)

	if count > 1:
		if rand:
			var index: int

			while true:
				index = randi() % count + 1
				if not last.has(last_name_) or last[last_name_] != index:
					break

			last[last_name_] = index
			suffix = &"_" + str(last[last_name_])
		else:
			if not last.has(last_name_) or last[last_name_] == count:
				last[last_name_] = 1
				suffix = &"_1"
			else:
				last[last_name_] += 1
				suffix = &"_" + str(last[last_name_])

	_play(Core.AudioType.SFX, name, suffix)

func load_sfx(name: StringName) -> void:
	_load(Core.AudioType.SFX, name)

func unload_sfx(name: StringName) -> void:
	_unload(Core.AudioType.SFX, name)

func play_ambiance(name: StringName, fade_time: float = 0.0) -> void:
	_play(Core.AudioType.AMBIANCE, name, &"", fade_time)

func stop_ambiance(name: StringName = &"", fade_time: float = 0.0) -> void:
	_stop(Core.AudioType.AMBIANCE, name, fade_time)

func load_ambiance(name: StringName) -> void:
	_load(Core.AudioType.AMBIANCE, name)

func unload_ambiance(name: StringName) -> void:
	_unload(Core.AudioType.AMBIANCE, name)

func play_dialogue(name: StringName) -> void:
	_play(Core.AudioType.DIALOGUE, name)

func stop_dialogue(name: StringName = &"") -> void:
	_stop(Core.AudioType.DIALOGUE, name)

func load_dialogue(name: StringName) -> void:
	_load(Core.AudioType.DIALOGUE, name)

func unload_dialogue(name: StringName) -> void:
	_unload(Core.AudioType.DIALOGUE, name)

func get_volume(type: Core.AudioType) -> float:
	var bus: int = _get_audio_bus_index(type)
	return db_to_linear(AudioServer.get_bus_volume_db(bus))

func set_volume(type: Core.AudioType, value: float) -> void:
	_current_volume[type] = value;

	var bus: int = _get_audio_bus_index(type)

	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value < 0.05)

func quiet_volume(type: Core.AudioType) -> void:
	var bus: int = _get_audio_bus_index(type)

	# TODO: Make this configurable?
	var value_: float = _current_volume[type] / 3

	AudioServer.set_bus_volume_db(bus, linear_to_db(value_))
	AudioServer.set_bus_mute(bus, value_ < 0.05)

func normal_volume(type: Core.AudioType) -> void:
	var bus: int = _get_audio_bus_index(type)

	AudioServer.set_bus_volume_db(bus, linear_to_db(_current_volume[type]))
	AudioServer.set_bus_mute(bus, _current_volume[type] < 0.05)

func _play(
	type_: Core.AudioType,
	name_: StringName,
	suffix_: StringName = &"",
	fade_time_: float = 0.0
) -> void:
	var audio_: Dictionary = _get_audio(type_)

	_load(type_, name_, suffix_)

	var pitch_: float = 1.0
	var pan_offset_: Vector2 = Vector2.ZERO

	if _data[type_].has(name_):
		var data_: Dictionary = _data[type_].get(name_)
		if data_.pitch:
			pitch_ = randf_range(data_.min_pitch, data_.max_pitch)
			
		if data_.has(&"pan_offset"):
			pan_offset_ = data_.pan_offset

	audio_[name_ + suffix_].pitch_scale = pitch_
	
	if audio_[name_ + suffix_] is AudioStreamPlayer2D:
		audio_[name_ + suffix_].position = Core.camera.position + pan_offset_

	if type_ == Core.AudioType.SFX:
		audio_[name_ + suffix_].play()
	else:
		# Stop audio that is not the specified
		_stop(type_, name_)

		if audio_[name_].playing:
			return

		var last_name_: String = _get_last_name(type_, name_)

		if not last.has(last_name_):
			last[last_name_] = 0.0

		audio_[name_].play(last[last_name_])

		if fade_time_ != 0.0:
			audio_[name_].volume_db = -80.0
			var tween: Tween = Core.game.create_tween()
			tween.tween_property(audio_[name_], "volume_db", 0.0, fade_time_).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _stop(type: Core.AudioType, name: StringName = &"", fade_time: float = 0.0) -> void:
	var audio: Dictionary = _get_audio(type)

	for existing_name: StringName in audio:
		if existing_name == name:
			continue

		if not audio[existing_name].playing:
			continue

		if fade_time != 0.0:
			var tween: Tween = Core.game.create_tween()
			tween.tween_property(audio[existing_name], "volume_db", -80.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_callback(_stop.bind(type, existing_name))
			continue

		if type != Core.AudioType.SFX:
			var last_name: String = _get_last_name(type, existing_name)
			last[last_name] = audio[existing_name].get_playback_position()
		audio[existing_name].stop()
		audio[existing_name].volume_db = 0.0

func _load(type: Core.AudioType, name: StringName, suffix: StringName = &"") -> void:
	var audio: Dictionary = _get_audio(type)

	if audio.has(name + suffix):
		return

	var path: String = _get_path(type)

	var format: StringName = &""
	var pause_: bool = false
	var has_pan: bool = false
	var file_name: StringName = name
	
	if _data[type].has(name):
		var data_: Dictionary = _data[type].get(name)
		format = data_.format

		if data_.has(&"pause"):
			pause_ = data_.pause
			
		if data_.has(&"name"):
			file_name = data_.name
			
		if data_.has(&"pan_offset"):
			has_pan = true
	
	var audio_player: Variant 
	if has_pan:
		audio_player = AudioStreamPlayer2D.new()
	else:
		audio_player = AudioStreamPlayer.new()
	
	match type:
		Core.AudioType.SFX:
			audio_player.bus = &"SFX"
			audio_player.max_polyphony = 16
		Core.AudioType.MUSIC:
			audio_player.bus = &"Music"
			if not pause_:
				audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		Core.AudioType.AMBIANCE:
			audio_player.bus = &"Ambiance"
			if not pause_:
				audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		Core.AudioType.DIALOGUE:
			audio_player.bus = &"Dialogue"

	if format != &"":
		audio_player.stream = load("res://assets/audio/" + path + "/" + file_name + suffix + "." + format)
	else:
		if ResourceLoader.exists("res://assets/audio/" + path + "/" + file_name + suffix + ".ogg"):
			audio_player.stream = load("res://assets/audio/" + path + "/" + file_name + suffix + ".ogg")
		elif ResourceLoader.exists("res://assets/audio/" + path + "/" + file_name + suffix + ".mp3"):
			audio_player.stream = load("res://assets/audio/" + path + "/" + file_name + suffix + ".mp3")
		else:
			audio_player.stream = load("res://assets/audio/" + path + "/" + file_name + suffix + ".wav")

	Core.game.add_level_child(audio_player)

	audio[name + suffix] = audio_player

func _unload(type: Core.AudioType, name: StringName) -> void:
	var audio: Dictionary = _get_audio(type)

	if type == Core.AudioType.SFX:
		var count: int = 1

		if _data[type].has(name):
			var data_: Dictionary = _data[type].get(name)
			count = data_.count

		if count > 1:
			for i: int in count:
				if audio.has(name + "_" + str(count + 1)):
					Core.game.remove_level_child(audio[name + "_" + str(count + 1)])
		elif audio.has(name):
			Core.game.remove_level_child(audio[name])
	else:
		if audio.has(name):
			Core.game.remove_level_child(audio[name])

func _get_audio(type: Core.AudioType) -> Dictionary:
	match type:
		Core.AudioType.SFX:
			return sfx
		Core.AudioType.MUSIC:
			return music
		Core.AudioType.AMBIANCE:
			return ambiance
		Core.AudioType.DIALOGUE:
			return dialogue

	assert(false, "Invalid Core.AudioType passed.")
	return {}

func _get_path(type: Core.AudioType) -> String:
	match type:
		Core.AudioType.SFX:
			return "sfx"
		Core.AudioType.MUSIC:
			return "music"
		Core.AudioType.AMBIANCE:
			return "ambiance"
		Core.AudioType.DIALOGUE:
			return "dialogue"

	assert(false, "Invalid Core.AudioType passed.")
	return ""

func _get_last_name(type: Core.AudioType, name: StringName) -> String:
	match type:
		Core.AudioType.SFX:
			return "sfx." + name
		Core.AudioType.MUSIC:
			return "music." + name
		Core.AudioType.AMBIANCE:
			return "ambiance." + name
		Core.AudioType.DIALOGUE:
			return "dialogue." + name

	assert(false, "Invalid Core.AudioType passed.")
	return ""

func _get_audio_bus_index(type: Core.AudioType) -> int:
	match type:
		Core.AudioType.SFX:
			return AudioServer.get_bus_index(&"SFX")
		Core.AudioType.MUSIC:
			return AudioServer.get_bus_index(&"Music")
		Core.AudioType.AMBIANCE:
			return AudioServer.get_bus_index(&"Ambiance")
		Core.AudioType.DIALOGUE:
			return AudioServer.get_bus_index(&"Dialogue")
		Core.AudioType.MASTER:
			return AudioServer.get_bus_index(&"Master")

	assert(false, "Invalid Core.AudioType passed.")
	return 0
