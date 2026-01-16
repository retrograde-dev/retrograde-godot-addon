extends UnitActor
class_name FieldActor

func _init(unit_: BaseUnit, enabled: bool = true) -> void:
	super._init(unit_, &"field", enabled)

func ready() -> void:
	super.ready()
	
	var field_: FieldController = unit.get_node_or_null("%FieldController")
	if field_ != null:
		field_.field_entered.connect(_on_field_entered)
		field_.field_exited.connect(_on_field_exited)

func _on_field_entered(field_value_: FieldValue) -> void:
	match field_value_.type:
		Core.FieldType.MOVE:
			match field_value_.direction_x:
				Core.UnitDirection.LEFT:
					move_x(-1.0)
				Core.UnitDirection.RIGHT:
					move_x(1.0)
				_:
					move_x(0.0)
		
			match field_value_.direction_y:
				Core.UnitDirection.UP:
					move_x(-1.0)
				Core.UnitDirection.DOWN:
					move_x(1.0)
				_:
					move_x(0.0)
		Core.FieldType.SPEED:
			match field_value_.speed:
				Core.UnitSpeed.SLOW:
					speed_slow()
				Core.UnitSpeed.FAST:
					speed_fast()
				_:
					speed_normal()
	
func _on_field_exited(_field_value: FieldValue) -> void:
	pass
	
func process(delta: float) -> void:
	super.process(delta)

	if not can_process():
		return
	
	if not can_unit_process():
		return

	# Only follow field if player not in control
	# TODO: Some sort of toggle, to continue after no inputs from user
	# and then stop again once inputs happen
	if can_unit_input():
		return

func speed_slow() -> void:
	unit.actions.release(unit.move.action_move_fast)
	unit.actions.press(unit.move.action_move_slow)
	
func speed_normal() -> void:
	unit.actions.release(unit.move.action_move_slow)
	unit.actions.release(unit.move.action_move_fast)
	
func speed_fast() -> void:
	unit.actions.release(unit.move.action_move_slow)
	unit.actions.press(unit.move.action_move_fast)

func move_x(intensity_: float) -> void:
	if is_unit_climbing():
		if intensity_ < 0:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.press(unit.climb.action_climb_up)
		elif intensity_ > 0:
			unit.actions.release(unit.climb.action_climb_up)
			unit.actions.press(unit.climb.action_climb_down)
		else:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.release(unit.climb.action_climb_up)
	else:
		if intensity_ < 0:
			unit.actions.release(unit.move.action_move_right)
			unit.actions.press(unit.move.action_move_left)
		elif intensity_ > 0:
			unit.actions.release(unit.move.action_move_left)
			unit.actions.press(unit.move.action_move_right)
		else:
			unit.actions.release(unit.move.action_move_left)
			unit.actions.release(unit.move.action_move_right)
		
func move_y(intensity_: float) -> void:
	if is_unit_climbing():
		if intensity_ < 0:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.press(unit.climb.action_climb_up)
		elif intensity_ > 0:
			unit.actions.release(unit.climb.action_climb_up)
			unit.actions.press(unit.climb.action_climb_down)
		else:
			unit.actions.release(unit.climb.action_climb_down)
			unit.actions.release(unit.climb.action_climb_up)
	else:
		if intensity_ < 0:
			unit.actions.release(unit.move.action_move_down)
			unit.actions.press(unit.move.action_move_up)
		elif intensity_ > 0:
			unit.actions.release(unit.move.action_move_up)
			unit.actions.press(unit.move.action_move_down)
		else:
			unit.actions.release(unit.move.action_move_down)
			unit.actions.release(unit.move.action_move_up)

func move_left() -> void:
	move_y(0.0)
	move_x(-1.0)
	
func move_right() -> void:
	move_y(0.0)
	move_x(1.0)
	
func move_up() -> void:
	move_x(0.0)
	move_y(-1.0)
	
func move_down() -> void:
	move_x(0.0)
	move_y(1.0)

func move_stop() -> void:
	move_x(0)
	move_y(0)
