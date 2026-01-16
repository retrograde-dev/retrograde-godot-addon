extends Node
class_name Retrograde

var game: BaseGame = null
var game_difficulty: Core.GameDifficulty = Core.GameDifficulty.NORMAL

var nodes: NodeHandler
var camera: Camera2D
var level: BaseLevel
var player: PlayerUnit
var inputs: InputHandler
var items: ItemHandler
var level_select: LevelSelectHandler
var cursor: BaseCursor
var hud: HUDController
var audio: AudioHandler
var help: HelpHandler
var speech: SpeechHandler
var states: Dictionary
var settings: SettingsFile
var save: SaveFile
var ui: UIController

var locale: String = "en"
var LOCALES: Array[String] = ["en", "jp"]

var slow_mouse_speed: float = 0.5
var normal_mouse_speed: float = 1.0
var fast_mouse_speed: float = 1.5

var slow_joypad_speed: float = 0.5
var normal_joypad_speed: float = 1.0
var fast_joypad_speed: float = 1.5
var joypad_vibrations: bool = false

var last_input_device: Core.InputDevice = Core.InputDevice.KEYBOARD
var last_joypad_device: int = 0

var MENU_LEVEL: StringName = &"menu"
var START_LEVEL: StringName = &"start"

var TILE_SIZE: int = 8
var PHYSICS_TILE_SIZE: int = 8
var FIELD_TILE_SIZE: int = 8

var DEAD_ZONE: Vector2 = Vector2(-2048.0, -2048.0)
var VECTOR_2_EMPTY: Vector2 = Vector2(-2048.0, -2048.0)
var VECTOR_2I_EMPTY: Vector2i = Vector2i(-2048, -2048)

var ENABLE_MOUSE_CAPTURE: bool = false
var MOUSE_CURSOR_SIZE: int = 8

var ENABLE_INPUT_RESOURCES: bool = false

var GLOBAL_MODES: Array[StringName] = []

var MENU_CAMERA_ZOOM: float = 1.0
var MENU_CAMERA_TARGET_OFFSET: Vector2 = Vector2.ZERO

var LEVEL_CAMERA_ZOOM: float = 1.0
var LEVEL_CAMERA_TARGET_OFFSET: Vector2 = Vector2.ZERO

var MIN_AUDIO_PITCH: float = 0.9
var MAX_AUDIO_PITCH: float = 1.11

var ENABLE_PLAY_TIME: bool = false
var ENABLE_GAME_DIFFICULTY: bool = false
var ENABLE_LEVEL_SELECT: bool = false
var ENABLE_LEVEL_SKIP: bool = false
var ENABLE_LEVEL_PREVIOUS: bool = false
var ENABLE_LEVEL_NEXT: bool = false
var ENABLE_PLAY_AGAIN: bool = false

# Minimum amount of time for killables to wait after death before being hidden and disabled
var MIN_COLLISION_WAIT_DELTA: float = 0.05

# Used to move unit a slight amount to change collision state
var MIN_COLLISION_OFFSET: float = 0.01

var ENEMY_GROUPS: Array[StringName] = [&"enemy", &"mutual_enemy"]
var FRIEND_GROUPS: Array[StringName] = [&"friend", &"mutual_friend"]
var MUTUAL_ENEMY_GROUPS: Array[StringName] = [&"mutual_enemy"]
var MUTUAL_FRIEND_GROUPS: Array[StringName] = [&"mutual_friend"]

var PHYSICS_SOLID_LAYER_NUMBER: int = 1
var PHYSICS_LIQUID_LAYER_NUMBER: int = 2
var PHYSICS_GAS_LAYER_NUMBER: int = 3
var PHYSICS_FLOOR_LAYER_NUMBER: int = 4
var PHYSICS_WALL_LAYER_NUMBER: int = 5
var PHYSICS_CEILING_LAYER_NUMBER: int = 6
var PHYSICS_ROAM_LAYER_NUMBER: int = 7
var PHYSICS_CLIMB_LAYER_NUMBER: int = 8
var PHYSICS_STAIRS_LAYER_NUMBER: int = 9
var PHYSICS_EDGE_LAYER_NUMBER: int = 10
var PHYSICS_ELEVATION_LAYER_NUMBER: int = 11
var PHYSICS_RISE_LAYER_NUMBER: int = 12
var PHYSICS_FALL_LAYER_NUMBER: int = 13
var PHYSICS_RAIL_LAYER_NUMBER: int = 14
var PHYSICS_WIN_LAYER_NUMBER: int = 15
var PHYSICS_LOSE_LAYER_NUMBER: int = 16
var PHYSICS_MODIFIER_LAYER_NUMBER: int = 17
var PHYSICS_STATUS_LAYER_NUMBER: int = 18
var PHYSICS_INTERACTION_LAYER_NUMBER: int = 19
var PHYSICS_FIELD_LAYER_NUMBER: int = 20

var PHYSICS_SOLID_LAYER_ID: int = 0
var PHYSICS_LIQUID_LAYER_ID: int = 1
var PHYSICS_GAS_LAYER_ID: int = 2
var PHYSICS_FLOOR_LAYER_ID: int = 3
var PHYSICS_WALL_LAYER_ID: int = 4
var PHYSICS_CEILING_LAYER_ID: int = 5
var PHYSICS_ROAM_LAYER_ID: int = 6
var PHYSICS_CLIMB_LAYER_ID: int = 7
var PHYSICS_STAIRS_LAYER_ID: int = 8
var PHYSICS_EDGE_LAYER_ID: int = 9
var PHYSICS_ELEVATION_LAYER_ID: int = 10
var PHYSICS_RISE_LAYER_ID: int = 11
var PHYSICS_FALL_LAYER_ID: int = 12
var PHYSICS_RAIL_LAYER_ID: int = 13
var PHYSICS_WIN_LAYER_ID: int = 0
var PHYSICS_LOSE_LAYER_ID: int = 0
var PHYSICS_MODIFIER_LAYER_ID: int = 0
var PHYSICS_STATUS_LAYER_ID: int = 0
var PHYSICS_INTERACTION_LAYER_ID: int = 0
var PHYSICS_FIELD_LAYER_ID: int = 0

var FIELD_BOUNDS_LAYER_NUMBER: int = 25
var FIELD_MOVE_LAYER_NUMBER: int = 26
var FIELD_SPEED_LAYER_NUMBER: int = 27

var FIELD_BOUNDS_LAYER_ID: int = 0
var FIELD_MOVE_LAYER_ID: int = 1
var FIELD_SPEED_LAYER_ID: int = 2

var EXIT_DELAY: float = 0.4

enum Layer {
	NONE,
	SOLID,
	LIQUID,
	GAS,
	FLOOR,
	WALL,
	CEILING,
	ROAM,
	CLIMB,
	STAIRS,
	EDGE,
	ELEVATION,
	RISE,
	FALL,
	RAIL,
	WIN,
	LOSE,
	MODIFIER,
	STATUS,
	INTERACTION,
	FIELD,
}

func get_layer_number(layer_: Core.Layer) -> int:
	match layer_:
		Core.Layer.SOLID:
			return PHYSICS_SOLID_LAYER_NUMBER
		Core.Layer.LIQUID:
			return PHYSICS_LIQUID_LAYER_NUMBER
		Core.Layer.GAS:
			return PHYSICS_GAS_LAYER_NUMBER
		Core.Layer.FLOOR:
			return PHYSICS_FLOOR_LAYER_NUMBER
		Core.Layer.WALL:
			return PHYSICS_WALL_LAYER_NUMBER
		Core.Layer.CEILING:
			return PHYSICS_CEILING_LAYER_NUMBER
		Core.Layer.ROAM:
			return PHYSICS_ROAM_LAYER_NUMBER
		Core.Layer.CLIMB:
			return PHYSICS_CLIMB_LAYER_NUMBER
		Core.Layer.STAIRS:
			return PHYSICS_STAIRS_LAYER_NUMBER
		Core.Layer.EDGE:
			return PHYSICS_EDGE_LAYER_NUMBER
		Core.Layer.ELEVATION:
			return PHYSICS_ELEVATION_LAYER_NUMBER
		Core.Layer.RISE:
			return PHYSICS_RISE_LAYER_NUMBER
		Core.Layer.FALL:
			return PHYSICS_FALL_LAYER_NUMBER
		Core.Layer.RAIL:
			return PHYSICS_RAIL_LAYER_NUMBER
		Core.Layer.WIN:
			return PHYSICS_WIN_LAYER_NUMBER
		Core.Layer.LOSE:
			return PHYSICS_LOSE_LAYER_NUMBER
		Core.Layer.MODIFIER:
			return PHYSICS_MODIFIER_LAYER_NUMBER
		Core.Layer.STATUS:
			return PHYSICS_STATUS_LAYER_NUMBER
		Core.Layer.INTERACTION:
			return PHYSICS_INTERACTION_LAYER_NUMBER
		Core.Layer.FIELD:
			return PHYSICS_FIELD_LAYER_NUMBER

	return -1

func get_physics_layer_id(layer_: Core.Layer) -> int:
	match layer_:
		Core.Layer.SOLID:
			return PHYSICS_SOLID_LAYER_ID
		Core.Layer.LIQUID:
			return PHYSICS_LIQUID_LAYER_ID
		Core.Layer.GAS:
			return PHYSICS_GAS_LAYER_ID
		Core.Layer.FLOOR:
			return PHYSICS_FLOOR_LAYER_ID
		Core.Layer.WALL:
			return PHYSICS_WALL_LAYER_ID
		Core.Layer.CEILING:
			return PHYSICS_CEILING_LAYER_ID
		Core.Layer.ROAM:
			return PHYSICS_ROAM_LAYER_ID
		Core.Layer.CLIMB:
			return PHYSICS_CLIMB_LAYER_ID
		Core.Layer.STAIRS:
			return PHYSICS_STAIRS_LAYER_ID
		Core.Layer.EDGE:
			return PHYSICS_EDGE_LAYER_ID
		Core.Layer.ELEVATION:
			return PHYSICS_ELEVATION_LAYER_ID
		Core.Layer.RISE:
			return PHYSICS_RISE_LAYER_ID
		Core.Layer.FALL:
			return PHYSICS_FALL_LAYER_ID
		Core.Layer.RAIL:
			return PHYSICS_RAIL_LAYER_ID
		Core.Layer.WIN:
			return PHYSICS_WIN_LAYER_ID
		Core.Layer.LOSE:
			return PHYSICS_LOSE_LAYER_ID
		Core.Layer.MODIFIER:
			return PHYSICS_MODIFIER_LAYER_ID
		Core.Layer.STATUS:
			return PHYSICS_STATUS_LAYER_ID
		Core.Layer.INTERACTION:
			return PHYSICS_INTERACTION_LAYER_ID
		Core.Layer.FIELD:
			return PHYSICS_FIELD_LAYER_ID

	return -1

func get_field_layer_id(layer_: Core.Layer) -> int:
	#match layer_:
		#Core.Layer.FIELD_BOUNDS:
			#return FIELD_BOUNDS_LAYER_ID
		#Core.Layer.FIELD_MOVE:
			#return FIELD_MOVE_LAYER_ID
		#Core.Layer.FIELD_SPEED:
			#return FIELD_SPEED_LAYER_ID

	return -1
	
func get_field_layer(field_type_: Core.FieldType) -> Core.Layer:
	#match field_type_:
		#Core.FieldType.BOUNDS:
			#return Core.Layer.FIELD_BOUNDS
		#Core.FieldType.MOVE:
			#return Core.Layer.FIELD_MOVE
		#Core.FieldType.SPEED:
			#return Core.Layer.FIELD_SPEED

	return Core.Layer.NONE

enum DoorType {
	AREA,
	ROOM,
}

enum InputDevice {
	NONE,
	KEYBOARD,
	MOUSE,
	JOYPAD,
}

enum InputType {
	NONE,
	KEY,
	MOUSE_BUTTON,
	JOYPAD_BUTTON,
	JOYPAD_MOTION,
}

enum InputJoypad {
	DEFAULT,
	PS4,
	PS5,
	XBOX,
	STEAM_DECK,
	NINTENDO_JOYCON_R_1,
	NINTENDO_JOYCON_L_1,
	NINTENDO_JOYCON_R_2,
	NINTENDO_JOYCON_L_2,
	NINTENDO_PRO,
}

enum ResetType {
	START,
	RESTART,
	REFRESH,
	STOP,
}

enum LevelMode {
	GAME,
	MENU
}

enum LevelType {
	PLATFORMER,
}

enum UIType {
	GAME,
	LOADER,
	MENU,
}

enum GameDifficulty {
	EASY,
	NORMAL,
	HARD,
}

enum AudioType {
	MASTER,
	MUSIC,
	SFX,
	AMBIANCE,
}

enum DataType {
	AREA,
	OBJECT,
	ITEM,
	LEVEL,
}

enum LockType {
	NONE,
	KEY,
	PASSCODE,
	TERMINAL,
	OBSTRUCTION,
}

enum LockMode {
	LOCK_ONLY,
	UNLOCK_ONLY,
	MANUAL,
	AUTO,
}

enum LockState {
	NONE,
	LOCKED,
	UNLOCKED,
	BYPASSED,
}

enum UnitType {
	ENEMY,
	FRIEND,
	ITEM,
	NEUTRAL,
	OBJECT,
	PLAYER,
	PROJECTILE,
	VEHICLE,
	WEAPON,
}

enum ItemType {
	NONE,
	ACCESSORY,
	ARMOR,
	ARMOR_HEALTH,
	COMPONENT,
	FOOD,
	HEALTH,
	HEALTH_FOOD,
	KEY,
	KNIFE,
	LOCK_PICK,
	REPAIR,
	SHIELD,
	TOOL,
}

enum ItemCollisionMode {
	PLAYER,
	TILE,
}

enum ItemMode {
	MULTIPLE, # Multiple items in area
	SINGLE, # Single item in area
}

enum ComponentType {
	MIXED,
	INPUT,
	OUTPUT,
}

enum Validation {
	NONE,
	IGNORE,
	ERROR,
	SUCCESS,
	WARNING,
}

# Lock the unit in a specific state
enum UnitMode {
	NONE,
	NORMAL,
	CLIMBING,
}

enum UnitMovement {
	IDLE,
	MOVING,
	CLIMBING,
	JUMPING,
	FALLING,
}

enum UnitPhysics {
	PLATFORM,
	PLANE,
}

enum UnitSpeed {
	NORMAL,
	SLOW,
	FAST,
}

enum UnitStance {
	NORMAL,
	CROUCH,
	PRONE,
}

enum UnitDirection {
	NONE,
	LEFT,
	LEFT_UP,
	LEFT_DOWN,
	RIGHT,
	RIGHT_UP,
	RIGHT_DOWN,
	UP,
	UP_LEFT,
	UP_RIGHT,
	DOWN,
	DOWN_LEFT,
	DOWN_RIGHT,
}

const PLAY_DIRECTIONS: Dictionary = {
	UnitDirection.NONE: [&"idle"],
	UnitDirection.LEFT: [&"left", &"x", &"xy"],
	UnitDirection.RIGHT: [&"right", &"x", &"xy"],
	UnitDirection.UP: [&"up", &"y", &"xy"],
	UnitDirection.DOWN: [&"down", &"y", &"xy"],
	UnitDirection.UP_LEFT: [&"up_left", &"xy", &"up", &"y", &"left", &"x"],
	UnitDirection.UP_RIGHT: [&"up_right", &"xy", &"up", &"y", &"right", &"x"],
	UnitDirection.DOWN_LEFT: [&"down_left", &"xy", &"down", &"y", &"left", &"x"],
	UnitDirection.DOWN_RIGHT: [&"down_right", &"xy", &"down", &"y", &"right", &"x"],
	UnitDirection.LEFT_UP: [&"left_up", &"xy", &"left", &"x", &"up", &"y"],
	UnitDirection.LEFT_DOWN: [&"left_down", &"xy", &"left", &"x", &"down", &"y"],
	UnitDirection.RIGHT_UP: [&"right_up", &"xy", &"right", &"x", &"up", &"y"],
	UnitDirection.RIGHT_DOWN: [&"right_down", &"xy", &"right", &"x", &"down", &"y"],
}

enum PlatformerBehavior {
	NONE,
	CLIMB,
	CROUCH,
	FALL,
	JUMP,
	MOVE,
}

enum WeaponType {
	NONE,
	MELEE,
	LASER,
	PROJECTILE,
}

enum ProjectileType {
	NONE,
	BULLET,
	EXPLOSION,
	ROCKET,
}

enum Edge {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
}

enum ActorState {
	NONE,
	IDLE,
	START,
	STOP,
	UPDATE,
}

enum Error {
	ACTOR_RESTRICTION,
	GAME_RESTRICTION,
	UNHANDLED,
	UNIT_RESTRICTION,
	CANCELED,
}

enum SpeechStyle {
	TALK,
	THINK,
}

enum SpeechSize {
	SMALL,
	MEDIUM,
	LARGE
}

enum Alignment {
	TOP_LEFT,
	TOP_RIGHT,
	TOP_CENTER,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	BOTTOM_CENTER,
	CENTER_LEFT,
	CENTER_RIGHT,
	CENTER_CENTER,
}

enum Orientation {
	HORIZONTAL,
	VERTICAL,
	#DIAGONAL
}

enum CollisionMode {
	NONE,
	DAMAGE,
	KILL,
}

enum FieldType {
	NONE,
	BOUNDS,
	MOVE,
	SPEED,
}

enum DamageType {
	NONE,
}

enum AttackType {
	NONE,
	WEAPON,
}

func apply_difficulty_modifier(value: int, inverse: bool = false, safe: int = 0) -> int:
	if inverse:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value *= 2
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value /= 2
	else:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value /= 2
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value *= 2

	if value == 0:
		value = 1

	if safe > 0 and value >= safe:
		value = safe - 1

	return value

func apply_difficulty_modifier_float(value: float, inverse: bool = false, safe: float = 0.0) -> float:
	if inverse:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value *= 2.0
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value /= 2.0
	else:
		if Core.game_difficulty == Core.GameDifficulty.EASY:
			value /= 2.0
		elif Core.game_difficulty == Core.GameDifficulty.HARD:
			value *= 2.0

	if value == 0:
		value = 1.0

	if safe > 0.0 and value >= safe:
		value = safe - 1.0

	return value

func is_friends(node1: Node2D, node2: Node2D) -> bool:
	return !is_enemies(node1, node2)

func is_enemies(node1: Node2D, node2: Node2D) -> bool:
	if node1 == node2:
		return false

	for group: StringName in Core.MUTUAL_ENEMY_GROUPS:
		if node1.is_in_group(group) and node2.is_in_group(group):
			return true

	for group: StringName in Core.MUTUAL_FRIEND_GROUPS:
		if node1.is_in_group(group) and node2.is_in_group(group):
			return false

	var node1_enemy: bool = false
	var node2_enemy: bool = false
	var node1_friend: bool = false
	var node2_friend: bool = false

	for group: StringName in Core.ENEMY_GROUPS:
		if node1.is_in_group(group):
			node1_enemy = true

		if node2.is_in_group(group):
			node2_enemy = true

	for group: StringName in Core.FRIEND_GROUPS:
		if node1.is_in_group(group):
			node1_friend = true

		if node2.is_in_group(group):
			node2_friend = true

	if node1_enemy and node2_friend:
		return true

	if node2_enemy and node1_friend:
		return true

	return false

func is_friend(node: Node2D) -> bool:
	for group: StringName in Core.FRIEND_GROUPS:
		if node.is_in_group(group):
			return true

	return false

func is_enemy(node: Node2D) -> bool:
	for group: StringName in Core.ENEMY_GROUPS:
		if node.is_in_group(group):
			return true

	return false

func clear_groups(node: Node2D) -> void:
	var groups: Array[StringName] = node.get_groups()

	for group: StringName in groups:
		node.remove_from_group(group)

func select_random(array: Array, count: int) -> Array:
	count = min(count, array.size())

	var shuffled: Array = array.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, count)

func array_equals_unordered(array_1: Array, array_2: Array) -> bool:
	if array_1.size() != array_2.size():
		return false

	for value: Variant in array_1:
		if not array_2.has(value):
			return false

	return true

func dictionary_contains(superset: Dictionary, subset: Dictionary) -> bool:
	for key: Variant in subset:
		if not superset.has(key):
			return false

		var value_subset: Variant = subset[key]
		var value_superset: Variant = superset[key]

		if value_subset is Dictionary and value_superset is Dictionary:
			if not dictionary_contains(value_subset, value_superset):
				return false
		elif value_subset != value_superset:
			return false

	return true

func get_closest_vector2(from: Vector2, to1: Vector2, to2: Vector2) -> Vector2:
	return to1 if to1.distance_squared_to(from) < to2.distance_squared_to(from) else to2

func format_time(time: int) -> String:
	var total_seconds: int = floori(time / 1000.0)
	var hours: int = floori(total_seconds / 3600.0)
	var minutes: int = floori((total_seconds % 3600) / 60.0)
	var seconds: int = total_seconds % 60
	return "%d:%02d:%02d" % [hours, minutes, seconds]

func get_align_offset(rect_: Rect2, alignment_: Core.Alignment) -> Vector2:
	match alignment_:
		Core.Alignment.TOP_LEFT:
			return -rect_.position

		Core.Alignment.TOP_RIGHT:
			return -rect_.position - Vector2(rect_.size.x, 0)

		Core.Alignment.TOP_CENTER:
			return -rect_.position - Vector2(rect_.size.x / 2, 0)

		Core.Alignment.BOTTOM_LEFT:
			return -rect_.position - Vector2(0, rect_.size.y)

		Core.Alignment.BOTTOM_RIGHT:
			return -rect_.position - rect_.size

		Core.Alignment.BOTTOM_CENTER:
			return -rect_.position - Vector2(rect_.size.x / 2, rect_.size.y)

		Core.Alignment.CENTER_LEFT:
			return -rect_.position - Vector2(0, rect_.size.y / 2)

		Core.Alignment.CENTER_RIGHT:
			return -rect_.position - Vector2(rect_.size.x, rect_.size.y / 2)

		Core.Alignment.CENTER_CENTER:
			return -rect_.position - (rect_.size / 2)

	return Vector2.ZERO

func get_collision_rect(collision_object_: CollisionObject2D) -> Rect2:
	var total_rect_: Rect2 = Rect2()

	for owner_id_: int in collision_object_.get_shape_owners():
		var shape_count_: int = collision_object_.shape_owner_get_shape_count(owner_id_)

		for i: int in shape_count_:
			var shape_: Shape2D = collision_object_.shape_owner_get_shape(owner_id_, i)
			var transform_: Transform2D = collision_object_.shape_owner_get_transform(owner_id_)
			var shape_rect_: Rect2 = Core._get_shape_bounding_rect(shape_, transform_)

			if total_rect_.has_area():
				total_rect_ = total_rect_.expand(shape_rect_.position)
				total_rect_ = total_rect_.expand(shape_rect_.end)
			else:
				total_rect_.position = shape_rect_.position
				total_rect_.size = shape_rect_.size

	return total_rect_

func get_global_collision_rect(collision_object_: CollisionObject2D) -> Rect2:
	var total_rect_: Rect2 = Rect2()

	for owner_id_: int in collision_object_.get_shape_owners():
		var shape_count_: int = collision_object_.shape_owner_get_shape_count(owner_id_)

		for i: int in shape_count_:
			var shape_: Shape2D = collision_object_.shape_owner_get_shape(owner_id_, i)
			var local_transform_: Transform2D = collision_object_.shape_owner_get_transform(owner_id_)
			var global_transform_: Transform2D = collision_object_.global_transform * local_transform_
			var shape_rect_: Rect2 = Core._get_shape_bounding_rect(shape_, global_transform_)

			if total_rect_.has_area():
				total_rect_ = total_rect_.expand(shape_rect_.position)
				total_rect_ = total_rect_.expand(shape_rect_.end)
			else:
				total_rect_.position = shape_rect_.position
				total_rect_.size = shape_rect_.size

	return total_rect_

func _get_shape_bounding_rect(shape_: Shape2D, transform_: Transform2D) -> Rect2:
	var points_: PackedVector2Array = []
	
	if shape_ is RectangleShape2D:
		var half_: Vector2 = shape_.size * 0.5
		
		points_ = PackedVector2Array([
			Vector2(-half_.x, -half_.y),
			Vector2(half_.x, -half_.y),
			Vector2(half_.x, half_.y),
			Vector2(-half_.x, half_.y)
		])
	elif shape_ is CircleShape2D:
		var radius_: float = shape_.radius
		
		points_ = PackedVector2Array([
			Vector2(-radius_, -radius_),
			Vector2(radius_, -radius_),
			Vector2(radius_, radius_),
			Vector2(-radius_, radius_)
		])
	elif shape_ is CapsuleShape2D:
		var radius_: float = shape_.radius
		var half_h_: float = shape_.height * 0.5

		points_ = PackedVector2Array([
			Vector2(-radius_, -half_h_ - radius_),
			Vector2(radius_, -half_h_ - radius_),
			Vector2(radius_, half_h_ + radius_),
			Vector2(-radius_, half_h_ + radius_)
		])
	else:
		push_error("Shape2D type not supported.")
		return Rect2()
	
	# Transform points to global space and find min/max
	var min_pos_: Vector2 = Vector2(INF, INF)
	var max_pos_: Vector2 = Vector2(-INF, -INF)
	
	for point_: Vector2 in points_:
		var global_point_: Vector2 = transform_ * point_
		min_pos_.x = min(min_pos_.x, global_point_.x)
		min_pos_.y = min(min_pos_.y, global_point_.y)
		max_pos_.x = max(max_pos_.x, global_point_.x)
		max_pos_.y = max(max_pos_.y, global_point_.y)
	
	return Rect2(min_pos_, max_pos_ - min_pos_)

func is_adjacent_rect(from_rect_: Rect2, to_rect_: Rect2, edge_: Core.Edge) -> bool:
	if from_rect_.size == Vector2.ZERO or to_rect_.size == Vector2.ZERO:
		return false

	#if edge_ == Core.Edge.NONE:
		#if from_rect_.intersects(to_rect_):
			#return true

	var from_rect_up: float = from_rect_.position.y
	var from_rect_down: float = from_rect_.position.y + from_rect_.size.y
	var from_rect_left: float = from_rect_.position.x
	var from_rect_right: float = from_rect_.position.x + from_rect_.size.x

	var to_rect_up: float = to_rect_.position.y
	var to_rect_down: float = to_rect_.position.y + to_rect_.size.y
	var to_rect_left: float = to_rect_.position.x
	var to_rect_right: float = to_rect_.position.x + to_rect_.size.x

	if edge_ == Core.Edge.NONE:
		if is_equal_approx(from_rect_up, to_rect_down):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.UP)

		if is_equal_approx(from_rect_down, to_rect_up):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.DOWN)

		if is_equal_approx(from_rect_left, to_rect_right):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.LEFT)

		if is_equal_approx(from_rect_right, to_rect_left):
			return is_adjacent_rect(from_rect_, to_rect_, Core.Edge.RIGHT)

		return false

	if edge_ == Core.Edge.UP or edge_ == Core.Edge.DOWN:
		if edge_ == Core.Edge.UP and not is_equal_approx(from_rect_up, to_rect_down):
			return false

		if edge_ == Core.Edge.DOWN and not is_equal_approx(from_rect_down, to_rect_up):
			return false

		if is_equal_approx(from_rect_left, to_rect_left):
			return true

		if is_equal_approx(from_rect_right, to_rect_right):
			return true

		if from_rect_left < to_rect_left and from_rect_right > to_rect_right:
			return true

		if from_rect_left > to_rect_left and from_rect_right < to_rect_right:
			return true

		return false

	if edge_ == Core.Edge.LEFT or edge_ == Core.Edge.RIGHT:
		if edge_ == Core.Edge.LEFT and not is_equal_approx(from_rect_left, to_rect_right):
			return false

		if edge_ == Core.Edge.RIGHT and not is_equal_approx(from_rect_right, to_rect_left):
			return false

		if is_equal_approx(from_rect_up, to_rect_up):
			return true

		if is_equal_approx(from_rect_down, to_rect_down):
			return true

		if from_rect_up < to_rect_up and from_rect_down > to_rect_down:
			return true

		if from_rect_up > to_rect_up and from_rect_down < to_rect_down:
			return true

	return false

func get_opposing_edge(edge_: Core.Edge) -> Core.Edge:
	if edge_ == Core.Edge.UP:
		return Core.Edge.DOWN

	if edge_ == Core.Edge.DOWN:
		return Core.Edge.UP

	if edge_ == Core.Edge.LEFT:
		return Core.Edge.RIGHT

	if edge_ == Core.Edge.RIGHT:
		return Core.Edge.LEFT

	return Core.Edge.NONE

func get_edge_direction(edge_: Core.Edge) -> Vector2i:
	if edge_ == Core.Edge.UP:
		return Vector2i.UP

	if edge_ == Core.Edge.DOWN:
		return Vector2i.DOWN

	if edge_ == Core.Edge.LEFT:
		return Vector2i.LEFT

	if edge_ == Core.Edge.RIGHT:
		return Vector2i.RIGHT

	return Vector2i.ZERO

# Function to add a prefix to the texture path
func add_suffix_to_path(path_: StringName, suffix_: StringName) -> StringName:
	var file_name: String = path_.get_file()
	var extension: String = path_.get_extension()

	if extension == "":
		file_name = file_name + "_" + suffix_
	else:
		# - 1 for the period
		file_name = file_name.substr(0, file_name.length() - extension.length() - 1) + \
			"_" + suffix_ + \
			"." + extension

	return path_.get_base_dir() + "/" + file_name

func get_root_unit(node_: Node2D) -> BaseUnit:
	var parent: Node = node_.get_parent()

	if parent is BaseCharacterBody2D or parent is BaseNode2D:
		var root_parent: BaseUnit = get_root_unit(parent)

		if root_parent != null:
			return root_parent

		if parent is BaseUnit:
			return parent

	return null

func rotate_tile_0(alternate_id_: int) -> int:
	alternate_id_ &= ~(TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V)
	return alternate_id_

func rotate_tile_90(alternate_id_: int) -> int:
	alternate_id_ &= ~TileSetAtlasSource.TRANSFORM_FLIP_V
	alternate_id_ |= TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
	return alternate_id_

func rotate_tile_180(alternate_id_: int) -> int:
	alternate_id_ &= ~TileSetAtlasSource.TRANSFORM_TRANSPOSE
	alternate_id_ |= TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
	return alternate_id_

func rotate_tile_270(alternate_id_: int) -> int:
	alternate_id_ &= ~TileSetAtlasSource.TRANSFORM_FLIP_H
	alternate_id_ |= TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
	return alternate_id_
