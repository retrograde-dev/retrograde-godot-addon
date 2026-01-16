extends BaseUnit 
class_name PlayerUnit

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
		
func _init(alias_: StringName) -> void:
	super._init(alias_, Core.UnitType.PLAYER)
	
	actors = ActorHandler.new(self)
	actors.add_all({
		&"interact": InteractActor.new(self),
		&"items": ItemsActor.new(self),
		&"collision": CollisionActor.new(self),
		&"damage": DamageActor.new(self),
		&"health": HealthActor.new(self),
		&"hunger": HungerActor.new(self),
		&"life": LifeActor.new(self),
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

	actions = ActionHandler.new(self)
	alignment = Core.Alignment.BOTTOM_CENTER
