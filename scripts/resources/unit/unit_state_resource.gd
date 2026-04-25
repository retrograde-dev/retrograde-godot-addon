extends Resource
class_name UnitStateResource

@export var unit_mode: Core.UnitMode = Core.UnitMode.NONE
@export var unit_speed: Core.UnitSpeed = Core.UnitSpeed.NORMAL
@export var unit_movement: Core.UnitMovement = Core.UnitMovement.IDLE
@export var unit_physics: Core.UnitPhysics = Core.UnitPhysics.PLATFORM
@export var unit_stance: Core.UnitStance = Core.UnitStance.NORMAL
@export var unit_direction: Core.UnitDirection = Core.UnitDirection.NONE

var unit_direction_x: Core.UnitDirection:
	get:
		if (unit_direction == Core.UnitDirection.LEFT or
			unit_direction == Core.UnitDirection.LEFT_UP or
			unit_direction == Core.UnitDirection.LEFT_DOWN or
			unit_direction == Core.UnitDirection.UP_LEFT or
			unit_direction == Core.UnitDirection.DOWN_LEFT
		):
			return Core.UnitDirection.LEFT
			
		if (unit_direction == Core.UnitDirection.RIGHT or
			unit_direction == Core.UnitDirection.RIGHT_UP or
			unit_direction == Core.UnitDirection.RIGHT_DOWN or
			unit_direction == Core.UnitDirection.UP_RIGHT or
			unit_direction == Core.UnitDirection.DOWN_RIGHT
		):
			return Core.UnitDirection.RIGHT
			
		return Core.UnitDirection.NONE
	set(value):
		if (unit_direction == Core.UnitDirection.UP or
			unit_direction == Core.UnitDirection.LEFT_UP or
			unit_direction == Core.UnitDirection.RIGHT_UP or
			unit_direction == Core.UnitDirection.UP_LEFT or
			unit_direction == Core.UnitDirection.UP_RIGHT
		):
			if (value == Core.UnitDirection.LEFT or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.DOWN_LEFT
			):
				unit_direction = Core.UnitDirection.LEFT_UP
			elif (value == Core.UnitDirection.RIGHT or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.UP_RIGHT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.RIGHT_UP
			else:
				unit_direction = Core.UnitDirection.UP
		elif (unit_direction == Core.UnitDirection.DOWN or
			unit_direction == Core.UnitDirection.LEFT_DOWN or
			unit_direction == Core.UnitDirection.RIGHT_DOWN or
			unit_direction == Core.UnitDirection.DOWN_LEFT or
			unit_direction == Core.UnitDirection.DOWN_RIGHT
		):
			if (value == Core.UnitDirection.LEFT or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.DOWN_LEFT
			):
				unit_direction = Core.UnitDirection.LEFT_DOWN
			elif (value == Core.UnitDirection.RIGHT or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.UP_RIGHT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.RIGHT_DOWN
			else:
				unit_direction = Core.UnitDirection.DOWN
		else:
			if (value == Core.UnitDirection.LEFT or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.DOWN_LEFT
			):
				unit_direction = Core.UnitDirection.LEFT
			elif (value == Core.UnitDirection.RIGHT or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.UP_RIGHT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.RIGHT
			else:
				unit_direction = Core.UnitDirection.NONE
			
var unit_direction_y: Core.UnitDirection:
	get:
		if (unit_direction == Core.UnitDirection.UP or
			unit_direction == Core.UnitDirection.LEFT_UP or
			unit_direction == Core.UnitDirection.RIGHT_UP or
			unit_direction == Core.UnitDirection.UP_LEFT or
			unit_direction == Core.UnitDirection.UP_RIGHT
		):
			return Core.UnitDirection.UP
			
		if (unit_direction == Core.UnitDirection.DOWN or
			unit_direction == Core.UnitDirection.LEFT_DOWN or
			unit_direction == Core.UnitDirection.RIGHT_DOWN or
			unit_direction == Core.UnitDirection.DOWN_LEFT or
			unit_direction == Core.UnitDirection.DOWN_RIGHT
		):
			return Core.UnitDirection.DOWN
			
		return Core.UnitDirection.NONE
	set(value):
		if (unit_direction == Core.UnitDirection.LEFT or
			unit_direction == Core.UnitDirection.LEFT_UP or
			unit_direction == Core.UnitDirection.LEFT_DOWN or
			unit_direction == Core.UnitDirection.UP_LEFT or
			unit_direction == Core.UnitDirection.DOWN_LEFT
		):
			if (value == Core.UnitDirection.UP or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.UP_RIGHT
			):
				unit_direction = Core.UnitDirection.UP_LEFT
			elif (value == Core.UnitDirection.DOWN or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.DOWN_LEFT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.DOWN_LEFT
			else:
				unit_direction = Core.UnitDirection.LEFT
		elif (unit_direction == Core.UnitDirection.RIGHT or
			unit_direction == Core.UnitDirection.RIGHT_UP or
			unit_direction == Core.UnitDirection.RIGHT_DOWN or
			unit_direction == Core.UnitDirection.UP_RIGHT or
			unit_direction == Core.UnitDirection.DOWN_RIGHT
		):
			if (value == Core.UnitDirection.UP or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.UP_RIGHT
			):
				unit_direction = Core.UnitDirection.UP_RIGHT
			elif (value == Core.UnitDirection.DOWN or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.DOWN_LEFT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.DOWN_RIGHT
			else:
				unit_direction = Core.UnitDirection.RIGHT
		else:
			if (value == Core.UnitDirection.UP or
				value == Core.UnitDirection.LEFT_UP or
				value == Core.UnitDirection.RIGHT_UP or
				value == Core.UnitDirection.UP_LEFT or
				value == Core.UnitDirection.UP_RIGHT
			):
				unit_direction = Core.UnitDirection.UP
			elif (value == Core.UnitDirection.DOWN or
				value == Core.UnitDirection.LEFT_DOWN or
				value == Core.UnitDirection.RIGHT_DOWN or
				value == Core.UnitDirection.DOWN_LEFT or
				value == Core.UnitDirection.DOWN_RIGHT
			):
				unit_direction = Core.UnitDirection.DOWN
			else:
				unit_direction = Core.UnitDirection.NONE
