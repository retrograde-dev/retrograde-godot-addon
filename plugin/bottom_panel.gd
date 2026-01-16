@tool
extends Control

func _ready() -> void:
	var tab: Control = preload("res://addons/retrograde/plugin/tabs/main_tab.tscn").instantiate()

	%TabContainer.add_child(tab)
	%TabContainer.set_tab_title(0, "Initialize")

	if is_addon_enabled("retrograde_image"):
		tab = load("res://addons/retrograde_image/plugin/tabs/retrograde_image_tab.tscn").instantiate()
#
		%TabContainer.add_child(tab)
		%TabContainer.set_tab_title(1, "Image")

func is_addon_enabled(addon_name: String) -> bool:
	if not ProjectSettings.has_setting("editor_plugins/enabled"):
		return false
		
	var enabled_: PackedStringArray = ProjectSettings.get_setting("editor_plugins/enabled")

	return enabled_.has("res://addons/" + addon_name + "/plugin.cfg")
