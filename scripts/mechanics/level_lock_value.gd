class_name LevelLockValue

var alias: StringName
var type: Core.LockType
var mode: Core.LockMode
var unlocked: bool
var bypassable: bool
var meta: Dictionary

var keys: Array[StringName]:
	get:
		return meta.keys if meta.has("keys") else []
	set(value):
		meta.keys = value

var locked: int:
	get:
		return not unlocked
	set(value):
		unlocked = not value

func _init(
	alias_: StringName,
	type_: Core.LockType,
	mode_: Core.LockMode,
	unlocked_: bool = false,
	bypassable_: bool = false,
	meta_: Dictionary = {}
) -> void:
	alias = alias_
	type = type_
	mode = mode_
	unlocked = unlocked_
	bypassable = bypassable_
	meta = meta_

func try_unlock() -> Core.LockState:
	if unlock():
		return Core.LockState.UNLOCKED
		
	if bypass():
		return Core.LockState.BYPASSED
		
	if locked:
		return Core.LockState.LOCKED
		
	return Core.LockState.NONE

func try_lock() -> Core.LockState:
	if lock():
		return Core.LockState.LOCKED
		
	if unlocked:
		return Core.LockState.UNLOCKED
		
	return Core.LockState.NONE

func lock() -> bool:
	if locked:
		return false

	if mode != Core.LockMode.LOCK_ONLY and mode != Core.LockMode.MANUAL:
		return false

	if Core.player == null:
		return false

	if type == Core.LockType.KEY:
		if not meta.has("keys"):
			return false
			
		var player_keys_: Array[ItemValue]

		var items_actor: BaseActor = Core.player.get_actor_or_null(&"items")
		
		if items_actor == null:
			player_keys_ = []
		else:
			player_keys_ = items_actor.get_items_from_type(Core.ItemType.KEY)

		for player_key_: ItemValue in player_keys_:
			if meta.keys.has(player_key_.alias):
				locked = true
				break

	return locked

func unlock() -> bool:
	if unlocked:
		return false

	if type != Core.LockType.KEY:
		return false

	if mode == Core.LockMode.LOCK_ONLY:
		return false

	if Core.player == null:
		return false
		
	if type == Core.LockType.KEY:
		if not meta.has("keys"):
			return false

		var player_keys_: Array[ItemValue]

		var items_actor: BaseActor = Core.player.get_actor_or_null(&"items")
		
		if items_actor == null:
			player_keys_ = []
		else:
			player_keys_ = items_actor.get_items_from_type(Core.ItemType.KEY)

		for player_key_: ItemValue in player_keys_:
			if meta.keys.has(player_key_.alias):
				unlocked = true
				break

	return unlocked

func bypass() -> bool:
	if unlocked or not bypassable:
		return false

	if mode == Core.LockMode.LOCK_ONLY:
		return false

	if Core.player == null:
		return false

	if type == Core.LockType.KEY:
		var picks_: Array[ItemValue]

		var items_actor: BaseActor = Core.player.get_actor_or_null(&"items")
		
		if items_actor == null:
			picks_ = []
		else:
			picks_ = items_actor.get_items_from_type(Core.ItemType.LOCK_PICK)

		if picks_.is_empty():
			return false

		unlocked = true
		return true

	return false
