extends BaseUnit
class_name EnemyUnit

var collision: BaseActor:
	get:
		return actors.use(&"collision")

var damage: BaseActor:
	get:
		return actors.use(&"damage")
		
var health: BaseActor:
	get:
		return actors.use(&"health")
		
var life: BaseActor:
	get:
		return actors.use(&"life")
	
var field: BaseActor:
	get:
		return actors.use(&"field")
		
var climb: BaseActor:
	get:
		return actors.use(&"climb")
		
var fall: BaseActor:
	get:
		return actors.use(&"fall")

var roam: BaseActor:
	get:
		return actors.use(&"roam")
		
var weapons: BaseActor:
	get:
		return actors.use(&"weapons")
		
var move: BaseActor:
	get:
		return actors.use(&"move")
		
		
func _init(alias_: StringName) -> void:
	super._init(alias_, Core.UnitType.ENEMY)
	
	actors = ActorHandler.new(self)
	actors.add_all({
		&"collision": CollisionActor.new(self),
		&"damage": DamageActor.new(self),
		&"health": HealthActor.new(self),
		&"life": LifeActor.new(self),
		&"field": FieldActor.new(self),
		&"climb": ClimbActor.new(self),
		&"fall": FallActor.new(self),
		&"roam": RoamActor.new(self),
		&"weapons": WeaponsActor.new(self),
		&"move": MoveActor.new(self),
	})
	
	actions = ActionHandler.new(self)
	alignment = Core.Alignment.BOTTOM_CENTER
