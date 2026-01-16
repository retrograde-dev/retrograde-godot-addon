extends BaseJsonFile
class_name SettingsFile

const FILE_PATH: String = "user://settings.json"

var default_data: Dictionary

func _init() -> void:
	super._init(FILE_PATH)
	
	var enabled_: Array[StringName] = []
	
	if FileAccess.file_exists("res://data/ui/settings.json"):
		var file_: SettingsDataFile = SettingsDataFile.new("res://data/ui/settings.json")
		file_.load()
		
		if not file_.data.enabled.has(&"locale"):
			enabled_.push_back(&"locale")
			
		enabled_.append_array(file_.data.enabled)
	else:
		enabled_.push_back(&"locale")
	
	for alias_: StringName in enabled_:
		if (alias_ == &"audio_master" or
			alias_ == &"audio_music" or
			alias_ == &"audio_sfx" or
			alias_ == &"audio_ambiance"
		):
			default_data.set(alias_, 0.5)
		else:
			default_data.set(alias_, Core[alias_])

func clean_save_data(_data: Variant) -> Variant:
	var data_: Dictionary = {}
	
	for alias_: StringName in default_data:
		if alias_ == &"audio_master":
			data_.set(alias_, Core.audio.get_volume(Core.AudioType.MASTER))
		elif alias_ == &"audio_music":
			data_.set(alias_, Core.audio.get_volume(Core.AudioType.MUSIC))
		elif alias_ == &"audio_sfx":
			data_.set(alias_, Core.audio.get_volume(Core.AudioType.SFX))
		elif alias_ == &"audio_ambiance":
			data_.set(alias_, Core.audio.get_volume(Core.AudioType.AMBIANCE))
		else:
			data_.set(alias_, Core[alias_])

	return data_
	
func load() -> void:
	super.load()
	
	_load_from_data(data)

func _load_from_data(data_: Dictionary) -> void:
	for alias_: StringName in default_data:
		if alias_ == &"audio_master":
			if data_.has(alias_):
				Core.audio.set_volume(Core.AudioType.MASTER, data_[alias_])
			else:
				Core.audio.set_volume(Core.AudioType.MASTER, default_data[alias_])
		elif alias_ == &"audio_music":
			if data_.has(alias_):
				Core.audio.set_volume(Core.AudioType.MUSIC, data_[alias_])
			else:
				Core.audio.set_volume(Core.AudioType.MUSIC, default_data[alias_])
		elif alias_ == &"audio_sfx":
			if data_.has(alias_):
				Core.audio.set_volume(Core.AudioType.SFX, data_[alias_])
			else:
				Core.audio.set_volume(Core.AudioType.SFX, default_data[alias_])
		elif alias_ == &"audio_ambiance":
			if data_.has(alias_):
				Core.audio.set_volume(Core.AudioType.AMBIANCE, data_[alias_])
			else:
				Core.audio.set_volume(Core.AudioType.AMBIANCE, default_data[alias_])
		else:
			if data_.has(alias_):
				Core[alias_] = data_[alias_]
			else:
				Core[alias_] = default_data[alias_]
		
	if TranslationServer.get_locale() != Core.locale and TranslationServer.get_locale().substr(0, 3) != Core.locale + "_":
		TranslationServer.set_locale(Core.locale)
