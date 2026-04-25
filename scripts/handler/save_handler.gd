class_name SaveHandler

const SAVE_PATH: String = "user://saves/"
const SAVE_PREFIX: String = "save_"
const SAVE_EXTENSION: String = ".tres"
const AUTO_SAVE_PATH: String = "user://saves/auto/"
const LAST_GAME_FILE: String = "user://last_game.json"

var _last_game_file: JsonFile
var _files: PackedStringArray = []
var _next_id: int = 1

signal load_error(save_id_: int, save_type_: Core.SaveType)
signal load_before(save_id_: int, save_type_: Core.SaveType)
signal load_after(save_id_: int, data_: GameResource, save_type_: Core.SaveType)

signal save_error(save_id_: int, data_: GameResource, save_type_: Core.SaveType)
signal save_before(save_id_: int, data_: GameResource, save_type_: Core.SaveType)
signal save_after(save_id_: int, data_: GameResource, save_type_: Core.SaveType)

signal delete_error(save_id_: int, save_type_: Core.SaveType)
signal delete_before(save_id_: int, save_type_: Core.SaveType)
signal delete_after(save_id_: int, save_type_: Core.SaveType)
#TODO: Threading for saving so as to not intrupt game during autosave/checkpoint/etc
#var _thread: Thread

func _init() -> void:
	_last_game_file = JsonFile.new(LAST_GAME_FILE)
	_last_game_file.load()
	
	var error_: Error = DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	if error_ != OK:
		return
		
	error_ = DirAccess.make_dir_recursive_absolute(AUTO_SAVE_PATH)
	if error_ != OK:
		return

	var files_: PackedStringArray = DirAccess.get_files_at(SAVE_PATH)
	
	for file_: String in files_:
		if not file_.begins_with(SAVE_PREFIX):
			continue
		
		if not ResourceLoader.exists(SAVE_PATH + file_, "GameResource"):
			continue
			
		_files.append(file_.get_basename())
			
		var file_id_: String = file_.substr(
			SAVE_PREFIX.length(),
			file_.length() - SAVE_PREFIX.length() - SAVE_EXTENSION.length()
		)
		
		if file_id_.is_valid_int():
			var id_: int = file_id_.to_int()
			if id_ > _next_id:
				_next_id = id_
				
	_next_id += 1
				
func has_last_game() -> bool:
	if _last_game_file.data.is_empty():
		return false
		
	if not _last_game_file.data.has(&"save_id"):
		return false
		
	var path_: String = get_save_path(
		_last_game_file.data.get(&"save_id"),
		_last_game_file.data.get(&"save_type", Core.SaveType.NORMAL)
	)
	
	return ResourceLoader.exists(path_, "GameResource")
	
func load_last_game() -> GameResource:
	if _last_game_file.data.is_empty():
		load_error.emit(0, Core.SaveType.NORMAL)
		return null
		
	if not _last_game_file.data.has(&"save_id"):
		load_error.emit(0, Core.SaveType.NORMAL)
		return null
		
	var save_id_: int = _last_game_file.data.get(&"save_id")
	var save_type_: Core.SaveType = _last_game_file.data.get(&"save_type", Core.SaveType.NORMAL)
	
	var path_: String = get_save_path(save_id_, save_type_)
	
	if not ResourceLoader.exists(path_, "GameResource"):
		load_error.emit(save_id_, save_type_)
		return null
	
	load_before.emit(save_id_, save_type_)

	var data_: GameResource = ResourceLoader.load(path_)
	
	load_after.emit(save_id_, data_, save_type_)
	
	return data_

func load_game(
	save_id_: int, 
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> GameResource:
	var file_: String = "%s%03d" % [SAVE_PREFIX, save_id_]
	
	if save_type_ == Core.SaveType.NORMAL and not _files.has(file_):
		load_error.emit(save_id_, save_type_)
		return null
	
	var path_: String = get_save_path(save_id_, save_type_)
	
	if not ResourceLoader.exists(path_, "GameResource"):
		load_error.emit(save_id_, save_type_)
		return null
		
	_last_game_file.data.set(&"save_id", save_id_)
	_last_game_file.data.set(&"save_type", save_type_)
	_last_game_file.save()

	load_before.emit(save_id_, save_type_)

	var data_: GameResource = ResourceLoader.load(path_)
	
	load_after.emit(save_id_, data_, save_type_)
	
	return data_
	
func save_game(
	save_id_: int, 
	data_: GameResource,
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> Error:
	if save_id_ < 0:
		save_error.emit(save_id_, data_, save_type_)
		return ERR_PARAMETER_RANGE_ERROR
	
	var auto_save_id_: int = save_id_
	var next_id_: int = _next_id
	
	if save_type_ == Core.SaveType.NORMAL:
		if save_id_ == 0:
			save_id_ = _next_id
			data_.save_id = save_id_
			_next_id += 1
		elif save_id_ >= _next_id:
			_next_id = save_id_ + 1
	
	var path_: String = get_save_path(save_id_, save_type_)
	
	data_.last_played = Time.get_unix_time_from_system()
	
	save_before.emit(save_id_, data_, save_type_)
	
	var error_: Error = ResourceSaver.save(data_, path_)
	if error_ != OK:
		_next_id = next_id_
		save_error.emit(save_id_, data_, save_type_)
		return error_
		
	_last_game_file.data.set(&"save_id", save_id_)
	_last_game_file.data.set(&"save_type", save_type_)
	_last_game_file.save()
	
	if save_type_ == Core.SaveType.NORMAL:
		var file_: String = "%s%03d" % [SAVE_PREFIX, save_id_]
		
		if not _files.has(file_):
			_files.append(file_)
	
	save_after.emit(save_id_, data_, save_type_)
	
	if save_type_ == Core.SaveType.NORMAL and auto_save_id_ != 0:
		delete_save(auto_save_id_, Core.SaveType.AUTO)
	
	return OK

func delete_save(
	save_id_: int,
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> Error:
	var path_: String = get_save_path(save_id_, save_type_)

	if not ResourceLoader.exists(path_, "GameResource"):
		return ERR_FILE_NOT_FOUND
		
	delete_before.emit(save_id_, save_type_)
		
	var error_: Error = DirAccess.remove_absolute(path_)
	if error_ != OK:
		delete_error.emit(save_id_, save_type_)
		return error_
	
	delete_after.emit(save_id_, save_type_)
	
	return error_

func get_save_path(
	save_id_: int,
	save_type_: Core.SaveType = Core.SaveType.NORMAL,
) -> String:
	if save_type_ == Core.SaveType.AUTO:
		return "%s%s%03d%s" % [
			AUTO_SAVE_PATH, 
			SAVE_PREFIX, 
			save_id_,
			SAVE_EXTENSION
		]
	elif save_type_ == Core.SaveType.CHECKPOINT:
		return "%s%s%03d%s%s" % [
			AUTO_SAVE_PATH, 
			SAVE_PREFIX, 
			save_id_,
			"_checkpoint",
			SAVE_EXTENSION
		]
	elif save_type_ == Core.SaveType.RESTART:
		return "%s%s%03d%s%s" % [
			AUTO_SAVE_PATH, 
			SAVE_PREFIX, 
			save_id_,
			"_restart",
			SAVE_EXTENSION
		]
	else:
		return "%s%s%03d%s" % [
			SAVE_PATH, 
			SAVE_PREFIX, 
			save_id_,
			SAVE_EXTENSION
		]
