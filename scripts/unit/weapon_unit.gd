extends BaseUnit
class_name WeaponUnit

var weapon_type: Core.WeaponType
var attacks: Array[WeaponAttack]

var signal_can_attack: bool = false

signal attack_error(weapon_: WeaponUnit, attack_: AttackValue, error_: Core.Error)
signal attack_before(weapon_: WeaponUnit, attack_: AttackValue)
signal attack_after(weapon_: WeaponUnit, attack_: AttackValue)
signal attack_complete(weapon_: WeaponUnit, attack_: AttackValue)

var _attack_cooldown: CooldownTimer = CooldownTimer.new()

var current_attack_value: AttackValue = null

var queue_delta: float = 0.25
var _queue_weapon_attack: WeaponAttack = null
var _queue_cooldown_delta: float = 0.0
var _queue_meta: Dictionary = {}

func _init(
	alias_: StringName, 
	weapon_type_: Core.WeaponType,
	attacks_: Array[WeaponAttack]
) -> void:
	super._init(alias_, Core.UnitType.WEAPON)
	weapon_type = weapon_type_
	attacks = attacks_

func reset(reset_type_: Core.ResetType) -> void:
	super.reset(reset_type_)
	
	if (reset_type_ == Core.ResetType.START or
		reset_type_ == Core.ResetType.RESTART
	):
		current_attack_value = null
		clear_queue()
		_attack_cooldown.reset()

func get_current_attack_delta() -> float:
	return _attack_cooldown.current_delta

func clear_queue() -> void:
	_queue_weapon_attack = null
	_queue_cooldown_delta = 0.0
	_queue_meta = {}

func get_weapon_attack_from_alias(attack_alias_: StringName) -> WeaponAttack:
	for attack_: WeaponAttack in attacks:
		if attack_.alias == attack_alias_:
			return attack_
			
	return null
	
func attack(meta_: Dictionary = {}) -> void:
	_attack_from_weapon_attack(attacks[0], meta_)
	
func attack_from_alias(attack_alias_: StringName, meta_: Dictionary = {}) -> void:
	var attack_: WeaponAttack = get_weapon_attack_from_alias(attack_alias_)
	
	if attack_ != null:
		_attack_from_weapon_attack(attack_, meta_)
		return
			
	assert(false, "Attack not found. (" + attack_alias_ + ")")
	
func attack_from_index(attack_index_: int, meta_: Dictionary = {}) -> void:
	assert(attack_index_ > 0 and attack_index_ <= attacks.size(), "Invalid attack index. (" + alias + ", " + str(attack_index_) + ")")
	
	if attack_index_ <= 0 or attack_index_ > attacks.size():
		return
	
	_attack_from_weapon_attack(attacks[attack_index_ -1], meta_)
	
func attack_from_attack_value(attack_value_: AttackValue, meta_: Dictionary = {}) -> void:
	assert(attack_value_.type == Core.AttackType.WEAPON, "Attack is not a weapon attack.")
	
	if attack_value_.type != Core.AttackType.WEAPON:
		return
	
	if attack_value_.meta.has("weapon_attack_alias"):
		attack_from_alias(attack_value_.meta.weapon_attack_alias, meta_)
	else:
		attack(meta_)

func _attack_from_weapon_attack(weapon_attack_: WeaponAttack, meta_: Dictionary = {}) -> void:
	if not _attack_cooldown.is_stopped:
		# Queue an attack if already attacking
		_queue_cooldown_delta = _attack_cooldown.current_delta
		_queue_weapon_attack = weapon_attack_
		_queue_meta = meta_.duplicate()
		return
			
	clear_queue()
	
	meta_ = meta_.duplicate()
	meta_.weapon_attack_alias = weapon_attack_.alias
	meta_.weapon_attack_delta = weapon_attack_.delta
		
	var attack_value_: AttackValue = AttackValue.new(
		Core.AttackType.WEAPON, 
		alias, 
		meta_
	)
	attack_value_.node = self
	
	signal_can_attack = true
	attack_before.emit(self, attack_value_)
	
	if signal_can_attack:
		current_attack_value = attack_value_
		
		if weapon_attack_.delta > 0:
			_attack_cooldown.delta = weapon_attack_.delta
		else:
			# Any number larger than the max animation length
			_attack_cooldown.delta = 99999
		_attack_cooldown.start()
		
		attack_after.emit(self, attack_value_)

func _process(delta_: float) -> void:
	super._process(delta_)

	if not is_running():
		return

	_attack_cooldown.process(delta_)

	if _attack_cooldown.is_complete:
		if _queue_weapon_attack != null:
			if _attack_cooldown.delta - _queue_cooldown_delta >= queue_delta:
				_queue_weapon_attack = null
	
		_attack_cooldown.stop()
	
		attack_complete.emit(self, current_attack_value)
		
		current_attack_value = null
	
		if _queue_weapon_attack != null:
			_attack_from_weapon_attack(_queue_weapon_attack, _queue_meta)
