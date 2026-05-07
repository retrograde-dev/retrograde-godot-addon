extends BaseActor
class_name PartyActor

var select_action_size: int = 10

var action_select_next_unit: StringName = &"party_next_unit"
var action_select_previous_unit: StringName = &"party_previous_unit"
var action_select_unit: StringName = &"party_select_unit_"

func physics_process(delta: float) -> void:
	super.physics_process(delta)
	
	if not can_physics_process():
		return
		
	_action_select_next_unit_unit()
	_action_select_previous_unit_unit()
	
	for i: int in select_action_size:
		_action_select_unit(i)
		

func _action_select_next_unit_unit() -> void:
	if not Core.game.actions.is_just_pressed(action_select_next_unit, true):
		return
	
	if Core.game.actions.is_just_pressed(action_select_previous_unit, true):
		return
		
	select_next_unit()
	
func _action_select_previous_unit_unit() -> void:
	if not Core.game.actions.is_just_pressed(action_select_previous_unit, true):
		return
	
	if Core.game.actions.is_just_pressed(action_select_next_unit, true):
		return
		
	select_previous_unit()

func _action_select_unit(slot_: int) -> void:
	if not Core.game.actions.is_just_pressed(action_select_unit + str(slot_ + 1), true):
		return
		
	select_unit(slot_)

func select_next_unit() -> void:
	Core.party.select_next_unit()
		
func select_previous_unit() -> void:
	Core.party.select_previous_unit()
		
func select_unit(index_: int) -> void:
	Core.party.select_unit(index_)

func get_actions() -> Array[StringName]:
	var actions_: Array[StringName] = [
		action_select_next_unit,
		action_select_previous_unit,
	]
	
	for i: int in select_action_size:
		actions_.push_back(action_select_unit + str(i + 1))
		
	return actions_
