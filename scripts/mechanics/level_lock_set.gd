class_name LevelLockSet

var locks: Array[LevelLockValue]

func _init(level_: BaseLevel) -> void:
	
	if not level_.data.level.data.has(&"locks"):
		return
		
	for lock_: Dictionary in level_.data.level.data.locks:
		locks.push_back(LevelLockValue.new(
			lock_.alias,
			lock_.type,
			lock_.mode,
			lock_.has(&"unlocked") and lock_.unlocked,
			lock_.has(&"bypassable") and lock_.bypassable,
			lock_.meta if lock_.has(&"meta") else {}
		))
		

func has_lock(alias_: StringName) -> bool:
	for lock_: LevelLockValue in locks:
		if lock_.alias == alias_:
			return true
			
	return false

func get_lock(alias_: StringName) -> LevelLockValue:
	for lock_: LevelLockValue in locks:
		if lock_.alias == alias_:
			return lock_
			
	return null
