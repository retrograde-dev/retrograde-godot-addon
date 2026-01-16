extends Control
class_name BaseUI

@export var ui_type: Core.UIType = Core.UIType.MENU

var alias: StringName

func _init(alias_: StringName) -> void:
	alias = alias_

func _ready() -> void:
	update()
	if visible:
		process_mode = Node.PROCESS_MODE_DISABLED
		_focus_first_button()
	else:
		process_mode = Node.PROCESS_MODE_INHERIT

func _input(event_: InputEvent) -> void:
	# TODO: Change this to an action with a function call
	if not visible:
		return

	if event_ is InputEventKey and event_.pressed and event_.keycode == KEY_ESCAPE:
		if alias == &"pause":
			accept_event()
			return

		var button_: UIButton = _get_escape_button(self)
		if button_ != null:
			button_.emit_signal(&"pressed")
			accept_event()

func update() -> void:
	pass

func show_ui() -> void:
	visible = true
	update()
	process_mode = Node.PROCESS_MODE_INHERIT
	_focus_first_button()

func hide_ui() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false

func goto(alias_: StringName) -> void:
	alias_ = Core.ui.prepare_ui_alias(alias_, alias)

	if alias_ == &"":
		return

	if alias_ == &"exit":
		Core.game.stop()
		return

	if alias_ == &"start":
		Core.game.start()
		return

	if alias_.begins_with(&"start:"):
		var level_alias_: StringName = alias_.substr(6)
		Core.game.start_level(level_alias_)
		return

	var ui_node: BaseUI = _get_ui(alias_)

	if ui_node != null:
		Core.ui.prepare_ui(alias_, alias)
		hide_ui()
		ui_node.show_ui()

func _get_ui(alias_: StringName) -> BaseUI:
	var parent: Node = get_parent()

	for child: Node in parent.get_children():
		if not child is BaseUI:
			continue

		if child.alias != alias_:
			continue

		return child

	return null

func _focus_first_button() -> void:
	var button: UIButton = _get_first_button(self)

	if button != null:
		button.grab_focus()

func _get_first_button(node: Node) -> UIButton:
	if node is UIButton:
		return node

	for child: Node in node.get_children():
		if child is Control:
			var button: UIButton = _get_first_button(child)
			if button != null:
				return button

	return null

func _get_escape_button(node: Node) -> UIButton:
	if node is UIButton:
		if node.goto_ui_alias == &"menu" or node.goto_ui_alias == &"parent":
			return node

		return null

	for child: Node in node.get_children():
		if child is Control:
			var button: UIButton = _get_escape_button(child)
			if button != null:
				return button

	return null
