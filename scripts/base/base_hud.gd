extends BaseNode2D
class_name BaseHUD

@export_category("Position")
@export var hud_alignment: Core.Alignment = Core.Alignment.TOP_CENTER
@export var hud_offset: Vector2 = Vector2.ZERO

var alias: StringName

signal rect_changed(hud_: BaseHUD)

func _init(alias_: StringName) -> void:
	alias = alias_
