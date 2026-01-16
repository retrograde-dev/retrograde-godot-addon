#@tool

extends TextureButton
class_name UIButton

@export var goto_ui_alias: StringName

@export_category("Visual")
@export var style: StringName = &"":
	set(value):
		style = value
		if is_node_ready():
			_update_style()

@export_multiline var text: String:
	get: return %UILabel.text
	set(value):
		%UILabel.text = value

@export_category("Audio")
@export var entered_sfx: StringName = &""
@export var exited_sfx: StringName = &""
@export var pressed_sfx: StringName = &""

var _existing_textures: Dictionary = {}

func _ready() -> void:
	_existing_textures.normal = texture_normal
	_existing_textures.pressed = texture_pressed
	_existing_textures.hover = texture_hover
	_existing_textures.disabled = texture_disabled
	_existing_textures.focused = texture_focused
	_existing_textures.click_mask = texture_click_mask
		
	_update_style()

func _update_style() -> void:
	if style == &"":
		set_theme(null)
		set_theme_type_variation(&"")
		%UILabel.style = &""
		%UIMarginContainer.style = &""
		# TODO: Reset textures/sfx etc
		return
		
	assert(Core.ui.has_button(style), "Button style not found. (" + style + ")")
	
	if not Core.ui.has_button(style):
		return
		
	var button_: Dictionary = Core.ui.get_button(style)
	
	if not _existing_textures.normal and button_.texture.normal:
		texture_normal = ResourceLoader.load(button_.texture.normal)
		
	if not _existing_textures.pressed and button_.texture.pressed:
		texture_pressed = ResourceLoader.load(button_.texture.pressed)
		
	if not _existing_textures.hover and button_.texture.hover:
		texture_hover = ResourceLoader.load(button_.texture.hover)

	if not _existing_textures.disabled and button_.texture.disabled:
		texture_disabled = ResourceLoader.load(button_.texture.disabled)
		
	if not _existing_textures.focused and button_.texture.focused:
		texture_focused = ResourceLoader.load(button_.texture.focused)
		
	if not _existing_textures.click_mask and button_.texture.click_mask:
		texture_click_mask = ResourceLoader.load(button_.texture.click_mask)
	
	if texture_normal:
		size = texture_normal.get_size()
	else:
		size = Vector2(Core.TILE_SIZE, Core.TILE_SIZE)
	
	%UIMarginContainer.style = button_.margin_container
	
	if button_.type == &"label":
		%TextureRect.visible = false
		
		%UILabel.style = button_.label
		%UILabel.visible = true
	elif button_.type == &"icon":
		%UILabel.visible = false
		
		if button_.icon:
			%TextureRect.texture = ResourceLoader.load(button_.icon)
			%TextureRect.visible = true
		else:
			%TextureRect.visible = false
			%TextureRect.texture = null
	else:
		%UILabel.visible = false
		%TextureRect.visible = false
		
	if button_.theme == null:
		set_theme(null)
	else:
		set_theme(ResourceLoader.load(button_.theme))
		
	set_theme_type_variation(button_.theme_type_variation)

func get_parent_ui() -> BaseUI:
	var parent: Node = get_parent()

	while parent != null:
		if parent is BaseUI:
			break

		parent = parent.get_parent()
		
	return parent

func _on_pressed() -> void:
	if goto_ui_alias == &"":
		return

	var parent: BaseUI = get_parent_ui()
	if parent != null:
		_play_sfx(&"pressed")
			
		parent.goto(goto_ui_alias)
		
func _on_mouse_entered() -> void:
	_play_sfx(&"entered")
	
	if Core.ui.has_button(style):
		var button_: Dictionary = Core.ui.get_button(style)
		if button_.focus_on_hover:
			grab_focus()

func _on_mouse_exited() -> void:
	_play_sfx(&"exited")

func _play_sfx(name_: StringName) -> void:
	if get(name_ + &"_sfx") != &"":
		Core.audio.play_sfx(get(name_ + &"_sfx"))
		return
	
	if Core.ui.has_button(style):
		var button_: Dictionary = Core.ui.get_button(style)
		
		if button_.sfx[name_] != &"":
			Core.audio.play_sfx(button_.sfx[name_])
