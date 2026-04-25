extends Resource
class_name LockResource

@export var lock_type: Core.LockType = Core.LockType.NONE
@export var lock_mode: Core.LockMode = Core.LockMode.UNLOCK
@export var lock_access: Core.LockAccess = Core.LockAccess.NONE
@export var unlocked: bool = false
@export var bypassable: bool = false
@export var meta: Dictionary = {}

var locked: int:
	get:
		return not unlocked
	set(value):
		unlocked = not value
		
var keys: Array[StringName]:
	get:
		return meta.keys if meta.has(&"keys") else []
	set(value):
		meta.keys = value
		
var passcode: StringName:
	get:
		return meta.passcode if meta.has(&"passcode") else &""
	set(value):
		meta.passcode = value


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

	if (lock_mode != Core.LockMode.LOCK and 
		lock_mode != Core.LockMode.LOCK_AND_UNLOCK
	):
		return false

	if Core.player == null:
		return false

	if lock_type == Core.LockType.KEY:
		if not meta.has(&"keys"):
			return false
			
		var player_keys_: Array[InventoryItemResource]

		var items_actor: BaseActor = Core.player.get_actor_or_null(&"items")
		
		if items_actor == null:
			player_keys_ = []
		else:
			player_keys_ = items_actor.get_items_from_type(Core.ItemType.KEY)

		for player_key_: InventoryItemResource in player_keys_:
			if meta.keys.has(player_key_.alias):
				locked = true
				break

	return locked

func unlock() -> bool:
	if unlocked:
		return false

	if lock_type != Core.LockType.KEY:
		return false

	if (lock_mode != Core.LockMode.UNLOCK and
		lock_mode != Core.LockMode.LOCK_AND_UNLOCK and
		lock_mode != Core.LockMode.AUTO_LOCK
	):
		return false

	if Core.player == null:
		return false
		
	if lock_type == Core.LockType.KEY:
		if not meta.has(&"keys"):
			return false

		var player_keys_: Array[InventoryItemResource]

		var items_actor: BaseActor = Core.player.get_actor_or_null(&"items")
		
		if items_actor == null:
			player_keys_ = []
		else:
			player_keys_ = items_actor.get_items_from_type(Core.ItemType.KEY)

		for player_key_: InventoryItemResource in player_keys_:
			if meta.keys.has(player_key_.alias):
				unlocked = true
				break

	return unlocked

func bypass() -> bool:
	if unlocked or not bypassable:
		return false

	if lock_mode == Core.LockMode.LOCK:
		return false

	if Core.player == null:
		return false

	if lock_type == Core.LockType.KEY:
		var picks_: Array[InventoryItemResource]

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
