class_name InputResourceHandler

var _data: Dictionary

func _init() -> void:
	if FileAccess.file_exists("res://data/input_resources.json"):
		var file_: InputResourcesDataFile = InputResourcesDataFile.new("res://data/input_resources.json")
		file_.load()
		_data = file_.data
	else:
		_data = {
			&"default": {
				&"frame_count": Vector2i(1, 1),
				&"frame_orientation": Core.Orientation.HORIZONTAL,
				&"frame_set": AnimationFrameSet.new([
					AnimationFrameValue.new(0, 1),
				]),
			},
			&"animations": [],
		}

var keyboard_texture: Resource = load("res://assets/inputs/keyboard.png")
var keyboard_keys: Dictionary = {
	KEY_A: load("res://assets/inputs/keyboard/a.png"),
	KEY_B: load("res://assets/inputs/keyboard/b.png"),
	KEY_C: load("res://assets/inputs/keyboard/c.png"),
	KEY_D: load("res://assets/inputs/keyboard/d.png"),
	KEY_E: load("res://assets/inputs/keyboard/e.png"),
	KEY_F: load("res://assets/inputs/keyboard/f.png"),
	KEY_G: load("res://assets/inputs/keyboard/g.png"),
	KEY_H: load("res://assets/inputs/keyboard/h.png"),
	KEY_I: load("res://assets/inputs/keyboard/i.png"),
	KEY_J: load("res://assets/inputs/keyboard/j.png"),
	KEY_K: load("res://assets/inputs/keyboard/k.png"),
	KEY_L: load("res://assets/inputs/keyboard/l.png"),
	KEY_M: load("res://assets/inputs/keyboard/m.png"),
	KEY_N: load("res://assets/inputs/keyboard/n.png"),
	KEY_O: load("res://assets/inputs/keyboard/o.png"),
	KEY_P: load("res://assets/inputs/keyboard/p.png"),
	KEY_Q: load("res://assets/inputs/keyboard/q.png"),
	KEY_R: load("res://assets/inputs/keyboard/r.png"),
	KEY_S: load("res://assets/inputs/keyboard/s.png"),
	KEY_T: load("res://assets/inputs/keyboard/t.png"),
	KEY_U: load("res://assets/inputs/keyboard/u.png"),
	KEY_V: load("res://assets/inputs/keyboard/v.png"),
	KEY_W: load("res://assets/inputs/keyboard/w.png"),
	KEY_X: load("res://assets/inputs/keyboard/x.png"),
	KEY_Y: load("res://assets/inputs/keyboard/y.png"),
	KEY_Z: load("res://assets/inputs/keyboard/z.png"),
	
	KEY_1: load("res://assets/inputs/keyboard/1.png"),
	KEY_2: load("res://assets/inputs/keyboard/2.png"),
	KEY_3: load("res://assets/inputs/keyboard/3.png"),
	KEY_4: load("res://assets/inputs/keyboard/4.png"),
	KEY_5: load("res://assets/inputs/keyboard/5.png"),
	KEY_6: load("res://assets/inputs/keyboard/6.png"),
	KEY_7: load("res://assets/inputs/keyboard/7.png"),
	KEY_8: load("res://assets/inputs/keyboard/8.png"),
	KEY_9: load("res://assets/inputs/keyboard/9.png"),
	KEY_0: load("res://assets/inputs/keyboard/0.png"),
	
	KEY_F1: load("res://assets/inputs/keyboard/f1.png"),
	KEY_F2: load("res://assets/inputs/keyboard/f2.png"),
	KEY_F3: load("res://assets/inputs/keyboard/f3.png"),
	KEY_F4: load("res://assets/inputs/keyboard/f4.png"),
	KEY_F5: load("res://assets/inputs/keyboard/f5.png"),
	KEY_F6: load("res://assets/inputs/keyboard/f6.png"),
	KEY_F7: load("res://assets/inputs/keyboard/f7.png"),
	KEY_F8: load("res://assets/inputs/keyboard/f8.png"),
	KEY_F9: load("res://assets/inputs/keyboard/f9.png"),
	KEY_F10: load("res://assets/inputs/keyboard/f10.png"),
	KEY_F11: load("res://assets/inputs/keyboard/f11.png"),
	KEY_F12: load("res://assets/inputs/keyboard/f12.png"),
	
	KEY_UP: load("res://assets/inputs/keyboard/up.png"),
	KEY_DOWN: load("res://assets/inputs/keyboard/down.png"),
	KEY_LEFT: load("res://assets/inputs/keyboard/left.png"),
	KEY_RIGHT: load("res://assets/inputs/keyboard/right.png"),
	
	KEY_APOSTROPHE: load("res://assets/inputs/keyboard/apostrophe.png"),
	KEY_BACKSPACE: load("res://assets/inputs/keyboard/backspace.png"),
	KEY_BACKSLASH: load("res://assets/inputs/keyboard/back_slash.png"),
	KEY_BRACKETLEFT: load("res://assets/inputs/keyboard/bracket_left.png"),
	KEY_BRACKETRIGHT: load("res://assets/inputs/keyboard/bracket_right.png"),
	KEY_COMMA: load("res://assets/inputs/keyboard/comma.png"),
	KEY_DELETE: load("res://assets/inputs/keyboard/delete.png"),
	KEY_END: load("res://assets/inputs/keyboard/end.png"),
	KEY_ENTER: load("res://assets/inputs/keyboard/enter.png"),
	KEY_EQUAL: load("res://assets/inputs/keyboard/equal.png"),
	KEY_ESCAPE: load("res://assets/inputs/keyboard/escape.png"),
	KEY_HOME: load("res://assets/inputs/keyboard/home.png"),
	KEY_INSERT: load("res://assets/inputs/keyboard/insert.png"),
	KEY_MINUS: load("res://assets/inputs/keyboard/minus.png"),
	KEY_PAGEDOWN: load("res://assets/inputs/keyboard/page_down.png"),
	KEY_PAGEUP: load("res://assets/inputs/keyboard/page_up.png"),
	KEY_PAUSE: load("res://assets/inputs/keyboard/pause.png"),
	KEY_PERIOD: load("res://assets/inputs/keyboard/period.png"),
	KEY_PRINT: load("res://assets/inputs/keyboard/print.png"),
	KEY_QUESTION: load("res://assets/inputs/keyboard/question_mark.png"),
	KEY_SEMICOLON: load("res://assets/inputs/keyboard/semi_colon.png"),
	KEY_SLASH: load("res://assets/inputs/keyboard/slash.png"),
	KEY_SPACE: load("res://assets/inputs/keyboard/space.png"),
	KEY_TAB: load("res://assets/inputs/keyboard/tab.png"),
	KEY_ASCIITILDE: load("res://assets/inputs/keyboard/tilde.png"),
	
	KEY_CTRL: load("res://assets/inputs/keyboard/ctrl.png"),
	KEY_ALT: load("res://assets/inputs/keyboard/alt.png"),
	KEY_SHIFT: load("res://assets/inputs/keyboard/shift.png"),
}

var mouse_texture: Resource = load("res://assets/inputs/mouse.png")
var mouse_buttons: Dictionary = {
	MOUSE_BUTTON_LEFT: load("res://assets/inputs/mouse/left.png"),
	MOUSE_BUTTON_RIGHT: load("res://assets/inputs/mouse/right.png"),
	MOUSE_BUTTON_MIDDLE: load("res://assets/inputs/mouse/middle.png"),
	MOUSE_BUTTON_WHEEL_DOWN: load("res://assets/inputs/mouse/wheel_down.png"),
	MOUSE_BUTTON_WHEEL_UP: load("res://assets/inputs/mouse/wheel_up.png"),
}

var joypad_texture: Resource = load("res://assets/inputs/joypad.png")
var joypad_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad/a.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad/b.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad/x.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad/y.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad/view.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad/menu.png"),
	JOY_BUTTON_MISC1: load("res://assets/inputs/joypad/share.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad/r1.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad/l1.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad/r3.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad/l3.png"),
	JOY_BUTTON_PADDLE1: load("res://assets/inputs/joypad/l4.png"),
	JOY_BUTTON_PADDLE2: load("res://assets/inputs/joypad/r4.png"),
	JOY_BUTTON_PADDLE3: load("res://assets/inputs/joypad/l5.png"),
	JOY_BUTTON_PADDLE4: load("res://assets/inputs/joypad/r5.png"),
}
var joypad_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad/l_stick_left.png"),
		1: load("res://assets/inputs/joypad/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad/l_stick_up.png"),
		1: load("res://assets/inputs/joypad/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad/r_stick_left.png"),
		1: load("res://assets/inputs/joypad/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad/r_stick_up.png"),
		1: load("res://assets/inputs/joypad/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad/l2.png"),
		1: load("res://assets/inputs/joypad/l2.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad/r2.png"),
		1: load("res://assets/inputs/joypad/r2.png")
	}
}

var joypad_ps4_texture: Resource = load("res://assets/inputs/joypad_ps4.png")
var joypad_ps4_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_ps4/cross.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_ps4/circle.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_ps4/square.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_ps4/triangle.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_ps4/share.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad_ps4/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_ps4/options.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_ps4/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_ps4/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_ps4/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_ps4/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_ps4/r1.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_ps4/l1.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_ps4/r3.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_ps4/l3.png"),
	JOY_BUTTON_TOUCHPAD: load("res://assets/inputs/joypad_ps4/trackpad.png"),
}
var joypad_ps4_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_ps4/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_ps4/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_ps4/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_ps4/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_ps4/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_ps4/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_ps4/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_ps4/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_ps4/l2.png"),
		1: load("res://assets/inputs/joypad_ps4/l2.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_ps4/r2.png"),
		1: load("res://assets/inputs/joypad_ps4/r2.png")
	}
}

var joypad_ps5_texture: Resource = load("res://assets/inputs/joypad_ps4.png")
var joypad_ps5_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_ps5/cross.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_ps5/circle.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_ps5/square.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_ps5/triangle.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_ps5/create.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad_ps5/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_ps5/options.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_ps5/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_ps5/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_ps5/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_ps5/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_ps5/r1.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_ps5/l1.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_ps5/r3.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_ps5/l3.png"),
	JOY_BUTTON_TOUCHPAD: load("res://assets/inputs/joypad_ps5/trackpad.png"),
}
var joypad_ps5_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_ps5/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_ps5/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_ps5/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_ps5/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_ps5/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_ps5/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_ps5/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_ps5/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_ps5/l2.png"),
		1: load("res://assets/inputs/joypad_ps5/l2.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_ps5/r2.png"),
		1: load("res://assets/inputs/joypad_ps5/r2.png")
	}
}

var joypad_nintendo_joycons_texture: Resource = load("res://assets/inputs/joypad_nintendo_joycons.png")
var joypad_nintendo_joycons_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_nintendo_joycons/b.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_nintendo_joycons/a.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_nintendo_joycons/y.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_nintendo_joycons/x.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_nintendo_joycons/minus.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad_nintendo_joycons/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_nintendo_joycons/plus.png"),
	JOY_BUTTON_MISC1: load("res://assets/inputs/joypad_nintendo_joycons/capture.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_nintendo_joycons/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_nintendo_joycons/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_nintendo_joycons/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_nintendo_joycons/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_nintendo_joycons/r.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_nintendo_joycons/l.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_nintendo_joycons/rs.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_nintendo_joycons/ls.png"),
}
var joypad_nintendo_joycons_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/zl.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/zl.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_nintendo_joycons/zr.png"),
		1: load("res://assets/inputs/joypad_nintendo_joycons/zr.png")
	}
}

var joypad_nintendo_pro_texture: Resource = load("res://assets/inputs/joypad_nintendo_pro.png")
var joypad_nintendo_pro_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_nintendo_pro/b.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_nintendo_pro/a.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_nintendo_pro/y.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_nintendo_pro/x.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_nintendo_pro/minus.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad_nintendo_pro/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_nintendo_pro/plus.png"),
	JOY_BUTTON_MISC1: load("res://assets/inputs/joypad_nintendo_pro/capture.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_nintendo_pro/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_nintendo_pro/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_nintendo_pro/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_nintendo_pro/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_nintendo_pro/r.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_nintendo_pro/l.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_nintendo_pro/rs.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_nintendo_pro/ls.png"),
}
var joypad_nintendo_pro_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/zl.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/zl.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_nintendo_pro/zr.png"),
		1: load("res://assets/inputs/joypad_nintendo_pro/zr.png")
	}
}

var joypad_steam_deck_texture: Resource = load("res://assets/inputs/joypad_steam_deck.png")
var joypad_steam_deck_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_steam_deck/a.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_steam_deck/b.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_steam_deck/x.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_steam_deck/y.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_steam_deck/view.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_steam_deck/menu.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_steam_deck/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_steam_deck/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_steam_deck/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_steam_deck/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_steam_deck/r1.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_steam_deck/l1.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_steam_deck/r3.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_steam_deck/l3.png"),
	JOY_BUTTON_PADDLE1: load("res://assets/inputs/joypad_steam_deck/l4.png"),
	JOY_BUTTON_PADDLE2: load("res://assets/inputs/joypad_steam_deck/r4.png"),
	JOY_BUTTON_PADDLE3: load("res://assets/inputs/joypad_steam_deck/l5.png"),
	JOY_BUTTON_PADDLE4: load("res://assets/inputs/joypad_steam_deck/r5.png"),
}
var joypad_steam_deck_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_steam_deck/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_steam_deck/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_steam_deck/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_steam_deck/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_steam_deck/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_steam_deck/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_steam_deck/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_steam_deck/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_steam_deck/l2.png"),
		1: load("res://assets/inputs/joypad_steam_deck/l2.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_steam_deck/r2.png"),
		1: load("res://assets/inputs/joypad_steam_deck/r2.png")
	}
}

var joypad_xbox_texture: Resource = load("res://assets/inputs/joypad_steam_deck.png")
var joypad_xbox_buttons: Dictionary = {
	JOY_BUTTON_A: load("res://assets/inputs/joypad_xbox/a.png"),
	JOY_BUTTON_B: load("res://assets/inputs/joypad_xbox/b.png"),
	JOY_BUTTON_X: load("res://assets/inputs/joypad_xbox/x.png"),
	JOY_BUTTON_Y: load("res://assets/inputs/joypad_xbox/y.png"),
	JOY_BUTTON_BACK: load("res://assets/inputs/joypad_xbox/view.png"),
	JOY_BUTTON_GUIDE: load("res://assets/inputs/joypad_xbox/home.png"),
	JOY_BUTTON_START: load("res://assets/inputs/joypad_xbox/menu.png"),
	JOY_BUTTON_MISC1: load("res://assets/inputs/joypad_xbox/share.png"),
	JOY_BUTTON_DPAD_UP: load("res://assets/inputs/joypad_xbox/d_pad_up.png"),
	JOY_BUTTON_DPAD_DOWN: load("res://assets/inputs/joypad_xbox/d_pad_up.png"),
	JOY_BUTTON_DPAD_RIGHT: load("res://assets/inputs/joypad_xbox/d_pad_right.png"),
	JOY_BUTTON_DPAD_LEFT: load("res://assets/inputs/joypad_xbox/d_pad_left.png"),
	JOY_BUTTON_RIGHT_SHOULDER: load("res://assets/inputs/joypad_xbox/rb.png"),
	JOY_BUTTON_LEFT_SHOULDER: load("res://assets/inputs/joypad_xbox/lb.png"),
	JOY_BUTTON_RIGHT_STICK: load("res://assets/inputs/joypad_xbox/rs.png"),
	JOY_BUTTON_LEFT_STICK: load("res://assets/inputs/joypad_xbox/ls.png"),
}
var joypad_xbox_motions: Dictionary = {
	JOY_AXIS_LEFT_X: {
		-1: load("res://assets/inputs/joypad_xbox/l_stick_left.png"),
		1: load("res://assets/inputs/joypad_xbox/l_stick_right.png")
	},
	JOY_AXIS_LEFT_Y: {
		-1: load("res://assets/inputs/joypad_xbox/l_stick_up.png"),
		1: load("res://assets/inputs/joypad_xbox/l_stick_down.png")
	},
	JOY_AXIS_RIGHT_X: {
		-1: load("res://assets/inputs/joypad_xbox/r_stick_left.png"),
		1: load("res://assets/inputs/joypad_xbox/r_stick_right.png")
	},
	JOY_AXIS_RIGHT_Y: {
		-1: load("res://assets/inputs/joypad_xbox/r_stick_up.png"),
		1: load("res://assets/inputs/joypad_xbox/r_stick_down.png")
	},
	JOY_AXIS_TRIGGER_LEFT: {
		-1: load("res://assets/inputs/joypad_xbox/lt.png"),
		1: load("res://assets/inputs/joypad_xbox/lt.png")
	},
	JOY_AXIS_TRIGGER_RIGHT: {
		-1: load("res://assets/inputs/joypad_xbox/rt.png"),
		1: load("res://assets/inputs/joypad_xbox/rt.png")
	}
}

func get_device_texture(input_device_: Core.InputDevice) -> Texture2D:
	match input_device_:
		Core.InputDevice.KEYBOARD:
			return keyboard_texture
		Core.InputDevice.MOUSE:
			return mouse_texture
		Core.InputDevice.JOYPAD:
			var joypad: Core.InputJoypad = Core.inputs.get_input_joypad(Core.last_joypad_device)
			
			match joypad:
				Core.InputJoypad.DEFAULT:
					return joypad_texture
				Core.InputJoypad.NINTENDO_JOYCON_R_1, \
				Core.InputJoypad.NINTENDO_JOYCON_L_1, \
				Core.InputJoypad.NINTENDO_JOYCON_R_2, \
				Core.InputJoypad.NINTENDO_JOYCON_L_2:
					return joypad_nintendo_joycons_texture
				Core.InputJoypad.NINTENDO_PRO:
					return joypad_nintendo_pro_texture
				Core.InputJoypad.PS4:
					return joypad_ps4_texture
				Core.InputJoypad.PS5:
					return joypad_ps5_texture
				Core.InputJoypad.STEAM_DECK:
					return joypad_steam_deck_texture
				Core.InputJoypad.XBOX:
					return joypad_xbox_texture
	
	return null

func get_device_texture_from_input_type(input_type_: Core.InputType) -> Texture2D:
	match input_type_:
		Core.InputType.KEY:
			return get_device_texture(Core.InputDevice.KEYBOARD)
		Core.InputType.MOUSE_BUTTON:
			return get_device_texture(Core.InputDevice.MOUSE)
		Core.InputType.JOYPAD_BUTTON:
			return get_device_texture(Core.InputDevice.JOYPAD)
		Core.InputType.JOYPAD_MOTION:
			return get_device_texture(Core.InputDevice.JOYPAD)
			
	return null
	
func get_input_texture(input_event_: InputEvent) -> Texture2D:
	if input_event_ is InputEventKey:
		return get_keyboard_key_texture(input_event_.physical_keycode)
	elif input_event_ is InputEventMouseButton:
		return get_mouse_button_texture(input_event_.button_index)
	elif input_event_ is InputEventJoypadButton:
		return get_joypad_button_texture(input_event_.button_index)
	elif input_event_ is InputEventJoypadMotion:
		return get_joypad_motion_texture(input_event_.axis, input_event_.axis_value)
		
	return null


func get_input_texture_animation(input_event_: InputEvent) -> TextureAnimation:
	if input_event_ is InputEventKey:
		return get_keyboard_key_texture_animation(input_event_.physical_keycode)
	elif input_event_ is InputEventMouseButton:
		return get_mouse_button_texture_animation(input_event_.button_index)
	elif input_event_ is InputEventJoypadButton:
		return get_joypad_button_texture_animation(input_event_.button_index)
	elif input_event_ is InputEventJoypadMotion:
		return get_joypad_motion_texture_animation(input_event_.axis, input_event_.axis_value)
		
	return null

func get_input_texture_from_input_events_data(input_event_data_: Dictionary) -> Texture2D:
	match input_event_data_.type:
		Core.InputType.KEY:
			return get_keyboard_key_texture(input_event_data_.physical_keycode)
		Core.InputType.MOUSE_BUTTON:
			return get_mouse_button_texture(input_event_data_.button_index)
		Core.InputType.JOYPAD_BUTTON:
			return get_joypad_button_texture(input_event_data_.button_index)
		Core.InputType.JOYPAD_MOTION:
			return get_joypad_motion_texture(input_event_data_.axis, input_event_data_.axis_value)
			
	return null

func get_input_texture_animation_from_input_events_data(input_event_data_: Dictionary) -> TextureAnimation:
	match input_event_data_.type:
		Core.InputType.KEY:
			return get_keyboard_key_texture_animation(input_event_data_.physical_keycode)
		Core.InputType.MOUSE_BUTTON:
			return get_mouse_button_texture_animation(input_event_data_.button_index)
		Core.InputType.JOYPAD_BUTTON:
			return get_joypad_button_texture_animation(input_event_data_.button_index)
		Core.InputType.JOYPAD_MOTION:
			return get_joypad_motion_texture_animation(input_event_data_.axis, input_event_data_.axis_value)
			
	return null
	
func get_keyboard_key_texture(keycode_: int) -> Texture2D:
	return keyboard_keys.get(keycode_, null)

func get_keyboard_key_texture_animation(keycode_: int) -> TextureAnimation:
	var texture_: Texture2D = get_keyboard_key_texture(keycode_)
	
	if texture_ == null:
		return null
	
	var animation_: Dictionary = _data.default
	
	for animation_data_: Dictionary in _data.animations:
		for input_: Dictionary in animation_data_.inputs:
			if input_.type == Core.InputType.KEY and input_.physical_keycode == keycode_:
				animation_ = animation_data_
				break
	
	return TextureAnimation.new(
		texture_,
		animation_.frame_count,
		animation_.frame_orientation,
		animation_.frame_set,
		true,
		true
	)

func get_mouse_button_texture(button_index_: int) -> Texture2D:
	return mouse_buttons.get(button_index_, null)

func get_mouse_button_texture_animation(button_index_: int) -> TextureAnimation:
	var texture_: Texture2D = get_mouse_button_texture(button_index_)
	
	if texture_ == null:
		return null
	
	var animation_: Dictionary = _data.default
	
	for animation_data_: Dictionary in _data.animations:
		for input_: Dictionary in animation_data_.inputs:
			if input_.type == Core.InputType.MOUSE_BUTTON and input_.button_index == button_index_:
				animation_ = animation_data_
				break
	
	return TextureAnimation.new(
		texture_,
		animation_.frame_count,
		animation_.frame_orientation,
		animation_.frame_set,
		true,
		true
	)

func get_joypad_button_texture(button_index_: int) -> Texture2D:
	var joypad: Core.InputJoypad = Core.inputs.get_input_joypad(Core.last_joypad_device)
			
	match joypad:
		Core.InputJoypad.DEFAULT:
			if joypad_buttons.has(button_index_):
				return joypad_buttons.get(button_index_)
		Core.InputJoypad.NINTENDO_JOYCON_R_1, \
		Core.InputJoypad.NINTENDO_JOYCON_L_1, \
		Core.InputJoypad.NINTENDO_JOYCON_R_2, \
		Core.InputJoypad.NINTENDO_JOYCON_L_2:
			if joypad_nintendo_joycons_buttons.has(button_index_):
				return joypad_nintendo_joycons_buttons.get(button_index_)
		Core.InputJoypad.NINTENDO_PRO:
			if joypad_nintendo_pro_buttons.has(button_index_):
				return joypad_nintendo_pro_buttons.get(button_index_)
		Core.InputJoypad.PS4:
			if joypad_ps4_buttons.has(button_index_):
				return joypad_ps4_buttons.get(button_index_)
		Core.InputJoypad.PS5:
			if joypad_ps5_buttons.has(button_index_):
				return joypad_ps5_buttons.get(button_index_)
		Core.InputJoypad.STEAM_DECK:
			if joypad_steam_deck_buttons.has(button_index_):
				return joypad_steam_deck_buttons.get(button_index_)
		Core.InputJoypad.XBOX:
			if joypad_xbox_buttons.has(button_index_):
				return joypad_xbox_buttons.get(button_index_)
		
	return null
	
func get_joypad_button_texture_animation(button_index_: int) -> TextureAnimation:
	var texture_: Texture2D = get_joypad_button_texture(button_index_)
	
	if texture_ == null:
		return null
	
	var animation_: Dictionary = _data.default
	
	for animation_data_: Dictionary in _data.animations:
		for input_: Dictionary in animation_data_.inputs:
			if input_.type == Core.InputType.JOYPAD_BUTTON and input_.button_index == button_index_:
				animation_ = animation_data_
				break
	
	return TextureAnimation.new(
		texture_,
		animation_.frame_count,
		animation_.frame_orientation,
		animation_.frame_set,
		true,
		true
	)
	
func get_joypad_motion_texture(axis_: int, axis_value_: float) -> Texture2D:
	var joypad: Core.InputJoypad = Core.inputs.get_input_joypad(Core.last_joypad_device)
			
	match joypad:
		Core.InputJoypad.DEFAULT:
			if joypad_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_motions.get(axis_).get(1)
				else:
					return joypad_motions.get(axis_).get(-1)
		Core.InputJoypad.NINTENDO_JOYCON_R_1, \
		Core.InputJoypad.NINTENDO_JOYCON_L_1, \
		Core.InputJoypad.NINTENDO_JOYCON_R_2, \
		Core.InputJoypad.NINTENDO_JOYCON_L_2:
			if joypad_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_nintendo_joycons_motions.get(axis_).get(1)
				else:
					return joypad_nintendo_joycons_motions.get(axis_).get(-1)
		Core.InputJoypad.NINTENDO_PRO:
			if joypad_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_nintendo_pro_motions.get(axis_).get(1)
				else:
					return joypad_nintendo_pro_motions.get(axis_).get(-1)
		Core.InputJoypad.PS4:
			if joypad_ps4_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_ps4_motions.get(axis_).get(1)
				else:
					return joypad_ps4_motions.get(axis_).get(-1)
		Core.InputJoypad.PS5:
			if joypad_ps5_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_ps5_motions.get(axis_).get(1)
				else:
					return joypad_ps5_motions.get(axis_).get(-1)
		Core.InputJoypad.STEAM_DECK:
			if joypad_steam_deck_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_steam_deck_motions.get(axis_).get(1)
				else:
					return joypad_steam_deck_motions.get(axis_).get(-1)
		Core.InputJoypad.XBOX:
			if joypad_xbox_motions.has(axis_):
				if axis_value_ > 0:
					return joypad_xbox_motions.get(axis_).get(1)
				else:
					return joypad_xbox_motions.get(axis_).get(-1)
			
	return null

func get_joypad_motion_texture_animation(axis_: int, axis_value_: float) -> TextureAnimation:
	var texture_: Texture2D = get_joypad_motion_texture(axis_, axis_value_)
	
	if texture_ == null:
		return null
	
	var animation_: Dictionary = _data.default
	
	for animation_data_: Dictionary in _data.animations:
		for input_: Dictionary in animation_data_.inputs:
			if (input_.type == Core.InputType.JOYPAD_MOTION and 
				input_.axis == axis_ and
				input_.axis_value == axis_value_
			):
				animation_ = animation_data_
				break
	
	return TextureAnimation.new(
		texture_,
		animation_.frame_count,
		animation_.frame_orientation,
		animation_.frame_set,
		true,
		true
	)
