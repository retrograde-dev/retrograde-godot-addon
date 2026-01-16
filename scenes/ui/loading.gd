extends BaseUI

#@onready var sprite_loader: AnimatedSprite2D = $AnimatedSprite2DLoader

func _init() -> void:
	super._init(&"loading")	
	
func _ready() -> void:
	_update_loader_position()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_loader_position()
		
func _update_loader_position() -> void:
	pass
	# Subtract margin of 48 plus half of image size (48x12)
	#if sprite_loader:
		#var sprite_position = Vector2(get_viewport().size) - Vector2(48, 48) - (Vector2(28, 12) * sprite_loader.scale)
		#sprite_loader.position = sprite_position
