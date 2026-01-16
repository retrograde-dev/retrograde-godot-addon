extends Node2D
class_name PlayerGrid

@export var texture: Texture2D

func _ready() -> void:
	%Sprite2DGrid.texture = texture

func _process(delta_: float) -> void:
	update_grid_position(delta_)

func update_grid_position(_delta: float) -> void:
	if not Core.game.is_enabled:
		return

	if Core.player == null or %Sprite2DGrid.texture == null:
		return
		
	var size_: Vector2 = texture.get_size()

	var player_position_: Vector2 = Core.player.position + Core.player.items.drop_offset
	var sprite_position_: Vector2 = ((player_position_) / Core.TILE_SIZE).floor() * Core.TILE_SIZE + Vector2(Core.TILE_SIZE / 2, Core.TILE_SIZE / 2)
	var shader_position_: Vector2 = (player_position_ - sprite_position_ + (size_ / 2)) / size_

	var material_: ShaderMaterial = %Sprite2DGrid.material

	material_.set_shader_parameter("position_x", shader_position_.x)
	material_.set_shader_parameter("position_y", shader_position_.y)

	position = sprite_position_
