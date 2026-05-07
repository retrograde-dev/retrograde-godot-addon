extends BaseUnit 
class_name EntityUnit

@export var zone_entity: ZoneEntityResource = null
@export var meta: Dictionary = {}

var entity: EntityResource:
	get = get_entity,
	set = set_entity

func get_entity() -> EntityResource:
	return zone_entity.entity
	
func set_entity(value: EntityResource) -> void:
	zone_entity.entity = value
	
var collision: BaseActor:
	get:
		return actors.use(&"collision")

var damage: BaseActor:
	get:
		return actors.use(&"damage")
		
var health: BaseActor:
	get:
		return actors.use(&"health")
		
var hunger: BaseActor:
	get:
		return actors.use(&"hunger")

var items: BaseActor:
	get:
		return actors.use(&"items")
		
var life: BaseActor:
	get:
		return actors.use(&"life")

var field: BaseActor:
	get:
		return actors.use(&"field")
		
var interact: BaseActor:
	get:
		return actors.use(&"interact")

var win: BaseActor:
	get:
		return actors.use(&"win")

var lose: BaseActor:
	get:
		return actors.use(&"lose")

var crouch: BaseActor:
	get:
		return actors.use(&"crouch")
		
var jump: BaseActor:
	get:
		return actors.use(&"jump")
		
var climb: BaseActor:
	get:
		return actors.use(&"climb")
	
var fall: BaseActor:
	get:
		return actors.use(&"fall")

var weapons: BaseActor:
	get:
		return actors.use(&"weapons")
		
var move: BaseActor:
	get:
		return actors.use(&"move")
		
var roam: BaseActor:
	get:
		return actors.use(&"roam")
		
func _init() -> void:
	super._init(Core.UnitType.ENTITY)
	
	actors = ActorHandler.new()
	actors.add_all({
		&"interact": InteractActor.new(self),
		&"items": ItemsActor.new(self),
		&"collision": CollisionActor.new(self),
		&"damage": DamageActor.new(self),
		&"health": HealthActor.new(self),
		&"hunger": HungerActor.new(self),
		&"life": LifeActor.new(self),
		&"field": FieldActor.new(self),
		&"lose": LoseActor.new(self),
		&"win": WinActor.new(self),
		&"crouch": CrouchActor.new(self),
		&"jump": JumpActor.new(self),
		&"climb": ClimbActor.new(self),
		&"fall": FallActor.new(self),
		&"roam": RoamActor.new(self),
		&"weapons": WeaponsActor.new(self),
		&"move": MoveActor.new(self),
	})

	actions = ActionHandler.new(self, actors)
	alignment = Core.Alignment.BOTTOM_CENTER
	
func use_item(item_: ItemResource) -> bool:
	var used_: bool = false
	
	if item_.type == Core.ItemType.FOOD:
		if item_.meta.has("hunger"):
			_increase_unit_hunger(item_.meta.hunger)
		
		used_ = true
	elif item_.type == Core.ItemType.HEALTH_FOOD:
		if item_.meta.has("hunger"):
			_increase_unit_hunger(item_.meta.hunger)
			
		if item_.meta.has("health"):
			_increase_unit_health(item_.meta.health)
			
		used_ = true
	elif item_.type == Core.ItemType.ARMOR:
		if item_.meta.has("armor"):
			_increase_unit_armor(item_.meta.armor)
			
		used_ = true
	elif item_.type == Core.ItemType.ARMOR_HEALTH:
		if item_.meta.has("armor"):
			_increase_unit_armor(item_.meta.armor)
			
		if item_.meta.has("health"):
			_increase_unit_health(item_.meta.health)
			
		used_ = true
	elif item_.type == Core.ItemType.HEALTH or item_.type == Core.ItemType.REPAIR:
		if item_.meta.has("health"):
			_increase_unit_health(item_.meta.health)
			
		used_ = true
	
	return used_

func _increase_unit_health(amount: float) -> void:
	if amount == 0.0:
		return
	
	health.increase_health(amount)
	
func _increase_unit_armor(amount: float) -> void:
	if amount == 0.0:
		return
	
	health.increase_armor(amount)

func _increase_unit_hunger(amount: float) -> void:
	if amount == 0.0:
		return
	
	hunger.increase_hunger(amount)

func export(data_: Resource = null) -> Resource:
	if data_ == null:
		data_ = EntityUnitResource.new(
			zone_entity.duplicate(true) as ZoneEntityResource
		)
	else:
		assert(data_ is EntityUnitResource, "Invalid resource.")
		
		data_.zone_entity = zone_entity.duplicate(true) as ZoneEntityResource
	
	data_.node = self
	
	super.export(data_)
	
	return data_
	
func import(data_: Resource) -> void:
	assert(data_ is EntityUnitResource, "Invalid resource.")
	
	zone_entity = data_.zone_entity.duplicate(true) as ZoneEntityResource
	
	super.import(data_)
