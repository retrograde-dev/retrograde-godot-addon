@tool
extends EditorPlugin

var bottom_panel: Control
var _settings: Dictionary = {
	"setup": {
		"viewport_size": {
			"value": 0,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "180 x 90,320 x 180,640 x 360,1920 x 1080"
		},
		"layer_names": {
			"value": false,
			"type": TYPE_BOOL
		},
		"tile_size": {
			"value": 0,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "8 px,16 px,32 px,64 px,128 px,256 px,512 px"
		},
		"physics_size": {
			"value": 0,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "8 px,16 px,32 px,64 px,128 px,256 px,512 px"
		},
		"field_size": {
			"value": 0,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "8 px,16 px,32 px,64 px,128 px,256 px,512 px"
		},
		"cursor_size": {
			"value": 0,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "8 px,16 px,32 px,64 px,128 px,256 px,512 px"
		},
		"mouse_capture": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"audio": {
		"bus_layout": {
			"value": false,
			"type": TYPE_BOOL
		},
		"music": {
			"value": false,
			"type": TYPE_BOOL
		},
		"ambiance": {
			"value": false,
			"type": TYPE_BOOL
		},
		"sfx": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"game": {
		"main_scene": {
			"value": false,
			"type": TYPE_BOOL
		},
		"level_controller": {
			"value": false,
			"type": TYPE_BOOL
		},
		"ambiance_controller": {
			"value": false,
			"type": TYPE_BOOL
		},
		"ui_controller": {
			"value": false,
			"type": TYPE_BOOL
		},
		"hud_controller": {
			"value": false,
			"type": TYPE_BOOL
		},
		"cutscene_controller": {
			"value": false,
			"type": TYPE_BOOL
		},
		"camera": {
			"value": false,
			"type": TYPE_BOOL
		},
		"player_grid": {
			"value": false,
			"type": TYPE_BOOL
		},
		"day_night_cycle": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"levels": {
		"menu_level": {
			"value": false,
			"type": TYPE_BOOL
		},
		"start_level": {
			"value": false,
			"type": TYPE_BOOL
		},
		"start_level_alias": {
			"value": "start",
			"type": TYPE_STRING
		},
		"start_as_menu": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"tile_sets": {
		"physics": {
			"structure": {
				"value": false,
				"type": TYPE_BOOL
			},
			"climb": {
				"value": false,
				"type": TYPE_BOOL
			},
			"elevation": {
				"value": false,
				"type": TYPE_BOOL
			},
		},
		"modifiers": {
			"value": false,
			"type": TYPE_BOOL
		},
		"win": {
			"value": false,
			"type": TYPE_BOOL
		},
		"lose": {
			"value": false,
			"type": TYPE_BOOL
		},
		"field": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"hud": {
		"health": {
			"value": false,
			"type": TYPE_BOOL
		},
		"hunger": {
			"value": false,
			"type": TYPE_BOOL
		},
		"items": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"ui": {
		"difficulty": {
			"value": false,
			"type": TYPE_BOOL
		},
		"level_select": {
			"value": false,
			"type": TYPE_BOOL
		},
		"skip_level": {
			"value": false,
			"type": TYPE_BOOL
		},
		"next_level": {
			"value": false,
			"type": TYPE_BOOL
		},
		"previous_level": {
			"value": false,
			"type": TYPE_BOOL
		},
		"play_again": {
			"value": false,
			"type": TYPE_BOOL
		},
		"play_time": {
			"value": false,
			"type": TYPE_BOOL
		},
		"win": {
			"value": false,
			"type": TYPE_BOOL
		},
		"lose": {
			"value": false,
			"type": TYPE_BOOL
		},
		"settings": {
			"value": false,
			"type": TYPE_BOOL
		},
		"controls": {
			"value": false,
			"type": TYPE_BOOL
		},
		"credits": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"data": {
		"settings": {
			"value": false,
			"type": TYPE_BOOL
		},
		"sfx": {
			"value": false,
			"type": TYPE_BOOL
		},
		"credits": {
			"value": false,
			"type": TYPE_BOOL
		},
		"level_select": {
			"value": false,
			"type": TYPE_BOOL
		},
		"input": {
			"value": false,
			"type": TYPE_BOOL
		},
		"controls": {
			"value": false,
			"type": TYPE_BOOL
		},
		"ui": {
			"value": false,
			"type": TYPE_BOOL
		},
		"hud": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"input": {
		"move": {
			"value": false,
			"type": TYPE_BOOL
		},
		"climb": {
			"value": false,
			"type": TYPE_BOOL
		},
		"crouch": {
			"value": false,
			"type": TYPE_BOOL
		},
		"jump": {
			"value": false,
			"type": TYPE_BOOL
		},
		"interact": {
			"value": false,
			"type": TYPE_BOOL
		},
		"item": {
			"use": {
				"value": false,
				"type": TYPE_BOOL
			},
			"pick_up": {
				"value": false,
				"type": TYPE_BOOL
			},
			"drop": {
				"value": false,
				"type": TYPE_BOOL
			},
			"select": {
				"value": 0,
				"type": TYPE_INT
			},
		}
	},
	"settings": {
		"audio": {
			"value": false,
			"type": TYPE_BOOL
		},
		"mouse": {
			"slow_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
			"normal_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
			"fast_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
		},
		"joypad": {
			"slow_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
			"normal_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
			"fast_speed": {
				"value": false,
				"type": TYPE_BOOL
			},
			"vibrations": {
				"value": false,
				"type": TYPE_BOOL
			},
		},
	},
	"localization": {
		"translations": {
			"value": false,
			"type": TYPE_BOOL
		},
		"locales": {
			"english": {
				"value": false,
				"type": TYPE_BOOL
			},
			"japanese": {
				"value": false,
				"type": TYPE_BOOL
			},
		}
	},
	"file_system": {
		"create_folders": {
			"value": false,
			"type": TYPE_BOOL
		},
		"set_folder_colors": {
			"value": false,
			"type": TYPE_BOOL
		},
	},
	"debug": {
		"strict_typing": {
			"value": false,
			"type": TYPE_BOOL
		},
	}
}

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	_init_settings()
	_load_bottom_panel()

func _exit_tree() -> void:
	remove_control_from_bottom_panel(bottom_panel)
	bottom_panel.queue_free()
	bottom_panel = null

func _init_settings() -> void:
	for name_: String in _settings.keys():
		var key_: String = "addons/retrograde/" + name_
		_set_settings(key_, _settings[name_])
	
	ProjectSettings.save()
	
func _set_settings(key_: String, settings_: Dictionary) -> void:
	if settings_.has("type"):
		if ProjectSettings.has_setting(key_):
			return
				
		var setting_: Dictionary = settings_.duplicate()
		
		ProjectSettings.set_setting(key_, setting_.get("value"))
		ProjectSettings.set_initial_value(key_, setting_.get("value"))
		setting_.erase("value")
		setting_.set("name", key_)
		ProjectSettings.add_property_info(setting_)
	else:
		for name_: String in settings_.keys():
			var new_key_: String = key_ + "/" + name_
			_set_settings(new_key_, settings_[name_])
			
func _load_bottom_panel() -> void:
	bottom_panel = preload("res://addons/retrograde/plugin/bottom_panel.tscn").instantiate()
			
	add_control_to_bottom_panel(bottom_panel, "Retrograde")
