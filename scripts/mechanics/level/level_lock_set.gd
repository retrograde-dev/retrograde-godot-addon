class_name LevelLockSet

func has_lock(lock_alias_: StringName) -> bool:
	if Core.level.data.locks.has(lock_alias_):
		return true
			
	return false

func get_lock(lock_alias_: StringName) -> LockResource:
	return Core.level.data.locks.get(lock_alias_, null)
